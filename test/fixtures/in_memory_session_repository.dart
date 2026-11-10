import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/models/workout_session.dart';
import 'package:q_helper/domain/repositories/plan_repository.dart';
import 'package:q_helper/domain/repositories/session_repository.dart';

/// In-memory session repository for widget tests. Follows the contract of the
/// Drift implementation.
class InMemorySessionRepository implements SessionRepository {
  InMemorySessionRepository(this._plans, {required this._now});

  final PlanRepository _plans;
  final DateTime Function() _now;
  final Map<String, WorkoutSession> _sessions = {};
  int _n = 0;

  List<WorkoutSession> get stored => _sessions.values.toList();

  @override
  Future<WorkoutSession> start(String planId) async {
    if (await findActive() != null) {
      throw StateError('A session is already running');
    }
    final plan = await _plans.get(planId);
    if (plan == null) throw StateError('Plan $planId does not exist');
    final now = _now().toUtc();
    final session = WorkoutSession(
      id: 'session-${_n++}',
      sourcePlanId: plan.id,
      planSnapshot: plan,
      startedAtWall: now,
      deadlineAtWall: now.add(Duration(seconds: plan.targetDurationSeconds)),
      status: SessionStatus.running,
      updatedAtWall: now,
      workingPlan: plan,
    );
    _sessions[session.id] = session;
    return session;
  }

  @override
  Future<WorkoutSession?> get(String id) async => _sessions[id];

  @override
  Future<WorkoutSession?> findActive() async {
    for (final s in _sessions.values) {
      if (s.status == SessionStatus.running) return s;
    }
    return null;
  }

  @override
  Future<WorkoutSession> finish(String id, SessionStatus status) async {
    if (status == SessionStatus.running) throw ArgumentError.value(status);
    final current = _sessions[id];
    if (current == null) throw StateError('Session $id does not exist');
    if (current.status == status) return current;
    if (current.status != SessionStatus.running) {
      throw StateError('Session $id already ended');
    }
    final updated = current.copyWith(status: status, updatedAtWall: _now());
    return _sessions[id] = updated;
  }

  @override
  Future<WorkoutSession> saveProgress(
    String id, {
    required WorkoutPlan workingPlan,
    String? activeSegmentId,
    String? activeActivityId,
    Map<String, Object?>? masterTimerState,
    Map<String, Object?>? intervalTimerState,
  }) async {
    final current = _sessions[id];
    if (current == null) throw StateError('Session $id does not exist');
    if (current.status != SessionStatus.running) {
      throw StateError('Session $id has ended');
    }
    final updated = current.withProgress(
      workingPlan: workingPlan,
      updatedAtWall: _now().toUtc(),
      activeSegmentId: activeSegmentId,
      activeActivityId: activeActivityId,
      masterTimerState: masterTimerState,
      intervalTimerState: intervalTimerState,
    );
    return _sessions[id] = updated;
  }
}
