import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/core/timer/interval_timer.dart';
import 'package:q_helper/core/timer/master_timer.dart';
import 'package:q_helper/core/timer/session_timers.dart';

import '../../fixtures/fake_clock.dart';

Duration s(int seconds) => Duration(seconds: seconds);

IntervalConfig config({int rounds = 3}) =>
    IntervalConfig(work: s(40), rest: s(20), rounds: rounds);

void main() {
  late FakeClock clock;
  late SessionTimers timers;

  setUp(() {
    clock = FakeClock();
    timers = SessionTimers.start(clock, const Duration(minutes: 45));
  });

  group('master and interval independence', () {
    test('master deadline never moves through any interval operation', () {
      final deadline = timers.master.deadlineWall;

      timers.startInterval(config());
      clock.advance(s(10));
      timers.interval!.pause();
      clock.advance(s(30));
      timers.interval!.resume();
      timers.interval!.skipPhase();
      timers.interval!.reset();
      timers.interval!.start();
      timers.stopInterval();
      timers.startInterval(config(rounds: 10));

      expect(timers.master.deadlineWall, deadline);
    });

    test('master keeps counting while the interval is paused or absent', () {
      timers.startInterval(config());
      clock.advance(s(60));
      timers.interval!.pause();
      clock.advance(const Duration(minutes: 5));
      expect(timers.master.read(clock).elapsed, const Duration(minutes: 6));

      timers.stopInterval();
      clock.advance(const Duration(minutes: 4));
      expect(timers.master.read(clock).elapsed, const Duration(minutes: 10));
    });

    test('an interval ending does not affect the master', () {
      timers.startInterval(config(rounds: 1));
      clock.advance(s(100));
      expect(timers.interval!.read().status, IntervalStatus.finished);
      expect(
        timers.master.read(clock).remaining,
        const Duration(minutes: 45) - s(100),
      );
    });

    test('interval keeps running when the master has expired', () {
      timers.startInterval(config(rounds: 100));
      clock.advance(const Duration(minutes: 46));
      final master = timers.master.read(clock);
      expect(master.isExpired, isTrue);
      expect(master.overtime, const Duration(minutes: 1));
      expect(timers.interval!.read().status, IntervalStatus.running);
    });

    test('replacing the interval starts a fresh one', () {
      timers.startInterval(config());
      clock.advance(s(70));
      timers.startInterval(config(rounds: 5));
      final r = timers.interval!.read();
      expect(r.round, 1);
      expect(r.rounds, 5);
      expect(r.remainingInPhase, s(40));
    });

    test('stopInterval removes the interval', () {
      timers.startInterval(config());
      timers.stopInterval();
      expect(timers.interval, isNull);
    });
  });

  group('persistence', () {
    test('restores both timers after process death', () {
      timers.startInterval(config());
      clock.advance(s(30));
      final saved = timers.toJson();

      clock.suspend(s(100));
      clock.restartProcess();

      final restored = SessionTimers.fromJson(saved, clock);
      expect(restored.master.read(clock).elapsed, const Duration(seconds: 130));
      expect(restored.master.deadlineWall, timers.master.deadlineWall);
      // 130 s into a 40/20 x3 interval: round 3 work, 10 s in.
      final r = restored.interval!.read();
      expect(r.round, 3);
      expect(r.phase, IntervalPhase.work);
      expect(r.remainingInPhase, s(30));
    });

    test('restores a session with no interval', () {
      final restored = SessionTimers.fromJson(timers.toJson(), clock);
      expect(restored.interval, isNull);
      expect(restored.master, isA<MasterTimer>());
    });
  });
}
