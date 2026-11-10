import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/models/workout_segment.dart';

/// Lengths of the built-in structural templates, in minutes.
const List<int> templateMinutes = [45, 60];

const List<String> _segmentNames = ['Warm-O-Rama', 'The Thang', 'Mary', 'CoT'];

/// Minutes per segment, in the same order as [_segmentNames].
const Map<int, List<int>> _allocations = {
  45: [7, 25, 8, 5],
  60: [8, 35, 10, 7],
};

WorkoutPlan _build({
  required String Function() newId,
  required DateTime now,
  required int minutes,
  List<int>? allocation,
}) {
  final planId = newId();
  return WorkoutPlan(
    id: planId,
    title: '',
    targetDurationSeconds: minutes * 60,
    createdAt: now,
    updatedAt: now,
    segments: [
      for (var i = 0; i < _segmentNames.length; i++)
        WorkoutSegment(
          id: newId(),
          planId: planId,
          title: _segmentNames[i],
          sortOrder: i,
          estimatedDurationSeconds: allocation == null
              ? null
              : allocation[i] * 60,
          activities: const [],
        ),
    ],
  );
}

/// A new plan with the default four segments and no activities or time split.
WorkoutPlan blankPlan({
  required String Function() newId,
  required DateTime now,
  int minutes = 45,
}) => _build(newId: newId, now: now, minutes: minutes);

/// A new plan from a structural template: segment names and time allocations
/// only. Exercise content is left for the Q to add.
WorkoutPlan templatePlan(
  int minutes, {
  required String Function() newId,
  required DateTime now,
}) {
  final allocation = _allocations[minutes];
  if (allocation == null) {
    throw ArgumentError.value(minutes, 'minutes', 'no such template');
  }
  return _build(
    newId: newId,
    now: now,
    minutes: minutes,
    allocation: allocation,
  );
}
