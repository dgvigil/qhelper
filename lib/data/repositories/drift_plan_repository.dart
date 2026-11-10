import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:q_helper/data/database/app_database.dart';
import 'package:q_helper/domain/models/validation.dart';
import 'package:q_helper/domain/models/workout_activity.dart';
import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/models/workout_segment.dart';
import 'package:q_helper/domain/repositories/plan_repository.dart';
import 'package:uuid/uuid.dart';

class DriftPlanRepository implements PlanRepository {
  DriftPlanRepository(this._db, {Clock? clock, String Function()? newId})
    : _clock = clock ?? const Clock(),
      _newId = newId ?? (() => const Uuid().v4());

  final AppDatabase _db;
  final Clock _clock;
  final String Function() _newId;

  @override
  Future<WorkoutPlan> create(WorkoutPlan plan) async {
    _validate(plan);
    await _db.transaction(() => _insert(plan));
    return plan;
  }

  @override
  Future<WorkoutPlan?> get(String id) async {
    final row = await (_db.select(
      _db.plans,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    return row == null ? null : _load(row);
  }

  @override
  Future<List<WorkoutPlan>> list() async {
    final rows = await (_db.select(
      _db.plans,
    )..orderBy([(p) => OrderingTerm.desc(p.updatedAt)])).get();
    return [for (final row in rows) await _load(row)];
  }

  @override
  Future<WorkoutPlan> update(WorkoutPlan plan) async {
    _validate(plan);
    return _db.transaction(() async {
      final existing = await (_db.select(
        _db.plans,
      )..where((p) => p.id.equals(plan.id))).getSingleOrNull();
      if (existing == null) {
        throw StateError('Plan ${plan.id} does not exist');
      }
      final saved = plan.copyWith(
        createdAt: existing.createdAt,
        updatedAt: _clock.now().toUtc(),
      );
      // Children are replaced wholesale; deleting segments cascades.
      await (_db.delete(
        _db.segments,
      )..where((s) => s.planId.equals(plan.id))).go();
      await (_db.update(
        _db.plans,
      )..where((p) => p.id.equals(plan.id))).write(_planRow(saved));
      await _insertChildren(saved);
      return saved;
    });
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.plans)..where((p) => p.id.equals(id))).go();
  }

  @override
  Future<WorkoutPlan> duplicate(String id) async {
    final source = await get(id);
    if (source == null) throw StateError('Plan $id does not exist');
    final now = _clock.now().toUtc();
    final planId = _newId();
    final copy = WorkoutPlan(
      id: planId,
      title: '${source.title} (copy)',
      description: source.description,
      targetDurationSeconds: source.targetDurationSeconds,
      createdAt: now,
      updatedAt: now,
      segments: [
        for (final s in source.segments)
          _copySegment(s, planId: planId, segmentId: _newId()),
      ],
    );
    return create(copy);
  }

  WorkoutSegment _copySegment(
    WorkoutSegment s, {
    required String planId,
    required String segmentId,
  }) {
    return WorkoutSegment(
      id: segmentId,
      planId: planId,
      title: s.title,
      sortOrder: s.sortOrder,
      estimatedDurationSeconds: s.estimatedDurationSeconds,
      activities: [
        for (final a in s.activities)
          WorkoutActivity(
            id: _newId(),
            segmentId: segmentId,
            sortOrder: a.sortOrder,
            name: a.name,
            notes: a.notes,
            details: a.details,
          ),
      ],
    );
  }

  void _validate(WorkoutPlan plan) {
    final issues = plan.validate();
    if (issues.isNotEmpty) throw PlanValidationException(issues);
  }

  Future<void> _insert(WorkoutPlan plan) async {
    await _db.into(_db.plans).insert(_planRow(plan));
    await _insertChildren(plan);
  }

  Future<void> _insertChildren(WorkoutPlan plan) async {
    for (final segment in plan.segments) {
      await _db
          .into(_db.segments)
          .insert(
            SegmentsCompanion.insert(
              id: segment.id,
              planId: plan.id,
              title: segment.title,
              sortOrder: segment.sortOrder,
              estimatedDurationSeconds: Value(segment.estimatedDurationSeconds),
            ),
          );
      for (final activity in segment.activities) {
        await _db
            .into(_db.activities)
            .insert(_activityRow(segment.id, activity));
      }
    }
  }

  PlansCompanion _planRow(WorkoutPlan plan) {
    return PlansCompanion.insert(
      id: plan.id,
      title: plan.title,
      description: Value(plan.description),
      targetDurationSeconds: plan.targetDurationSeconds,
      createdAt: plan.createdAt.toUtc(),
      updatedAt: plan.updatedAt.toUtc(),
      schemaVersion: plan.schemaVersion,
    );
  }

  ActivitiesCompanion _activityRow(String segmentId, WorkoutActivity a) {
    final d = a.details;
    return ActivitiesCompanion.insert(
      id: a.id,
      segmentId: segmentId,
      sortOrder: a.sortOrder,
      kind: a.kind.name,
      name: a.name,
      notes: Value(a.notes),
      repetitions: Value(d is RepsDetails ? d.repetitions : null),
      workSeconds: Value(d is TimedDetails ? d.workSeconds : null),
      restSeconds: Value(d is TimedDetails ? d.restSeconds : null),
      rounds: Value(d is TimedDetails ? d.rounds : null),
      instructions: Value(d is FreeFormDetails ? d.instructions : null),
    );
  }

  Future<WorkoutPlan> _load(Plan row) async {
    final segmentRows =
        await (_db.select(_db.segments)
              ..where((s) => s.planId.equals(row.id))
              ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)]))
            .get();
    final segments = <WorkoutSegment>[];
    for (final s in segmentRows) {
      final activityRows =
          await (_db.select(_db.activities)
                ..where((a) => a.segmentId.equals(s.id))
                ..orderBy([(a) => OrderingTerm.asc(a.sortOrder)]))
              .get();
      segments.add(
        WorkoutSegment(
          id: s.id,
          planId: s.planId,
          title: s.title,
          sortOrder: s.sortOrder,
          estimatedDurationSeconds: s.estimatedDurationSeconds,
          activities: [for (final a in activityRows) _activity(a)],
        ),
      );
    }
    return WorkoutPlan(
      id: row.id,
      title: row.title,
      description: row.description,
      targetDurationSeconds: row.targetDurationSeconds,
      createdAt: row.createdAt.toUtc(),
      updatedAt: row.updatedAt.toUtc(),
      schemaVersion: row.schemaVersion,
      segments: segments,
    );
  }

  WorkoutActivity _activity(Activity a) {
    final kind = ActivityKind.values.byName(a.kind);
    final details = switch (kind) {
      ActivityKind.reps => RepsDetails(repetitions: a.repetitions!),
      ActivityKind.timed => TimedDetails(
        workSeconds: a.workSeconds!,
        restSeconds: a.restSeconds!,
        rounds: a.rounds!,
      ),
      ActivityKind.freeForm => FreeFormDetails(instructions: a.instructions!),
    };
    return WorkoutActivity(
      id: a.id,
      segmentId: a.segmentId,
      sortOrder: a.sortOrder,
      name: a.name,
      notes: a.notes,
      details: details,
    );
  }
}
