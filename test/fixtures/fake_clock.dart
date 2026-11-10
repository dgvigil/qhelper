import 'package:q_helper/core/clock/app_clock.dart';

/// Controllable clock for tests. Wall time and monotonic time are separate so
/// tests can model suspension (monotonic pauses), clock changes (only wall
/// moves), and process restarts (monotonic resets).
class FakeClock implements AppClock {
  FakeClock({DateTime? wall, this._mono = Duration.zero})
    : _wall = wall ?? DateTime.utc(2026, 11, 10, 5, 30);

  DateTime _wall;
  Duration _mono;

  @override
  DateTime get now => _wall;

  @override
  Duration get elapsed => _mono;

  /// Normal passage of time while the app is active.
  void advance(Duration d) {
    _wall = _wall.add(d);
    _mono += d;
  }

  /// The app is suspended: wall time moves, monotonic time does not (as on
  /// iOS and Android, where the monotonic clock stops during device sleep).
  void suspend(Duration d) {
    _wall = _wall.add(d);
  }

  /// The user or the network changes the device clock.
  void setWall(DateTime wall) {
    _wall = wall;
  }

  /// Process death and relaunch: monotonic time restarts from zero.
  void restartProcess() {
    _mono = Duration.zero;
  }
}
