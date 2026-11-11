# Competitive analysis: F3 Q Sheet and Q Master for F3

- Prepared: 2026-11-10; revised 2026-11-10 to separate evidence levels.
- Sources: the two public App Store listings only (descriptions, version history,
  ratings, privacy labels, compatibility). **No app was installed or run.**
  Version dates on the listings carry no year, so release cadence is approximate.
- Companion to the [v0.1 spec](../Q_Helper_v0.1_Open_Source_Spec.md) and the
  [roadmap](roadmap.md).

## 0. How to read this document

Each competitor capability has one of three evidence levels:

| Level | Meaning |
|---|---|
| **Confirmed** | A project member installed and ran the app; app version and date recorded |
| **Advertised** | The developer's listing says so; unverified |
| **Unknown** | Not stated on the listing, or not checked. **Not evidence that the feature is absent** |

Currently nothing is Confirmed. Roadmap track P1 (competitive field testing)
upgrades Advertised and Unknown entries by running the apps. Do not describe a
competitor as lacking a feature unless it is Confirmed missing.

## 1. Summary

Two free iOS apps from solo developers already cover the "Q tool" space. Both
advertise a workout builder, timers, and F3 content; one advertises backblast
and a preamble script, the other Apple Watch, AI generation, and Slackblast
posting. Neither listing mentions an Android version, a daily faith or
motivation feature, or fellowship guidance. That is unknown, not proven absent.

Q Helper's candidate advantages, each to be validated: **Android** (planned),
**timer reliability and audible handling** (planned), **open source**, and
**Fellowship and Faith content** (planned for v0.2). Candidate disadvantages
where competitors advertise features: **content library and Exicon**,
**backblast**, **Apple Watch**, and **AI generation**.

Position: keep v0.1 narrow and reliable, make the Three-F
foundation the focus of v0.2, and run P1 and P2 in parallel. Open the F3 Nation
content-permission conversation now; it is only required for official Exicon
integration, which is conditional and not a release dependency.

## 2. The two competitors

### F3 Q Sheet: Workout Leader (Dane Bonnigson)
All items below are **Advertised** unless noted.
- Free, iPhone only, iOS 17+, 2.4 MB, no ratings yet. Versions 1.0 (Oct 12) and
  1.1.0 (Oct 14), so roughly a month old.
- Run mode: preamble checklist with full script (welcome, FNG check, disclaimer,
  phones/emergency, core principles, mission, credo); phase timers for
  Warm-O-Rama, the Thang, Mary; 45:00 overall clock; loud 3-2-1 and end beeps at
  a user-set alarm volume (even with ringer off); notification when locked;
  screen stays awake.
- Extras: Tabata/EMOM interval timer, dice roller, deck-of-cards flipper.
- Content: 100 ready-to-run workouts across 20 formats; filters by gear,
  intensity, format; favorites; 86-exercise Exicon; 51-term lexicon and a slang
  translator; link to the F3 Nation map.
- Build your own: step-by-step builder; copy steps from library workouts;
  duplicate and edit library workouts ("Mine" filter).
- Circle of Trust: Count-o-rama, Name-o-rama with FNG marking, notes for
  announcements and prayer requests, one-tap backblast, saved backblast history.
- Privacy label: declares no data collected (self-declared, unverified).
- v1.1.0 says "Now F3 Q Sheet, with the official F3 logo."

### Q Master for F3 (Ian Wilkinson)
All items below are **Advertised** unless noted.
- Free (no in-app purchases found on the listing), iPhone/iPad/Apple Watch/Mac/
  Vision, iOS 18+, 60 MB. 6 ratings, 5.0. Roughly ten releases (1.0 on Feb 6
  through 3.5.1 on Oct 27).
- Planning: "digital weinke" builder with custom sections, drag-reorder
  (including between sections), paste a workout list from a spreadsheet or
  another app, and a "Q scheduler".
