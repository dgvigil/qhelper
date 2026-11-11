# Q Helper roadmap: phases and milestones

*Draft for discussion. Prepared 2026-11-10; revised 2026-11-10 for the Three-F
direction. Status reflects the repository on that date.*

Q Helper is a free, offline-first, open-source companion for F3 Qs supporting all
three F3 pillars: **Fitness, Fellowship, and Faith**. v0.1 is fitness: plan the
workout, run it with reliable timers, call audibles without losing the plan.
Fellowship and faith arrive in v0.2. Licensed GPLv3 plus the
[App Store exception](../APP-STORE-EXCEPTION.md); source at the public
`dgvigil/qhelper` repository. Developed and published by GV5 Technologies LLC;
initial copyright holder Dave Vigil. Independent community project, not
affiliated with or endorsed by F3 Nation. Product detail lives in the
[v0.1 spec](../Q_Helper_v0.1_Open_Source_Spec.md); market context in the
[competitive analysis](competitive-analysis.md); content rules in the
[content policy](legal/content-policy.md).

This revision adds parallel research tracks and re-plans releases after v0.1
(v0.2 to v0.4 plus a backlog). Phases 0-8 and the v0.1 release gate are
unchanged. Nothing after v0.1 is implemented yet.

## At a glance

| # | Phase | Outcome | Status |
|---|---|---|---|
| 0 | Public foundation | Repo, license, governance, CI, app skeleton | **Done** |
| 1 | Domain and persistence | Plans saved locally, session snapshots | **Done** |
| 2 | Timer engine | Reliable master countdown and intervals | **Done** |
| 3 | Session state machine | Run, skip, edit, end, recover a workout | **Done** |
| 4 | Weinke UI | Build, save, duplicate, share a workout | **Done** (device check pending) |
| 5 | Live UI and device adapters | Run a workout on a phone, offline | **Done in code and on the iOS simulator** (physical devices pending) |
| 6 | Quality assurance | Tested on real devices | **Automated work done; physical-device runs need maintainer** |
| 7 | Beta release | TestFlight and Google Play internal testing | Needs maintainer |
| 8 | Field validation | 3+ Qs lead real workouts | Needs maintainers and Qs |

| Release / track | Outcome | Status |
|---|---|---|
| v0.2 | Three-F foundation: daily encouragement, fellowship playbook | Planned |
| v0.3 | Circle of Trust assistance and backblast drafting | Planned |
| v0.4 | Apple Watch, Wear OS evaluation, Live Activities, hands-free | Planned |
| Conditional | Official Exicon integration, only with documented F3 permission | Conditional |
| Backlog | AI workout generation, community synchronization | Future |
| P1, P2 | Competitive field testing; Three-F user discovery | Parallel, non-blocking |

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
**Met** (61 tests passing, analyze clean).

Notes from implementation:
- The session record holds the plan snapshot, deadline, and status. Timer
  state (Phase 2) and active segment/activity (Phase 3) columns are added with
  those phases. The schema is unreleased, so this needs no migration.
- Generated Drift code (`*.g.dart`) is committed because CI does not run
  `build_runner`. Regenerate with `fvm dart run build_runner build`.
- Dates are stored as text to keep millisecond precision (`build.yaml`).
- The app does not open the database yet; wiring through Riverpod arrives
  with the UI phases.

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
**Met** (111 tests passing, analyze clean).

Notes from implementation:
- Timers are plain Dart in `lib/core/` and take an injected `AppClock`
  (wall and monotonic time). Tests use `FakeClock` to model suspension, device
  clock changes, and process restarts.
- Elapsed time is the larger of the monotonic and wall differences. A backward
  clock change cannot add time; a forward change shortens a countdown (a
  documented limitation, covered by a test).
- Cues: a phase change observed within 2 seconds plays its cue; anything later
  is counted as a missed transition and never replayed.
- Timers serialize to JSON for recovery after process death. Writing that state
  into the session record is part of Phase 3 (M3.4).

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
**Met** (177 tests passing, analyze clean).

