# Content licensing and review policy

> **LEGAL REVIEW REQUIRED** before any content ships in a release. This policy
> records the maintainer's intent; it is not legal advice.

Applies to non-code content bundled with or proposed for Q Helper: scripture,
motivational quotations, original Q Helper text (fellowship playbook, guides,
checklists), and community-contributed content. Code is covered by the
[licensing policy](licensing-policy.md) (GPLv3 plus the App Store exception).

## Principles

1. **The GPL covers code, not content.** Every content entry carries its own
   source and license. Do not assume a content item is GPL or free to reuse.
2. **No provenance, no ship.** An entry without complete provenance is rejected.
3. **Faith content is opt-in.** Default Off, with a perspective disclosure
   (see below). The Motivation track is secular in wording.
4. **Small and reviewed beats large and unverified.**
5. **F3 materials stay out** unless written permission is recorded in
   `docs/legal/`: no Exicon, Q101 text, or F3 logos.

## Scripture

- Use public-domain texts only: KJV, ASV, WEB (World English Bible, public
  domain). Record the edition used.
- Modern copyrighted translations (NIV, ESV, NLT, and similar) require a written
  license that permits offline redistribution in a GPL app. Until one is
  recorded here, do not include them.
- Quote verse text exactly from a named source edition; cite book, chapter,
  and verse.

## Motivational quotations

- Include only quotations that are public domain, or whose rights holder has
  given written permission.
- Every quotation needs a verifiable primary source (book, speech, date), not
  just a quote-aggregator site. Do not scrape quote sites.
- Unattributable or disputed quotes are rejected, not "attributed to".
- Quotes by living authors need permission.

## Original content (fellowship playbook, guides, checklists)

- Written by the maintainer or contributors for this project; no copying from
  other apps, F3 documents, or books.
- Content license: **decision pending legal review.** Proposed:
  CC BY-SA 4.0 for text, recorded per file. Until decided, mark files
  "license pending" and do not ship.
- Copyright stays with authors, consistent with the licensing policy;
  no CLA.

## Community-contributed content

- Contributor must state they wrote it or have the right to submit it, give
  the source, and accept the project's content license once chosen.
- DCO sign-off is required, as for code. It does not replace the license
  acceptance.
- Submissions are proposals; nothing ships until reviewed.

## Provenance record (required for every entry)

| Field | Meaning |
|---|---|
| `id` | Stable identifier |
| `track` | scripture, motivation, or playbook |
| `text` | The content |
| `source` | Work, edition, or URL of primary source |
| `author` | Person or translation committee |
| `license` | Public domain, permission (link to record), or content license |
| `submitted_by` | Contributor or maintainer |
| `reviewed_by` | Reviewers (see below) |
| `review_date` | Date of last review |

Stored with the content package and summarized in
[third-party-licenses.md](third-party-licenses.md).

## Review process

1. Provenance check: fields complete, source verified, license valid.
2. Content review by two people, at least one a maintainer.
3. Scripture: one reviewer confirms text matches the named edition and the
   verse is not used out of context.
4. Inclusivity check: wording is respectful of PAX of any belief; the
   Motivation track has no religious language; no shaming, politics, or
   promises about health or outcomes.
5. Playbook: one reviewer who has run a fellowship event checks it is practical.
6. Record reviewers and date in the provenance record.

Reviewers: two volunteers have agreed to review scripture and quotations. Both
have many years in the faith and in leadership roles. Record reviewers by role
or initials in provenance records, not full names. Because the initial
reviewers are close to the maintainer, the inclusivity check (step 4) should
also be done by someone independent of them, such as a P2 discovery
participant. A playbook reviewer is still open (tracked in the
[roadmap](../roadmap.md)).

## Perspective disclosure

The scripture and motivation content reflects the Christian faith of the
author. The opt-in screen and About screen must say so plainly, along with
these points: F3 does not support any one religion; Q Helper is an independent
project, not endorsed by F3 Nation; faith content is optional and can be turned
off at any time. Do not imply that F3 or other PAX hold these views. Wording is
tested with P2 discovery participants before release.

## Prototype Codex bundle (not cleared to ship)

A prototype in this repository bundles exercise and term text from F3 Nation's
[the-codex](https://github.com/F3-Nation/the-codex) so a phone can search it
offline. That repository has no license file. The text is not covered by the
GPL. Principle 5 still applies: this bundle must not ship in a release until
written permission is recorded in `docs/legal/`. The import path and the
refresh steps are in [tool/codex/README.md](../../tool/codex/README.md). The
decision is [ADR-0004](../architecture/decisions/0004-on-device-assistant-prototype.md).

## Removal and takedown

- Anyone may report a rights, accuracy, or inclusivity concern through the
  project's issue tracker or the contact in SECURITY.md.
- Maintainers pull the entry in the next release and record the reason;
  rights claims are acted on promptly.
- Removed entries are not reintroduced without a new review.
