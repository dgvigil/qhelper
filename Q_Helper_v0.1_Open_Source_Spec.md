# Q Helper v0.1 — Open-Source Product & Engineering Specification

**Developer / official publisher:** GV5 Technologies LLC  
**Initial copyright holder:** Dave Vigil (contributors retain copyright in their contributions)  
**Status:** Implementation handoff / beta target  
**Target platforms:** iOS 17+ and Android 10+ (API 29+)  
**Implementation:** Flutter / Dart, Riverpod, Drift/SQLite  
**Distribution:** Apple TestFlight and Google Play internal testing  
**Repository:** Public GitHub repository `dgvigil/qhelper` (decided; supersedes the earlier GV5-org proposal)  
**Code license:** GNU GPL v3 with an App Store distribution exception (GPLv3 §7); see `LICENSE`, `APP-STORE-EXCEPTION.md`, ADR-0001. Supersedes the earlier Apache-2.0 proposal. **Legal review required** before external contributions or store distribution.  
**Product:** Free; no ads, subscriptions, accounts, or telemetry SDKs

## 1. Purpose and product principles

Q Helper is an offline-first digital Weinke and live-workout companion for volunteer workout leaders (Qs). It helps a Q prepare a workout, keep track of the overall finish time, manage intervals, and call audibles without losing the original plan. It must **support the Q rather than become the Q**. Prioritize glanceable information, large controls, and minimal interaction in darkness and outdoor conditions.

The initial release is a field-testable beta, not a full F3 knowledge platform. It must be usable without permission to redistribute F3's Exicon, Q101, logos, or other content. The name, branding, and distribution must not imply official F3 affiliation. F3 Tech outreach and licensing discussions run in parallel and do not block v0.1.

**Success:** at least three Qs prepare and lead a real workout with the beta; both iOS and Android testers can install signed releases; all core features work offline; timer recovery and session isolation pass automated and physical-device tests.

## 2. Scope

### Included in v0.1

1. **Workout list:** create, edit, duplicate, delete, and reopen locally saved plans.
2. **Weinke builder:** title; target duration (30/45/60 minutes or custom); ordered, renameable/removable segments; ordered activities; basic validation; unsaved-changes protection.
3. **Activity types:** reps (name, count, notes), timed (name, work/rest durations, rounds, notes), and free-form (name, instructions). Exercise names entered by user; optional autocomplete from prior user entries.
4. **Default structure:** Warm-o-Rama, The Thang, Mary, CoT. Two editable *structural* templates (45 and 60 minutes) containing only segment names, time allocations, and neutral placeholders; no copied exercise descriptions.
5. **Live session:** persistent master countdown; current/next activity; large Back/Next/Skip controls; session-only edits; optional interval timer; overtime display; explicit end action and confirmation.
6. **Quick interval timer:** configurable work/rest/rounds and optional sound/haptic cues, without creating a plan.
7. **Resilience:** local persistence; session restoration; accurate master clock on app resume; configurable screen-awake behavior; end-of-workout local notification when permitted.
8. **Export:** share plain-text workout plan through native share sheet.
9. **Settings/About:** sound, haptics, keep-awake, default duration, privacy policy, support link, GV5 credit, independent-project notice.
10. **Beta delivery:** reproducible iOS and Android builds, TestFlight upload, Play internal testing upload, release notes and tester instructions.

### Explicitly excluded

Bundled Exicon or Q101 content; official logos; F3 API calls; accounts; sync; AI workout generation; attendance; backblast; cloud backend; wearables; cadence metronome; Live Activities; nested-circuit editing UI; advertising; analytics SDKs. Future releases may add these after validation and permissions.

## 3. Technology and architecture

- **Flutter stable** pinned by exact version in repository/toolchain configuration; Dart bundled with that Flutter version.
- **State management:** Riverpod. **Navigation:** go_router. **Persistence:** Drift over SQLite. **Sharing:** share_plus. **Notifications:** flutter_local_notifications (or an equivalent maintained plugin selected after capability verification).
- **Architecture:** presentation → application/controller → pure-Dart domain/services → repository interfaces → Drift implementation. Platform adapters isolate notification, haptic, audio, app-lifecycle, and screen-awake functionality.
- Timer calculations and session transitions must be UI-independent and testable with an injected clock.
- Use immutable plan/session snapshots or explicit deep copies. A live session must never mutate the saved template.
- Document major choices as architecture decision records (ADRs). Pin dependency versions; commit `pubspec.lock`; assess transitive dependency licenses.
- Minimum iOS 17; Android minSdk 29. Select Android targetSdk to meet Google Play policy **at the time of upload**; do not confuse targetSdk with minSdk.

