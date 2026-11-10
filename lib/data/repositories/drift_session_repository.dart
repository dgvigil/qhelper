import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:q_helper/data/database/app_database.dart';
import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/models/workout_session.dart';
import 'package:q_helper/domain/repositories/plan_repository.dart';
import 'package:q_helper/domain/repositories/session_repository.dart';
import 'package:uuid/uuid.dart';

class DriftSessionRepository implements SessionRepository {
  DriftSessionRepository(
    this._db, {
    required this._plans,
    Clock? clock,
    String Function()? newId,
  }) : _clock = clock ?? const Clock(),
       _newId = newId ?? (() => const Uuid().v4());

  final AppDatabase _db;
  final PlanRepository _plans;
  final Clock _clock;
  final String Function() _newId;

  @override
  Future<WorkoutSession> start(String planId) {
    return _db.transaction(() async {
      if (await findActive() != null) {
        throw StateError('A session is already running');
      }
      final plan = await _plans.get(planId);
      if (plan == null) throw StateError('Plan $planId does not exist');

      final now = _clock.now().toUtc();
      final session = WorkoutSession(
        id: _newId(),
        sourcePlanId: plan.id,
        planSnapshot: plan,
        startedAtWall: now,
        deadlineAtWall: now.add(Duration(seconds: plan.targetDurationSeconds)),
        status: SessionStatus.running,
        updatedAtWall: now,
        workingPlan: plan,
      );
      await _db
          .into(_db.sessions)
          .insert(
            SessionsCompanion.insert(
              id: session.id,
              sourcePlanId: Value(session.sourcePlanId),
              planSnapshot: jsonEncode(plan.toJson()),
              startedAtWall: session.startedAtWall,
              deadlineAtWall: session.deadlineAtWall,
              status: session.status.name,
              updatedAtWall: session.updatedAtWall,
              workingPlan: jsonEncode(plan.toJson()),
            ),
          );
      return session;
    });
  }

  @override
  Future<WorkoutSession?> get(String id) async {
    final row = await (_db.select(
      _db.sessions,
    )..where((s) => s.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  @override
  Future<WorkoutSession?> findActive() async {
    final row =
        await (_db.select(_db.sessions)
              ..where((s) => s.status.equals(SessionStatus.running.name))
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  @override
  Future<WorkoutSession> finish(String id, SessionStatus status) async {
    if (status == SessionStatus.running) {
      throw ArgumentError.value(status, 'status', 'must be a final status');
    }
    return _db.transaction(() async {
      final current = await get(id);
      if (current == null) throw StateError('Session $id does not exist');
      if (current.status == status) return current;
      if (current.status != SessionStatus.running) {
        throw StateError('Session $id already ended as ${current.status.name}');
      }
      final updated = current.copyWith(
        status: status,
        updatedAtWall: _clock.now().toUtc(),
      );
      await (_db.update(_db.sessions)..where((s) => s.id.equals(id))).write(
        SessionsCompanion(
          status: Value(updated.status.name),
          updatedAtWall: Value(updated.updatedAtWall),
        ),
      );
      return updated;
    });
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
    return _db.transaction(() async {
      final current = await get(id);
      if (current == null) throw StateError('Session $id does not exist');
      if (current.status != SessionStatus.running) {
        throw StateError('Session $id has ended');
      }
      final updated = current.withProgress(
        workingPlan: workingPlan,
        updatedAtWall: _clock.now().toUtc(),
        activeSegmentId: activeSegmentId,
        activeActivityId: activeActivityId,
        masterTimerState: masterTimerState,
        intervalTimerState: intervalTimerState,
      );
      await (_db.update(_db.sessions)..where((s) => s.id.equals(id))).write(
        SessionsCompanion(
          workingPlan: Value(jsonEncode(workingPlan.toJson())),
          activeSegmentId: Value(activeSegmentId),
          activeActivityId: Value(activeActivityId),
          masterTimerState: Value(_encode(masterTimerState)),
          intervalTimerState: Value(_encode(intervalTimerState)),
          updatedAtWall: Value(updated.updatedAtWall),
        ),
      );
      return updated;
    });
  }

  static String? _encode(Map<String, Object?>? m) =>
      m == null ? null : jsonEncode(m);

  static Map<String, Object?>? _decode(String? s) =>
      s == null ? null : jsonDecode(s) as Map<String, Object?>;

  WorkoutSession _toModel(Session row) {
    return WorkoutSession(
      id: row.id,
      sourcePlanId: row.sourcePlanId,
      planSnapshot: WorkoutPlan.fromJson(
        jsonDecode(row.planSnapshot) as Map<String, Object?>,
      ),
      startedAtWall: row.startedAtWall.toUtc(),
      deadlineAtWall: row.deadlineAtWall.toUtc(),
      status: SessionStatus.values.byName(row.status),
      updatedAtWall: row.updatedAtWall.toUtc(),
      workingPlan: WorkoutPlan.fromJson(
        jsonDecode(row.workingPlan) as Map<String, Object?>,
      ),
      activeSegmentId: row.activeSegmentId,
      activeActivityId: row.activeActivityId,
      masterTimerState: _decode(row.masterTimerState),
      intervalTimerState: _decode(row.intervalTimerState),
    );
  }
}
