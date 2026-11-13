# Glossary

Plain-language definitions of the F3 and project terms used in this repository,
for contributors who are new to F3. The definitions are original wording for
this project. They are not taken from, and do not replace, any official F3
material. Q Helper is an independent community project and is not affiliated
with or endorsed by F3 Nation.

## F3 terms

| Term | Meaning in this project |
|---|---|
| **F3** | A free, volunteer-led men's fitness group that meets outdoors. Its three pillars are Fitness, Fellowship, and Faith |
| **The 3 Fs** | Fitness, Fellowship, and Faith. Q Helper's v0.1 focuses on fitness; later releases add the other two (see the [roadmap](roadmap.md)) |
| **Q** | The volunteer who leads a workout |
| **PAX** | The men who take part in a workout |
| **FNG** | A first-time participant |
| **AO** | The place where a group meets for its workouts |
| **Beatdown** | The workout itself |
| **Weinke** | The Q's plan for a workout. In Q Helper this is a *workout plan*, built in the builder |
| **Warm-O-Rama** | The warm-up segment |
| **The Thang** | The main segment of the workout |
| **Mary** | The core-focused finishing segment |
| **CoT (Circle of Trust)** | The closing circle: counting off, names, announcements, and prayer requests |
| **Count-o-rama / Name-o-rama** | Part of the CoT where PAX call out their number and then their names |
| **Audible** | A change the Q makes to the plan while the workout is under way |
| **Backblast** | A short written report of a workout, usually posted afterward. Planned for v0.3 |
| **Coffeeteria** | An informal coffee gathering after a workout, part of fellowship |
| **2nd F / 3rd F** | Fellowship and Faith |
| **Exicon** | F3's glossary of exercises. A prototype bundles it for offline lookup and is not cleared to ship; see the [content policy](legal/content-policy.md) |
| **Q101** | F3 training material for new Qs. Not bundled in Q Helper without written permission |

## Project terms

| Term | Meaning |
|---|---|
| **Plan** | A saved workout: title, target duration, ordered segments, and activities |
| **Segment** | A named block of a plan, such as The Thang |
| **Activity** | One item in a segment: *reps* (a count), *timed* (work, rest, rounds), or *free-form* (instructions) |
| **Session** | A running workout. It holds its own copy of the plan, so edits and audibles never change the saved plan |
| **Master countdown** | The workout-wide timer with a fixed deadline. It never pauses and shows overtime after the deadline |
| **Interval timer** | The work / rest / rounds timer for a timed activity |
| **Overtime** | Time past the master deadline. The workout keeps running until the Q ends it |
| **Cue** | A sound or vibration at a phase change |
| **Phase gate** | The exit criteria that must be met before the next roadmap phase starts |
| **ADR** | Architecture decision record, in [docs/architecture/decisions](architecture/decisions) |
