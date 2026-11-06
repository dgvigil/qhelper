# Signing and release architecture

Design only. **No credentials are required or stored for Phases 0–5.** Release
automation is built in Phase 7. Community contributors never need Apple or Google
credentials to build or test.

## Principles

- Official GV5-signed store builds come only from protected release workflows,
  triggered by the maintainer on trusted tags, running in a GitHub Environment
  with required approval before any secret is exposed.
- Fork pull requests never receive signing secrets; public CI uses `pull_request`
  with read-only `GITHUB_TOKEN`. `pull_request_target` is not used.
- Never commit keystores, API keys, certificates, or provisioning profiles.
  Rotate any exposed secret immediately.
- Third-party actions are pinned by commit SHA and audited.

## iOS (TestFlight)

- Bundle ID `com.gv5technologies.qhelper` (availability to be verified).
- macOS runner with a compatible Xcode, Apple Developer team, distribution
  certificate and provisioning (or approved managed signing), and an App Store
  Connect API key stored as environment secrets.
- Build signed IPA → upload to App Store Connect → wait for processing →
  configure TestFlight testers.

## Android (Google Play internal testing)

- Application ID `com.gv5technologies.qhelper`.
- Play App Signing; an upload keystore kept in environment secrets; a Play
  service account with minimal permissions.
- Build signed AAB → upload to the internal testing track.
- targetSdk chosen to satisfy Play policy at upload time.

## Versioning

Start at `0.1.0+1`. Increment the build number (iOS build, Android versionCode)
on every upload. Tag releases, record the commit SHA, and retain artifacts under
a stated policy.

## Human actions required (cannot be automated)

Apple Developer Program and Play Console accounts, organization verification,
bundle/app ID reservation, certificates and keys, store listings, privacy policy
URL, and release authorization. Legal review of the licensing exception must
precede any store distribution.
