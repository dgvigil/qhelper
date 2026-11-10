import 'dart:convert';

import 'package:q_helper/domain/models/workout_plan.dart';

enum SessionStatus { running, completed, endedEarly, interrupted }

/// A live run of a workout. Holds its own immutable copy of the plan, so later
/// edits or deletion of the saved plan cannot change it.
///
/// [planSnapshot] is the plan exactly as it was at start and never changes.
/// [workingPlan] starts as a copy and holds session-only edits (audibles).
class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.planSnapshot,
    required this.startedAtWall,
    required this.deadlineAtWall,
    required this.status,
    required this.updatedAtWall,
    required this.workingPlan,
    this.sourcePlanId,
    this.activeSegmentId,
    this.activeActivityId,
    this.masterTimerState,
    this.intervalTimerState,
  });

  final String id;
  final String? sourcePlanId;
  final WorkoutPlan planSnapshot;
  final DateTime startedAtWall;
  final DateTime deadlineAtWall;
  final SessionStatus status;
  final DateTime updatedAtWall;
  final WorkoutPlan workingPlan;
  final String? activeSegmentId;
  final String? activeActivityId;
  final Map<String, Object?>? masterTimerState;
  final Map<String, Object?>? intervalTimerState;

  /// Replaces progress fields wholesale; null clears an optional field.
  WorkoutSession withProgress({
    required WorkoutPlan workingPlan,
    required DateTime updatedAtWall,
    String? activeSegmentId,
    String? activeActivityId,
    Map<String, Object?>? masterTimerState,
    Map<String, Object?>? intervalTimerState,
  }) {
    return WorkoutSession(
      id: id,
      sourcePlanId: sourcePlanId,
      planSnapshot: planSnapshot,
      startedAtWall: startedAtWall,
      deadlineAtWall: deadlineAtWall,
      status: status,
      updatedAtWall: updatedAtWall,
      workingPlan: workingPlan,
      activeSegmentId: activeSegmentId,
      activeActivityId: activeActivityId,
      masterTimerState: masterTimerState,
      intervalTimerState: intervalTimerState,
    );
  }

  WorkoutSession copyWith({
    SessionStatus? status,
    DateTime? updatedAtWall,
    String? sourcePlanId,
  }) {
    return WorkoutSession(
      id: id,
      sourcePlanId: sourcePlanId ?? this.sourcePlanId,
      planSnapshot: planSnapshot,
      startedAtWall: startedAtWall,
      deadlineAtWall: deadlineAtWall,
      status: status ?? this.status,
      updatedAtWall: updatedAtWall ?? this.updatedAtWall,
      workingPlan: workingPlan,
      activeSegmentId: activeSegmentId,
      activeActivityId: activeActivityId,
      masterTimerState: masterTimerState,
      intervalTimerState: intervalTimerState,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is WorkoutSession &&
      other.id == id &&
      other.sourcePlanId == sourcePlanId &&
      other.planSnapshot == planSnapshot &&
      other.startedAtWall == startedAtWall &&
      other.deadlineAtWall == deadlineAtWall &&
      other.status == status &&
      other.updatedAtWall == updatedAtWall &&
      other.workingPlan == workingPlan &&
      other.activeSegmentId == activeSegmentId &&
      other.activeActivityId == activeActivityId &&
      _json(other.masterTimerState) == _json(masterTimerState) &&
      _json(other.intervalTimerState) == _json(intervalTimerState);

  static String? _json(Map<String, Object?>? m) =>
      m == null ? null : jsonEncode(m);

  @override
  int get hashCode => Object.hash(
    id,
    sourcePlanId,
    planSnapshot,
    startedAtWall,
    deadlineAtWall,
    status,
    updatedAtWall,
    workingPlan,
    activeSegmentId,
    activeActivityId,
    _json(masterTimerState),
    _json(intervalTimerState),
  );
}
