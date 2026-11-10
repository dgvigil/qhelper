import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/data/database/app_database.dart';
import 'package:q_helper/data/repositories/drift_plan_repository.dart';
import 'package:q_helper/data/repositories/drift_session_repository.dart';
import 'package:q_helper/domain/models/workout_session.dart';

import '../../fixtures/plans.dart';

void main() {
  late AppDatabase db;
  late DateTime now;
  late int idCounter;
  late DriftPlanRepository plans;
  late DriftSessionRepository sessions;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime.utc(2026, 11, 10, 5, 30);
    idCounter = 0;
    final clock = Clock(() => now);
    String newId() => 'id-${idCounter++}';
    plans = DriftPlanRepository(db, clock: clock, newId: newId);
    sessions = DriftSessionRepository(
      db,
      plans: plans,
      clock: clock,
      newId: newId,
    );
    await plans.create(buildPlan());
  });

  tearDown(() => db.close());

  group('start', () {
    test(
      'snapshots the plan and sets a deadline from the target duration',
      () async {
        final plan = (await plans.get('plan-1'))!;
        final session = await sessions.start('plan-1');

        expect(session.sourcePlanId, 'plan-1');
        expect(session.planSnapshot, plan);
        expect(session.status, SessionStatus.running);
        expect(session.startedAtWall, now);
        expect(session.deadlineAtWall, now.add(const Duration(seconds: 2700)));
        expect(session.updatedAtWall, now);
      },
    );

    test('can be read back unchanged', () async {
      final started = await sessions.start('plan-1');
      expect(await sessions.get(started.id), started);
    });

    test('uses the duration of the plan being started', () async {
      await plans.create(buildPlan(id: 'short', targetDurationSeconds: 1800));
      final session = await sessions.start('short');
      expect(session.deadlineAtWall, now.add(const Duration(minutes: 30)));
    });

    test('throws when the plan does not exist', () async {
      await expectLater(sessions.start('nope'), throwsA(isA<StateError>()));
    });

    test('refuses a second session while one is running', () async {
      await sessions.start('plan-1');
      await expectLater(sessions.start('plan-1'), throwsA(isA<StateError>()));
    });

    test('allows a new session after the previous one ends', () async {
      final first = await sessions.start('plan-1');
      await sessions.finish(first.id, SessionStatus.completed);
      final second = await sessions.start('plan-1');
      expect(second.id, isNot(first.id));
    });
  });

  group('snapshot immutability', () {
    test('editing the plan afterwards does not change the session', () async {
      final started = await sessions.start('plan-1');
      final original = (await plans.get('plan-1'))!;

      now = now.add(const Duration(minutes: 5));
      await plans.update(
        original.copyWith(
          title: 'Changed mid-workout',
          targetDurationSeconds: 600,
          segments: [original.segments[0]],
        ),
      );

      final session = (await sessions.get(started.id))!;
      expect(session.planSnapshot, original);
      expect(session.planSnapshot.title, 'Tuesday Beatdown');
      expect(session.planSnapshot.segments, hasLength(2));
      expect(session.deadlineAtWall, started.deadlineAtWall);
    });

    test('deleting the plan keeps the snapshot and clears the link', () async {
      final started = await sessions.start('plan-1');
      await plans.delete('plan-1');

      final session = (await sessions.get(started.id))!;
      expect(session.sourcePlanId, isNull);
      expect(session.planSnapshot, started.planSnapshot);
      expect(session.planSnapshot.segments[0].activities, hasLength(2));
    });
  });

  group('findActive', () {
    test('is null when no session has started', () async {
      expect(await sessions.findActive(), isNull);
    });

    test('returns the running session', () async {
      final started = await sessions.start('plan-1');
      expect(await sessions.findActive(), started);
    });

    test('is null once the session has ended', () async {
      final started = await sessions.start('plan-1');
      await sessions.finish(started.id, SessionStatus.endedEarly);
      expect(await sessions.findActive(), isNull);
    });
  });

  group('finish', () {
    test('records the final status and time', () async {
      final started = await sessions.start('plan-1');
      now = now.add(const Duration(minutes: 44));
      final finished = await sessions.finish(
        started.id,
        SessionStatus.completed,
      );

      expect(finished.status, SessionStatus.completed);
      expect(finished.updatedAtWall, now);
      expect(finished.startedAtWall, started.startedAtWall);
      expect(await sessions.get(started.id), finished);
    });

    test('is safe to repeat with the same status', () async {
      final started = await sessions.start('plan-1');
      final first = await sessions.finish(started.id, SessionStatus.endedEarly);
      now = now.add(const Duration(minutes: 1));
      final second = await sessions.finish(
        started.id,
        SessionStatus.endedEarly,
      );
      expect(second, first);
    });

    test('does not let a finished session change to another status', () async {
      final started = await sessions.start('plan-1');
      await sessions.finish(started.id, SessionStatus.completed);
      await expectLater(
        sessions.finish(started.id, SessionStatus.endedEarly),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects running as a final status', () async {
      final started = await sessions.start('plan-1');
      await expectLater(
        sessions.finish(started.id, SessionStatus.running),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws for an unknown session', () async {
      await expectLater(
        sessions.finish('nope', SessionStatus.completed),
        throwsA(isA<StateError>()),
      );
    });
  });
}
