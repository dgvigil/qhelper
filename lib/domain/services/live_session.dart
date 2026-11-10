import 'package:q_helper/core/clock/app_clock.dart';
import 'package:q_helper/core/timer/interval_timer.dart';
import 'package:q_helper/core/timer/session_timers.dart';
import 'package:q_helper/domain/models/validation.dart';
import 'package:q_helper/domain/models/workout_activity.dart';
import 'package:q_helper/domain/models/workout_session.dart';
import 'package:q_helper/domain/repositories/session_repository.dart';
import 'package:q_helper/domain/services/plan_edits.dart' as edits;

/// The state machine for leading one workout.
///
/// Holds the running session, its timers, and the current position. Every
/// change is saved through the [SessionRepository] so the workout can be
/// recovered after the app closes. Operations run one at a time, in call
/// order, so quick repeated taps cannot interleave or corrupt state.
///
/// - Next / Back move between activities and never wrap. Leaving an activity
///   discards its interval; entering a timed activity prepares a fresh one.
/// - Edits (audibles) change only the session's working copy of the plan.
/// - Nothing here can move the master deadline.
/// - After the session ends, navigation and controls do nothing; edits throw.
class LiveSession {
  LiveSession._(this._sessions, this._session, this.timers);

  /// Starts a new session from a saved plan. Throws `StateError` if the plan
  /// is missing or another session is running.
  static Future<LiveSession> start({
    required String planId,
    required SessionRepository sessions,
    required AppClock clock,
  }) async {
    final session = await sessions.start(planId);
    final timers = SessionTimers.start(
      clock,
      Duration(seconds: session.workingPlan.targetDurationSeconds),
    );
    final live = LiveSession._(sessions, session, timers);
    live._enter(edits.flattenActivities(session.workingPlan).firstOrNull);
    await live._save();
    return live;
  }

  /// Rebuilds the running session after a relaunch, or null if none is running.
  static Future<LiveSession?> recover({
    required SessionRepository sessions,
    required AppClock clock,
  }) async {
    final session = await sessions.findActive();
    if (session == null) return null;

    final master =
        session.masterTimerState ??
        {
          'durationMs': Duration(
            seconds: session.workingPlan.targetDurationSeconds,
          ).inMilliseconds,
          'startedAtWall': session.startedAtWall.toIso8601String(),
        };
    final timers = SessionTimers.fromJson({
      'master': master,
      'interval': session.intervalTimerState,
    }, clock);

    final live = LiveSession._(sessions, session, timers);
    final all = edits.flattenActivities(session.workingPlan);
    final saved = all.where((a) => a.id == session.activeActivityId);
    live._currentId = (saved.isNotEmpty ? saved.first : all.firstOrNull)?.id;

    final current = live.current;
    final details = current?.details;
    if (details is! TimedDetails) {
      timers.stopInterval();
    } else if (timers.interval == null) {
      live._enter(current);
    }
    return live;
  }

  final SessionRepository _sessions;
  final SessionTimers timers;

  WorkoutSession _session;
  String? _currentId;
  Future<void> _tail = Future.value();

  WorkoutSession get session => _session;
  bool get isRunning => _session.status == SessionStatus.running;

  List<WorkoutActivity> get _all =>
      edits.flattenActivities(_session.workingPlan);

  int get _index => _all.indexWhere((a) => a.id == _currentId);

  WorkoutActivity? get current {
    final i = _index;
    return i < 0 ? null : _all[i];
  }

  /// The activity after the current one, if any.
  WorkoutActivity? get upcoming {
    final i = _index;
    final all = _all;
    return i < 0 || i + 1 >= all.length ? null : all[i + 1];
  }

  bool get hasPrevious => _index > 0;

  // ---- navigation --------------------------------------------------------

  /// Moves to the next activity. If [fromActivityId] is given and is no longer
  /// current (a stale or repeated tap), nothing happens.
  Future<void> next({String? fromActivityId}) =>
      _move(1, fromActivityId: fromActivityId);

  Future<void> back({String? fromActivityId}) =>
      _move(-1, fromActivityId: fromActivityId);