- AI: generate a workout from a short prompt (a reviewer cites "1 hour of 40%
  cardio, 60% arms").
- Exicon: exercise picker loads descriptions and videos dynamically from the
  official Exicon.
- Games/timers: Deck of Pain, Dodecahedron of Death, Tabata timer.
- Apple Watch: workouts sync to the watch; complication support.
- Sharing: social share, AirDrop a whole beatdown to another Q Master user,
  post directly to Slackblast; find beatdowns near you.
- Privacy label: declares no data collected (self-declared; AI generation and
  dynamic Exicon loading suggest network use, so verify before repeating it).
- Reviews are short and positive ("no wet, soggy paper", "build workouts with ease").

## 3. Feature matrix

Competitor columns: **A** = Advertised, **U** = Unknown (not stated or not
checked), **C** = Confirmed (none yet). Q Helper column shows plan, not shipped
fact: v0.1 = in the v0.1 spec; v0.2 to v0.4 = roadmap; Backlog = unscheduled;
Excluded = not planned.

| Capability | Q Sheet | Q Master | Q Helper |
|---|---|---|---|
| iOS | A (iPhone) | A (iPhone/iPad/Watch/Mac) | v0.1 |
| Android | U (no Android listing found; Play Store not checked) | U (same) | v0.1 |
| Free, no ads | A | A (ads not stated) | v0.1 |
| No account required | A | U | v0.1 |
| Open source | U (no source link on listing) | U (same) | v0.1 (GPLv3) |
| Build own workout | A | A | v0.1 |
| Flexible length (30/45/60/custom) | U (listing describes a 45:00 clock) | U | v0.1 |
| Master countdown with overtime | A (overall clock); overtime U | U | v0.1 |
| Session-only audible edits, saved plan untouched | U | U | v0.1 |
| Recover after app kill | U | U | v0.1 |
| Interval/Tabata timer | A | A | v0.1 |
| Loud alarm independent of ringer | A | U | Best-effort cues in v0.1; loud-alarm option to investigate |
| Preamble script | A | U | Not planned yet |
| Workout library | A (100) | U (AI instead) | v0.1: 2 structural templates |
| Exicon | A (86 exercises) | A (full, with videos) | Conditional on F3 permission |
| AI workout generation | U | A | Backlog |
| Dice / cards games | A | A | Not planned |
| Count-o-rama / Name-o-rama | A | U | v0.3 |
| Backblast | A (history) | A (Slackblast post) | v0.3 |
| Apple Watch | U | A | v0.4 |
| Share/export plan | A (backblast) | A (social, AirDrop, Slackblast) | v0.1 plain text |
| Find a workout / F3 map | A (link) | A | Not planned |
| Daily faith/motivation | U | U | v0.2 |
| Fellowship guidance | U | U | v0.2 |

## 4. Where Q Helper may differentiate (hypotheses to validate)

1. **Android.** Neither App Store listing mentions it, but that is not proof
   neither developer ships one. P1 checks the Play Store and developer sites.
2. **Audibles without losing the plan.** The session snapshot (spec section 4)
   lets a Q change the live workout while the saved plan stays intact. The
   listings do not say whether the competitors do this; P1 will test it.
3. **Reliability under real conditions.** Master deadline independent of
   intervals, overtime display, resume after the app is killed, tested clock
   behavior. Competitor behavior is Unknown until tested.
4. **Open source and trust.** Inspectable and forkable; not dependent on one
   developer. Neither listing shows source, but check before claiming it.
5. **Faith and fellowship.** Not advertised by either listing. Q Sheet's
   prayer-request notes are the nearest feature. Discovery (P2) tests demand.
6. **Flexible duration.** Q Sheet advertises a 45:00 clock; whether it supports
   other lengths is Unknown.

## 5. Where competitors advertise strength

- **Content:** Q Sheet advertises 100 workouts; Q Master the full Exicon with video.
- **Backblast:** Both advertise it (history; Slackblast).
- **Apple Watch:** Q Master advertises it and a reviewer cites hands-free use.
- **AI generation:** Q Master advertises it.
- **Games:** Dice, deck of cards, Deck of Pain, Dodecahedron of Death.
- **Pace:** Q Master's version history shows a high release cadence.
- **F3 relationship:** Q Sheet displays the official F3 logo; Q Master pulls the
  official Exicon. This suggests some arrangement with F3 Nation, but the
  terms are Unknown.

## 6. Faith and fellowship opportunity

F3's three Fs are fitness, faith, fellowship. Neither listing advertises
fellowship or faith features. Planned for v0.2 (see [roadmap](roadmap.md)).

### Faith: optional daily encouragement
- Offline, small reviewed collection (starter target 30-60 entries, not 365).
- **Opt-in.** Preferences: Scripture, Motivation, Both, Off; default Off.
  Using the maintainer's rough estimate (about 62% Christian, 29% unaffiliated,
  remainder other faiths; not independently sourced), default-on scripture
  would alienate many users. The secular Motivation track serves PAX who do not
  want scripture.
