import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:q_helper/app/providers.dart';
import 'package:q_helper/domain/models/workout_activity.dart';
import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/models/workout_segment.dart';
import 'package:q_helper/domain/services/name_suggestions.dart';
import 'package:q_helper/domain/services/plan_edits.dart' as edits;
import 'package:q_helper/domain/services/plan_text_export.dart';
import 'package:q_helper/domain/services/templates.dart';
import 'package:q_helper/features/builder/activity_form_sheet.dart';
import 'package:q_helper/features/builder/segment_dialog.dart';

const _quickMinutes = [30, 45, 60];

/// Build, edit, save, and share one workout.
///
/// With no [planId] it starts a new workout (blank, or from the structural
/// template of [templateMinutes]). Edits stay in memory until saved, and
/// leaving with unsaved edits asks first.
class BuilderScreen extends ConsumerStatefulWidget {
  const BuilderScreen({this.planId, this.templateMinutes, super.key});

  final String? planId;
  final int? templateMinutes;

  @override
  ConsumerState<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends ConsumerState<BuilderScreen> {
  WorkoutPlan? _plan;
  WorkoutPlan? _baseline;
  bool _notFound = false;
  bool _showErrors = false;
  bool _leaving = false;
  bool _customDuration = false;

  final _title = TextEditingController();
  final _description = TextEditingController();
  final _customMinutes = TextEditingController();

  bool get _dirty => _plan != _baseline;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _customMinutes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = widget.planId;
    WorkoutPlan? plan;
    if (id == null) {
      final newId = ref.read(idGeneratorProvider);
      final now = ref.read(nowProvider)();
      final minutes = widget.templateMinutes;
      plan = minutes != null && templateMinutes.contains(minutes)
          ? templatePlan(minutes, newId: newId, now: now)
          : blankPlan(newId: newId, now: now);
    } else {
      plan = await ref.read(planRepositoryProvider).get(id);
    }
    if (!mounted) return;
    if (plan == null) {
      setState(() => _notFound = true);
      return;
    }
    setState(() {
      _plan = plan;
      _baseline = plan;
      _title.text = plan!.title;
      _description.text = plan.description ?? '';
      _syncDurationControls(plan);
    });
  }

  void _syncDurationControls(WorkoutPlan plan) {
    final minutes = plan.targetDurationSeconds ~/ 60;
    final quick =
        plan.targetDurationSeconds % 60 == 0 && _quickMinutes.contains(minutes);
    _customDuration = !quick;
    _customMinutes.text = '$minutes';
  }

  void _update(WorkoutPlan plan) => setState(() => _plan = plan);

  // ---- duration ----------------------------------------------------------

  void _pickQuick(int minutes) {
    setState(() {
      _customDuration = false;
      _plan = _plan!.copyWith(targetDurationSeconds: minutes * 60);
    });
  }

  void _pickCustom() {
    setState(() {
      _customDuration = true;
      _customMinutes.text = '${_plan!.targetDurationSeconds ~/ 60}';
    });
  }

  void _customChanged(String text) {
    final minutes = int.tryParse(text.trim());
    _update(_plan!.copyWith(targetDurationSeconds: (minutes ?? 0) * 60));
  }

  // ---- segments ----------------------------------------------------------

  Future<void> _addSegment() async {
    final result = await showSegmentDialog(context);
    if (result == null) return;
    final plan = _plan!;
    _update(
      edits.addSegment(
        plan,
        WorkoutSegment(
          id: ref.read(idGeneratorProvider)(),
          planId: plan.id,
          title: result.title,
          sortOrder: plan.segments.length,
          estimatedDurationSeconds: result.minutes == null
              ? null
              : result.minutes! * 60,
          activities: const [],
        ),
      ),
    );
  }

  Future<void> _editSegment(WorkoutSegment segment) async {
    final result = await showSegmentDialog(context, segment: segment);
    if (result == null) return;
    final plan = _plan!;
    _update(
      plan.copyWith(
        segments: [
          for (final s in plan.segments)
            if (s.id == segment.id)
              WorkoutSegment(
                id: s.id,
                planId: s.planId,
                title: result.title,
                sortOrder: s.sortOrder,
                estimatedDurationSeconds: result.minutes == null
                    ? null
                    : result.minutes! * 60,
                activities: s.activities,
              )
            else
              s,
        ],
      ),
    );
  }