### Suggested repository layout

```text
.github/
  workflows/{ci,ios-beta,android-beta}.yml
  ISSUE_TEMPLATE/{bug_report,feature_request}.yml
  PULL_REQUEST_TEMPLATE.md
  CODEOWNERS
  dependabot.yml
android/
ios/
lib/
  app/{app,router,theme}/
  core/{clock,timer,platform,errors}/
  domain/{models,services,repositories}/
  data/{database,migrations,repositories}/
  features/{home,builder,workouts,live_session,quick_timer,templates,settings}/
  shared/widgets/
test/{unit,widget,fixtures}/
integration_test/
docs/{architecture/decisions,development,testing,release,privacy}/
assets/{icons,templates}/
LICENSE
NOTICE
README.md
CONTRIBUTING.md
CODE_OF_CONDUCT.md
SECURITY.md
CHANGELOG.md
analysis_options.yaml
pubspec.yaml
pubspec.lock
```

## 4. Domain contract

**WorkoutPlan:** `id`, `title`, `description?`, `targetDurationSeconds`, `createdAt`, `updatedAt`, `schemaVersion`, ordered `segments`.

**WorkoutSegment:** `id`, `planId`, `title`, `sortOrder`, `estimatedDurationSeconds?`, ordered `activities`. Default segment labels are user-editable, not required.

**WorkoutActivity:** `id`, `segmentId`, `sortOrder`, `kind` (reps | timed | freeForm), `name`, `notes?`, plus validated type-specific fields:
- reps: positive integer `repetitions`;
- timed: positive `workSeconds`, nonnegative `restSeconds`, positive `rounds`;
- freeForm: `instructions`.

**WorkoutSession:** `id`, `sourcePlanId?`, serialized immutable `planSnapshot`, `startedAtWall`, `deadlineAtWall`, `activeSegmentId?`, `activeActivityId?`, `masterTimerState`, `intervalTimerState`, `status`, `updatedAtWall`. Session statuses: running, completed, endedEarly, interrupted. A fresh session snapshot is made at start; plan edits made later cannot alter the active session.

Use stable UUIDs, explicit ordering, foreign keys, transactions for multi-row writes, migration tests, and schema versioning. Do not build recursive blocks merely for speculative future use; document a future migration path if nested circuits become necessary.

## 5. Timer and lifecycle behavior

**Master timer:** stores the intended wall-clock deadline and reconstructable timing state. It is independent of interval state and exercise navigation. Skipping, extending, pausing an interval, or editing a session activity **must not move the master deadline**. After the deadline, show overtime until the session is ended.

**Interval timer:** work/rest/rounds with start, pause, resume, reset, phase skip, and completion. Specify and test whether the last round includes a rest phase; default: no final rest after the last work period. UI updates may use a periodic ticker, but elapsed time must never be calculated by decrementing a displayed integer each tick.

**Clock design:** inject a test clock. Use monotonic elapsed time for in-process timing; persist sufficient wall-clock and elapsed/pause state to restore after backgrounding or process death. Explicitly document device clock-change and reboot limitations; test both where feasible.

**Lifecycle:** app resume recomputes remaining time. Persist session changes transactionally at meaningful transitions. Recover active session on relaunch and offer Resume / End. Keep screen awake only during live mode when the user has opted in. Local end notification is best-effort, permission-dependent; neither iOS nor Android guarantees exact background audio/haptic delivery. Do not require exact-alarm permission or unrestricted background execution for v0.1. Handle notification-denied and silent/Focus modes gracefully.

**Critical tests:** deadline accuracy; master/interval independence; pause/resume; repeated rounds; skip/back; overtime; 10-minute simulated suspension; session recovery; source plan immutability; app relaunch; notification-denied behavior.

## 6. UX screens and acceptance criteria

### Home / saved plans
- Show saved plans, Create, Templates, Quick Timer, Settings.
- Reopen, duplicate, delete with confirmation; empty state clearly invites first plan.

### Builder
- Edit title/duration/segments/activities; reorder segments and activities; validate inputs; save; duplicate; start; share.
- Never silently discard unsaved changes. Structural templates remain editable.

### Live workout
- Always-visible large master countdown; current activity prominently displayed; next activity visible; reps/interval/instructions as appropriate.
- Large Back, Next, Skip; interval controls clearly distinguished from master countdown; session-only edits; End confirmation.
- High contrast, dark-first, large targets, accessible labels and scaling; no mandatory automatic advancement.

