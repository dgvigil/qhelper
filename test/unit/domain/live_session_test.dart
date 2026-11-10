import 'dart:async';

import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/core/timer/interval_timer.dart';
import 'package:q_helper/data/database/app_database.dart';
import 'package:q_helper/data/repositories/drift_plan_repository.dart';
import 'package:q_helper/data/repositories/drift_session_repository.dart';
import 'package:q_helper/domain/models/validation.dart';
import 'package:q_helper/domain/models/workout_activity.dart';
import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/models/workout_session.dart';
import 'package:q_helper/domain/repositories/session_repository.dart';
import 'package:q_helper/domain/services/live_session.dart';

import '../../fixtures/fake_clock.dart';
import '../../fixtures/plans.dart';

Duration s(int seconds) => Duration(seconds: seconds);

const ssh = 'plan-1-act-0';
const mosey = 'plan-1-act-1';
const burpees = 'plan-1-act-2';

/// Delays the first saveProgress call so a later call would finish first if
/// operations were allowed to overlap.
class SlowFirstSave implements SessionRepository {
  SlowFirstSave(this._inner);

  final SessionRepository _inner;
  int _saves = 0;

  @override
  Future<WorkoutSession> saveProgress(
    String id, {
    required WorkoutPlan workingPlan,
    String? activeSegmentId,
    String? activeActivityId,
    Map<String, Object?>? masterTimerState,
    Map<String, Object?>? intervalTimerState,
  }) async {
    if (_saves++ == 1) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    return _inner.saveProgress(
      id,
      workingPlan: workingPlan,
      activeSegmentId: activeSegmentId,
      activeActivityId: activeActivityId,
      masterTimerState: masterTimerState,
      intervalTimerState: intervalTimerState,
    );
  }

  @override
  Future<WorkoutSession> start(String planId) => _inner.start(planId);

  @override
  Future<WorkoutSession?> get(String id) => _inner.get(id);

  @override
  Future<WorkoutSession?> findActive() => _inner.findActive();

