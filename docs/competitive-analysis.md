# Competitive analysis: F3 Q Sheet and Q Master for F3

- Prepared: 2026-11-10
- Sources: the two public App Store listings only (descriptions, version history,
  ratings, privacy labels, compatibility). **No app was installed or run.** All
  claims below are the developers' own statements and unverified. Version dates
  on the listings carry no year, so release cadence is approximate.
- Companion to the [v0.1 spec](../Q_Helper_v0.1_Open_Source_Spec.md).

## 1. Summary

Two free, iOS-only apps from solo developers already cover the "Q tool" space.
Neither lists Android support, a daily faith/motivation feature, or fellowship
guidance. Both use F3's Exicon; one displays the official F3 logo. The cheapest
real advantages for Q Helper are **Android**, **timer reliability and audible
handling**, **open source**, and **faith and fellowship content**. The cheapest
real disadvantages are **content** (workout library, Exicon), **backblast**, and
**Apple Watch/AI**, where competitors already ship.

Recommendation: continue. Keep v0.1 narrow and reliable, then make
faith + fellowship the headline of v0.2. Open the F3 Nation content-permission
conversation now, since both competitors appear to have solved it.

## 2. The two competitors

### F3 Q Sheet: Workout Leader (Dane Bonnigson)
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
- Privacy: declares no data collected; no account, ads, or tracking.
- Notable: v1.1.0 says "Now F3 Q Sheet, with the official F3 logo."

### Q Master for F3 (Ian Wilkinson)
- Free (no in-app purchases found on the listing), iPhone/iPad/Apple Watch/Mac/
  Vision, iOS 18+, 60 MB. 6 ratings, 5.0. Roughly ten releases (1.0 on Feb 6
  through 3.5.1 on Oct 27), so it iterates quickly.
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
- Privacy: declares no data collected.
- Reviews are short and positive ("no wet, soggy paper", "build workouts with ease").

## 3. Feature matrix

Legend: Y = listed, N = not listed, P = planned/partial.

| Capability | Q Sheet | Q Master | Q Helper v0.1 |
|---|---|---|---|
| iOS | Y (iPhone) | Y (iPhone/iPad/Watch) | Y |
| **Android** | N | N | **Y** |
| Free, no ads | Y | Y | Y |
| No account | Y | Not stated | Y |
| Open source | N | N | **Y** |
| Build own workout | Y | Y | Y |
| Flexible length (30/45/60/custom) | N (45 min) | Not stated | **Y** |
| Master countdown + overtime | Overall clock; overtime not stated | Not stated | **Y** |
| Session-only audible edits (plan untouched) | N | N | **Y** |
| Recover after app kill | Not stated | Not stated | **Y** |
| Interval/Tabata timer | Y | Y | Y |
| Loud alarm independent of ringer | Y | Not stated | N (best-effort cues) |
| Preamble script | Y | N | N |
| Workout library | 100 | N (AI instead) | N (2 structural templates) |
| Exicon | 86 exercises | Full, with videos | N (no rights) |
| AI workout generation | N | Y | N (excluded) |
| Dice / cards games | Y | Y | N |
| Count-o-rama / Name-o-rama | Y | N | N |
| Backblast | Y (history) | Slackblast post | N (excluded) |
| Apple Watch | N | Y | N (roadmap v0.3) |
| Share/export plan | Backblast only | Social, AirDrop, Slackblast | Plain-text share |
| Find a workout / F3 map | Link | Y | N |
| Daily faith/motivation | N | N | **Proposed** |
| Fellowship guidance | N | N | **Proposed** |

## 4. Where Q Helper can win

1. **Android.** Neither app lists it. Every Android Q is unserved. This is the
   clearest, most defensible gap, and Flutter already targets it.
2. **Audibles without losing the plan.** The session snapshot (spec section 4)
   lets a Q change the live workout while the saved plan stays intact. Neither
   listing mentions this.
3. **Reliability under real conditions.** Master deadline independent of
   intervals, overtime display, resume after the app is killed, tested clock
   behavior. Competitor listings are silent on all of it.
4. **Open source and trust.** Inspectable, forkable, and not dependent on one
   developer. Useful for a volunteer community.
5. **Faith and fellowship.** The second and third Fs are unserved. Q Sheet's
   prayer-request notes are the only nearby feature.
6. **Flexible duration** versus a fixed 45-minute model.

## 5. Where competitors are ahead

- **Content:** Q Sheet ships 100 workouts; Q Master has the full Exicon with
  video. A new Q picking an app will compare libraries first.
- **Backblast:** Both cover it (history; Slackblast). The spec excludes it.
- **Apple Watch:** Q Master already has it and users cite it ("no phone in hand").
- **AI generation:** Q Master has it; the spec excludes it.
- **Games:** Dice, deck of cards, Deck of Pain, Dodecahedron of Death.
- **Pace:** Q Master's release cadence is high; a solo developer can out-ship a
  spec-driven, phase-gated project.
