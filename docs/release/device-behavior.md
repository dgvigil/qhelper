# What Q Helper does on your phone (Phase 6, M6.2)

Plain statements of behavior for the store listing, tester instructions, and
support. They describe how the app is built; items marked **(to confirm)**
depend on the phone and must be checked in the
[device matrix](../testing/device-matrix.md) before they are published.

Nothing here promises exact delivery. Phones decide when to run background
work, play sounds, and show notifications.

## Timing

- The workout countdown is based on a fixed deadline. It keeps counting while
  the phone is locked, the app is in the background, or the app has been closed.
- When you return, the app recalculates from the clock. It does not "catch up"
  tick by tick.
- After the deadline the countdown switches to **overtime** and counts up. The
  workout is never ended automatically.
- The interval timer (work, rest, rounds) also keeps running while you are
  away. If you were away for several phases, it shows the phase you are in now.
  If you pause it, it stays paused.
- **Device clock changes.** If the phone's clock is moved back, the countdown
  does not gain time. If it is moved forward, the countdown loses that time.
  Automatic time-zone or network time adjustments can cause small jumps. After
  a restart of the phone, timing is rebuilt from the clock and is best effort.

## Sounds and vibration (cues)

- Cues play at the start of work and rest, when the interval finishes, and once
  when the workout time is up. They use your phone's alert sound and vibration.
- They follow the phone's settings: the silent switch, Do Not Disturb or Focus,
  volume, and Low Power mode may mute or change them. **(to confirm on each
  platform)**
- Cues are played only when the change is seen on time (within about 2 seconds).
  If the app was in the background, missed cues are **not** played later.
- You can turn sound and vibration off separately in Settings.
- A loud alarm that overrides the silent switch is not part of this version.

## End-of-workout notification

- Optional. The first time you start a workout, the app asks for permission to
  show notifications. If you say no, nothing else changes, and the app does not
  ask again. You can turn the feature off in Settings.
- If allowed, one local notification is scheduled for the workout's planned end.
  It is not sent over the internet.
- It is scheduled without exact-alarm permission, so it may arrive a little
  late, especially in battery-saving modes. **(to confirm)**
- On iPhone, a notification may not be shown while Q Helper is open on screen;
  the app's own overtime display and cue cover that case. **(to confirm)**
- Ending the workout cancels the notification.

## Screen awake

- If "Keep screen awake during workouts" is on, the screen stays on while the
  live workout screen or the quick timer is open, and is released when you leave
  it or end the workout.
- If the phone locks anyway (for example you press the side button), the
  workout continues and the countdown stays correct.

## Closing and reopening the app

- Leaving the live screen does not end the workout.
- If the app is closed or restarted, Home shows **Workout in progress** with
  **Resume** and **End workout**. Resume restores your place, any changes you
  made during the workout, and the timers.
- Changes you make during a workout (called audibles) apply only to that
  workout. Your saved workout is not changed.

## Offline and privacy

- Everything works without an internet connection. The app has no accounts,
  ads, analytics, or crash reporting. See the [privacy policy](../privacy/privacy-policy.md).
- Sharing a workout uses your phone's share sheet and only when you tap Share.
