# Testing

Strict TDD for domain, timer, and session logic: write a failing test, confirm
it fails for the right reason, make it pass with minimal code, refactor on green.

## Commands

```sh
fvm flutter pub get
dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test                          # unit + widget
fvm flutter test integration_test         # device-targeted (-d <device id>)
```

## Layers

- `test/unit` — pure Dart: models, validation, timer, session state machine.
- `test/widget` — screens and navigation.
- `integration_test/` — end-to-end flows on an iOS simulator and an Android
  emulator. Both platforms are required.

- [simulator-guide.md](simulator-guide.md) — run and hand-check the app in the
  iOS simulator or an Android emulator.
- [device-matrix.md](device-matrix.md) and
  [accessibility-checklist.md](accessibility-checklist.md) — physical-device
  checks.

## Manual: process-kill and relaunch recovery

Documented separately because it cannot be fully automated.
See [process-kill-recovery.md](process-kill-recovery.md).