  @override
  Future<WorkoutSession> finish(String id, SessionStatus status) =>
      _inner.finish(id, status);
}

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late DriftPlanRepository plans;
  late DriftSessionRepository sessions;
  late int idCounter;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clock = FakeClock();
    idCounter = 0;
    final repoClock = Clock(() => clock.now);
    String newId() => 'id-${idCounter++}';
    plans = DriftPlanRepository(db, clock: repoClock, newId: newId);
    sessions = DriftSessionRepository(
      db,
      plans: plans,
      clock: repoClock,
      newId: newId,
    );
    await plans.create(buildPlan());
  });

  tearDown(() => db.close());

  Future<LiveSession> begin([String planId = 'plan-1']) =>
      LiveSession.start(planId: planId, sessions: sessions, clock: clock);

  Future<LiveSession?> recover() =>
      LiveSession.recover(sessions: sessions, clock: clock);

  WorkoutActivity activity(String id, String name) => WorkoutActivity(
    id: id,
    segmentId: 'x',
    sortOrder: 0,
    name: name,
    details: const RepsDetails(repetitions: 12),
  );

  group('start', () {
    test('begins at the first activity with the next one visible', () async {
      final live = await begin();
      expect(live.session.status, SessionStatus.running);
      expect(live.current!.id, ssh);
      expect(live.upcoming!.id, mosey);
      expect(live.hasPrevious, isFalse);
    });

    test('starts the master countdown at the plan duration', () async {
      final live = await begin();
      expect(
        live.timers.master.read(clock).remaining,
        const Duration(minutes: 45),
      );
      expect(live.timers.master.deadlineWall, live.session.deadlineAtWall);
    });

    test('has no interval for a reps activity', () async {
      final live = await begin();
      expect(live.timers.interval, isNull);
    });

    test('saves position and timers right away', () async {
      final live = await begin();
      final saved = (await sessions.get(live.session.id))!;
      expect(saved.activeActivityId, ssh);
      expect(saved.activeSegmentId, 'plan-1-seg-0');
      expect(saved.masterTimerState, isNotNull);
    });

    test('handles a plan with no activities', () async {
      final empty = buildPlan(id: 'empty').copyWith(segments: []);
      await plans.create(empty);
      final live = await begin('empty');
      expect(live.current, isNull);
      expect(live.upcoming, isNull);
      await live.next();
      expect(live.current, isNull);
    });

    test('fails for a missing plan', () async {
      await expectLater(begin('nope'), throwsStateError);
    });

    test('refuses to start while another session is running', () async {
      await begin();
      await expectLater(begin(), throwsStateError);
    });
  });

  group('navigation', () {
    test('next and back move through activities in workout order', () async {
      final live = await begin();
      await live.next();
      expect(live.current!.id, mosey);
      expect(live.hasPrevious, isTrue);
      await live.next();
      expect(live.current!.id, burpees);
      expect(live.upcoming, isNull);
      await live.back();
      expect(live.current!.id, mosey);
    });

    test(
      'next on the last activity and back on the first do nothing',
      () async {
        final live = await begin();
        await live.back();
        expect(live.current!.id, ssh);
        await live.next();
        await live.next();
        await live.next();
        expect(live.current!.id, burpees);
      },
    );

    test('each move is saved', () async {
      final live = await begin();
      await live.next();
      final saved = (await sessions.get(live.session.id))!;
      expect(saved.activeActivityId, mosey);
      expect(saved.activeSegmentId, 'plan-1-seg-0');
      await live.next();
      expect(
        (await sessions.get(live.session.id))!.activeSegmentId,
        'plan-1-seg-1',
      );
    });

    test('entering a timed activity prepares an idle interval', () async {
      final live = await begin();
      await live.next();
      await live.next();
      final r = live.timers.interval!.read();
      expect(r.status, IntervalStatus.idle);
      expect(live.timers.interval!.config.work, s(40));
      expect(live.timers.interval!.config.rest, s(20));
      expect(live.timers.interval!.config.rounds, 5);
    });

    test('leaving a timed activity stops its interval', () async {
      final live = await begin();
      await live.next();
      await live.next();
      await live.startInterval();
      await live.back();
      expect(live.timers.interval, isNull);
    });

    test('returning to a timed activity resets its interval', () async {
      final live = await begin();
      await live.next();
      await live.next();
      await live.startInterval();
      clock.advance(s(50));
      expect(live.timers.interval!.read().phase, IntervalPhase.rest);

      await live.back();
      await live.next();
      final r = live.timers.interval!.read();
      expect(r.status, IntervalStatus.idle);
      expect(r.elapsed, Duration.zero);
    });

    test('navigation never moves the master deadline', () async {
      final live = await begin();
      final deadline = live.timers.master.deadlineWall;
      clock.advance(const Duration(minutes: 3));
      await live.next();
      await live.next();
      await live.back();
      await live.back();
      expect(live.timers.master.deadlineWall, deadline);
      expect(
        live.timers.master.read(clock).elapsed,
        const Duration(minutes: 3),
      );
    });

    test('a stale next from an old screen is ignored', () async {
      final live = await begin();
      await live.next(fromActivityId: ssh);
      await live.next(fromActivityId: ssh);
      expect(live.current!.id, mosey);
    });
  });

  group('double taps', () {
    test('two quick unguarded next calls both apply, in order', () async {
      final live = await begin();
      unawaited(live.next());
      await live.next();
      expect(live.current!.id, burpees);
      final saved = (await sessions.get(live.session.id))!;
      expect(saved.activeActivityId, burpees);
    });

    test('two quick guarded next calls move only once', () async {
      final live = await begin();
      unawaited(live.next(fromActivityId: ssh));
      await live.next(fromActivityId: ssh);
      expect(live.current!.id, mosey);
      final saved = (await sessions.get(live.session.id))!;
      expect(saved.activeActivityId, mosey);
    });

    test(
      'overlapping operations are applied in order even if a save is slow',
      () async {
        final live = await LiveSession.start(
          planId: 'plan-1',
          sessions: SlowFirstSave(sessions),
          clock: clock,
        );
        final first = live.next();
        final second = live.back();
        await Future.wait([first, second]);

        expect(live.current!.id, ssh);
        expect(live.session.activeActivityId, ssh);
        expect((await sessions.get(live.session.id))!.activeActivityId, ssh);
      },
    );

    test('ending twice at once finishes the session once', () async {
      final live = await begin();
      unawaited(live.complete());
      await live.complete();
      expect(live.session.status, SessionStatus.completed);
      expect(
        (await sessions.get(live.session.id))!.status,
        SessionStatus.completed,
      );
    });
  });

  group('interval controls', () {
    Future<LiveSession> atBurpees() async {
      final live = await begin();
      await live.next();
      await live.next();
      return live;
    }

    test('start, pause, resume, skip, and reset drive the interval', () async {
      final live = await atBurpees();
      await live.startInterval();
      clock.advance(s(10));
      await live.pauseInterval();
      clock.advance(s(100));
      expect(live.timers.interval!.read().remainingInPhase, s(30));
      await live.resumeInterval();
      await live.skipPhase();
      expect(live.timers.interval!.read().phase, IntervalPhase.rest);
      await live.resetInterval();
      expect(live.timers.interval!.read().status, IntervalStatus.idle);
    });

    test('controls do nothing on an activity without an interval', () async {
      final live = await begin();
      await live.startInterval();
      await live.skipPhase();
      expect(live.timers.interval, isNull);
    });

    test('interval state is saved', () async {
      final live = await atBurpees();
      await live.startInterval();
      final saved = (await sessions.get(live.session.id))!;
      expect(saved.intervalTimerState!['status'], 'running');
    });

    test('interval controls never move the master deadline', () async {
      final live = await atBurpees();
      final deadline = live.timers.master.deadlineWall;
      await live.startInterval();
      clock.advance(s(20));
      await live.pauseInterval();
      await live.resumeInterval();
      await live.skipPhase();
      await live.resetInterval();
      expect(live.timers.master.deadlineWall, deadline);
    });
  });

  group('audibles', () {
    test('editing an activity changes only the session copy', () async {
      final live = await begin();
      final savedPlan = (await plans.get('plan-1'))!;

      await live.editActivity(
        live.current!.copyWith(details: const RepsDetails(repetitions: 50)),
      );

      expect((live.current!.details as RepsDetails).repetitions, 50);
      final stored = (await sessions.get(live.session.id))!;
      expect(
        (stored.workingPlan.segments[0].activities[0].details as RepsDetails)
            .repetitions,
        50,
      );
      expect(stored.planSnapshot, savedPlan);
      expect(await plans.get('plan-1'), savedPlan);
    });

    test('adding an activity appears in order and is saved', () async {
      final live = await begin();
      await live.addActivity(
        'plan-1-seg-0',
        activity('extra', 'Plank'),
        index: 1,
      );
      await live.next();
      expect(live.current!.name, 'Plank');
      expect(live.upcoming!.id, mosey);
      final stored = (await sessions.get(live.session.id))!;
      expect(stored.workingPlan.segments[0].activities.map((a) => a.name), [
        'SSH',
        'Plank',
        'Mosey',
      ]);
    });

    test('removing the current activity moves to the next one', () async {
      final live = await begin();
      await live.next();
      await live.removeActivity(mosey);
      expect(live.current!.id, burpees);
      expect(live.timers.interval, isNotNull);
    });

    test('removing the last activity moves back to the previous one', () async {
      final live = await begin();
      await live.next();
      await live.next();
      await live.removeActivity(burpees);
      expect(live.current!.id, mosey);
      expect(live.timers.interval, isNull);
    });

    test('removing every activity leaves nothing current', () async {
      final live = await begin();
      await live.removeActivity(ssh);
      await live.removeActivity(mosey);
      await live.removeActivity(burpees);
      expect(live.current, isNull);
      expect(live.upcoming, isNull);
    });

    test('removing another activity keeps the current one', () async {
      final live = await begin();
      await live.next();
      await live.removeActivity(ssh);
      expect(live.current!.id, mosey);
      expect(live.hasPrevious, isFalse);
    });

    test('editing the current timed activity resets its interval', () async {
      final live = await begin();
      await live.next();
      await live.next();
      await live.startInterval();
      clock.advance(s(30));

      await live.editActivity(
        live.current!.copyWith(
          details: const TimedDetails(
            workSeconds: 30,
            restSeconds: 10,
            rounds: 4,
          ),
        ),
      );

      final interval = live.timers.interval!;
      expect(interval.read().status, IntervalStatus.idle);
      expect(interval.config.work, s(30));
      expect(interval.config.rounds, 4);
    });

    test(
      'turning the current activity into a non-timed one drops the interval',
      () async {
        final live = await begin();
        await live.next();
        await live.next();
        await live.editActivity(
          live.current!.copyWith(details: const RepsDetails(repetitions: 20)),
        );
        expect(live.timers.interval, isNull);
      },
    );

    test('an invalid edit is rejected and changes nothing', () async {
      final live = await begin();
      final before = live.session.workingPlan;
      await expectLater(
        live.editActivity(
          live.current!.copyWith(details: const RepsDetails(repetitions: 0)),
        ),
        throwsA(isA<PlanValidationException>()),
      );
      expect(live.session.workingPlan, before);
      expect((await sessions.get(live.session.id))!.workingPlan, before);
    });

    test('editing an unknown activity fails', () async {
      final live = await begin();
      await expectLater(
        live.editActivity(activity('nope', 'Ghost')),
        throwsStateError,
      );
    });

    test('audibles never move the master deadline', () async {
      final live = await begin();
      final deadline = live.timers.master.deadlineWall;
      clock.advance(const Duration(minutes: 5));
      await live.addActivity('plan-1-seg-1', activity('e', 'Plank'));
      await live.removeActivity(mosey);
      await live.editActivity(live.current!.copyWith(name: 'Renamed'));
      expect(live.timers.master.deadlineWall, deadline);
      expect(
        live.timers.master.read(clock).elapsed,
        const Duration(minutes: 5),
      );
    });

    test('the saved plan is untouched after a full session of edits', () async {
      final savedPlan = (await plans.get('plan-1'))!;
      final live = await begin();
      await live.next();
      await live.editActivity(live.current!.copyWith(name: 'Changed'));
      await live.addActivity('plan-1-seg-0', activity('e', 'Plank'));
      await live.removeActivity(ssh);
      await live.complete();
      expect(await plans.get('plan-1'), savedPlan);
      expect((await sessions.get(live.session.id))!.planSnapshot, savedPlan);
    });
  });

  group('ending', () {
    test(
      'complete records the status and frees the slot for a new session',
      () async {
        final live = await begin();
        await live.complete();
        expect(live.session.status, SessionStatus.completed);
        expect(await sessions.findActive(), isNull);
        expect(await begin(), isA<LiveSession>());
      },
    );

    test('endEarly records endedEarly', () async {
      final live = await begin();
      await live.endEarly();
      expect(live.session.status, SessionStatus.endedEarly);
    });

    test('ending again, even differently, changes nothing', () async {
      final live = await begin();
      await live.complete();
      await live.complete();
      await live.endEarly();
      expect(live.session.status, SessionStatus.completed);
      expect(
        (await sessions.get(live.session.id))!.status,
        SessionStatus.completed,
      );
    });

    test('navigation and interval controls do nothing after the end', () async {
      final live = await begin();
      await live.complete();
      await live.next();
      await live.startInterval();
      expect(live.current!.id, ssh);
    });

    test('edits after the end are rejected', () async {
      final live = await begin();
      await live.complete();
      await expectLater(
        live.editActivity(live.current!.copyWith(name: 'Late')),
        throwsStateError,
      );
      await expectLater(live.removeActivity(ssh), throwsStateError);
    });

    test('the master clock can run past the deadline without ending', () async {
      final live = await begin();
      clock.advance(const Duration(minutes: 50));
      final master = live.timers.master.read(clock);
      expect(master.isExpired, isTrue);
      expect(live.session.status, SessionStatus.running);
    });
  });

  group('recover', () {
    test('returns null when nothing is running', () async {
      expect(await recover(), isNull);
    });

    test('returns null after the session ended', () async {
      final live = await begin();
      await live.complete();
      expect(await recover(), isNull);
    });

    test('restores position, edits, master, and a running interval', () async {
      final live = await begin();
      await live.editActivity(
        live.current!.copyWith(details: const RepsDetails(repetitions: 30)),
      );
      await live.next();
      await live.next();
      await live.startInterval();
      clock.advance(s(30));

      clock.suspend(s(60));
      clock.restartProcess();

      final back = (await recover())!;
      expect(back.session.id, live.session.id);
      expect(back.current!.id, burpees);
      expect(
        (back.session.workingPlan.segments[0].activities[0].details
                as RepsDetails)
            .repetitions,
        30,
      );
      expect(back.timers.master.read(clock).elapsed, s(90));
      // 90 s into 40/20 x5: round 2 work, 30 s in.
      final r = back.timers.interval!.read();
      expect(r.status, IntervalStatus.running);
      expect(r.round, 2);
      expect(r.phase, IntervalPhase.work);
      expect(r.remainingInPhase, s(10));
    });

    test('a paused interval stays paused after recovery', () async {
      final live = await begin();
      await live.next();
      await live.next();
      await live.startInterval();
      clock.advance(s(10));
      await live.pauseInterval();

      clock.suspend(const Duration(hours: 1));
      clock.restartProcess();

      final back = (await recover())!;
      final r = back.timers.interval!.read();
      expect(r.status, IntervalStatus.paused);
      expect(r.remainingInPhase, s(30));
    });

    test('a recovered session can be ended', () async {
      await begin();
      clock.restartProcess();
      final back = (await recover())!;
      await back.endEarly();
      expect(back.session.status, SessionStatus.endedEarly);
      expect(await sessions.findActive(), isNull);
    });

    test('a recovered session keeps navigating and saving', () async {
      await begin();
      clock.restartProcess();
      final back = (await recover())!;
      await back.next();
      expect((await sessions.get(back.session.id))!.activeActivityId, mosey);
    });

    test('recovers a session whose plan was deleted', () async {
      final live = await begin();
      await plans.delete('plan-1');
      final back = (await recover())!;
      expect(back.session.id, live.session.id);
      expect(back.session.sourcePlanId, isNull);
      expect(back.current!.id, ssh);
    });
  });
}
