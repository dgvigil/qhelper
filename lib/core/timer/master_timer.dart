import 'package:q_helper/core/clock/app_clock.dart';
import 'package:q_helper/core/timer/time_anchor.dart';

class MasterReading {
  const MasterReading({required this.elapsed, required this.duration});

  final Duration elapsed;
  final Duration duration;

  /// Time left, never negative.
  Duration get remaining =>
      elapsed >= duration ? Duration.zero : duration - elapsed;

  bool get isExpired => elapsed >= duration;

  /// Time past the deadline, zero until the deadline passes.
  Duration get overtime => isExpired ? elapsed - duration : Duration.zero;
}

/// Workout-wide countdown with a fixed deadline. It has no pause, extend, or
/// skip operations, so nothing can move the deadline. Reaching it only
/// switches the reading to overtime; the workout is never ended automatically.
class MasterTimer {
  MasterTimer._(this.duration, this._anchor);

  factory MasterTimer.start(AppClock clock, Duration duration) {
    if (duration <= Duration.zero) {
      throw ArgumentError.value(duration, 'duration', 'must be positive');
    }
    return MasterTimer._(duration, TimeAnchor.capture(clock));
  }

  factory MasterTimer.fromJson(Map<String, Object?> json, AppClock clock) {
    final startedAt = DateTime.parse(json['startedAtWall']! as String);
    return MasterTimer._(
      Duration(milliseconds: json['durationMs']! as int),
      TimeAnchor.fromWall(clock, startedAt),
    );
  }

  final Duration duration;
  final TimeAnchor _anchor;

  DateTime get deadlineWall => _anchor.wall.add(duration);

  MasterReading read(AppClock clock) =>
      MasterReading(elapsed: _anchor.elapsed(clock), duration: duration);

  Map<String, Object?> toJson() => {
    'durationMs': duration.inMilliseconds,
    'startedAtWall': _anchor.wall.toUtc().toIso8601String(),
  };
}
