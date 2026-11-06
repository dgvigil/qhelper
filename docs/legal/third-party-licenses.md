# Third-party licenses

Audit of `pubspec.lock` (Flutter 3.47.9, generated 2026-11-05). Licenses were
classified automatically from each package's LICENSE file in the pub cache and
the flagged item reviewed by hand. **Not legal advice; pending legal review**
([licensing-policy.md](licensing-policy.md)). Re-run whenever `pubspec.lock`
changes.

## Summary

| License | Packages | GPLv3-compatible |
|---|---|---|
| BSD (2/3-clause) | 112 | Yes |
| MIT | 13 | Yes |
| Apache-2.0 | 5 | Yes (GPLv3 only; not GPLv2) |
| MPL-2.0 | 1 (`dbus`) | Yes, via MPL-2.0 §3.3 secondary-license clause |
| Flutter SDK packages | 8 | BSD-3 (Flutter) |

No GPL-incompatible or proprietary dependency was found.

## Items reviewed by hand

- **`dbus` 0.8.0 (MPL-2.0)** — transitive via `wakelock_plus` and
  `flutter_local_notifications_linux`. Used only by Linux plugin code, which is
  not built into the iOS or Android apps (Linux is not a supported platform).
  MPL-2.0 is file-level copyleft and is compatible with GPLv3 unless the file
  carries an "Incompatible With Secondary Licenses" notice; none was seen in the
  LICENSE. If a Linux build is ever added, re-check this.
- **`sqlite3` 3.x** — bundles SQLite (public domain) through build hooks;
  `sqlite3_flutter_libs` is deliberately not used (end-of-life, no longer needed).

## Direct dependencies

| Package | Version | Purpose |
|---|---|---|
| flutter_riverpod | 3.4.3 | State management |
| go_router | 18.1.3 | Navigation |
| drift | 2.35.3 | SQLite persistence |
| sqlite3 | 3.9.0 | SQLite bindings |
| share_plus | 13.3.1 | Native share sheet |
| flutter_local_notifications | 22.3.3 | End-of-workout notification |
| wakelock_plus | 1.8.2 | Keep screen awake |
| uuid | 4.6.0 | Stable IDs |
| clock | 1.1.3 | Injectable clock |
| path_provider / path | 2.1.6 / 1.9.1 | Database location |
| shared_preferences | 2.5.6 | Settings |
| timezone / flutter_timezone | 0.11.2 / 5.1.1 | Notification scheduling |
| cupertino_icons | 1.0.8 | iOS icons |
| drift_dev, build_runner (dev) | 2.35.2 / 2.17.1 | Code generation |
| flutter_lints (dev) | 6.0.0 | Lints |

## Assets

No third-party fonts, images, or exercise content are bundled. The app icon is
original and not covered by the GPL. See [licensing-policy.md](licensing-policy.md).
