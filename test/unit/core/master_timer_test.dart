import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/core/timer/master_timer.dart';

import '../../fixtures/fake_clock.dart';

const fortyFive = Duration(minutes: 45);

void main() {
  late FakeClock clock;

  setUp(() => clock = FakeClock());

  group('countdown', () {
    test('starts with the full duration remaining', () {
      final timer = MasterTimer.start(clock, fortyFive);
      final r = timer.read(clock);
      expect(r.remaining, fortyFive);
      expect(r.elapsed, Duration.zero);
      expect(r.isExpired, isFalse);
      expect(r.overtime, Duration.zero);
    });

    test('counts down as time passes', () {
      final timer = MasterTimer.start(clock, fortyFive);
      clock.advance(const Duration(minutes: 10, seconds: 30));
      expect(
        timer.read(clock).remaining,
        const Duration(minutes: 34, seconds: 30),
      );
    });

    test('is exactly zero at the deadline, expired, with no overtime', () {
      final timer = MasterTimer.start(clock, fortyFive);
      clock.advance(fortyFive);
      final r = timer.read(clock);
      expect(r.remaining, Duration.zero);
      expect(r.isExpired, isTrue);
      expect(r.overtime, Duration.zero);
    });

    test('shows overtime after the deadline and never goes negative', () {
      final timer = MasterTimer.start(clock, fortyFive);
      clock.advance(fortyFive + const Duration(minutes: 2, seconds: 5));
      final r = timer.read(clock);
      expect(r.remaining, Duration.zero);
      expect(r.overtime, const Duration(minutes: 2, seconds: 5));
    });

    test('has a fixed wall-clock deadline', () {
      final start = clock.now;
      final timer = MasterTimer.start(clock, fortyFive);
      clock.advance(const Duration(minutes: 20));
      expect(timer.deadlineWall, start.add(fortyFive));
    });

    test('rejects a non-positive duration', () {
      expect(
        () => MasterTimer.start(clock, Duration.zero),
        throwsArgumentError,
      );
    });
  });

  group('suspension and clock changes', () {
    test('keeps counting through a 10-minute suspension', () {
      final timer = MasterTimer.start(clock, fortyFive);
      clock.advance(const Duration(minutes: 5));
      clock.suspend(const Duration(minutes: 10));
      expect(timer.read(clock).remaining, const Duration(minutes: 30));
    });

    test('does not gain time when the device clock moves backwards', () {
      final timer = MasterTimer.start(clock, fortyFive);
      clock.advance(const Duration(minutes: 10));
      clock.setWall(clock.now.subtract(const Duration(hours: 1)));
      expect(timer.read(clock).remaining, const Duration(minutes: 35));
    });

    test(
      'limitation: a forward device clock change shortens the countdown',
      () {
        final timer = MasterTimer.start(clock, fortyFive);
        clock.advance(const Duration(minutes: 10));
        clock.setWall(clock.now.add(const Duration(minutes: 15)));
        expect(timer.read(clock).remaining, const Duration(minutes: 20));
      },
    );
  });

  group('persistence', () {
    test('restores after process death using wall-clock time', () {
      final timer = MasterTimer.start(clock, fortyFive);
      clock.advance(const Duration(minutes: 12));
      final saved = timer.toJson();

      clock.suspend(const Duration(minutes: 8));
      clock.restartProcess();

      final restored = MasterTimer.fromJson(saved, clock);
      expect(restored.read(clock).remaining, const Duration(minutes: 25));
      expect(restored.deadlineWall, timer.deadlineWall);

      clock.advance(const Duration(minutes: 5));
      expect(restored.read(clock).remaining, const Duration(minutes: 20));
    });

    test('restores into overtime when the deadline passed while closed', () {
      final timer = MasterTimer.start(clock, fortyFive);
      final saved = timer.toJson();
      clock.suspend(const Duration(minutes: 50));
      clock.restartProcess();
      final r = MasterTimer.fromJson(saved, clock).read(clock);
      expect(r.isExpired, isTrue);
      expect(r.overtime, const Duration(minutes: 5));
    });
  });
}
