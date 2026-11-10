import 'package:flutter/material.dart';
import 'package:q_helper/domain/models/workout_segment.dart';

typedef SegmentEdit = ({String title, int? minutes});

/// Dialog for naming a segment and optionally giving it a time estimate.
Future<SegmentEdit?> showSegmentDialog(
  BuildContext context, {
  WorkoutSegment? segment,
}) {
  return showDialog<SegmentEdit>(
    context: context,
    builder: (_) => _SegmentDialog(segment: segment),
  );
}

class _SegmentDialog extends StatefulWidget {
  const _SegmentDialog({this.segment});

  final WorkoutSegment? segment;

  @override
  State<_SegmentDialog> createState() => _SegmentDialogState();
}

class _SegmentDialogState extends State<_SegmentDialog> {
  late final TextEditingController _title;
  late final TextEditingController _minutes;
  String? _titleError;
  String? _minutesError;

  @override
  void initState() {
    super.initState();
    final seconds = widget.segment?.estimatedDurationSeconds;
    _title = TextEditingController(text: widget.segment?.title ?? '');
    _minutes = TextEditingController(
      text: seconds == null ? '' : '${seconds ~/ 60}',
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _minutes.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    final minutesText = _minutes.text.trim();
    final minutes = minutesText.isEmpty ? null : int.tryParse(minutesText);
    final badMinutes =
        minutesText.isNotEmpty && (minutes == null || minutes <= 0);
    if (title.isEmpty || badMinutes) {
      setState(() {
        _titleError = title.isEmpty ? 'Enter a name' : null;
        _minutesError = badMinutes ? 'Enter minutes greater than zero' : null;
      });
      return;
    }
    Navigator.pop(context, (title: title, minutes: minutes));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.segment == null ? 'New segment' : 'Edit segment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('segment-title-field'),
            controller: _title,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Segment name',
              errorText: _titleError,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('segment-minutes-field'),
            controller: _minutes,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Minutes (optional)',
              errorText: _minutesError,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save segment')),
      ],
    );
  }
}
