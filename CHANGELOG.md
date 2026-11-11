# Changelog

All notable changes are documented here. Format based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow the
`MAJOR.MINOR.PATCH+BUILD` scheme in `pubspec.yaml`.

## [Unreleased]

### Added
- Project foundation: Flutter skeleton (iOS 17+, Android API 29+), FVM-pinned
  toolchain, GPLv3 license with App Store exception, governance documents, and CI.

- Phase 1: domain models with validation and JSON, Drift schema v1, plan
  repository (create, read, update, delete, duplicate), and session snapshots
  that are unaffected by later plan edits or deletion.

- Phase 2: injectable clock, fixed-deadline master countdown with overtime,
  work/rest/rounds interval timer with pause, resume, reset and phase skip,
  missed-cue handling, and JSON recovery of timer state.

- Phase 3: live session state machine with Next/Back/Skip, session-only
  edits (audibles), safe repeated end, saved progress, and recovery after
  relaunch. The saved plan is never modified.

- Phase 4: Home list with duplicate, share and delete; workout builder with
  title, duration, segments, activities, reordering, validation and
  unsaved-changes protection; 45 and 60 minute structural templates;
  plain-text sharing; exercise name suggestions from the Q's own workouts.

- Phase 5: live workout screen (master countdown with overtime, current and
  next activity, Back/Next, interval panel, session-only edits, End dialog),
  Resume or End for a running workout, Quick Timer, Settings and About, sound
  and haptic cues, optional keep-awake, and an end-of-workout notification
  that is requested in context and never required.

- Phase 6 (automated part): accessibility and large-text tests for every
  screen, long-run timer tests, an offline guard test, a device test matrix,
  an accessibility checklist, device behavior notes, and a known-issues list.
  Fixed: the one-hour countdown wrapping at large text, interval header
  overflow, a dead "Add activity" item, and the end notification not being
  cancelled when turned off.

### Changed
- Documentation only: roadmap now plans v0.2 (Three-F foundation) through v0.4,
  adds parallel research tracks and per-release exit criteria; competitive
  analysis separates confirmed, advertised, and unknown capabilities; new
  content licensing and review policy. No application changes.
