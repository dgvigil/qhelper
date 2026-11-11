# Manual check: process kill and relaunch recovery

Automated tests cover session recovery against the real database
(`integration_test/app_flow_test.dart`), but they restart the app inside the
test process. Only a person can confirm that the operating system really kills
the app and that a workout comes back. Run this on a physical iPhone and a
physical Android phone before every beta build, and record the result in the
release notes.

Use a fresh install, airplane mode on, and a workout with at least three
activities where the second one is timed (for example 40 s work, 20 s rest,
5 rounds).

## Steps

1. Start the workout. Note the master countdown and move to the timed
   activity with **Next**.
2. Start the interval timer. Note the phase and the time left in it.
3. Force-close the app.
   - iPhone: swipe up from the bottom, hold, and flick Q Helper away.
   - Android: open recents and swipe Q Helper away, then also use
     **Settings > Apps > Q Helper > Force stop** on a second run.
4. Wait 60 seconds (lock the phone for part of it).
5. Reopen Q Helper.

## Expected

- Home shows **Workout in progress** with **Resume** and **End workout**.
- **Resume** opens the live screen on the same activity.
- The master countdown has kept counting: about one minute less than before
  the close, or overtime if the deadline passed.
- The interval timer is in the phase that matches the elapsed time. Missed
  phase changes are skipped, and no sounds or vibrations are replayed.
- Edits made during the workout (audibles) are still there, and the saved
  workout on Home is unchanged.
- **End workout** ends it, and Home no longer shows the banner.

## Variations to repeat

| Variation | Expected |
|---|---|
| Pause the interval before closing | Still paused after Resume, with the same time left |
| Close during overtime | Resume shows overtime, no end sound |
| Reboot the phone instead of closing the app | Workout is offered for Resume. The countdown follows the device clock, so it may be off if the clock was changed (documented limitation) |
| Deny notifications, then repeat | Same result; no errors |
| Turn the phone clock back 10 minutes, then Resume | The countdown does not gain time |
| Turn the phone clock forward 10 minutes, then Resume | The countdown loses time (documented limitation) |

## Record

Device and OS version, app build, date, tester, pass or fail for each row, and
anything surprising. File defects as issues with the label `release-blocker`
if a workout is lost or the countdown is clearly wrong.
