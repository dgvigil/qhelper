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

## Added with the assistant prototype (2026-11-13)

Direct packages added for [ADR-0004](../architecture/decisions/0004-on-device-assistant-prototype.md).
Each LICENSE file was read. This is not a fresh count of every package in the
lockfile.

| Package | Version | License | GPLv3-compatible | Purpose |
|---|---|---|---|---|
| flutter_edge_ai | 2.6.0 | MIT | Yes | On-device model API |
| flutter_edge_ai_litertlm | 1.20.0 | MIT | Yes | LiteRT-LM engine (the native runtime it downloads at build time is Apache-2.0) |
| connectivity_plus | 7.3.2 | BSD-3 | Yes | Wi-Fi check before the model download |

New transitive packages noticed in the same lockfile change: `background_downloader` (BSD), `large_file_handler` (MIT), `genai_primitives` and `json_schema_builder` (BSD), `decimal` and `rational` (Apache-2.0), `email_validator` (MIT), `mutex` (BSD). `nm` 0.6.0 is MPL-2.0, same situation as `dbus` above: pulled in for Linux network status, and the iOS and Android apps do not build that code into a store binary. No GPL-incompatible code license was seen in these LICENSE files.

### Model weights (not a Dart package, not committed)

TwIL-LM3-Pro and TwIL-LM3 are under the **webAI Non-Commercial License ver. 1.0**.
That license limits use to non-commercial research and education. It is not
compatible with the GPL's permission to use the work for any purpose, and it
does not belong in a store build of Q Helper. The app downloads the INT4
`.litertlm` file only when a Q asks, and the weights are gitignored.
The base models (IBM Granite 4.2 for Pro, SmolLM3 for TwIL-LM3) are
Apache-2.0; the fine-tunes are not.

### Exercise and term text

The bundled Codex database is F3 Nation text from `the-codex`, which has no
license file. It is not GPL and is not cleared to ship. See the
[content policy](content-policy.md).

## Assets

No third-party fonts or images are bundled. The app icon is original and not
covered by the GPL. The prototype Codex database is the exception described
above. See [licensing-policy.md](licensing-policy.md).
