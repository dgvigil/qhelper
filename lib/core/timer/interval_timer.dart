import 'package:q_helper/core/clock/app_clock.dart';
import 'package:q_helper/core/timer/time_anchor.dart';

enum IntervalStatus { idle, running, paused, finished }

enum IntervalPhase { work, rest }

/// A sound or haptic moment for the UI to play.
enum IntervalCue { workStart, restStart, finished }

class IntervalObservation {
  const IntervalObservation({
    required this.reading,
    required this.cue,
    required this.missedTransitions,
  });

  final IntervalReading reading;

  /// Set only for a transition seen on time. Missed cues are never replayed.
  final IntervalCue? cue;

  /// Phase starts crossed since the last observation without a cue.
  final int missedTransitions;
}

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
  IntervalTimer(
    this.config,
    this._clock, {
    this.cueGrace = const Duration(seconds: 2),
  });

  factory IntervalTimer.fromJson(Map<String, Object?> json, AppClock clock) {
    final timer = IntervalTimer(
      IntervalConfig(
        work: Duration(milliseconds: json['workMs']! as int),
        rest: Duration(milliseconds: json['restMs']! as int),
        rounds: json['rounds']! as int,
      ),
      clock,
    );
    timer._status = IntervalStatus.values.byName(json['status']! as String);
    timer._accumulated = Duration(milliseconds: json['accumulatedMs']! as int);
    timer._lastObservedIndex = json['lastObservedIndex']! as int;
    final startedAt = json['runStartedAtWall'] as String?;
    if (startedAt != null) {
      timer._runAnchor = TimeAnchor.fromWall(clock, DateTime.parse(startedAt));
    }
    return timer;
  }

  final IntervalConfig config;
  final AppClock _clock;

  /// How late a transition may be observed and still play its cue.
  final Duration cueGrace;

  IntervalStatus _status = IntervalStatus.idle;
  Duration _accumulated = Duration.zero;
  TimeAnchor? _runAnchor;
  int _lastObservedIndex = -1;

  /// Active time consumed, not clamped to the total.
  Duration _rawElapsed() {
    final anchor = _runAnchor;
    final running = anchor == null || _status != IntervalStatus.running
        ? Duration.zero
        : anchor.elapsed(_clock);
    return _accumulated + running;
  }

  Duration _activeElapsed() {
    final raw = _rawElapsed();
    return raw > config.total ? config.total : raw;
  }

  Map<String, Object?> toJson() => {
    'workMs': config.work.inMilliseconds,
    'restMs': config.rest.inMilliseconds,
    'rounds': config.rounds,
    'status': _status.name,
    'accumulatedMs': _accumulated.inMilliseconds,
    'runStartedAtWall': _status == IntervalStatus.running
        ? _runAnchor?.wall.toUtc().toIso8601String()
        : null,
    'lastObservedIndex': _lastObservedIndex,
  };

  /// Reads the timer and reports the cue for a phase change seen on time.
  /// Transitions skipped over (suspension, late UI tick) are counted in
  /// [IntervalObservation.missedTransitions] and get no cue.
  IntervalObservation observe() {
    final reading = read();
    if (reading.status != IntervalStatus.running &&
        reading.status != IntervalStatus.finished) {
      return IntervalObservation(
        reading: reading,
        cue: null,
        missedTransitions: 0,
      );
    }
    final index = reading.segmentIndex;
    if (index == _lastObservedIndex) {
      return IntervalObservation(
        reading: reading,
        cue: null,
        missedTransitions: 0,
      );
    }
    final segments = config.segments;
    final phaseStart = index < segments.length
        ? segments[index].start
        : config.total;
    final lateness = _rawElapsed() - phaseStart;
    final crossed = index - _lastObservedIndex;
    _lastObservedIndex = index;

    final IntervalCue? cue = lateness > cueGrace
        ? null
        : switch (reading.phase) {
            IntervalPhase.work => IntervalCue.workStart,
            IntervalPhase.rest => IntervalCue.restStart,
            null => IntervalCue.finished,
          };
    return IntervalObservation(
      reading: reading,
      cue: cue,
      missedTransitions: cue == null ? crossed : crossed - 1,
    );
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
    _lastObservedIndex = -1;
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
