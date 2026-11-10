# AGENTS.md — Q Helper

Instructions for coding agents working **only in `dgvigil/qhelper`**. Q Helper is a free, offline-first Flutter application for iOS and Android that helps F3 workout leaders plan and run workouts. The product roadmap also explores optional Fellowship and Faith experiences. This is an independent community project, not an official F3 Nation application.

## Source of truth and scope

- Read the repository's current specification, roadmap, architecture decision records (ADRs), and relevant code before proposing changes. The roadmap controls *when* features ship; the specification controls accepted v0.1 behavior. If they conflict, flag the conflict rather than silently deciding.
- Respect phase gates. Do not implement future Exicon, AI, cloud accounts, wearable, Faith, or Fellowship features while working on v0.1 unless the maintainer explicitly authorizes them.
- The public repository is `dgvigil/qhelper`. The initial copyright holder is Dave Vigil; GV5 Technologies LLC is credited as publisher. Follow the repository's GPLv3 plus App Store exception and contribution policies. Do not assume official F3 names, logos, exercise descriptions, scripture translations, or third-party quotes are licensed for reuse.
- Keep the app usable offline. Do not introduce network services, telemetry, authentication, or permissions without an approved requirement.

## Inspect before editing

1. Read the target file and nearby tests before editing. Search for all references/callers and understand the impact of changes.
2. Check existing patterns in `lib/`, `test/`, `integration_test/`, `docs/`, and the relevant platform project before introducing new abstractions.
3. Make the smallest coherent change. Preserve public APIs and persisted formats unless a change and migration are explicitly planned.
4. Never claim tests passed, a device was tested, or a store build was published unless you actually verified it.

## Development philosophy: strict TDD

Follow the red–green–refactor discipline from Harry Percival's *Test-Driven Development with Python* ("Obey the Testing Goat"), adapted to Flutter and Dart.

1. **Red:** Write a test that expresses the next observable behavior. Run it and verify it fails for the *intended behavioral reason*, not a syntax, import, setup, or missing-plugin error. A new feature may begin with a high-level widget/integration acceptance test, then be driven by smaller unit tests.
2. **Green:** Write only enough production code to pass. Prefer the simplest implementation over speculative generalization.
3. **Refactor:** Improve naming, structure, and duplication while all relevant tests stay green. Do not mix refactoring with behavior changes.
4. **Commit at green:** Make small, reviewable commits with passing relevant tests. Bugs begin with a regression test that fails before the fix.

For changes that are inherently non-behavioral (documentation, formatting, metadata, generated files), validate them with the appropriate check rather than manufacturing meaningless failing tests. Never use TDD as an excuse to skip platform verification.

### Flutter testing pyramid

| Layer | Tools | What to verify |
|---|---|---|
| Static checks | `fvm dart format`, `fvm flutter analyze` | Formatting, lint rules, type errors |
| Domain unit tests | `flutter_test`, Dart fakes | Validation, plan ordering, duplication, session snapshots, state transitions, timer math |
| Persistence integration tests | Drift with `NativeDatabase.memory()` and repository tests | CRUD, transactions, foreign keys, ordering, isolation, migration behavior |
| Widget tests | `testWidgets`, `WidgetTester`, Riverpod overrides | Builder flows, controls, validation, navigation, accessibility semantics, loading/error states |
| Device integration tests | Flutter `integration_test` on iOS simulator and Android emulator/physical devices | Create → save → relaunch → run → modify → finish → export, platform adapters and lifecycle |
| Manual physical-device checks | iPhone and Android hardware | Lock screen, background/suspension, force-close/relaunch, notifications, sound/silent/Focus, haptics, battery and outdoor readability |

Prefer many fast, deterministic unit and widget tests. Use full device tests for platform behavior that cannot be proven with mocks. A widget test is not proof that an OS notification or background callback works.

### Test-writing conventions

- Test user-observable behavior and stable domain contracts, not private method calls or widget tree implementation details.
- Use `test`, `group`, `expect`, `testWidgets`, `pumpWidget`, and controlled `pump`/`pumpAndSettle` where appropriate. Avoid arbitrary `Future.delayed` or real sleeps; inject time and advance a fake clock.
- Override Riverpod providers with fakes for repositories, clocks, and platform boundaries. Avoid deep mock chains and unnecessary mocking of pure domain objects.
- Use an in-memory Drift database for persistence tests; close it after each test. Enable and verify foreign-key behavior where applicable. Test multi-row saves and session transitions transactionally.
- Triangulate before adding abstractions; tolerate small duplication until extraction genuinely simplifies the design.
- Add a characterization test before changing untested legacy behavior.
- Keep fixtures small, deterministic, and free of personal information or real credentials.
- A passing suite is necessary but not sufficient: check the relevant platform behavior and phase acceptance criteria.

## Q Helper behavior that must not regress

### Plans and persistence