Notes from implementation:
- `LiveSession` (`lib/domain/services/live_session.dart`) is pure Dart. It
  saves position, working plan, and timer state after every change.
- Controls: Next and Back move between activities and never wrap. Skip skips
  the current interval phase. Interval start, pause, resume, and reset are
  separate calls. A guarded `next(fromActivityId:)` lets the UI ignore a stale
  or repeated tap.
- The session keeps the original `planSnapshot` untouched and a `workingPlan`
  that holds audibles, so the planned workout stays available later (for
  example for a backblast).
- Operations run one at a time in call order; a test with a deliberately slow
  save fails if that serialization is removed.
- After the session ends, navigation does nothing and edits throw.
- On relaunch, `LiveSession.recover` returns the running session for a
  Resume / End prompt. Ending uses `endEarly`; the `interrupted` status is
  reserved and not set yet.

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
**Met in automated tests** (acceptance widget test plus 80+ widget and unit
tests). Not yet confirmed by a person on a real device; that belongs to
Phase 6 and the field work in Phase 8.

Notes from implementation:
- Screens: Home (list, empty state, duplicate, share, delete with
  confirmation), Builder, and Templates. The app now opens the on-device
  database at launch (`lib/main.dart`).
- Reordering uses Move up / Move down menu items instead of drag handles. They
  work with screen readers and large text, and are easy to test.
- Templates hold only segment names and times (45 and 60 minutes), with no
  exercise text. A blank new workout uses the same four segments without times.
- Name suggestions (M4.6) come only from the Q's own saved workouts and the
  workout being edited.
- Widget tests use an in-memory repository. The real database path (create,
  save, relaunch, reopen) is covered by repository tests now and by the
  integration tests in Phase 5.6.
- Starting a workout from the builder or list arrives with the live screen in
  Phase 5.

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

**Status: built and tested; the gate itself still needs physical devices.**
- Verified: unit and widget tests (including denied notifications and failing
  platform services), and both integration flows on an iOS simulator with the
  real database, run offline.
- Not verified: any physical iPhone or Android phone, and any Android emulator
  (no Android system image on the development machine). Lock screen,
  silent switch and Focus, real notification delivery, and the screen-awake
  lock are Phase 6 checks. Use
  [process-kill-recovery.md](testing/process-kill-recovery.md).

Notes from implementation:
- `LiveScreen` runs a session through `LiveSession`. Leaving the screen never
  ends the workout; Home offers **Resume** or **End workout**.
- The 250 ms ticker only repaints. Cues play only when a phase change is seen
  within 2 seconds; after a suspension the display jumps to the right phase and
  nothing is replayed.
- Next/Back pass the activity they were drawn for, so a stale or repeated tap
  is ignored.
- Cues use the system alert sound and haptics. They follow the phone's silent
  and Focus settings; a loud alarm that overrides the ringer is not part of
  v0.1 and remains an open investigation.
- The end-of-workout notification is scheduled inexactly, with no exact-alarm
  permission. The permission prompt appears once, when the first workout
  starts.
- Keep-screen-awake defaults to on and can be turned off in Settings. The spec
  says "when the user has opted in"; confirm the default before beta.
- Privacy and support links are shown as copyable text. Making them tappable
  needs the `url_launcher` dependency and a license check.
- The privacy policy in `docs/privacy/` is a draft that needs review before
  store submission (Phase 7).

## Phase 6: Quality assurance (needs maintainer)

Goal: confidence on real hardware.

| Milestone | What it delivers |
|---|---|
| M6.1 Physical-device matrix | iPhone and Android: airplane mode, lock/unlock, background, app killed and relaunched, silent/Focus modes, large text, long workout, overtime |
| M6.2 Documented behavior | What notifications and cues actually do, without promising exact delivery |
| M6.3 Accessibility pass | Screen reader labels, text scaling, contrast |
| M6.4 Defect triage | No known release-blocking bugs |

