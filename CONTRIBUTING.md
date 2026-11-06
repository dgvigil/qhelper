# Contributing to Q Helper

> **Not yet accepting external contributions.** The licensing exception and
> these contribution terms are pending legal review (see
> [docs/legal/licensing-policy.md](docs/legal/licensing-policy.md)). Issues and
> discussion are welcome now; pull requests will be reviewed once that is done.

## Licensing of contributions

Q Helper is licensed under the **GNU GPL v3** with the **App Store exception**
in [APP-STORE-EXCEPTION.md](APP-STORE-EXCEPTION.md). By submitting a
contribution you agree that:

1. **You license your contribution under the GNU GPL v3 *with* the App Store
   exception** in APP-STORE-EXCEPTION.md. This is required so the project can be
   distributed through Apple's App Store/TestFlight and Google Play.
2. **You keep the copyright** in your contribution. There is no copyright
   assignment and no CLA.
3. You have the right to submit it (see the DCO below), and it contains no F3
   logos, Exicon, Q101 text, or other third-party material without written
   rights.

**DCO sign-off alone is not enough.** The Developer Certificate of Origin
certifies where code came from; it does not grant the App Store exception. Every
pull request must include both:

- `Signed-off-by: Your Name <you@example.com>` on each commit (`git commit -s`), and
- the checked acceptance box in the pull request template stating you license
  the contribution under GPLv3 plus the App Store exception.

Pull requests missing either will not be merged.

## Workflow

1. Open or find an issue. v0.1 scope is fixed by the spec; larger features wait.
2. Fork, branch from `main`.
3. **Write a failing test first**, then the minimum code to pass it, then
   refactor on green. Timer, session, and persistence logic require unit tests.
4. Run before pushing:
   ```sh
   fvm flutter pub get
   dart format --output=none --set-exit-if-changed .
   fvm flutter analyze
   fvm flutter test
   ```
5. Open a PR using the template. CI must pass and the maintainer must review.

## Dependencies

New dependencies must be GPLv3-compatible, pinned to an exact version, and added
to [docs/legal/third-party-licenses.md](docs/legal/third-party-licenses.md).

## Conduct and security

Follow the [Code of Conduct](CODE_OF_CONDUCT.md). Report vulnerabilities
privately per [SECURITY.md](SECURITY.md).
