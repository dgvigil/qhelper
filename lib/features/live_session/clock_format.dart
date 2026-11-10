/// Countdown text: m:ss, or h:mm:ss from one hour. Partial seconds round up
/// so the display never reads 0:00 while time remains.
String formatCountdown(Duration d) {
  final totalMs = d.inMilliseconds;
  final seconds = totalMs <= 0 ? 0 : (totalMs + 999) ~/ 1000;
  return _clock(seconds);
}

/// Time past the deadline, counting up: +m:ss.
String formatOvertime(Duration d) => '+${_clock(d.inSeconds)}';

String _clock(int totalSeconds) {
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  final s = totalSeconds % 60;
  final ss = s.toString().padLeft(2, '0');
  if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$ss';
  return '$m:$ss';
}

/// Coarse wording for screen readers, so the label changes once a minute
/// instead of every second.
String spokenDuration(Duration d) {
  if (d <= Duration.zero) return 'no time';
  final minutes = (d.inSeconds + 59) ~/ 60;
  if (d < const Duration(minutes: 1)) return 'less than a minute';
  return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
}
