import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/features/live_session/clock_format.dart';

void main() {
  group('formatCountdown', () {
    test('shows minutes and seconds', () {
      expect(formatCountdown(const Duration(minutes: 45)), '45:00');
      expect(formatCountdown(const Duration(minutes: 5, seconds: 9)), '5:09');
      expect(formatCountdown(const Duration(seconds: 59)), '0:59');
    });

    test('shows hours past 59 minutes', () {
      expect(
        formatCountdown(const Duration(hours: 1, minutes: 5, seconds: 9)),
        '1:05:09',
      );
      expect(formatCountdown(const Duration(minutes: 60)), '1:00:00');
    });

    test('rounds partial seconds up so it never shows 0:00 early', () {
      expect(formatCountdown(const Duration(milliseconds: 400)), '0:01');
      expect(
        formatCountdown(const Duration(seconds: 4, milliseconds: 1)),
        '0:05',
      );
    });

    test('is 0:00 only at exactly zero', () {
      expect(formatCountdown(Duration.zero), '0:00');
    });
  });

  group('formatOvertime', () {
    test('counts up with a plus sign, rounding down', () {
      expect(
        formatOvertime(const Duration(seconds: 5, milliseconds: 900)),
        '+0:05',
      );
      expect(formatOvertime(const Duration(minutes: 2, seconds: 5)), '+2:05');
      expect(
        formatOvertime(const Duration(hours: 1, minutes: 1, seconds: 1)),
        '+1:01:01',
      );
    });
  });

  test('spokenDuration is whole minutes for a screen reader', () {
    expect(
      spokenDuration(const Duration(minutes: 34, seconds: 30)),
      '35 minutes',
    );
    expect(spokenDuration(const Duration(minutes: 1)), '1 minute');
    expect(spokenDuration(const Duration(seconds: 20)), 'less than a minute');
    expect(spokenDuration(Duration.zero), 'no time');
  });
}