- **Rights and review:** governed by the [content policy](legal/content-policy.md):
  public-domain scripture, verified quotations, per-entry provenance, two-person
  review.

### Fellowship: playbook
- Original guides and checklists: coffeeteria, monthly luncheon, holiday
  gathering, service project, 2nd-F check-in.
- Plain-text share through the existing share sheet. No accounts, scheduling
  backend, event registration, or social features.
- Original content has no dependency on F3.

### Why this matters
It differentiates on mission rather than features. A timer can be copied in a
sprint; a community-reviewed fellowship playbook is harder to copy. Whether Qs
want it is a hypothesis for P2 discovery.

## 7. Collaboration vs. competition

1. **Compete on the hypothesized gaps.** Low friction, no dependency on another
   developer.
2. **Approach Ian Wilkinson (Q Master).** Possible asks: how Exicon data was
   obtained and what rights apply; interest in an Android companion; a shared
   plan file format.
3. **Approach Dane Bonnigson (Q Sheet).** Newest and simplest; open to feedback?
   (Unknown.)
4. **F3 Tech / F3 Nation.** Needed only for official Exicon integration, which
   is conditional and not a release dependency. Record any result in
   `docs/legal/`.

Caution: neither listing shows an open-source license. Sharing code with a
closed app conflicts with GPLv3 unless that developer relicenses; data-format
or referral collaboration is more likely.

## 8. Risks

| Risk | Note |
|---|---|
| Content gap affects adoption | Good structural templates in v0.1; original playbook in v0.2; Exicon only with permission |
| Solo competitors iterate faster | Keep v0.1 narrow; ship cross-platform early |
| GPL + App Store | Pending legal review; blocks store release regardless of competition |
| Inclusivity of faith content | Opt-in, default Off, secular track, review per content policy |
| Content provenance | Per-entry records and review; see content policy |
| Competitor privacy claims | "No data collected" is self-declared; do not repeat without verification |
| Independence notice | If F3 Nation grants official status, revisit the wording |
| Analysis based on listings only | P1 field testing replaces Unknown with Confirmed |

## 9. Resulting roadmap decisions

Applied in [roadmap.md](roadmap.md):

1. v0.1 scope unchanged; Phases 0-8 preserved.
2. v0.2 is the Three-F foundation (daily encouragement, content collection,
   fellowship playbook).
3. Circle of Trust assistance and backblast drafting moved to v0.3.
4. Exicon integration is conditional on documented F3 permission.
5. Apple Watch, Wear OS evaluation, Live Activities, and hands-free controls in v0.4.
6. AI workout generation and community synchronization stay in the backlog.
7. P1 (this document's field testing) and P2 (Three-F discovery) run in parallel.
8. A loud-alarm investigation remains a candidate for Phase 5 device-adapter work.

## 10. Open questions

- Should the project contact either developer, and who leads that?
- Is Android-first messaging acceptable once P1 confirms the gap?
- Scripture and quotations: reviewers agreed (see content policy). Who reviews
  the fellowship playbook?
- Who runs P1 testing, and on which devices?
