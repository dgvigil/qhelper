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
}
