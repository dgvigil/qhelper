import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/core/timer/interval_timer.dart';

import '../../fixtures/fake_clock.dart';

Duration s(int seconds) => Duration(seconds: seconds);

IntervalConfig config({int work = 40, int rest = 20, int rounds = 3}) =>
    IntervalConfig(work: s(work), rest: s(rest), rounds: rounds);

void main() {
  longRunTests();

  late FakeClock clock;

  setUp(() => clock = FakeClock());

  IntervalTimer started({IntervalConfig? cfg}) {
    final t = IntervalTimer(cfg ?? config(), clock);
    t.start();
    return t;
  }

  group('cues', () {
    test('first observation after start cues the opening work period', () {
      final t = started();
      final o = t.observe();
      expect(o.cue, IntervalCue.workStart);
      expect(o.missedTransitions, 0);
    });

    test('a repeated observation in the same phase gives no cue', () {
      final t = started();
      t.observe();
      clock.advance(s(10));
      expect(t.observe().cue, isNull);
    });

    test('each on-time transition cues once', () {
      final t = started();
      t.observe();
      clock.advance(s(40));
      expect(t.observe().cue, IntervalCue.restStart);
      expect(t.observe().cue, isNull);
      clock.advance(s(20));
      expect(t.observe().cue, IntervalCue.workStart);
    });

    test('a slightly late observation still cues', () {
      final t = started();
      t.observe();
      clock.advance(s(41));
      final o = t.observe();
      expect(o.cue, IntervalCue.restStart);
      expect(o.missedTransitions, 0);
    });

    test('the end of the last round cues finished once', () {
      final t = started(cfg: config(rounds: 1));
      t.observe();
      clock.advance(s(40));
      expect(t.observe().cue, IntervalCue.finished);
      expect(t.observe().cue, isNull);
    });

    test('observing while idle or paused never cues', () {
      final idle = IntervalTimer(config(), clock);
      expect(idle.observe().cue, isNull);

      final t = started();
      t.observe();
      clock.advance(s(10));
      t.pause();
      clock.advance(s(100));
      expect(t.observe().cue, isNull);
    });
  });

  group('suspension', () {
    test('a 10-minute suspension resolves to the correct phase, no cue', () {
      final t = started(cfg: config(rounds: 20));
      t.observe();
      clock.advance(s(5));
      clock.suspend(s(600));

      final o = t.observe();
      // 605 s elapsed: ten full 60 s cycles, then 5 s into round 11 work.
      expect(o.reading.status, IntervalStatus.running);
      expect(o.reading.phase, IntervalPhase.work);
      expect(o.reading.round, 11);
      expect(o.reading.remainingInPhase, s(35));
      expect(o.cue, isNull, reason: 'missed cues are never replayed');
      expect(o.missedTransitions, 20);
    });

    test(
      'an interval that ended during suspension reports finished, no cue',
      () {
        final t = started(cfg: config(rounds: 2));
        t.observe();
        clock.suspend(s(600));
        final o = t.observe();
        expect(o.reading.status, IntervalStatus.finished);
        expect(o.cue, isNull);
        expect(o.missedTransitions, 3);
      },
    );

    test('a paused interval stays paused through suspension', () {
      final t = started();
      t.observe();
      clock.advance(s(10));
      t.pause();
      clock.suspend(s(600));
      final o = t.observe();
      expect(o.reading.status, IntervalStatus.paused);
      expect(o.reading.remainingInPhase, s(30));
      expect(o.cue, isNull);
      expect(o.missedTransitions, 0);

      t.resume();
      clock.advance(s(30));
      expect(t.read().phase, IntervalPhase.rest);
    });

    test('later transitions cue normally after a missed stretch', () {
      final t = started(cfg: config(rounds: 20));
      t.observe();
      clock.suspend(s(605));
      t.observe();
      clock.advance(s(35));
      expect(t.observe().cue, IntervalCue.restStart);
    });
  });

  group('persistence', () {
    test('a running interval restores after process death', () {
      final t = started();
      t.observe();
      clock.advance(s(10));
      final saved = t.toJson();

      clock.suspend(s(45));
      clock.restartProcess();

      final restored = IntervalTimer.fromJson(saved, clock);
      final o = restored.observe();
      // 55 s elapsed: 15 s into the first rest.
      expect(o.reading.status, IntervalStatus.running);
      expect(o.reading.phase, IntervalPhase.rest);
      expect(o.reading.remainingInPhase, s(5));
      expect(o.cue, isNull);
      expect(o.missedTransitions, 1);
    });

    test('a paused interval restores paused with its position', () {
      final t = started();
      clock.advance(s(50));
      t.pause();
      final saved = t.toJson();

      clock.suspend(s(3600));
      clock.restartProcess();

      final restored = IntervalTimer.fromJson(saved, clock);
      final r = restored.read();
      expect(r.status, IntervalStatus.paused);
      expect(r.phase, IntervalPhase.rest);
      expect(r.remainingInPhase, s(10));
    });

    test('an idle interval restores idle', () {
      final saved = IntervalTimer(config(), clock).toJson();
      final restored = IntervalTimer.fromJson(saved, clock);
      expect(restored.read().status, IntervalStatus.idle);
      expect(restored.config.rounds, 3);
    });

    test('a finished interval restores finished', () {
      final t = started(cfg: config(rounds: 1));
      clock.advance(s(60));
      final restored = IntervalTimer.fromJson(t.toJson(), clock);
      expect(restored.read().status, IntervalStatus.finished);
    });
  });
}

/// Long-run behavior: ticking every 250 ms like the screen does.
void longRunTests() {
  group('long run', () {
    test('a full interval cues every phase exactly once at 250 ms ticks', () {
      final clock = FakeClock();
      final t = IntervalTimer(config(rounds: 10), clock)..start();
      final cues = <IntervalCue>[];
      for (var i = 0; i < 4 * (40 + 20) * 10 + 8; i++) {
        final cue = t.observe().cue;
        if (cue != null) cues.add(cue);
        clock.advance(const Duration(milliseconds: 250));
      }
      expect(cues, [
        for (var r = 1; r <= 10; r++) ...[
          IntervalCue.workStart,
          if (r < 10) IntervalCue.restStart,
        ],
        IntervalCue.finished,
      ]);
    });

    test('hours of ticking stay consistent with the clock', () {
      final clock = FakeClock();
      final t = IntervalTimer(config(rounds: 1000), clock)..start();
      for (var i = 0; i < 3 * 3600; i++) {
        t.observe();
        clock.advance(const Duration(seconds: 1));
      }
      // 3 h = 10800 s; each round is 60 s: 180 rounds done, round 181 begins.
      final r = t.read();
      expect(r.round, 181);
      expect(r.phase, IntervalPhase.work);
      expect(r.remainingInPhase, const Duration(seconds: 40));
    });
  });
}
