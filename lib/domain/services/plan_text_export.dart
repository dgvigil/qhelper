import 'package:q_helper/domain/models/workout_activity.dart';
import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/services/plan_edits.dart';

/// Readable plain text for sharing a workout plan.
String planToText(WorkoutPlan plan) {
  final lines = <String>[
    plan.title,
    'Target duration: ${formatSeconds(plan.targetDurationSeconds)}',
    (plan.description ?? '').trim(),
  ];

  final segments = [...plan.segments]
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  for (final segment in segments) {
    lines.add('');
    final estimate = segment.estimatedDurationSeconds;
    lines.add(
      estimate == null
          ? segment.title
          : '${segment.title} (about ${formatSeconds(estimate)})',
    );
    final activities = flattenActivities(plan.copyWith(segments: [segment]));
    if (activities.isEmpty) {
      lines.add('   (nothing added yet)');
      continue;
    }
    for (var i = 0; i < activities.length; i++) {
      final a = activities[i];
      lines.add('${i + 1}. ${a.name}: ${_details(a.details)}');
      final notes = (a.notes ?? '').trim();
      if (notes.isNotEmpty) lines.add('   Notes: $notes');
    }
  }
  return lines.join('\n');
}

String _details(ActivityDetails d) => switch (d) {
  RepsDetails(:final repetitions) =>
    '$repetitions ${repetitions == 1 ? 'rep' : 'reps'}',
  TimedDetails(:final workSeconds, :final restSeconds, :final rounds) =>
    '${formatSeconds(workSeconds)} work'
        '${restSeconds > 0 ? ' / ${formatSeconds(restSeconds)} rest' : ''}'
        ' x $rounds ${rounds == 1 ? 'round' : 'rounds'}',
  FreeFormDetails(:final instructions) => instructions.trim(),
};

/// "45 min", "1 min 30 sec", "40 sec".
String formatSeconds(int total) {
  final minutes = total ~/ 60;
  final seconds = total % 60;
  if (minutes == 0) return '$seconds sec';
  if (seconds == 0) return '$minutes min';
  return '$minutes min $seconds sec';
}
