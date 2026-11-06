# ADR-0001: GPLv3 with App Store exception

- Status: Accepted (pending legal review)
- Date: 2026-11-05

## Context

The v0.1 spec proposed Apache-2.0. The maintainer chose strong copyleft.
GPLv3 is widely considered incompatible with Apple's App Store terms, which add
usage restrictions GPLv3 section 10 forbids.

## Decision

- License the code under **GPLv3** plus an **additional permission under GPLv3
  section 7** allowing App Store, TestFlight, and Google Play distribution
  ([APP-STORE-EXCEPTION.md](../../../APP-STORE-EXCEPTION.md)).
- Dave Vigil is the initial copyright holder. Contributors retain copyright.
- No CLA and no copyright assignment.
- Contributions need DCO sign-off **and** explicit acceptance of GPLv3 plus the
  exception, since DCO alone does not grant the exception.
- GV5 Technologies LLC is credited as developer and publisher; this does not
  change copyright ownership.
- Do not switch to MIT/Apache-2.0 or add a CLA without discussing with the
  maintainer first.

## Consequences

- Every contribution must carry the exception, or the project cannot ship to the
  stores. Review enforces this.
- Dependencies must be GPLv3-compatible; see
  [third-party-licenses.md](../../legal/third-party-licenses.md).
- Legal review is a gating item before external contributions and store release.