**Status.** Everything that can be done without a phone is done and written
down. The physical-device runs are the maintainer's.

| Milestone | State |
|---|---|
| M6.1 Device matrix | Ready: [device-matrix.md](testing/device-matrix.md) (24 scenarios, iPhone and Android). **Not run.** Needs a physical iPhone and Android phone |
| M6.2 Documented behavior | Written: [device-behavior.md](release/device-behavior.md). Items marked "to confirm" wait for the matrix |
| M6.3 Accessibility pass | Automated checks run in CI (overflow at 2x text, tap targets, labels, contrast, countdown announcement). Manual VoiceOver and TalkBack pass: [accessibility-checklist.md](testing/accessibility-checklist.md), **not run** |
| M6.4 Defect triage | [known-issues.md](release/known-issues.md): 4 defects found and fixed, no known release-blocking defects. Unknown until devices are tested |

What the automated pass found and fixed: a one-hour countdown wrapped at large
text, the interval panel header could overflow, "Add activity" did nothing in a
workout with no segments, and turning the notification setting off did not
cancel a scheduled one. New guards: a test that app code uses no networking
libraries, and long-run timer tests (a full interval at 250 ms ticks, three
hours of ticking).

Exit for Phase 6: the matrix is complete on both platforms with no open
release-blocking defects.

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

### v0.1 product validation (informs v0.2; does not change the gate above)

| Check | Evidence |
|---|---|
| Qs would use it again | At least 3 observed Qs say they would lead their next workout with it |
| Core promise holds | No audible, timer, or recovery failure reported in the observed workouts |
| Next-release priorities | Feedback ranks fellowship, faith, and backblast needs against P2 discovery |

## Parallel tracks (non-blocking)

These start now and never gate engineering phases or any release.

| Track | Activity | Output |
|---|---|---|
| P1 Competitive field testing | Install F3 Q Sheet and Q Master on real devices; run one scripted test (timer under lock, alarm with ringer off, audible edit, kill and relaunch); check Play Store for Android availability | Results recorded as **Confirmed** (with app version and date) in the [competitive analysis](competitive-analysis.md) |
| P2 Three-F user discovery | 5-8 short interviews: Qs, fellowship (2nd F) organizers, a faith (3rd F) lead, and at least one PAX who is not religious. Ask about daily-content tone, opt-in expectations, fellowship planning pain, and backblast habits | Summary in `docs/research/` with no personal details; feeds v0.2 and v0.3 scope |

## v0.2: Three-F foundation

Goal: add the second and third Fs without weakening the offline, no-account
core. Starts after v0.1 is released; discovery (P2) shapes details.

| Milestone | What it delivers |
|---|---|
| V0.2.1 Daily encouragement | Offline, opt-in. Preference: Scripture, Motivation, Both, or Off. Default Off; never show scripture unprompted. Opt-in screen carries the disclosure: F3 does not support any one religion; the author follows Jesus, so content reflects that |
| V0.2.2 Reviewed content collection | Small starter set (target 30-60 entries) with per-entry provenance and explicit license, reviewed under the [content policy](legal/content-policy.md) |
| V0.2.3 Fellowship playbook | Original guides and checklists: coffeeteria, luncheon, holiday gathering, service project, 2nd-F check-in; shared as plain text through the existing share sheet |

Non-goals: cloud backend, accounts, event registration, social features.

Exit criteria (product validation):
- Every shipped entry passes review and has complete provenance.
- Works fully offline; Off hides all faith content.
- Discovery participants (P2), including non-religious ones, find the opt-in and tone acceptable; no unresolved inclusivity objection.
- At least 3 Qs use the playbook to plan a real event, or report why not.
- No regression against v0.1 timer and session tests.

## v0.3: Circle of Trust assistance and backblast

| Milestone | What it delivers |
|---|---|
| V0.3.1 CoT assistance | Count-o-rama, name-o-rama, FNG marking, announcements and prayer-request notes |
| V0.3.2 Backblast drafting | Draft from the session and CoT notes; edit; share as plain text |