### Quick Timer
- Work/rest/rounds; start/pause/reset; optional audio/haptic; works without plan or network.

### Settings/About
- Default duration; cue preferences; keep-awake toggle; privacy/support links; GV5 credit; independent-project notice.

### Export
- Native share sheet with readable plain text: title, target duration, ordered segments, activity details, notes.

## 7. Open-source governance and licensing

1. The repository is **public** at `dgvigil/qhelper`. GV5 Technologies LLC is credited as developer and publisher (README, About, store listings); Dave Vigil is the initial copyright holder and maintainer.
2. Use **GPLv3 plus an App Store exception** (`APP-STORE-EXCEPTION.md`, GPLv3 §7); canonical `LICENSE` and accurate `NOTICE`. Contributors retain copyright; no CLA or assignment. Contributions require DCO sign-off **and** explicit acceptance of GPLv3 plus the exception (DCO alone does not grant it). Dependencies must be GPLv3-compatible. Do not change the license or add a CLA without discussing with the maintainer. See `docs/legal/licensing-policy.md`.
3. Keep code licensing separate from product trademarks, app icons, and third-party content. Do not claim Apache-2.0 covers F3 trademarks, Exicon, Q101, or community-authored materials. Track assets and their individual licenses in `docs/`.
4. Add `README`, `CONTRIBUTING`, `CODE_OF_CONDUCT`, `SECURITY`, `CHANGELOG`, PR template, issue forms, CODEOWNERS, dependency update configuration, and ADRs.
5. Start with maintainer-led governance. Require PR review, passing checks, DCO sign-off, and explicit acceptance of GPLv3 plus the App Store exception; no CLA.
6. Publish local development instructions, testing commands, architecture overview, roadmap, and reproducible unsigned build instructions. Community contributors should not need Apple/Google credentials to build or test.
7. Provide a private security contact or GitHub private vulnerability reporting; do not require security reports in public issues.
8. No official F3 branding or copied exercise text without explicit written rights. A permission to use content in GV5's distributed app is **not automatically** a license for forks to redistribute it. Keep any future licensed content in a separately governed package/source with clear distribution rules.
9. The project README and app About page must state: “Q Helper is an independent community project developed by GV5 Technologies LLC and is not affiliated with or endorsed by F3 Nation.” Revise only if authorization changes.
10. Clearly distinguish community source releases from **official GV5-signed store releases**. Third parties may fork code under the license, but may not use GV5's release credentials or imply official endorsement.

## 8. Security and CI/CD

### Public pull-request CI
- Trigger on `pull_request` and trusted pushes to `main`.
- Run pinned Flutter setup, `flutter pub get`, `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test`, and appropriate unsigned/debug build checks.
- No signing credentials or privileged release tokens available to fork PRs. Use minimal `GITHUB_TOKEN` permissions. Avoid `pull_request_target` workflows that check out and execute untrusted PR code.
- Enable dependency update alerts, secret scanning where available, branch protection, required reviews, and status checks.

### Protected official release workflows
- Run only from approved maintainer actions on trusted tags or protected branches/environments. Require environment approval before accessing signing secrets.
- Pin GitHub Actions by immutable SHAs where practical; audit third-party actions.
- **iOS:** macOS runner, compatible Xcode, Apple developer team, bundle ID, signing cert/provisioning or approved managed signing, App Store Connect API key; build signed IPA, upload to App Store Connect, await processing and complete TestFlight tester configuration.
- **Android:** signing keystore and credentials, Play Console app record, Play App Signing setup, API service account permissions; build signed AAB and upload to internal testing track.
- Version: start `0.1.0+1`; increment iOS build numbers and Android version codes for every upload. Tag releases, generate changelog/release notes, record commit SHA and build provenance, retain artifacts with explicit policy.
- Do not commit keystores, API keys, certificates, or sensitive provisioning materials. Rotate compromised secrets immediately.

## 9. Store preparation and distribution

### Apple TestFlight
- Verify Apple Developer Program account, team ownership, and bundle ID availability (`com.gv5technologies.qhelper` proposed, not guaranteed).
- Create App Store Connect record; prepare icon, metadata, screenshots, support/privacy URLs, compliance information, and beta review information.
- Sign and upload IPA. Configure internal testers first; external testers may require beta app review. Verify invitation, installation, launch, offline operation, and update flow on physical iPhone.

### Google Play
- Verify Play Console account and organization verification. Create app record and reserve application ID (`com.gv5technologies.qhelper` proposed).
- Configure Play App Signing, Data safety, content rating, privacy policy, required disclosures, and current target API level.
- Upload signed AAB to internal testing; add testers and distribute opt-in link. Test installation and updates on physical Android device. Expand to closed testing when appropriate. Account-specific production access requirements must be checked separately; internal testing is not public production release.

