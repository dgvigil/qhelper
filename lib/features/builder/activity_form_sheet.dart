import 'package:flutter/material.dart';
import 'package:q_helper/domain/models/workout_activity.dart';

/// Bottom sheet for adding or editing one activity.
///
/// Returns the finished activity, or null if cancelled. [suggest] supplies
/// earlier exercise names for the name field.
class ActivityFormSheet extends StatefulWidget {
  const ActivityFormSheet({
    required this.segmentId,
    required this.newId,
    required this.suggest,
    this.initial,
    super.key,
  });

  final String segmentId;
  final String Function() newId;
  final List<String> Function(String text) suggest;
  final WorkoutActivity? initial;

  @override
  State<ActivityFormSheet> createState() => _ActivityFormSheetState();
}

class _ActivityFormSheetState extends State<ActivityFormSheet> {
  late ActivityKind _kind;
  TextEditingController? _name;
  late final TextEditingController _notes;
  late final TextEditingController _reps;
  late final TextEditingController _work;
  late final TextEditingController _rest;
  late final TextEditingController _rounds;
  late final TextEditingController _instructions;

  final Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    final d = a?.details;
    _kind = a?.kind ?? ActivityKind.reps;
    _notes = TextEditingController(text: a?.notes ?? '');
    _reps = TextEditingController(
      text: d is RepsDetails ? '${d.repetitions}' : '',
    );
    _work = TextEditingController(
      text: d is TimedDetails ? '${d.workSeconds}' : '',
    );
    _rest = TextEditingController(
      text: d is TimedDetails ? '${d.restSeconds}' : '',
    );
    _rounds = TextEditingController(
      text: d is TimedDetails ? '${d.rounds}' : '',
    );
    _instructions = TextEditingController(
      text: d is FreeFormDetails ? d.instructions : '',
    );
  }

  @override
  void dispose() {
    _notes.dispose();
    _reps.dispose();
    _work.dispose();
    _rest.dispose();
    _rounds.dispose();
    _instructions.dispose();
    super.dispose();
  }

  int? _positive(TextEditingController c) {
    final n = int.tryParse(c.text.trim());
    return n != null && n > 0 ? n : null;
  }

  void _save() {
    final errors = <String, String>{};
    final name = (_name?.text ?? '').trim();
    if (name.isEmpty) errors['name'] = 'Enter a name';

    ActivityDetails? details;
    switch (_kind) {
      case ActivityKind.reps:
        final reps = _positive(_reps);
        if (reps == null) {
          errors['reps'] = 'Enter a number greater than zero';
        } else {
          details = RepsDetails(repetitions: reps);
        }
      case ActivityKind.timed:
        final work = _positive(_work);
        final rounds = _positive(_rounds);
        final restText = _rest.text.trim();
        final rest = restText.isEmpty ? 0 : int.tryParse(restText);
        if (work == null) errors['work'] = 'Enter a number greater than zero';
        if (rest == null || rest < 0) {
          errors['rest'] = 'Enter a number, zero or more';
        }
        if (rounds == null) {
          errors['rounds'] = 'Enter a number greater than zero';
        }
        if (errors.isEmpty) {
          details = TimedDetails(
            workSeconds: work!,
            restSeconds: rest!,
            rounds: rounds!,
          );
        }
      case ActivityKind.freeForm:
        final text = _instructions.text.trim();
        if (text.isEmpty) {
          errors['instructions'] = 'Enter instructions';
        } else {
          details = FreeFormDetails(instructions: text);
        }
    }

    if (errors.isNotEmpty || details == null) {
      setState(() {
        _errors
          ..clear()
          ..addAll(errors);
      });
      return;
    }
    final notes = _notes.text.trim();
    final initial = widget.initial;
    Navigator.pop(
      context,
      WorkoutActivity(
        id: initial?.id ?? widget.newId(),
        segmentId: widget.segmentId,
        sortOrder: initial?.sortOrder ?? 0,
        name: name,
        notes: notes.isEmpty ? null : notes,
        details: details,
      ),
    );
  }

  Widget _number(
    String key,
    String label,
    TextEditingController controller, {
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextField(
        key: Key('$key-field'),
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: _errors[key],
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              editing ? 'Edit activity' : 'Add activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SegmentedButton<ActivityKind>(
              segments: const [
                ButtonSegment(value: ActivityKind.reps, label: Text('Reps')),
                ButtonSegment(value: ActivityKind.timed, label: Text('Timed')),
                ButtonSegment(
                  value: ActivityKind.freeForm,
                  label: Text('Free-form'),
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() {
                _kind = s.first;
                _errors.clear();
              }),
            ),
            const SizedBox(height: 12),
            Autocomplete<String>(
              initialValue: TextEditingValue(text: widget.initial?.name ?? ''),
              optionsBuilder: (value) => widget.suggest(value.text),
              fieldViewBuilder: (context, controller, focusNode, _) {
                _name = controller;
                return TextField(
                  key: const Key('activity-name'),
                  controller: controller,
                  focusNode: focusNode,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Exercise name',
                    errorText: _errors['name'],
                    border: const OutlineInputBorder(),
                  ),
                );
              },
            ),
            switch (_kind) {
              ActivityKind.reps => _number('reps', 'Repetitions', _reps),
              ActivityKind.timed => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _number('work', 'Work (seconds)', _work),
                  _number('rest', 'Rest (seconds)', _rest, hint: '0'),
                  _number('rounds', 'Rounds', _rounds),
                ],
              ),
              ActivityKind.freeForm => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextField(
                  key: const Key('instructions-field'),
                  controller: _instructions,
                  minLines: 2,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Instructions',
                    errorText: _errors['instructions'],
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            },
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                key: const Key('activity-notes'),
                controller: _notes,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Save activity'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