Exit criteria:
- At least 3 Qs produce and post a real backblast using the app.
- Drafting is faster than their usual method, by their own report.
- All data stays on device unless the Q shares it.

## Conditional: official Exicon integration

Proceeds only when F3 permission is documented in `docs/legal/`. It is not a
dependency of any release; if permission never arrives, nothing slips. Until
then, no Exicon content, F3 logos, or Q101 text ships. If granted, revisit the
independence wording and schedule it into the next open release.

## v0.4: Wearables and hands-free

| Milestone | What it delivers |
|---|---|
| V0.4.1 Apple Watch | Companion glance and controls for a running workout |
| V0.4.2 Wear OS evaluation | Spike and written go/no-go before any build commitment |
| V0.4.3 Live Activities | iOS lock-screen / Dynamic Island timer |
| V0.4.4 Hands-free controls | Better cues and controls for phone-free leading |

Exit criteria:
- Watch and Live Activity timers match the phone to within one second after a 10-minute suspension.
- At least 3 Qs lead a workout using hands-free controls and report whether the phone stayed in the pocket.
- Wear OS: decision recorded with evidence, whether go or no-go.

## Future backlog (unscheduled)

- AI workout generation.
- Community synchronization.
- From the earlier spec list: offline search, favorites, more templates, first-Q guidance, deterministic suggested plans, cadence assistance, structured plan import/export.

Each item needs its own discovery and exit criteria before scheduling.

## Gating items outside the code

| Item | Owner | Blocks |
|---|---|---|
| Legal review of license exception and contribution terms | Maintainer | External contributions; Phase 7 |
| F3 Nation / F3 Tech content-permission conversation | Maintainer | Official Exicon integration only; shapes the independence notice |
| Content reviewers: scripture and quotes agreed (two family members); fellowship reviewer still open | Maintainer | v0.2 content release |
| Recruit an Android beta tester | Maintainer | Phase 6 Android testing; Phase 7 Play internal test; Phase 8 |
| Legal review of content licensing choices | Maintainer | v0.2 content release |
| Apple Developer and Google Play accounts | Maintainer | Phase 7 |
| GitHub repo settings (branch protection, secret scanning, private vulnerability reporting) | Maintainer | Public contributions |
| Privacy policy and support URLs | Maintainer | Phases 5 (About) and 7 |
| Physical test devices | Maintainer | Phase 6 |

## Maintainer decisions (2026-11-10)

| Question | Decision |
|---|---|
| Is v0.1 the right first release? | Yes. v0.1 goes to TestFlight (and Play internal testing) for a small group of testers |
| Backblast | Committed to match the other apps. Stays in v0.3 as already planned; the v0.1 scope and gate are not expanded. Moving it earlier would be a separate decision |
| Faith content placement | In the main app, opt-in (default Off), with a disclaimer: F3 does not endorse any one religion; the author follows Jesus, so the scripture and quotations reflect that. See the [content policy](legal/content-policy.md) |
| Scripture and quotation review | Two family members with long faith and leadership experience (the maintainer's brother and father) review them |
| Platforms for the beta | Both iOS and Android together |
| Beta testers | Maintainer (iPhone, later Apple Watch); the maintainer's brother (iPhone, F3 Q) |

## Open questions

1. **Android tester needed.** Nobody is recruited yet. Phase 6 Android device
   testing, the Play internal test in Phase 7, and field validation on Android
   (Phase 8) all depend on this. Recruit at least one Android user in an F3 group.
2. Who can take part in Three-F discovery interviews (P2)? Include at least one
   PAX who is not Christian, so the opt-in and disclaimer wording is tested
   against people it is meant to respect.
3. Who reviews fellowship playbook checklists (someone who has run a 2nd-F event)?
4. Who reviews non-scripture quotations for accuracy of source, if not the
   same two reviewers?
