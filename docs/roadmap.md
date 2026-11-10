# Q Helper roadmap: phases and milestones

*Draft for discussion. Prepared 2026-11-10. Status reflects the repository on that date.*

Q Helper is a free, offline-first, open-source (GPLv3) companion for F3 Qs:
plan the workout, run it with reliable timers, call audibles without losing the
plan. Developed and published by GV5 Technologies LLC; initial copyright holder
Dave Vigil. Independent community project, not affiliated with or endorsed by
F3 Nation. Product detail lives in the [v0.1 spec](../Q_Helper_v0.1_Open_Source_Spec.md);
market context in the [competitive analysis](competitive-analysis.md).

## At a glance

| # | Phase | Outcome | Status |
|---|---|---|---|
| 0 | Public foundation | Repo, license, governance, CI, app skeleton | **Done** |
| 1 | Domain and persistence | Plans saved locally, session snapshots | Not started |
| 2 | Timer engine | Reliable master countdown and intervals | Not started |
| 3 | Session state machine | Run, skip, edit, end, recover a workout | Not started |
| 4 | Weinke UI | Build, save, duplicate, share a workout | Not started |
| 5 | Live UI and device adapters | Run a workout on a phone, offline | Not started |
| 6 | Quality assurance | Tested on real devices | Needs maintainer |
| 7 | Beta release | TestFlight and Google Play internal testing | Needs maintainer |
| 8 | Field validation | 3+ Qs lead real workouts | Needs maintainers and Qs |
| 9 | v0.2 (proposed) | Faith and fellowship, backblast, content | Proposed |

Phases 1-5 are software work and can proceed in order, each ending at an exit
gate. Phases 6-8 need physical devices, store accounts, and real Qs.
Spec planning estimate for phases 0-8: about 8 weeks at 15-20 focused hours a
week. That is a planning estimate, not a commitment, and depends on device
testing, developer accounts, and store review.

## Phase 0: Public foundation (done)

Goal: a public, buildable, governed project.

| Milestone | Status |
|---|---|
| M0.1 Flutter app skeleton, iOS 17+ / Android API 29+, pinned toolchain (FVM) | Done |
| M0.2 GPLv3 license plus App Store exception drafted | Done (legal review pending) |
| M0.3 Contributor, security, conduct, issue and PR templates | Done |
| M0.4 CI: format, analyze, test, Android and iOS builds | Done |
| M0.5 Architecture decisions and signing plan documented | Done |
| M0.6 Dependency license audit | Done |

Exit gate: fresh clone builds; PR checks pass without secrets. Met.

## Phase 1: Domain and persistence

Goal: workouts live in a local database and a running session has its own copy.

| Milestone | What it delivers |
|---|---|
| M1.1 Domain models | Plan, segment, activity (reps, timed, free-form), session; validation rules |
| M1.2 Database schema | Local tables with ordering and cascade rules; schema v1 baseline |
| M1.3 Repositories | Create, read, update, delete, duplicate plans |
| M1.4 Session snapshots | Starting a workout copies the plan; later edits cannot change it |

Exit gate: automated tests for CRUD, ordering, validation, and snapshot
immutability pass. Migration tests begin once a second schema version exists.

## Phase 2: Timer engine

Goal: timing that stays right when the phone sleeps, locks, or the app closes.

| Milestone | What it delivers |
|---|---|
| M2.1 Injectable clock | Testable time; no counting down a displayed number |
| M2.2 Master countdown | Fixed deadline; independent of intervals and navigation; overtime display |
| M2.3 Interval timer | Work / rest / rounds; start, pause, resume, reset, skip; no rest after the last round |
| M2.4 Suspension and recovery | Running timers keep running in the background, paused stay paused, missed transitions resolved on return, missed cues never replayed |

Exit gate: deterministic test matrix passes, including a simulated 10-minute
suspension and master/interval independence.

## Phase 3: Session state machine

Goal: the logic of leading a workout, independent of any screen.

| Milestone | What it delivers |
|---|---|
| M3.1 Start from a snapshot | One active session at a time |
| M3.2 Navigate | Next, Back, Skip; leaving an activity stops its interval; returning resets it |
| M3.3 Audibles | Edit, add, or remove activities in the session only; saved plan untouched |
| M3.4 End and recover | Complete or end early (safe to repeat); offer Resume or End after a relaunch |

Exit gate: state-transition tests pass; double-taps cannot corrupt a session;
the source plan is never modified.

## Phase 4: Weinke UI

Goal: a Q can prepare a complete workout without a developer.