### Store assets and policy
- Prepare distinct platform screenshot sizes and a neutral original app icon. Do not use official F3 marks without permission.
- Publish a truthful privacy policy. Data is stored locally by design; audit plugins, OS diagnostics, crash reports, backups, and any platform services before declaring “no data collected.”
- No permissions for location, contacts, health data, or accounts. Request notification permission only in context. Ensure app is functional when denied.

## 10. Delivery phases and exit gates

| Phase | Work | Exit gate |
|---|---|---|
| **0 — Public foundation** | Create public repository, license and governance files, Flutter skeleton, dependency pinning, CI, docs, neutral branding | Fresh clone builds and tests on both simulators; PR checks pass without secrets |
| **1 — Domain & persistence** | Typed models, Drift schema/repositories, migrations, CRUD, plan duplication, session snapshots | Automated CRUD, ordering, validation, migration, and immutability tests pass |
| **2 — Timer engine** | Injected clock, master deadline, intervals, pause/resume, overtime, recovery | Deterministic timer test matrix passes, including master/interval independence |
| **3 — Session state machine** | Start from snapshot, advance/back/skip, session-only edits, end/recover | Pure-domain state transition tests pass; source plan remains unchanged |
| **4 — Weinke UI** | Home, builder, templates, activity forms, ordering, validation, export | A non-developer can prepare, save, reopen, duplicate, and share a complete workout |
| **5 — Live UI & adapters** | Glanceable screen, quick timer, haptics/audio, notifications, screen awake, lifecycle | Real device can run and modify a workout offline; denied permissions do not break flow |
| **6 — QA** | Unit/widget/integration tests, accessibility, lock/unlock, suspension, process recovery, offline field simulation | No known release-blocking defects; documented iOS/Android physical-device matrix |
| **7 — Beta release** | Signing, store records, metadata, protected publishing pipelines, TestFlight and Play internal test | Invited testers install official signed builds on both platforms |
| **8 — Field validation** | Recruit 3–5 Qs, observe actual workouts, triage defects, iterate | At least 3 Qs use it in real workouts; feedback and v0.2 backlog documented |

**Suggested cadence:** 8 weeks at approximately 15–20 focused hours/week, subject to device testing, developer-account readiness, and store review. This is a planning estimate, not a commitment. Prepare both developer accounts in Phase 0 to avoid late blockers.

## 11. Required tests and definition of done

### Automated
- Domain validation and ordering; save/duplicate/delete; database migration; timer deadline and intervals; state transitions; snapshot immutability; export formatting; widget navigation and controls.
- Integration flow: create → save → restart → reopen → start → skip/edit → pause/resume interval → finish → export.
- Required commands pass: `flutter pub get`, `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test`.

### Physical devices
- iPhone and Android phone: airplane mode, lock/unlock, app background/foreground, process termination/relaunch, notification allowed/denied, silent/Focus behavior, screen-awake on/off, dark conditions, large text, long workout, session overtime, install/update via beta stores.
- Document actual notification behavior rather than claiming guaranteed precise delivery.

### Release-complete
- All in-scope functionality works offline; no critical bugs; source is public with complete licensing and contributor docs; public CI passes; signed TestFlight and Google Play internal-test builds install; privacy policy and neutral store assets are published; at least three Qs complete real workouts and feedback is recorded.

## 12. Future roadmap (not v0.1 commitments)

Post-v0.1 releases are planned in [docs/roadmap.md](docs/roadmap.md), which supersedes the earlier v0.2-v0.4 list here. None of it changes the v0.1 scope or release gate.

Prioritize based on real Q feedback and licensing terms, not feature count.

## 13. Instructions to implementation agents

- Treat this specification as the v0.1 scope contract. Implement phases in order; do not add deferred features without approval.
- Write failing tests first for timer, session, and persistence behavior; keep UI separate from domain logic.
- Keep the repository buildable at every completed phase. Never commit credentials or copyrighted F3 materials without rights.
- At each phase boundary, report: delivered functionality, changed files, test evidence, unresolved risks, blockers requiring human action, and readiness for the next phase.
- Do not claim a store release is complete until the build has been uploaded, processed, distributed to testers, and installed successfully.
- Request human intervention for account verification, legal approval, store credentials, certificates, and release authorization; do not fabricate completion.

**Guiding principle:** *Plan the workout. Lead the men. Leave the phone alone.*
