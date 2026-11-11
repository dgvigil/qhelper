import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:q_helper/app/providers.dart';
import 'package:q_helper/core/platform/cue_service.dart';
import 'package:q_helper/core/platform/wakelock_service.dart';
import 'package:q_helper/core/timer/interval_timer.dart';
import 'package:q_helper/core/timer/master_timer.dart';
import 'package:q_helper/domain/models/workout_activity.dart';
import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/models/workout_session.dart';
import 'package:q_helper/domain/services/live_session.dart';
import 'package:q_helper/domain/services/name_suggestions.dart';
import 'package:q_helper/domain/services/plan_edits.dart' as edits;
import 'package:q_helper/domain/services/plan_text_export.dart';
import 'package:q_helper/features/builder/activity_form_sheet.dart';
import 'package:q_helper/features/live_session/clock_format.dart';
import 'package:q_helper/features/live_session/end_workout_dialog.dart';
import 'package:q_helper/features/live_session/interval_panel.dart';

/// Runs a workout: master countdown, current and next activity, Back / Next,
/// an interval panel for timed activities, session-only edits, and End.
///
/// With a [planId] it starts a new session; without one it resumes the
/// running session. Leaving the screen never ends the workout.
class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({this.planId, super.key});

  final String? planId;

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen>
    with WidgetsBindingObserver {
  static const _cueGrace = Duration(seconds: 2);

  late final WakelockService _wakelock = ref.read(wakelockServiceProvider);
  late final CueService _cues = ref.read(cueServiceProvider);

  LiveSession? _live;
  String? _message;
  bool _alreadyRunning = false;
  bool _wakelockOn = false;
  bool _endCued = false;
  StreamSubscription<void>? _ticks;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_open());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_ticks?.cancel());
    if (_wakelockOn) unawaited(_wakelock.disable());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tick();
  }

  Future<void> _open() async {
    final sessions = ref.read(sessionRepositoryProvider);
    final clock = ref.read(appClockProvider);
    final settings = await ref.read(settingsProvider.future);

    LiveSession? live;
    final planId = widget.planId;
    try {
      if (planId == null) {
        live = await LiveSession.recover(sessions: sessions, clock: clock);
        if (live == null) {
          _fail('No workout is in progress.');
          return;
        }
      } else {
        if (await sessions.findActive() != null) {
          if (mounted) setState(() => _alreadyRunning = true);
          return;
        }
        live = await LiveSession.start(
          planId: planId,
          sessions: sessions,
          clock: clock,
        );
        unawaited(
          ref
              .read(endNotificationCoordinatorProvider)
              .sessionStarted(live.session.deadlineAtWall),
        );
      }
    } on StateError {
      _fail('This workout could not be started.');
      return;
    }
    if (!mounted) return;

    _endCued = live.timers.master.read(clock).isExpired;
    if (settings.keepScreenAwake) {
      _wakelockOn = true;
      unawaited(_wakelock.enable());
    }
    _ticks = ref.read(tickStreamProvider).listen((_) => _tick());
    setState(() => _live = live);
    _tick();
  }

  void _fail(String message) {
    if (mounted) setState(() => _message = message);
  }

  /// Repaints from the clock and plays any cue seen on time. Missed cues are
  /// never replayed.
  void _tick() {
    final live = _live;
    if (!mounted || live == null) return;

    if (live.isRunning) {
      final interval = live.timers.interval;
      if (interval != null) {
        final cue = interval.observe().cue;
        if (cue != null) unawaited(_cues.play(_cueKind(cue)));
      }
      final master = live.timers.master.read(ref.read(appClockProvider));
      if (master.isExpired && !_endCued) {
        _endCued = true;
        if (master.overtime <= _cueGrace) {
          unawaited(_cues.play(CueKind.workoutEnd));
        }
      }
    }
    setState(() {});
  }

  CueKind _cueKind(IntervalCue cue) => switch (cue) {
    IntervalCue.workStart => CueKind.workStart,
    IntervalCue.restStart => CueKind.restStart,
    IntervalCue.finished => CueKind.intervalFinished,
  };

  Future<void> _act(Future<void> Function(LiveSession live) action) async {
    final live = _live;
    if (live == null) return;
    await action(live);
    _tick();
  }

  Future<void> _end() async {
    final live = _live;
    if (live == null) return;
    final status = await showEndWorkoutDialog(context);
    if (status == null) return;
    if (status == SessionStatus.completed) {
      await live.complete();
    } else {
      await live.endEarly();
    }
    await ref.read(endNotificationCoordinatorProvider).sessionEnded();
    ref.invalidate(activeSessionProvider);
    if (mounted) context.go('/');
  }

  // ---- audibles ----------------------------------------------------------

  List<String> _suggest(String text) {
    final saved = ref.read(planListProvider).value ?? const <WorkoutPlan>[];
    final draft = [
      for (final a in edits.flattenActivities(_live!.session.workingPlan))
        a.name,
    ];
    return suggestNames(saved, text, extra: draft);
  }

  Future<void> _editCurrent({required bool adding}) async {
    final live = _live!;
    final current = live.current;
    final segmentId =
        current?.segmentId ?? live.session.workingPlan.segments.firstOrNull?.id;
    if (segmentId == null || (!adding && current == null)) return;
    final result = await showModalBottomSheet<WorkoutActivity>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ActivityFormSheet(
        segmentId: segmentId,
        newId: ref.read(idGeneratorProvider),
        suggest: _suggest,
        initial: adding ? null : current,
      ),
    );
    if (result == null) return;
    await _act(
      (live) => adding
          ? live.addActivity(segmentId, result)
          : live.editActivity(result),
    );
  }

  Future<void> _removeCurrent() async {
    final current = _live!.current;
    if (current == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove "${current.name}" from this workout?'),
        content: const Text('Your saved workout is not changed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await _act((live) => live.removeActivity(current.id));
    }
  }

  // ---- build -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_alreadyRunning) return _alreadyRunningView(context);
    final message = _message;
    if (message != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: Center(child: Text(message)),
      );
    }
    final live = _live;
    if (live == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final clock = ref.read(appClockProvider);
    final master = live.timers.master.read(clock);
    final current = live.current;
    final upcoming = live.upcoming;
    final interval = live.timers.interval;

    return Scaffold(
      appBar: AppBar(
        title: Text(live.session.workingPlan.title),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Change this workout',
            onSelected: (v) => switch (v) {
              'edit' => unawaited(_editCurrent(adding: false)),
              'add' => unawaited(_editCurrent(adding: true)),
              _ => unawaited(_removeCurrent()),
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                enabled: current != null,
                child: const Text('Edit this activity'),
              ),
              PopupMenuItem(
                value: 'add',
                enabled: live.session.workingPlan.segments.isNotEmpty,
                child: const Text('Add activity'),
              ),
              PopupMenuItem(
                value: 'remove',
                enabled: current != null,
                child: const Text('Remove this activity'),
              ),
            ],
          ),
          IconButton(
            tooltip: 'End workout',
            icon: const Icon(Icons.stop_circle_outlined),
            onPressed: _end,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _MasterCountdown(master: master),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ActivityCard(activity: current, upcoming: upcoming),
                    if (interval != null) ...[
                      const SizedBox(height: 16),
                      IntervalPanel(
                        interval: interval,
                        onStart: () => _act((l) => l.startInterval()),
                        onPause: () => _act((l) => l.pauseInterval()),
                        onResume: () => _act((l) => l.resumeInterval()),
                        onSkip: () => _act((l) => l.skipPhase()),
                        onReset: () => _act((l) => l.resetInterval()),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _NavBar(
              hasBack: live.hasPrevious,
              hasNext: upcoming != null,
              onBack: () =>
                  _act((live) => live.back(fromActivityId: current?.id)),
              onNext: () =>
                  _act((live) => live.next(fromActivityId: current?.id)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _alreadyRunningView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A workout is already running',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Resume it or end it before starting another.'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.pushReplacement('/live/resume'),
                child: const Text('Resume'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasterCountdown extends StatelessWidget {
  const _MasterCountdown({required this.master});

  final MasterReading master;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overtime = master.isExpired;
    final color = overtime ? theme.colorScheme.error : null;
    final text = overtime
        ? formatOvertime(master.overtime)
        : formatCountdown(master.remaining);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Semantics(
        label: overtime
            ? 'Overtime'
            : 'Time remaining: ${spokenDuration(master.remaining)}',
        child: ExcludeSemantics(
          child: Column(
            children: [
              Text(
                overtime ? 'OVERTIME' : 'Time remaining',
                style: theme.textTheme.titleMedium?.copyWith(color: color),
              ),
              // Shrinks instead of wrapping, so 1:00:00 stays on one line even
              // at large text sizes.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  key: const Key('master-countdown'),
                  maxLines: 1,
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity, required this.upcoming});

  final WorkoutActivity? activity;
  final WorkoutActivity? upcoming;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = activity;
    if (a == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'This workout has no activities. Use the menu to add one.',
          ),
        ),
      );
    }
    final notes = (a.notes ?? '').trim();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              a.name,
              key: const Key('current-activity-name'),
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              describeActivityDetails(a.details),
              style: theme.textTheme.headlineSmall,
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: $notes', style: theme.textTheme.bodyLarge),
            ],
            const Divider(height: 32),
            Text(
              upcoming == null ? 'Last activity' : 'Next: ${upcoming!.name}',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.hasBack,
    required this.hasNext,
    required this.onBack,
    required this.onNext,
  });

  final bool hasBack;
  final bool hasNext;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    const size = Size.fromHeight(72);
    final textStyle = Theme.of(context).textTheme.titleLarge;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: size,
                textStyle: textStyle,
              ),
              onPressed: hasBack ? onBack : null,
              child: const Text('Back'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: size,
                textStyle: textStyle,
              ),
              onPressed: hasNext ? onNext : null,
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
