import 'package:flutter/material.dart';
import 'package:q_helper/domain/models/workout_session.dart';

/// Asks how a workout ended. Returns null if the Q chooses to keep going.
Future<SessionStatus?> showEndWorkoutDialog(BuildContext context) {
  return showDialog<SessionStatus>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('End workout?'),
      content: const Text('This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Keep going'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context, SessionStatus.endedEarly),
          child: const Text('End early'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, SessionStatus.completed),
          child: const Text('Finished'),
        ),
      ],
    ),
  );
}