- **F3 relationship:** Q Sheet displays the official F3 logo; Q Master pulls the
  official Exicon. Both suggest an arrangement with F3 Nation. We do not know
  the terms.

## 6. Faith and fellowship opportunity

Idea from the F3 discussion: F3's three Fs are fitness, faith, fellowship, and
the apps only serve fitness.

### Faith: daily scripture and motivation
- Offline bundle of ~365 entries; one rotates per day; shown on the home screen
  and optionally in the Circle of Trust or preamble.
- **Opt-in with a clear toggle.** Using the figures you cited (about 62% Christian,
  29% unaffiliated, remainder other faiths), a default-on scripture feature would
  alienate roughly four in ten users, and F3 workouts include non-Christian men.
  Offer content *tracks*: Scripture, Motivation (secular), or Both/Off. The
  motivation track also helps with the unaffiliated majority of newcomers.
- **Rights:** modern translations (NIV, ESV, NLT) are copyrighted and need a
  license. Use public-domain texts (KJV, WEB, ASV) and public-domain quotations
  with a documented provenance for every entry. Do not scrape quote sites.
- Content lives in a separate asset package with its own source and license
  table (`docs/legal/third-party-licenses.md`), consistent with spec section 7.8.

### Fellowship: ideas for the second F
- A short, original "Fellowship playbook" written by us: how to start a
  coffeeteria, a monthly luncheon, a Christmas/holiday gathering, a service
  project, a 2nd-F check-in; each as a simple checklist (who, when, where, what
  to say in the COT).
- Reminder prompt in the Circle of Trust ("any 2nd F plans this week?").
- No accounts or scheduling backend in v0.2; share as plain text through the
  existing share sheet.
- This is original content, so it has no licensing risk and no dependency on F3.

### Why this matters
It differentiates on mission, not features. A competitor can copy a timer in a
sprint; it is harder to copy a thoughtful, community-reviewed fellowship
playbook, especially if local Qs and chaplains help write it.

## 7. Collaboration vs. competition

Options, in rough order of fit:

1. **Compete on the gaps (recommended).** Android, reliability, open source,
   faith/fellowship. Low friction, no dependencies on another developer.
2. **Approach Ian Wilkinson (Q Master).** He has the most mature product, Watch
   support, and Exicon access. Possible asks: how he obtained Exicon data and
   what rights apply; whether he wants an Android companion (Q Helper is
   Flutter); whether shared file formats make sense (his AirDrop share and paste
   import suggest a data format could be agreed).
3. **Approach Dane Bonnigson (Q Sheet).** Newest, simplest, likely open to
   feedback; he has a library but no Android and no Watch.
4. **F3 Tech / F3 Nation.** The key conversation. Whatever permission the two
   competitors have, Q Helper needs the same to ship content in v0.2. The spec
   already runs this outreach in parallel; it should start now.

Caution: neither competitor is open source. A merge or code-sharing deal with a
closed app conflicts with GPLv3 unless that developer chooses to relicense. Any
collaboration is more likely to be data-format or referral based than shared code.

## 8. Risks

| Risk | Note |
|---|---|
| Content gap blocks adoption | Mitigate with F3 permission (v0.2) and good structural templates in v0.1 |
| Solo competitors out-iterate us | Stay narrow in v0.1; ship the cross-platform advantage early |
| GPL + App Store | Still pending legal review; blocks store release regardless of competition |
| Inclusivity of faith content | Opt-in tracks; never default-on scripture |
| Public-domain scripture/quotes provenance | Per-entry source table; legal check |
| Competitor privacy claims | "No data collected" is self-declared; AI generation and Exicon loading imply network use. Do not repeat the claim without verification. |
| Independence notice | If F3 Nation grants official status, revisit the "not affiliated" wording |

## 9. Suggested spec changes (for discussion, not applied)

1. Keep v0.1 scope as is. Add a short "Competitive position" section to the spec.
2. Move **backblast** from "excluded" to the v0.2 roadmap (both competitors ship it).
3. Add **v0.2: Faith and Fellowship**: opt-in daily content (Scripture/Motivation/Off),
   Fellowship playbook, content provenance table, separate asset package.
4. Reorder the roadmap: Watch (currently v0.3) stays after content; AI
   generation stays out in favor of deterministic suggested plans already listed.
5. Add a **loud alarm option** investigation to Phase 5: Q Sheet's alarm-volume
   feature is a field-valued behavior; verify what iOS and Android allow.
6. Start F3 Nation content-permission outreach immediately and record the result
   in `docs/legal/`.

## 10. Open questions for the maintainer

- Do you want to contact either developer, and who leads that?
- Are faith/fellowship features intended to be part of the open-source repo or a
  separately governed content package?
- Is Android-first marketing acceptable, since it is the clearest gap?
- Who will review the scripture/quote selections and the fellowship playbook?
