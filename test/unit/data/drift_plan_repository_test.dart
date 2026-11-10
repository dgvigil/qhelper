import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/data/database/app_database.dart';
import 'package:q_helper/data/repositories/drift_plan_repository.dart';
import 'package:q_helper/domain/models/validation.dart';
import 'package:q_helper/domain/models/workout_activity.dart';

import '../../fixtures/plans.dart';

void main() {
  late AppDatabase db;
  late DateTime now;
  late int idCounter;
  late DriftPlanRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime.utc(2026, 11, 10, 12);
    idCounter = 0;
    repo = DriftPlanRepository(
      db,
      clock: Clock(() => now),
      newId: () => 'gen-${idCounter++}',
    );
  });

  tearDown(() => db.close());

  Future<int> count(String table) async {
    final row = await db
        .customSelect('SELECT COUNT(*) AS c FROM $table')
        .getSingle();
    return row.read<int>('c');
  }

  group('create and get', () {
    test(
      'returns an equal plan after a round trip through the database',
      () async {
        final plan = buildPlan();
        await repo.create(plan);
        expect(await repo.get(plan.id), plan);
      },
    );

    test('returns null for an unknown id', () async {
      expect(await repo.get('missing'), isNull);
    });

    test('stores every activity kind with its specific fields', () async {
      final plan = buildPlan();
      await repo.create(plan);
      final loaded = (await repo.get(plan.id))!;
      final details = [
        for (final s in loaded.segments)
          for (final a in s.activities) a.details,
      ];
      expect(details, [
        const RepsDetails(repetitions: 25),
        const FreeFormDetails(instructions: 'Easy pace, 2 laps'),
        const TimedDetails(workSeconds: 40, restSeconds: 20, rounds: 5),
      ]);
    });

    test('rejects an invalid plan and writes nothing', () async {
      final bad = buildPlan(title: '');
      await expectLater(
        repo.create(bad),
        throwsA(
          isA<PlanValidationException>().having(
            (e) => e.issues.map((i) => i.field),
            'fields',
            ['title'],
          ),
        ),
      );
      expect(await count('plans'), 0);
      expect(await count('segments'), 0);
    });
  });

  group('list', () {
    test('returns the most recently updated plan first', () async {
      await repo.create(
        buildPlan(id: 'old', createdAt: DateTime.utc(2026, 1, 1)),
      );
      await repo.create(
        buildPlan(id: 'new', createdAt: DateTime.utc(2026, 6, 1)),
      );
      await repo.create(
        buildPlan(id: 'mid', createdAt: DateTime.utc(2026, 3, 1)),
      );
      expect((await repo.list()).map((p) => p.id), ['new', 'mid', 'old']);
    });

    test('is empty when nothing is saved', () async {
      expect(await repo.list(), isEmpty);
    });
  });

  group('ordering', () {
    test(
      'returns segments and activities by sortOrder, not insert order',
      () async {
        final plan = buildPlan();
        final shuffled = plan.copyWith(
          segments: [
            plan.segments[1],
            plan.segments[0].copyWith(
              activities: plan.segments[0].activities.reversed.toList(),
            ),
          ],
        );
        await repo.create(shuffled);
        final loaded = (await repo.get(plan.id))!;
        expect(loaded.segments.map((s) => s.sortOrder), [0, 1]);
        expect(loaded.segments[0].activities.map((a) => a.sortOrder), [0, 1]);
        expect(loaded, plan);
      },
    );

    test('persists a reorder made through update', () async {
      final plan = buildPlan();
      await repo.create(plan);
      final flipped = plan.copyWith(
        segments: [
          plan.segments[1].copyWith(sortOrder: 0),
          plan.segments[0].copyWith(sortOrder: 1),
        ],
      );
      await repo.update(flipped);
      final loaded = (await repo.get(plan.id))!;
      expect(loaded.segments.map((s) => s.title), ['The Thang', 'Warm-O-Rama']);
    });
  });

  group('update', () {
    test(
      'replaces children, keeps createdAt, and advances updatedAt',
      () async {
        final plan = buildPlan();
        await repo.create(plan);
        now = DateTime.utc(2026, 11, 11, 6);
        final edited = plan.copyWith(
          title: 'Renamed',
          segments: [plan.segments[0]],
        );
        final saved = await repo.update(edited);

        final loaded = (await repo.get(plan.id))!;
        expect(loaded, saved);
        expect(loaded.title, 'Renamed');
        expect(loaded.segments, hasLength(1));
        expect(loaded.createdAt, plan.createdAt);
        expect(loaded.updatedAt, now);
        expect(await count('segments'), 1);
        expect(await count('activities'), 2);
      },
    );

    test('throws for a plan that does not exist', () async {
      await expectLater(repo.update(buildPlan()), throwsA(isA<StateError>()));
    });

    test('rejects invalid edits and leaves the saved plan untouched', () async {
      final plan = buildPlan();
      await repo.create(plan);
      await expectLater(
        repo.update(plan.copyWith(targetDurationSeconds: 0)),
        throwsA(isA<PlanValidationException>()),
      );
      expect(await repo.get(plan.id), plan);
    });
  });

  group('delete', () {
    test('removes the plan and cascades to segments and activities', () async {
      await repo.create(buildPlan());
      await repo.create(buildPlan(id: 'keep'));
      await repo.delete('plan-1');
      expect(await repo.get('plan-1'), isNull);
      expect(await count('plans'), 1);
      expect(await count('segments'), 2);
      expect(await count('activities'), 3);
    });

    test('is safe to repeat', () async {
      await repo.create(buildPlan());
      await repo.delete('plan-1');
      await repo.delete('plan-1');
      expect(await count('plans'), 0);
    });
  });

  group('duplicate', () {
    test('copies structure with fresh ids and a copy title', () async {
      final original = buildPlan();
      await repo.create(original);
      now = DateTime.utc(2026, 11, 12);

      final copy = await repo.duplicate(original.id);

      expect(copy.id, isNot(original.id));
      expect(copy.title, 'Tuesday Beatdown (copy)');
      expect(copy.createdAt, now);
      expect(copy.updatedAt, now);
      expect(copy.segments.map((s) => s.title), ['Warm-O-Rama', 'The Thang']);
      expect(copy.segments[0].activities.map((a) => a.details), [
        const RepsDetails(repetitions: 25),
        const FreeFormDetails(instructions: 'Easy pace, 2 laps'),
      ]);

      final oldIds = {
        original.id,
        for (final s in original.segments) s.id,
        for (final s in original.segments)
          for (final a in s.activities) a.id,
      };
      final newIds = {
        copy.id,
        for (final s in copy.segments) s.id,
        for (final s in copy.segments)
          for (final a in s.activities) a.id,
      };
      expect(newIds.intersection(oldIds), isEmpty);
      expect(newIds, hasLength(oldIds.length));
    });

    test('links copied children to the copied parents', () async {
      await repo.create(buildPlan());
      final copy = await repo.duplicate('plan-1');
      for (final s in copy.segments) {
        expect(s.planId, copy.id);
        for (final a in s.activities) {
          expect(a.segmentId, s.id);
        }
      }
      expect((await repo.get(copy.id))!, copy);
    });

    test('leaves the original untouched', () async {
      final original = buildPlan();
      await repo.create(original);
      await repo.duplicate(original.id);
      expect(await repo.get(original.id), original);
      expect(await count('plans'), 2);
    });

    test('throws when the source does not exist', () async {
      await expectLater(repo.duplicate('nope'), throwsA(isA<StateError>()));
    });
  });

  test('database enforces foreign keys', () async {
    await expectLater(
      db.customStatement(
        'INSERT INTO segments (id, plan_id, title, sort_order) '
        "VALUES ('s', 'no-such-plan', 't', 0)",
      ),
      throwsA(anything),
    );
  });
}
