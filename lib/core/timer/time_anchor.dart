import 'package:q_helper/core/clock/app_clock.dart';

/// A moment on both clocks, used to measure time elapsed since then.
///
/// Elapsed time is the larger of the monotonic and wall-clock differences:
/// - while the app is active both agree;
/// - after device sleep the monotonic clock may lag, so wall time catches up;
/// - if the device clock moves backwards, the monotonic difference wins and
///   the timer cannot gain time.
/// A forward device clock change therefore shortens a countdown. That is a
/// documented limitation, not a bug (ADR-0003).
class TimeAnchor {
  const TimeAnchor({required this.wall, required this.mono});

  factory TimeAnchor.capture(AppClock clock) =>
      TimeAnchor(wall: clock.now, mono: clock.elapsed);

  /// Rebuilds an anchor for a moment recorded earlier as wall-clock time,
  /// for example after the process restarted and monotonic time reset.
  factory TimeAnchor.fromWall(AppClock clock, DateTime wall) {
    final sinceWall = clock.now.difference(wall);
    return TimeAnchor(wall: wall, mono: clock.elapsed - sinceWall);
  }

  final DateTime wall;
  final Duration mono;

  Duration elapsed(AppClock clock) {
    final byMono = clock.elapsed - mono;
    final byWall = clock.now.difference(wall);
    final result = byMono > byWall ? byMono : byWall;
    return result.isNegative ? Duration.zero : result;
  }
}