  Future<void> _move(int step, {String? fromActivityId}) {
    return _serial(() async {
      if (!isRunning) return;
      if (fromActivityId != null && fromActivityId != _currentId) return;
      final all = _all;
      final target = _index + step;
      if (_index < 0 || target < 0 || target >= all.length) return;
      _enter(all[target]);
      await _save();
    });
  }

  // ---- interval controls -------------------------------------------------

  Future<void> startInterval() => _interval((i) => i.start());
  Future<void> pauseInterval() => _interval((i) => i.pause());
  Future<void> resumeInterval() => _interval((i) => i.resume());
  Future<void> resetInterval() => _interval((i) => i.reset());

  /// Skips to the next work or rest phase of the current interval.
  Future<void> skipPhase() => _interval((i) => i.skipPhase());

  Future<void> _interval(void Function(IntervalTimer) action) {
    return _serial(() async {
      final interval = timers.interval;
      if (!isRunning || interval == null) return;
      action(interval);
      await _save();
    });
  }

  // ---- audibles (session-only edits) -------------------------------------

  /// Replaces an activity in this session only. Editing the current activity
  /// resets its interval. Throws [PlanValidationException] for invalid input
  /// and `StateError` for an unknown activity or an ended session.
  Future<void> editActivity(WorkoutActivity updated) {
    return _serial(() async {
      _requireRunning();
      _validate(updated);
      final plan = edits.replaceActivity(_session.workingPlan, updated);
      _session = _session.copyWith(workingPlan: plan);
      if (updated.id == _currentId) _enter(current);
      await _save();
    });
  }

  Future<void> addActivity(
    String segmentId,
    WorkoutActivity activity, {
    int? index,
  }) {
    return _serial(() async {
      _requireRunning();
      _validate(activity);
      final plan = edits.insertActivity(
        _session.workingPlan,
        segmentId,
        activity,
        index: index,
      );
      _session = _session.copyWith(workingPlan: plan);
      if (_currentId == null) _enter(_all.firstOrNull);
      await _save();
    });
  }

  /// Removes an activity. If it is current, the next activity (or the previous
  /// one when it was last) becomes current.
  Future<void> removeActivity(String activityId) {
    return _serial(() async {
      _requireRunning();
      final removedIndex = _all.indexWhere((a) => a.id == activityId);
      final plan = edits.removeActivity(_session.workingPlan, activityId);
      _session = _session.copyWith(workingPlan: plan);
      if (activityId == _currentId) {
        final all = _all;
        _enter(
          all.isEmpty
              ? null
              : all[removedIndex < all.length ? removedIndex : all.length - 1],
        );
      }
      await _save();
    });
  }

  // ---- ending ------------------------------------------------------------

  Future<void> complete() => _end(SessionStatus.completed);

  Future<void> endEarly() => _end(SessionStatus.endedEarly);

  /// Safe to repeat: once ended, further calls change nothing.
  Future<void> _end(SessionStatus status) {
    return _serial(() async {
      if (!isRunning) return;
      _session = await _sessions.finish(_session.id, status);
    });
  }

  // ---- internals ---------------------------------------------------------

  void _requireRunning() {
    if (!isRunning) throw StateError('Session has ended');
  }

  void _validate(WorkoutActivity activity) {
    final issues = activity.validate();
    if (issues.isNotEmpty) throw PlanValidationException(issues);
  }

  /// Makes [activity] current and gives it a fresh, idle interval if timed.
  void _enter(WorkoutActivity? activity) {
    _currentId = activity?.id;
    final details = activity?.details;
    if (details is TimedDetails) {
      timers.prepareInterval(
        IntervalConfig(
          work: Duration(seconds: details.workSeconds),
          rest: Duration(seconds: details.restSeconds),
          rounds: details.rounds,
        ),
      );
    } else {
      timers.stopInterval();
    }
  }

  Future<void> _save() async {
    final activity = current;
    _session = await _sessions.saveProgress(
      _session.id,
      workingPlan: _session.workingPlan,
      activeSegmentId: activity?.segmentId,
      activeActivityId: activity?.id,
      masterTimerState: timers.master.toJson(),
      intervalTimerState: timers.interval?.toJson(),
    );
  }

  Future<T> _serial<T>(Future<T> Function() operation) {
    final result = _tail.then((_) => operation());
    _tail = result.then<void>((_) {}, onError: (_) {});
    return result;
  }
}
