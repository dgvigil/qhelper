import 'package:q_helper/core/clock/app_clock.dart';
import 'package:q_helper/core/timer/interval_timer.dart';
import 'package:q_helper/core/timer/master_timer.dart';

/// The timers of one live workout: a fixed master countdown and at most one
/// interval timer for the current activity.
///
/// The master timer is created once and exposes no way to change its
/// deadline, so no interval operation (start, pause, skip, reset, replace,
/// stop) can affect it.
class SessionTimers {
  SessionTimers._(this._clock, this.master, this.interval);

  factory SessionTimers.start(AppClock clock, Duration workoutDuration) {
    return SessionTimers._(
      clock,
      MasterTimer.start(clock, workoutDuration),
      null,
    );
  }

  factory SessionTimers.fromJson(Map<String, Object?> json, AppClock clock) {
    final interval = json['interval'] as Map<String, Object?>?;
    return SessionTimers._(
      clock,
      MasterTimer.fromJson(json['master']! as Map<String, Object?>, clock),
      interval == null ? null : IntervalTimer.fromJson(interval, clock),
    );
  }

  final AppClock _clock;
  final MasterTimer master;
  IntervalTimer? interval;

  /// Replaces any current interval with a new one and starts it.
  IntervalTimer startInterval(IntervalConfig config) {
    final timer = IntervalTimer(config, _clock)..start();
    interval = timer;
    return timer;
  }

  void stopInterval() => interval = null;

  Map<String, Object?> toJson() => {
    'master': master.toJson(),
    'interval': interval?.toJson(),
  };
}
