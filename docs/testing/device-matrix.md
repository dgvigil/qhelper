# Physical-device test matrix (Phase 6, M6.1)

Run on at least one **iPhone** (iOS 17 or later) and one **Android phone**
(Android 10, API 29, or later, ideally one running Android 13+ for the
notification prompt). Simulators and emulators do not count: they cannot show
lock-screen, silent-switch, Focus, battery, or notification behavior.

Use a beta build, airplane mode on unless a row says otherwise, and a workout
with a reps activity, a free-form activity, and a timed activity (for example
40 s work, 20 s rest, 5 rounds) with a 45 minute target.

Mark each cell **Pass**, **Fail** (file an issue; label `release-blocker` if a
workout is lost or timing is clearly wrong), or **N/A**. Add the device, OS
version, app build, tester, and date at the top of each run.

| # | Scenario | What to do | Expected | iPhone | Android |
|---|---|---|---|---|---|
| 1 | Airplane mode, everything | Create, save, start, edit, finish, share (share sheet only) with all radios off | Everything works; no network errors or prompts | | |
| 2 | Lock and unlock mid-workout | Start a workout, lock for 2 minutes, unlock | Countdown is about 2 minutes lower; interval is in the right phase; no replayed sounds | | |
| 3 | Screen stays awake | Keep-awake on, leave the phone untouched for the system auto-lock time | Screen stays on during the workout, and returns to normal after ending | | |
| 4 | Keep-awake off | Turn it off in Settings and repeat row 3 | Screen locks as usual; workout continues | | |
| 5 | Background and foreground | Switch to another app for 3 minutes, return | Same as row 2 | | |
| 6 | Killed and relaunched | Follow [process-kill-recovery.md](process-kill-recovery.md) | Resume or End offered; position, edits, and timers correct | | |
| 7 | Silent switch / ringer off | Run an interval with sound and haptics on | Record what you hear and feel. Sound may be silent; haptics should still work | | |
| 8 | Focus / Do Not Disturb | Turn it on and run an interval | Record behavior. Q Helper must not crash or stall | | |
| 9 | Sound off, haptics on | Settings: sound off | Vibration only | | |
| 10 | Sound on, haptics off | Settings: haptics off | Sound only | | |
| 11 | Notification allowed | Allow when asked, start a 2 minute workout, lock the phone | A "Time is up" notification arrives near the deadline (not necessarily to the second) | | |
| 12 | Notification denied | Deny when asked, repeat row 11 | No notification; app works normally; no repeated prompts | | |
| 13 | Notification turned off in Settings | Turn off, start a workout | No prompt, no notification | | |
| 14 | Large text | Set the phone to its largest text size; open every screen | Nothing cut off or unreachable; countdown still readable | | |
| 15 | Screen reader | See [accessibility-checklist.md](accessibility-checklist.md) | All controls announced and usable | | |
| 16 | Long workout | 60 minute workout run for the full hour with the phone locked part of the time | Countdown accurate to a couple of seconds at the end | | |
| 17 | Overtime | Let a workout pass its deadline by 10 minutes | Overtime shown in a different color; one end cue only; workout is not ended automatically | | |
| 18 | Clock change back | While running, set the phone clock back 10 minutes | Countdown does not gain time | | |
| 19 | Clock change forward | Set it forward 10 minutes | Countdown loses time (documented limitation) | | |
| 20 | Low battery / Low Power mode | Run an interval with Low Power mode on | Timing stays correct; cues best effort | | |
| 21 | Rotate | Rotate the phone on the live screen | Layout still usable (portrait is the supported layout) | | |
| 22 | Outdoor readability | Use in bright sun and at dawn | Countdown and Next button readable; note anything hard to see | | |
| 23 | Interrupt by a call | Receive a call mid-workout, then return | Workout still running; time passed; no crash | | |
| 24 | Install update over a previous build | Install a newer beta over an older one with a saved workout | Saved workouts remain | | |

## Result summary

- Devices and OS versions:
- Build:
- Date and tester:
- Failures and issue links:
- Release blockers open: yes / no