| Milestone | What it delivers |
|---|---|
| M4.1 App navigation and theme | Dark-first, large targets, accessible labels |
| M4.2 Home | Saved workouts; reopen, duplicate, delete with confirmation; empty state |
| M4.3 Builder | Title, duration (30/45/60/custom), segments, activities, reorder, validation, unsaved-changes protection |
| M4.4 Templates | Two editable structure templates (45 and 60 minutes), segment names and times only |
| M4.5 Export | Plain-text plan through the share sheet |
| M4.6 Autocomplete (optional) | Suggest exercise names from the Q's own earlier entries |

Exit gate: a non-developer can build, save, reopen, duplicate, and share a
complete workout.

## Phase 5: Live UI and device adapters

Goal: run a real workout on a phone, offline.

| Milestone | What it delivers |
|---|---|
| M5.1 Live screen | Large master countdown, current and next activity, Back/Next/Skip, distinct interval panel, End confirmation |
| M5.2 Quick Timer | Work / rest / rounds without a saved plan |
| M5.3 Device adapters | Sound, haptics, keep-screen-awake, lifecycle handling |
| M5.4 End-of-workout notification | Asked for in context; app works fully if denied |
| M5.5 Settings and About | Default duration, cue preferences, privacy and support links, GV5 credit, independence notice |
| M5.6 Integration tests | Create, save, restart, reopen, start, edit, pause, finish, export on iOS and Android |

Exit gate: a real device runs and modifies a workout offline; denied
permissions do not break the flow.

## Phase 6: Quality assurance (needs maintainer)

Goal: confidence on real hardware.

| Milestone | What it delivers |
|---|---|
| M6.1 Physical-device matrix | iPhone and Android: airplane mode, lock/unlock, background, app killed and relaunched, silent/Focus modes, large text, long workout, overtime |
| M6.2 Documented behavior | What notifications and cues actually do, without promising exact delivery |
| M6.3 Accessibility pass | Screen reader labels, text scaling, contrast |
| M6.4 Defect triage | No known release-blocking bugs |

## Phase 7: Beta release (needs maintainer)

Goal: official signed builds in testers' hands.

| Milestone | What it delivers |
|---|---|
| M7.1 Accounts and records | Apple Developer and Google Play accounts verified; app records created |
| M7.2 Legal sign-off | Review of the App Store exception and contribution terms complete |
| M7.3 Store assets | Neutral original icon, screenshots, metadata, privacy policy URL |
| M7.4 Protected release pipelines | Signed builds from approved maintainer actions only |
| M7.5 TestFlight and Play internal testing | Testers install and update official builds |

## Phase 8: Field validation (needs maintainers and Qs)

Goal: prove it works in the field.

| Milestone | What it delivers |
|---|---|
| M8.1 Recruit 3-5 Qs | Mix of iPhone and Android |
| M8.2 Observed workouts | At least 3 Qs lead real workouts |
| M8.3 Feedback and backlog | Defects triaged; v0.2 priorities written down |

Release-complete (from the spec): everything works offline; no critical bugs;
public CI passes; signed builds install on both platforms; privacy policy and
neutral store assets published; three real workouts completed.

## Phase 9: v0.2 (proposed, not committed)

Ideas from the F3 discussion and the competitive analysis. None of this is in
the v0.1 scope; priorities should come from Q feedback.

| Milestone | What it delivers |
|---|---|
| M9.1 Daily faith and motivation | Offline rotating entries; Scripture, Motivation, or Off; public-domain sources with provenance |
| M9.2 Fellowship playbook | Original checklists for coffeeteria, luncheon, holiday gathering, service project |
| M9.3 Backblast | Draft and share from the Circle of Trust (competitors already ship it) |
| M9.4 Licensed content | Exicon and workout library, only with written F3 permission |
| M9.5 Later candidates | Apple Watch, Wear OS, hands-free cues, structured import/export |

## Gating items outside the code

| Item | Owner | Blocks |
|---|---|---|
| Legal review of license exception and contribution terms | Maintainer | External contributions; Phase 7 |
| F3 Nation / F3 Tech content-permission conversation | Maintainer | M9.4; shapes the independence notice |
| Apple Developer and Google Play accounts | Maintainer | Phase 7 |
| GitHub repo settings (branch protection, secret scanning, private vulnerability reporting) | Maintainer | Public contributions |
| Privacy policy and support URLs | Maintainer | Phases 5 (About) and 7 |
| Physical test devices | Maintainer | Phase 6 |

## Questions for reviewers

1. Is the v0.1 scope right for a first release, or is anything missing that a Q
   would not use the app without?
2. Should backblast move into v0.1, given both existing apps ship it?
3. Should faith and fellowship content be in the main app, behind an opt-in
   setting, or a separate add-on?
4. Who should review the scripture selections and fellowship checklists?
5. Android-first or both platforms at the same time for the beta?
6. Anyone willing to be a beta Q on iPhone or Android?
