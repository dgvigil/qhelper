# Testing Q Helper in a simulator

How to run and hand-check Q Helper on a Mac without a phone. It is written for
contributors and maintainers who want a quick manual check, or want to repeat
a verification later. Run every command from the repository root.

A simulator is not a substitute for a phone. See the last section, and the
[device matrix](device-matrix.md), for what only real hardware can show.

## 1. Run the app in the iOS simulator

```sh
open -a Simulator                          # start the Simulator app
fvm flutter devices                        # list simulators and their IDs
fvm flutter run -d "iPhone 17 Pro"         # build and launch the app
```

While it runs: `r` hot reloads after a code change, `R` restarts the app, and
`q` quits. Data lives inside the simulator, so saved workouts survive restarts
of the app.

If `fvm flutter devices` shows no iPhone, open Xcode > Settings > Components
and install an iOS simulator runtime, then try again.

## 2. Hand-check list

| Area | What to do | Expected |
|---|---|---|
| Build and save | Create a workout with a reps, a timed, and a free-form activity. Save it | It appears on Home with the right summary |
| Templates | Templates button, pick 45 or 60 minutes | Four segments with times; editable |
| Share | Menu on a workout > Share | The share sheet opens with readable plain text |
| Run a workout | Menu > Start. Use Next and Back | Countdown runs; current and next activity update |
| Interval timer | On a timed activity: Start, Pause, Resume, Skip, Reset | Phases and rounds follow the timer |
| Edit during a workout | "Change this workout" > edit, add, remove | Changes apply to this workout only; the saved workout is unchanged |
| End | End workout > End early or Finished | Back on Home; no "Workout in progress" banner |
| Recovery | Start a workout, then force-quit the app (see section 4), reopen | Home shows **Workout in progress**; Resume restores your place |
| Quick timer | Quick timer button, set work/rest/rounds, Start | Runs with no saved workout; bad input shows an error |
| Settings | Toggle each switch; change default length; open About | Saved immediately; a new workout uses the default length |
| Notification prompt | Start your first workout | A permission prompt appears once; Deny keeps everything working |
| Overtime | Create a 1 minute custom workout, start it, wait | Countdown turns to overtime in a different color; workout keeps running |

## 3. Appearance and accessibility in the simulator

```sh
xcrun simctl ui booted content_size accessibility-extra-extra-extra-large
xcrun simctl ui booted content_size large          # back to normal
xcrun simctl ui booted appearance dark             # or: light
```

Check that nothing is cut off at the largest text size, and that the countdown
(including `1:00:00` on a 60 minute workout) stays on one line.

For screen reader output, open Xcode > Open Developer Tool > Accessibility
Inspector, point it at the simulator, and inspect each screen's labels.

## 4. Fresh starts and relaunches

```sh
xcrun simctl terminate booted com.gv5technologies.qhelper   # kill the app, like a swipe-away
xcrun simctl launch booted com.gv5technologies.qhelper      # reopen it
xcrun simctl uninstall booted com.gv5technologies.qhelper   # remove the app and its data
xcrun simctl erase <device id>                              # reset one simulator completely
```

`xcrun simctl erase all` resets every simulator and removes all app data,
permissions, and settings. Use the single-device form unless you mean it. After
an erase the notification prompt will appear again.

## 5. Automated tests

```sh
fvm dart format --set-exit-if-changed .
fvm flutter analyze
fvm flutter test                                        # unit and widget tests
fvm flutter test integration_test -d "iPhone 17 Pro"    # full flows on the simulator
```

The integration tests use the real database on the simulator, offline. They
cover: create, save, restart, reopen, start, edit, pause, finish, export, and
recovering a workout after the app is closed.

## 6. Build without running

```sh
fvm flutter build ios --simulator --debug --no-codesign   # iOS simulator build
fvm flutter build apk --debug                             # Android debug build
```

If the Android build fails with a missing-file error from Gradle, stop the
daemon and clear the stale cache (it regenerates):
`cd android && ./gradlew --stop`, then remove `~/.gradle/caches/<gradle version>`.
Gradle may need `JAVA_HOME` set to Android Studio's bundled JDK:
`/Applications/Android Studio.app/Contents/jbr/Contents/Home`.

## 7. Android emulator (one-time setup)

Having the Android SDK installed does not mean an emulator image is. If
`fvm flutter devices` shows no Android device, add one:

1. Android Studio > Device Manager > Create Virtual Device.
2. Pick a Pixel phone and a recent system image (API 34 or newer). Download it
   (about 1 GB).
3. Start it, then run `fvm flutter run -d <emulator id>` (find the ID with
   `fvm flutter devices`).
4. For the integration tests: `fvm flutter test integration_test -d <emulator id>`.

Android 13 or newer shows the notification prompt; older versions do not.

## 8. What a simulator cannot show you

These need a real phone. They are rows in the [device matrix](device-matrix.md):

- Sound and vibration (haptics do not happen, and there is no silent switch).
- A real lock screen, Focus or Do Not Disturb, and Low Power mode.
- Whether a notification actually arrives while the phone is locked.
- The operating system killing the app for memory, and a real reboot.
- Battery, heat, and brightness outdoors.
- Real VoiceOver or TalkBack use with a finger.
- Android behavior on any physical device or vendor build.

Record real-device results in the device matrix, and file defects at
<https://github.com/dgvigil/qhelper/issues>.
