# Known issues and limits (Phase 6, M6.4)

Last reviewed after the automated Phase 6 pass. Release-blocking means a
workout can be lost, timing is clearly wrong, or the app cannot be used.
**No known release-blocking defects** in the code as tested on an iOS
simulator and in automated tests; physical-device results are still pending.

## Fixed during Phase 6

| Finding | Fix |
|---|---|
| A one-hour countdown (`1:00:00`) wrapped onto two lines at large text sizes | Countdown now shrinks to fit on one line |
| The interval panel header could overflow at large text | Header text is flexible |
| A workout with no segments offered "Add activity", which did nothing | Menu item is disabled |
| Turning the end-of-workout notification off during a workout did not cancel one already scheduled | Turning it off now cancels it |

## Open, not release-blocking

| Issue | Effect | Plan |
|---|---|---|
| iPhone may not show the notification while the app is in the foreground | None for the Q: the app shows overtime and plays the cue | Confirm on a device; set the iOS foreground presentation if needed |
| Forward device-clock change shortens the countdown | Documented limitation | Documented in [device-behavior.md](device-behavior.md) |
| Cues use the system alert sound and can be silenced by the phone | A Q may not hear the cue | Investigate a louder option after beta feedback |
| Privacy and support links are copyable text, not tappable | Minor inconvenience | Add `url_launcher` after a license check |
| "Keep screen awake" defaults to on | Spec says "when the user has opted in" | Maintainer to confirm the default before beta |
| Android has not been run on any emulator or phone | Unknown Android-specific defects | Phase 6 device matrix; recruit an Android tester |
| Portrait only is tested | Landscape layout may be cramped | Check matrix row 21 |

## How to report

Open an issue at <https://github.com/dgvigil/qhelper/issues>. Include the phone,
OS version, app build, and what you expected. Add the label `release-blocker` if
a workout is lost or timing is clearly wrong.
