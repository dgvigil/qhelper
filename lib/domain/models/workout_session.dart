import 'package:q_helper/domain/models/workout_plan.dart';

enum SessionStatus { running, completed, endedEarly, interrupted }

/// A live run of a workout. Holds its own immutable copy of the plan, so later
/// edits or deletion of the saved plan cannot change it.
///
/// Timer state and active-activity tracking are added with the timer engine
/// (Phase 2) and session state machine (Phase 3).
class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.planSnapshot,
    required this.startedAtWall,
    required this.deadlineAtWall,
    required this.status,
    required this.updatedAtWall,
    this.sourcePlanId,
  });

  final String id;
  final String? sourcePlanId;
  final WorkoutPlan planSnapshot;
  final DateTime startedAtWall;
  final DateTime deadlineAtWall;
  final SessionStatus status;
  final DateTime updatedAtWall;

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
      other.updatedAtWall == updatedAtWall;

  @override
  int get hashCode => Object.hash(
    id,
    sourcePlanId,
    planSnapshot,
    startedAtWall,
    deadlineAtWall,
    status,
    updatedAtWall,
  );
}