  Future<void> _removeSegment(WorkoutSegment segment) async {
    if (segment.activities.isNotEmpty) {
      final confirmed = await _confirm(
        title: 'Remove "${segment.title}"?',
        message:
            'This also removes its ${segment.activities.length} '
            '${segment.activities.length == 1 ? 'activity' : 'activities'}.',
        action: 'Remove',
      );
      if (!confirmed) return;
    }
    _update(edits.removeSegment(_plan!, segment.id));
  }

  // ---- activities --------------------------------------------------------

  List<String> _suggest(String text) {
    final saved = ref.read(planListProvider).value ?? const <WorkoutPlan>[];
    final draft = [for (final a in edits.flattenActivities(_plan!)) a.name];
    return suggestNames(saved, text, extra: draft);
  }

  Future<void> _editActivity(
    WorkoutSegment segment, {
    WorkoutActivity? existing,
  }) async {
    final result = await showModalBottomSheet<WorkoutActivity>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ActivityFormSheet(
        segmentId: segment.id,
        newId: ref.read(idGeneratorProvider),
        suggest: _suggest,
        initial: existing,
      ),
    );
    if (result == null) return;
    _update(
      existing == null
          ? edits.insertActivity(_plan!, segment.id, result)
          : edits.replaceActivity(_plan!, result),
    );
  }

  // ---- save, share, leave ------------------------------------------------

  Future<void> _save() async {
    final plan = _plan!;
    setState(() => _showErrors = true);
    if (plan.validate().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fix the highlighted problems first.')),
      );
      return;
    }
    final saved = await ref.read(planListProvider.notifier).save(plan);
    if (!mounted) return;
    setState(() {
      _plan = saved;
      _baseline = saved;
      _showErrors = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved')));
  }

  Future<void> _share() async {
    final plan = _plan!;
    final title = plan.title.trim();
    await ref
        .read(shareServiceProvider)
        .shareText(
          planToText(plan),
          subject: title.isEmpty ? 'Workout' : title,
        );
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
    String cancel = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _onPopBlocked() async {
    final discard = await _confirm(
      title: 'Discard changes?',
      message: 'Your edits to this workout have not been saved.',
      action: 'Discard',
      cancel: 'Keep editing',
    );
    if (!discard || !mounted) return;
    setState(() => _leaving = true);
    context.pop();
  }

  // ---- build -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_notFound) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: const Center(child: Text('This workout could not be found.')),
      );
    }
    final plan = _plan;
    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final segments = [...plan.segments]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final titleMissing = _showErrors && plan.title.trim().isEmpty;
    final customInvalid =
        _showErrors && _customDuration && plan.targetDurationSeconds <= 0;

    return PopScope(
      canPop: !_dirty || _leaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onPopBlocked();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.planId == null ? 'New workout' : 'Edit workout'),
          actions: [
            IconButton(
              tooltip: 'Share',
              icon: const Icon(Icons.ios_share),
              onPressed: _share,
            ),
            IconButton(
              tooltip: 'Save',
              icon: const Icon(Icons.check),
              onPressed: _save,
            ),
          ],
        ),
        // A Column in a scroll view (not a lazy list) keeps every field built,
        // which is fine for the small number of rows in one workout.
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('title-field'),
                controller: _title,
                textCapitalization: TextCapitalization.words,
                onChanged: (v) => _update(_plan!.copyWith(title: v)),
                decoration: InputDecoration(
                  labelText: 'Workout title',
                  errorText: titleMissing ? 'Enter a title' : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('description-field'),
                controller: _description,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (v) => _update(_plan!.copyWith(description: v)),
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text('Duration', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in _quickMinutes)
                    ChoiceChip(
                      label: Text('$m min'),
                      selected:
                          !_customDuration &&
                          plan.targetDurationSeconds == m * 60,
                      onSelected: (_) => _pickQuick(m),
                    ),
                  ChoiceChip(
                    label: const Text('Custom'),
                    selected: _customDuration,
                    onSelected: (_) => _pickCustom(),
                  ),
                ],
              ),
              if (_customDuration)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextField(
                    key: const Key('custom-minutes-field'),
                    controller: _customMinutes,
                    keyboardType: TextInputType.number,
                    onChanged: _customChanged,
                    decoration: InputDecoration(
                      labelText: 'Minutes',
                      errorText: customInvalid
                          ? 'Enter minutes greater than zero'
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Text('Segments', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (var i = 0; i < segments.length; i++)
                _SegmentCard(
                  segment: segments[i],
                  index: i,
                  count: segments.length,
                  onEdit: () => _editSegment(segments[i]),
                  onRemove: () => _removeSegment(segments[i]),
                  onMove: (to) => _update(edits.moveSegment(_plan!, i, to)),
                  onAddActivity: () => _editActivity(segments[i]),
                  onEditActivity: (a) =>
                      _editActivity(segments[i], existing: a),
                  onRemoveActivity: (a) =>
                      _update(edits.removeActivity(_plan!, a.id)),
                  onMoveActivity: (from, to) => _update(
                    edits.moveActivity(_plan!, segments[i].id, from, to),
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _addSegment,
                icon: const Icon(Icons.add),
                label: const Text('Add segment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentCard extends StatelessWidget {
  const _SegmentCard({
    required this.segment,
    required this.index,
    required this.count,
    required this.onEdit,
    required this.onRemove,
    required this.onMove,
    required this.onAddActivity,
    required this.onEditActivity,
    required this.onRemoveActivity,
    required this.onMoveActivity,
  });

  final WorkoutSegment segment;
  final int index;
  final int count;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final void Function(int to) onMove;
  final VoidCallback onAddActivity;
  final void Function(WorkoutActivity) onEditActivity;
  final void Function(WorkoutActivity) onRemoveActivity;
  final void Function(int from, int to) onMoveActivity;

  @override
  Widget build(BuildContext context) {
    final estimate = segment.estimatedDurationSeconds;
    final activities = [...segment.activities]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    segment.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (estimate != null) Text(formatSeconds(estimate)),
                PopupMenuButton<String>(
                  tooltip: 'Actions for segment ${segment.title}',
                  onSelected: (action) => switch (action) {
                    'edit' => onEdit(),
                    'up' => onMove(index - 1),
                    'down' => onMove(index + 1),
                    _ => onRemove(),
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'up',
                      enabled: index > 0,
                      child: const Text('Move up'),
                    ),
                    PopupMenuItem(
                      value: 'down',
                      enabled: index < count - 1,
                      child: const Text('Move down'),
                    ),
                    const PopupMenuItem(value: 'remove', child: Text('Remove')),
                  ],
                ),
              ],
            ),
            for (var i = 0; i < activities.length; i++)
              _ActivityTile(
                activity: activities[i],
                index: i,
                count: activities.length,
                onEdit: () => onEditActivity(activities[i]),
                onRemove: () => onRemoveActivity(activities[i]),
                onMove: (to) => onMoveActivity(i, to),
              ),
            TextButton.icon(
              key: Key('add-activity-${segment.id}'),
              onPressed: onAddActivity,
              icon: const Icon(Icons.add),
              label: const Text('Add activity'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
    required this.index,
    required this.count,
    required this.onEdit,
    required this.onRemove,
    required this.onMove,
  });

  final WorkoutActivity activity;
  final int index;
  final int count;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final void Function(int to) onMove;

  @override
  Widget build(BuildContext context) {
    final notes = (activity.notes ?? '').trim();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(activity.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(describeActivityDetails(activity.details)),
          if (notes.isNotEmpty) Text('Notes: $notes'),
        ],
      ),
      onTap: onEdit,
      trailing: PopupMenuButton<String>(
        tooltip: 'Actions for ${activity.name}',
        onSelected: (action) => switch (action) {
          'up' => onMove(index - 1),
          'down' => onMove(index + 1),
          _ => onRemove(),
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'up',
            enabled: index > 0,
            child: const Text('Move up'),
          ),
          PopupMenuItem(
            value: 'down',
            enabled: index < count - 1,
            child: const Text('Move down'),
          ),
          const PopupMenuItem(value: 'remove', child: Text('Remove')),
        ],
      ),
    );
  }
}
