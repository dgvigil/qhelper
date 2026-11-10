import 'package:q_helper/core/clock/app_clock.dart';
import 'package:q_helper/core/timer/time_anchor.dart';

enum IntervalStatus { idle, running, paused, finished }

enum IntervalPhase { work, rest }

class IntervalConfig {
  IntervalConfig({
    required this.work,
    required this.rest,
    required this.rounds,
  }) {
    if (work <= Duration.zero) {
      throw ArgumentError.value(work, 'work', 'must be positive');
    }
    if (rest.isNegative) {
      throw ArgumentError.value(rest, 'rest', 'must not be negative');
    }
    if (rounds <= 0) {
      throw ArgumentError.value(rounds, 'rounds', 'must be positive');
    }
  }

  final Duration work;
  final Duration rest;
  final int rounds;

  /// Work periods plus the rests between them. There is no rest after the
  /// last work period.
  late final List<IntervalSegment> segments = _buildSegments();

  Duration get total => segments.last.end;

  List<IntervalSegment> _buildSegments() {
    final result = <IntervalSegment>[];
    var start = Duration.zero;
    for (var round = 1; round <= rounds; round++) {
      result.add(IntervalSegment(IntervalPhase.work, round, start, work));
      start += work;
      if (round < rounds && rest > Duration.zero) {
        result.add(IntervalSegment(IntervalPhase.rest, round, start, rest));
        start += rest;
      }
    }
    return result;
  }
}

/// One work or rest period on the interval timeline.
class IntervalSegment {
  const IntervalSegment(this.phase, this.round, this.start, this.duration);

  final IntervalPhase phase;
  final int round;
  final Duration start;
  final Duration duration;

  Duration get end => start + duration;
}

class IntervalReading {
  const IntervalReading({
    required this.status,
    required this.elapsed,
    required this.remainingInPhase,
    required this.segmentIndex,
    required this.segment,
    required this.rounds,
  });

  final IntervalStatus status;

  /// Active (running) time consumed, excluding paused time.
  final Duration elapsed;
  final Duration remainingInPhase;

  /// Index into the config's segments; equals the segment count when finished.
  final int segmentIndex;
  final IntervalSegment? segment;
  final int rounds;

  IntervalPhase? get phase => segment?.phase;
  int? get round => segment?.round;
}

/// Work / rest / rounds timer.
///
/// Position is always recomputed from the clock, never counted down tick by
/// tick, so a missed tick or a long suspension resolves to the correct phase.
/// A running timer keeps running while the app is suspended; a paused timer
/// stays paused.
class IntervalTimer {
  IntervalTimer(this.config, this._clock);

  final IntervalConfig config;
  final AppClock _clock;

  IntervalStatus _status = IntervalStatus.idle;
  Duration _accumulated = Duration.zero;
  TimeAnchor? _runAnchor;

  Duration _activeElapsed() {
    final anchor = _runAnchor;
    final running = anchor == null || _status != IntervalStatus.running
        ? Duration.zero
        : anchor.elapsed(_clock);
    final total = _accumulated + running;
    return total > config.total ? config.total : total;
  }

  /// Starts from idle, or resumes when paused. No effect once running or
  /// finished.
  void start() {
    if (_status == IntervalStatus.idle || _status == IntervalStatus.paused) {
      _beginRun();
    }
  }

  void resume() => start();

  void pause() {
    if (read().status != IntervalStatus.running) return;
    _accumulated = _activeElapsed();
    _runAnchor = null;
    _status = IntervalStatus.paused;
  }

  void reset() {
    _status = IntervalStatus.idle;
    _accumulated = Duration.zero;
    _runAnchor = null;
  }

  /// Jumps to the start of the next phase, keeping running or paused state.
  /// Does nothing while idle or finished.
  void skipPhase() {
    final reading = read();
    final segment = reading.segment;
    if (segment == null || reading.status == IntervalStatus.idle) return;
    _accumulated = segment.end;
    if (_status == IntervalStatus.running) {
      _runAnchor = TimeAnchor.capture(_clock);
    }
  }

  IntervalReading read() {
    final elapsed = _activeElapsed();
    final segments = config.segments;
    if (_status != IntervalStatus.idle && elapsed >= config.total) {
      return IntervalReading(
        status: IntervalStatus.finished,
        elapsed: config.total,
        remainingInPhase: Duration.zero,
        segmentIndex: segments.length,
        segment: null,
        rounds: config.rounds,
      );
    }
    final index = segments.lastIndexWhere((s) => s.start <= elapsed);
    final segment = segments[index];
    return IntervalReading(
      status: _status,
      elapsed: elapsed,
      remainingInPhase: segment.end - elapsed,
      segmentIndex: index,
      segment: segment,
      rounds: config.rounds,
    );
  }

  void _beginRun() {
    _runAnchor = TimeAnchor.capture(_clock);
    _status = IntervalStatus.running;
  }
}
