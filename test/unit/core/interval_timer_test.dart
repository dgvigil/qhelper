import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/core/timer/interval_timer.dart';

import '../../fixtures/fake_clock.dart';

Duration s(int seconds) => Duration(seconds: seconds);

IntervalConfig config({int work = 40, int rest = 20, int rounds = 3}) =>
    IntervalConfig(work: s(work), rest: s(rest), rounds: rounds);

void main() {
  late FakeClock clock;

  setUp(() => clock = FakeClock());

  IntervalTimer started({IntervalConfig? cfg}) {
    final t = IntervalTimer(cfg ?? config(), clock);
    t.start();
    return t;
  }

  group('config', () {
    test('rejects non-positive work, negative rest, and zero rounds', () {
      expect(() => config(work: 0), throwsArgumentError);
      expect(() => config(rest: -1), throwsArgumentError);
      expect(() => config(rounds: 0), throwsArgumentError);
    });

    test('total excludes a rest after the final work period', () {
      // 3 work + 2 rest = 120 + 40
      expect(config().total, s(160));
      expect(config(rounds: 1).total, s(40));
    });
  });

  group('phases', () {
    test('is idle until started', () {
      final t = IntervalTimer(config(), clock);
      expect(t.read().status, IntervalStatus.idle);
      clock.advance(s(30));
      expect(t.read().status, IntervalStatus.idle);
      expect(t.read().elapsed, Duration.zero);
    });

    test('begins with round 1 work', () {
      final r = started().read();
      expect(r.status, IntervalStatus.running);
      expect(r.phase, IntervalPhase.work);
      expect(r.round, 1);
      expect(r.remainingInPhase, s(40));
    });

    test('moves from work to rest to the next round', () {
      final t = started();
      clock.advance(s(40));
      var r = t.read();
      expect(r.phase, IntervalPhase.rest);
      expect(r.round, 1);
      expect(r.remainingInPhase, s(20));

      clock.advance(s(25));
      r = t.read();
      expect(r.phase, IntervalPhase.work);
      expect(r.round, 2);
      expect(r.remainingInPhase, s(35));
    });

    test('has no rest after the last work period', () {
      final t = started(cfg: config(rounds: 2));
      clock.advance(s(40 + 20 + 40));
      final r = t.read();
      expect(r.status, IntervalStatus.finished);
      expect(r.phase, isNull);
    });

    test('skips zero-length rests', () {
      final t = started(cfg: config(rest: 0));
      clock.advance(s(40));
      final r = t.read();
      expect(r.phase, IntervalPhase.work);
      expect(r.round, 2);
    });

    test('a single round is one work period then finished', () {
      final t = started(cfg: config(rounds: 1));
      clock.advance(s(39));
      expect(t.read().status, IntervalStatus.running);
      clock.advance(s(1));
      expect(t.read().status, IntervalStatus.finished);
    });

    test('stays finished with zero remaining as time passes', () {
      final t = started(cfg: config(rounds: 1));
      clock.advance(s(500));
      final r = t.read();
      expect(r.status, IntervalStatus.finished);
      expect(r.remainingInPhase, Duration.zero);
      expect(r.elapsed, s(40));
    });
  });

  group('controls', () {
    test('pause freezes the reading and resume continues', () {
      final t = started();
      clock.advance(s(10));
      t.pause();
      clock.advance(s(300));
      expect(t.read().status, IntervalStatus.paused);
      expect(t.read().remainingInPhase, s(30));
      t.resume();
      clock.advance(s(5));
      expect(t.read().remainingInPhase, s(25));
    });

    test('start while paused resumes', () {
      final t = started();
      clock.advance(s(10));
      t.pause();
      t.start();
      expect(t.read().status, IntervalStatus.running);
    });

    test('pause, resume, and start are safe to repeat', () {
      final t = started();
      t.start();
      clock.advance(s(10));
      t.pause();
      t.pause();
      clock.advance(s(10));
      t.resume();
      t.resume();
      clock.advance(s(10));
      expect(t.read().elapsed, s(20));
    });

    test('reset returns to idle at the start of round 1', () {
      final t = started();
      clock.advance(s(75));
      t.reset();
      var r = t.read();
      expect(r.status, IntervalStatus.idle);
      expect(r.elapsed, Duration.zero);
      t.start();
      r = t.read();
      expect(r.round, 1);
      expect(r.phase, IntervalPhase.work);
      expect(r.remainingInPhase, s(40));
    });

    test('skipPhase jumps to the next phase while running', () {
      final t = started();
      clock.advance(s(10));
      t.skipPhase();
      var r = t.read();
      expect(r.phase, IntervalPhase.rest);
      expect(r.remainingInPhase, s(20));
      clock.advance(s(5));
      expect(t.read().remainingInPhase, s(15));
    });

    test('skipPhase while paused stays paused at the next phase', () {
      final t = started();
      clock.advance(s(10));
      t.pause();
      t.skipPhase();
      final r = t.read();
      expect(r.status, IntervalStatus.paused);
      expect(r.phase, IntervalPhase.rest);
      expect(r.remainingInPhase, s(20));
    });

    test('skipPhase on the last phase finishes the timer', () {
      final t = started(cfg: config(rounds: 1));
      t.skipPhase();
      expect(t.read().status, IntervalStatus.finished);
    });

    test('skipPhase does nothing while idle or finished', () {
      final idle = IntervalTimer(config(), clock);
      idle.skipPhase();
      expect(idle.read().status, IntervalStatus.idle);
      expect(idle.read().elapsed, Duration.zero);
    });
  });
}
