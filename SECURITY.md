# Security policy

## Reporting a vulnerability

Please **do not** open a public issue for security problems.

Use GitHub's private vulnerability reporting: go to the repository's
**Security** tab and choose **Report a vulnerability**
(<https://github.com/dgvigil/qhelper/security/advisories/new>).

You can expect an acknowledgement within a few days. Q Helper is maintained by
a small team, so fixes are best-effort.

## Scope

Q Helper stores data locally, has no accounts, and makes no network calls in
v0.1. Reports about local data handling, dependency vulnerabilities, leaked
credentials, or CI/release pipeline weaknesses are in scope.

## Secrets

Never commit keystores, API keys, certificates, or provisioning profiles. If you
find one in the repository, report it privately so it can be rotated.
