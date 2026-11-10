import 'package:q_helper/domain/models/workout_activity.dart';
import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/models/workout_segment.dart';

/// Pure helpers that return edited copies of a plan. They never mutate their
/// input, so a saved plan and a session's working copy cannot share edits.

List<WorkoutSegment> _orderedSegments(WorkoutPlan plan) =>
    [...plan.segments]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

List<WorkoutActivity> _orderedActivities(WorkoutSegment segment) =>
    [...segment.activities]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

/// All activities in workout order: by segment, then by position.
List<WorkoutActivity> flattenActivities(WorkoutPlan plan) => [
  for (final segment in _orderedSegments(plan)) ..._orderedActivities(segment),
];

List<WorkoutActivity> _renumber(String segmentId, List<WorkoutActivity> list) =>
    [
      for (var i = 0; i < list.length; i++)
        list[i].copyWith(segmentId: segmentId, sortOrder: i),
    ];

WorkoutPlan _mapSegments(
  WorkoutPlan plan,
  WorkoutSegment Function(WorkoutSegment) change,
) => plan.copyWith(segments: [for (final s in plan.segments) change(s)]);

/// Replaces the activity with the same id, keeping its segment and position.
WorkoutPlan replaceActivity(WorkoutPlan plan, WorkoutActivity updated) {
  var found = false;
  final result = _mapSegments(plan, (segment) {
    final index = segment.activities.indexWhere((a) => a.id == updated.id);
    if (index < 0) return segment;
    found = true;
    final original = segment.activities[index];
    final activities = [...segment.activities];
    activities[index] = updated.copyWith(
      segmentId: original.segmentId,
      sortOrder: original.sortOrder,
    );
    return segment.copyWith(activities: activities);
  });
  if (!found) throw StateError('Activity ${updated.id} not found');
  return result;
}

/// Inserts [activity] into a segment at [index] (default: the end).
WorkoutPlan insertActivity(
  WorkoutPlan plan,
  String segmentId,
  WorkoutActivity activity, {
  int? index,
}) {
  var found = false;
  final result = _mapSegments(plan, (segment) {
    if (segment.id != segmentId) return segment;
    found = true;
    final ordered = _orderedActivities(segment);
    ordered.insert(index ?? ordered.length, activity);
    return segment.copyWith(activities: _renumber(segment.id, ordered));
  });
  if (!found) throw StateError('Segment $segmentId not found');
  return result;
}

/// Removes an activity and renumbers the rest of its segment.
WorkoutPlan removeActivity(WorkoutPlan plan, String activityId) {
  var found = false;
  final result = _mapSegments(plan, (segment) {
    if (!segment.activities.any((a) => a.id == activityId)) return segment;
    found = true;
    final remaining = [
      for (final a in _orderedActivities(segment))
        if (a.id != activityId) a,
    ];
    return segment.copyWith(activities: _renumber(segment.id, remaining));
  });
  if (!found) throw StateError('Activity $activityId not found');
  return result;
}
