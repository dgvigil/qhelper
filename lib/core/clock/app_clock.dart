/// Time source for all timer logic (ADR-0003).
///
/// [now] is wall-clock time and survives process death. [elapsed] is monotonic
/// time since an arbitrary origin; it is immune to device clock changes but
/// may stop while the device is asleep and resets when the process restarts.
abstract interface class AppClock {
  DateTime get now;
  Duration get elapsed;
}

class SystemClock implements AppClock {
  SystemClock() {
    _stopwatch.start();
  }

  final Stopwatch _stopwatch = Stopwatch();

  @override
  DateTime get now => DateTime.now().toUtc();

  @override
  Duration get elapsed => _stopwatch.elapsed;
}
