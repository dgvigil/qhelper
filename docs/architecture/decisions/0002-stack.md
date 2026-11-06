# ADR-0002: Flutter, Riverpod, go_router, Drift

- Status: Accepted
- Date: 2026-11-05

## Decision

- **Flutter** pinned to an exact version in `.fvmrc` and managed with FVM
  everywhere (local and CI). Dart ships with that Flutter.
- **State:** Riverpod. **Navigation:** go_router. **Persistence:** Drift over
  SQLite (`sqlite3` 3.x with build hooks; `sqlite3_flutter_libs` is end-of-life
  and not used).
- Layers: presentation → controller → pure-Dart domain/services → repository
  interfaces → Drift implementation. Platform behaviors (notifications, haptics,
  audio, lifecycle, wakelock) sit behind adapter interfaces so they can be faked.
- All dependencies are pinned to exact versions; `pubspec.lock` is committed.
- Android minSdk 29; iOS 17. Android targetSdk follows Google Play policy at
  upload time.
- Drift schema v1 is the baseline; migration tests start once v2 exists.

## Consequences

Domain and timer logic are testable without Flutter or a device.
