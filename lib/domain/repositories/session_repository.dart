import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/models/workout_session.dart';

abstract interface class SessionRepository {
  /// Copies the saved plan into a new running session.
  /// Throws `StateError` if the plan is missing or a session is already running.
  Future<WorkoutSession> start(String planId);

  Future<WorkoutSession?> get(String id);

  /// The running session, if any. Used to offer Resume / End after a relaunch.
  Future<WorkoutSession?> findActive();

  /// Ends a session with a final [status]. Repeating the same status is a
  /// no-op. Throws `ArgumentError` for `running`, and `StateError` for an
  /// unknown session or one already ended with a different status.
  Future<WorkoutSession> finish(String id, SessionStatus status);

  /// Persists live progress for a running session: the working plan
  /// (session-only edits), position, and timer state. Optional fields that are
  /// omitted are cleared. The original snapshot is never touched. Throws
  /// `StateError` for an unknown or ended session.
  Future<WorkoutSession> saveProgress(
    String id, {
    required WorkoutPlan workingPlan,
    String? activeSegmentId,
    String? activeActivityId,
    Map<String, Object?>? masterTimerState,
    Map<String, Object?>? intervalTimerState,
  });
}
