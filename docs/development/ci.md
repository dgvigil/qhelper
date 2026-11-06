# Continuous integration

`.github/workflows/ci.yml` runs on `pull_request` and pushes to `main`:

| Job | Runner | Timeout | Checks |
|---|---|---|---|
| quality | ubuntu | 10 min | `flutter pub get`, `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test` |
| android-build | ubuntu | 15 min | `flutter build apk --debug` |
| ios-build | macOS | 30 min | `flutter build ios --no-codesign --debug` |

The Flutter version is read from `.fvmrc`, so CI and local FVM stay in sync.

## Timeout policy exception

The global policy is 10-15 minutes per job. The iOS job is set to 30 minutes
because cold macOS builds (Xcode, CocoaPods) are slow. This was explicitly
approved by the maintainer. Keep the exception limited to that job.

## Security

- `permissions: contents: read`; no secrets in this workflow.
- Actions pinned by commit SHA; Dependabot keeps them current.
- Never use `pull_request_target` to check out and run PR code.
