# Accessibility checklist (Phase 6, M6.3)

## Automated (runs in CI)

`test/widget/accessibility_test.dart` checks every screen on a 360 x 640 phone:

- no layout overflow at 1x and 2x text size;
- tap targets meet the Android (48 dp) and iOS (44 pt) guidelines;
- every tappable control has a spoken label;
- text contrast meets the WCAG guideline;
- the live countdown is announced in whole minutes (so a screen reader is not
  interrupted every second) and overtime is announced.

Note: Flutter's test font is wider than real fonts, so the overflow tests are
stricter than a real phone. A pass there is a good sign, not proof.

## Manual, on a real iPhone (VoiceOver) and Android phone (TalkBack)

Turn the screen reader on, then:

| Check | Pass |
|---|---|
| Home: swipe through every item; the plan list, menu buttons ("Actions for ..."), New workout, Quick timer, Settings, and Templates are all reachable and named | |
| Builder: every field says what it is; segment and activity menus are reachable; Move up and Move down work without dragging | |
| Activity sheet: kind buttons, fields, error messages are read when they appear | |
| Live screen: the countdown is read as minutes remaining; Back, Next, interval buttons, menu, and End workout are all reachable in a sensible order | |
| Live screen: the countdown does not spam announcements while running | |
| Overtime is announced as overtime | |
| End dialog: both choices and Keep going are readable and reachable | |
| Settings: each switch says its name and state | |
| Quick timer: fields, Start, Pause, Reset are reachable | |

Then set the phone to its largest text size (and bold text on iPhone):

| Check | Pass |
|---|---|
| Nothing is cut off or overlapping on any screen | |
| The countdown, including `1:00:00`, fits on one line | |
| Back and Next stay large and reachable without scrolling the page | |
| Dialogs scroll when needed | |

And check display settings: dark mode is the default; try increased contrast
and reduce motion; try the phone in bright light.

## Record

Device, OS, screen reader version, date, tester, and each failure with a
screenshot or screen recording. File failures as issues labeled `accessibility`.
