# Licensing policy

> **LEGAL REVIEW REQUIRED** before (a) accepting any external contribution and
> (b) distributing Q Helper through any app store. This policy records the
> maintainer's decisions; it is not legal advice.

## Decisions

| Topic | Decision |
|---|---|
| Code license | GNU GPL v3 ([LICENSE](../../LICENSE)) |
| Additional permission | App Store exception under GPL v3 §7 ([APP-STORE-EXCEPTION.md](../../APP-STORE-EXCEPTION.md)) |
| Initial copyright holder | Dave Vigil |
| Contributor copyright | Contributors **retain** copyright in their contributions |
| Copyright assignment / CLA | **None.** Do not introduce one without discussing with the maintainer first |
| Developer / publisher credit | GV5 Technologies LLC (README, About screen, store listings) |
| Official repository | `github.com/dgvigil/qhelper` (public) |
| Trademarks, icon, branding | Not covered by the GPL or the exception |
| F3 content | No F3 logos, Exicon, or Q101 text without explicit written rights |

## Copyright notice

Use: `Copyright (C) 2026 Dave Vigil and Q Helper contributors`. Do not claim
copyright on behalf of contributors who have not assigned it; the phrase
"and Q Helper contributors" reflects their retained rights.

## Contribution terms

DCO sign-off certifies origin and the right to submit. It does **not** grant
the App Store exception and does **not** transfer copyright. Therefore each
contribution must also include explicit acceptance that it is licensed under
GPL v3 **plus** the App Store exception. See [CONTRIBUTING.md](../../CONTRIBUTING.md).

Consequence: because contributors keep their copyright, the maintainer can
ship to app stores only if every contributor's code is under the exception.
Reject any PR that omits the acceptance.

## Dependency compatibility

Every dependency must be GPLv3-compatible (permissive licenses such as MIT,
BSD, Apache-2.0 are fine; Apache-2.0 is compatible with GPLv3 but not GPLv2).
Reject GPL-incompatible or proprietary dependencies. Audit table:
[third-party-licenses.md](third-party-licenses.md). Re-run the audit whenever
`pubspec.lock` changes.

## Open items for legal review

1. Wording of APP-STORE-EXCEPTION.md and whether it is effective against
   Apple's current terms.
2. Contribution acceptance language in CONTRIBUTING.md and the PR template.
3. Interaction of GV5 publisher credit with personal copyright ownership.
4. Whether the "trademarks not licensed" statement needs strengthening.