- A `WorkoutPlan` contains ordered segments and typed activities (reps, timed, free-form). Validate invalid counts, durations, and empty required values.
- A running `WorkoutSession` owns a **snapshot** of the source plan. Edits, skips, insertions, and reordering during a session never mutate the saved plan.
- Only one active workout session is supported in v0.1. Serialize rapid UI actions and persist state transitions atomically; completion and end actions must be idempotent.
- Drift/SQLite is local-first. Use schema versions and explicit migrations for changes to persisted data; do not delete user data to make tests pass.

### Master and interval timers

- The master workout deadline is independent of the current activity and its interval timer. Advancing, skipping, editing, or pausing an interval must not extend the workout deadline.
- Use injected wall-clock and monotonic time sources for deterministic tests. Derive time remaining from timestamps/elapsed time, **never** by decrementing a UI counter on each tick.
- During a live process, use monotonic elapsed time where appropriate; reconstruct persisted sessions after termination from saved state and wall-clock timestamps, documenting device-clock-change limitations.
- Running intervals progress through suspension; paused intervals remain paused. On resume, reconcile elapsed phases without replaying missed sound/haptic cues.
- Do not add a rest phase after the last work round. Reaching the master deadline displays overtime but does not automatically end the session.
- Next/Back/Skip stops the current interval; returning to an activity resets its interval. Editing a timed activity resets its interval. Ending a session cancels its pending notification and releases its wake lock.

### Flutter UI and platform boundaries

- Keep business logic in testable Dart services/models, not widgets. Use Riverpod for state/dependency management, `go_router` for navigation, and Drift for persistence, consistent with existing project patterns.
- Build a dark-first, high-contrast, glanceable live screen with large targets, accessible labels, and scalable text. Avoid interactions that require sustained attention while leading a workout.
- Wrap notifications, audio cues, haptics, screen-awake control, sharing, and lifecycle interactions behind small injectable interfaces. Test success, denial, unavailability, and cleanup paths.
- Background audio, notifications, and exact timing are platform-constrained. Never promise that a scheduled notification fires at an exact moment, or bypass OS permissions/restrictions. The workout must remain usable when notification permission is denied.
- Confirm actual iOS **and** Android behavior on appropriate devices before declaring a platform feature done.

## Commands and local verification

Use the Flutter/Dart versions pinned by FVM (`.fvmrc`) and the committed `pubspec.lock`. Prefer `fvm` commands consistently; do not silently upgrade dependencies or the SDK.

```bash
fvm flutter pub get
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
```

Run focused tests while iterating, then the relevant broader suite before committing. Device-targeted integration tests must specify an available emulator, simulator, or device; `flutter test integration_test` alone does not establish cross-platform coverage.

```bash
fvm flutter devices
fvm flutter test integration_test -d <device-id>
fvm flutter build apk --debug
# On macOS with Xcode configured:
fvm flutter build ios --no-codesign
```

If a toolchain or device is unavailable, report exactly which checks could not run. Do not substitute a successful Android build for an iOS verification claim.

## Git and collaboration workflow

- Work in small feature/phase branches. Follow the repository's branch protection, PR review, and CI requirements; do not bypass them.
- Before modifying shared interfaces, identify downstream callers and update tests at the same time.
- Commit only green changes. Use descriptive commits and summarize red/green evidence in the PR.
- Do not merge a phase until its documented exit criteria are satisfied. Report completed work, tests executed, known limitations, and any maintainer/device/store-account blockers.
- Follow `CONTRIBUTING.md`, `SECURITY.md`, and the documented licensing policy. Do not expose private security reports in public issues.

## Safety and release boundaries

These rules override the normal TDD workflow:

- Never publish to TestFlight, Google Play, or GitHub Releases; upload signed artifacts; rotate credentials; or change protected repository settings without explicit maintainer authorization.
- Never commit Apple signing assets, Android keystores, App Store Connect credentials, Play service-account keys, tokens, or real user data. Use protected CI environments and least-privilege secrets.
- Do not run destructive database operations, remove user data, rewrite Git history, or force-push without explicit authorization. Use disposable databases and fixtures in tests.
- Do not enable network calls, analytics, crash reporting, background services, or additional device permissions without approval and corresponding privacy documentation.
- Treat official F3 content, trademarks, third-party content, and app-store licensing exceptions as legal-review dependencies; do not infer permission from public availability.
- For physical-device tests or store distribution, explain prerequisites and request human action rather than claiming the agent completed them.

## Agent handoff checklist

Before saying a task or phase is done, report:

1. Behavior implemented and files changed.
2. The failing test(s) observed before implementation, and the passing results afterward (or why a non-behavioral change used a different check).
3. Commands run and whether they passed; distinguish unit/widget, simulator, and physical-device coverage.
4. Data migration, platform, privacy, licensing, or accessibility implications.
5. Remaining blockers and the next phase gate.
