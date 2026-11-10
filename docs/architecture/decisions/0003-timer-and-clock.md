# ADR-0003: Clock and timer design

- Status: Accepted
- Date: 2026-11-05

## Decision

- All timing goes through an injected `Clock` exposing wall time and monotonic
  elapsed time; tests use a fake clock.
- **While the app is active** elapsed time is measured monotonically. The UI
  ticker only triggers repaints; remaining time is always recomputed, never
  decremented from a displayed integer.
- **After process death** the session restores from persisted wall-clock
  timestamps (start, deadline, pause markers).
- The **master countdown** is deadline-based and independent of interval state
  and navigation. Reaching the deadline shows overtime; it never ends the
  workout automatically.
- **Running intervals keep running during suspension**; **paused intervals stay
  paused**. On resume, missed phase/round transitions are reconciled
  deterministically from elapsed time.
- **Missed audio and haptic cues are never replayed.**
- Default: no rest after the final work period.
- Next/Back/Skip stop the current interval. Returning to an activity, or editing
  a timed activity, resets its interval.

## Implementation notes (Phase 2)

- Elapsed time since an anchor is the larger of the monotonic and wall-clock
  differences. This keeps timers correct across device sleep (monotonic time
  may stop) and prevents a backward clock change from adding time.
- A cue plays only if its phase change is observed within a 2 second grace
  period; later transitions are reported as missed and never replayed.

## Known limitations (to document for users)

- Wall-clock recovery after process death is affected by manual device clock
  changes, automatic time-zone/NTP adjustments, and reboots (monotonic time
  resets). Behavior in these cases is best-effort and covered by tests where
  feasible.
- Local notifications are best-effort and permission-dependent; neither iOS nor
  Android guarantees exact background delivery. No exact-alarm permission is used.
