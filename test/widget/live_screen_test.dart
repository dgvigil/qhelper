import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/core/platform/cue_service.dart';
import 'package:q_helper/domain/models/app_settings.dart';
import 'package:q_helper/domain/models/workout_session.dart';

import '../fixtures/app_harness.dart';
import '../fixtures/in_memory_plan_repository.dart';
import '../fixtures/plans.dart';

Duration s(int seconds) => Duration(seconds: seconds);

void main() {
  late InMemoryPlanRepository repo;
  late AppHarness app;

  AppHarness harness({AppSettings settings = const AppSettings()}) {
    repo = InMemoryPlanRepository()..seed(buildPlan());
    return app = AppHarness(repo: repo, settings: settings);
  }

  setUp(() => harness());

  String textOf(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  Future<void> startFromHome(WidgetTester tester) async {
    useTallScreen(tester);
    await app.pump(tester);
    await tester.tap(find.byTooltip('Actions for Tuesday Beatdown'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
  }

  Future<void> toBurpees(WidgetTester tester) async {
    await next(tester);
    await next(tester);
  }

  group('display', () {
    testWidgets('shows the master countdown, current and next activity', (
      tester,
    ) async {
      await startFromHome(tester);
      expect(find.text('Time remaining'), findsOneWidget);
      expect(textOf(tester, 'master-countdown'), '45:00');
      expect(textOf(tester, 'current-activity-name'), 'SSH');
      expect(find.text('25 reps'), findsOneWidget);
      expect(find.text('Next: Mosey'), findsOneWidget);
    });

    testWidgets('counts down as time passes', (tester) async {
      await startFromHome(tester);
      await app.advance(tester, const Duration(minutes: 10, seconds: 30));
      expect(textOf(tester, 'master-countdown'), '34:30');
    });

    testWidgets('shows overtime after the deadline and keeps going', (
      tester,
    ) async {
      await startFromHome(tester);
      await app.advance(tester, const Duration(minutes: 46));
      expect(find.text('OVERTIME'), findsOneWidget);
      expect(textOf(tester, 'master-countdown'), '+1:00');
      expect(app.sessions.stored.single.status, SessionStatus.running);
    });

    testWidgets('plays the end cue once when the deadline passes on time', (
      tester,
    ) async {
      await startFromHome(tester);
      await app.advance(tester, const Duration(minutes: 44, seconds: 59));
      expect(app.cues.played, isEmpty);
      await app.advance(tester, s(1));
      expect(app.cues.played, [CueKind.workoutEnd]);
      await app.advance(tester, s(1));
      expect(app.cues.played, [CueKind.workoutEnd]);
    });

    testWidgets('does not replay the end cue after a long suspension', (
      tester,
    ) async {
      await startFromHome(tester);
      app.clock.suspend(const Duration(minutes: 50));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text('OVERTIME'), findsOneWidget);
      expect(textOf(tester, 'master-countdown'), '+5:00');
      expect(app.cues.played, isEmpty);
    });

    testWidgets('recomputes the countdown when the app resumes', (
      tester,
    ) async {
      await startFromHome(tester);
      app.clock.suspend(const Duration(minutes: 10));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(textOf(tester, 'master-countdown'), '35:00');
    });
  });

  group('navigation', () {
    testWidgets('Next and Back move between activities', (tester) async {
      await startFromHome(tester);
      await next(tester);
      expect(textOf(tester, 'current-activity-name'), 'Mosey');
      expect(find.text('Easy pace, 2 laps'), findsOneWidget);
      expect(find.text('Notes: Around the lot'), findsOneWidget);
      expect(find.text('Next: Burpee EMOM'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Back'));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'current-activity-name'), 'SSH');
    });

    testWidgets('Back is disabled on the first activity and Next on the last', (
      tester,
    ) async {
      await startFromHome(tester);
      expect(
        tester
            .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Back'))
            .onPressed,
        isNull,
      );
      await toBurpees(tester);
      expect(find.text('Last activity'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Next'))
            .onPressed,
        isNull,
      );
    });

    testWidgets('a double tap on Next moves only once', (tester) async {
      await startFromHome(tester);
      final nextButton = find.widgetWithText(FilledButton, 'Next');
      await tester.tap(nextButton);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();
      expect(textOf(tester, 'current-activity-name'), 'Mosey');
    });

    testWidgets('navigation never changes the countdown', (tester) async {
      await startFromHome(tester);
      await app.advance(tester, const Duration(minutes: 3));
      await next(tester);
      await next(tester);
      expect(textOf(tester, 'master-countdown'), '42:00');
    });
  });

  group('interval panel', () {
    testWidgets('only appears for timed activities', (tester) async {
      await startFromHome(tester);
      expect(find.byKey(const Key('interval-panel')), findsNothing);
      await toBurpees(tester);
      expect(find.byKey(const Key('interval-panel')), findsOneWidget);
      expect(textOf(tester, 'interval-phase'), 'READY');
      expect(textOf(tester, 'interval-round'), 'Round 1 of 5');
      expect(textOf(tester, 'interval-time'), '0:40');
    });

    testWidgets('runs work and rest phases with cues', (tester) async {
      await startFromHome(tester);
      await toBurpees(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Start'));
      await tester.pump();
      expect(textOf(tester, 'interval-phase'), 'WORK');
      expect(app.cues.played, [CueKind.workStart]);

      await app.advance(tester, s(40));
      expect(textOf(tester, 'interval-phase'), 'REST');
      expect(textOf(tester, 'interval-time'), '0:20');
      expect(app.cues.played.last, CueKind.restStart);

      await app.advance(tester, s(20));
      expect(textOf(tester, 'interval-phase'), 'WORK');
      expect(textOf(tester, 'interval-round'), 'Round 2 of 5');
      expect(app.cues.played.last, CueKind.workStart);
    });

    testWidgets('pause holds the interval while the master keeps counting', (
      tester,
    ) async {
      await startFromHome(tester);
      await toBurpees(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Start'));
      await tester.pump();
      await app.advance(tester, s(10));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Pause'));
      await tester.pump();
      await app.advance(tester, s(60));

      expect(textOf(tester, 'interval-time'), '0:30');
      expect(textOf(tester, 'master-countdown'), '43:50');

      await tester.tap(find.widgetWithText(FilledButton, 'Resume'));
      await tester.pump();
      await app.advance(tester, s(5));
      expect(textOf(tester, 'interval-time'), '0:25');
    });

    testWidgets('Skip jumps to the next phase and Reset starts over', (
      tester,
    ) async {
      await startFromHome(tester);
      await toBurpees(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Start'));
      await tester.pump();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Skip'));
      await tester.pump();
      expect(textOf(tester, 'interval-phase'), 'REST');

      await tester.tap(find.widgetWithText(OutlinedButton, 'Reset'));
      await tester.pump();
      expect(textOf(tester, 'interval-phase'), 'READY');
      expect(textOf(tester, 'interval-time'), '0:40');
    });

    testWidgets('a long suspension lands in the right phase with no cue', (
      tester,
    ) async {
      await startFromHome(tester);
      await toBurpees(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Start'));
      await tester.pump();
      app.cues.played.clear();

      app.clock.suspend(s(95));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      // 95 s into 40/20: round 2 work, 35 s in.
      expect(textOf(tester, 'interval-phase'), 'WORK');
      expect(textOf(tester, 'interval-round'), 'Round 2 of 5');
      expect(textOf(tester, 'interval-time'), '0:05');
      expect(app.cues.played, isEmpty);
    });

    testWidgets('finishing all rounds shows done', (tester) async {
      await startFromHome(tester);
      await toBurpees(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Start'));
      await tester.pump();
      await app.advance(tester, s(5 * 40 + 4 * 20));
      expect(textOf(tester, 'interval-phase'), 'DONE');
      expect(app.cues.played.last, CueKind.intervalFinished);
    });
  });

  group('audibles', () {
    Future<void> openMenu(WidgetTester tester, String item) async {
      await tester.tap(find.byTooltip('Change this workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(item));
      await tester.pumpAndSettle();
    }

    testWidgets('edits the current activity for this session only', (
      tester,
    ) async {
      await startFromHome(tester);
      await openMenu(tester, 'Edit this activity');
      await tester.enterText(find.byKey(const Key('reps-field')), '50');
      await tester.tap(find.text('Save activity'));
      await tester.pumpAndSettle();

      expect(find.text('50 reps'), findsOneWidget);
      expect(repo.stored.single, buildPlan());
      final session = app.sessions.stored.single;
      expect(session.planSnapshot, buildPlan());
    });

    testWidgets('adds an activity to the current segment', (tester) async {
      await startFromHome(tester);
      await openMenu(tester, 'Add activity');
      await tester.enterText(find.byKey(const Key('activity-name')), 'Plank');
      await tester.enterText(find.byKey(const Key('reps-field')), '1');
      await tester.tap(find.text('Save activity'));
      await tester.pumpAndSettle();

      // Added at the end of the first segment, so it follows Mosey.
      await next(tester);
      await next(tester);
      expect(textOf(tester, 'current-activity-name'), 'Plank');
      expect(repo.stored.single, buildPlan());
    });

    testWidgets('removing asks first, then moves on', (tester) async {
      await startFromHome(tester);
      await openMenu(tester, 'Remove this activity');
      expect(find.text('Remove "SSH" from this workout?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'current-activity-name'), 'SSH');

      await openMenu(tester, 'Remove this activity');
      await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'current-activity-name'), 'Mosey');
      expect(repo.stored.single, buildPlan());
    });

    testWidgets('editing never moves the countdown', (tester) async {
      await startFromHome(tester);
      await app.advance(tester, const Duration(minutes: 5));
      await openMenu(tester, 'Edit this activity');
      await tester.enterText(find.byKey(const Key('reps-field')), '12');
      await tester.tap(find.text('Save activity'));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'master-countdown'), '40:00');
    });
  });

  group('ending', () {
    testWidgets('asks before ending and can be cancelled', (tester) async {
      await startFromHome(tester);
      await tester.tap(find.byTooltip('End workout'));
      await tester.pumpAndSettle();
      expect(find.text('End workout?'), findsOneWidget);
      await tester.tap(find.text('Keep going'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('master-countdown')), findsOneWidget);
      expect(app.sessions.stored.single.status, SessionStatus.running);
    });

    testWidgets('End early ends the session and returns home', (tester) async {
      await startFromHome(tester);
      await tester.tap(find.byTooltip('End workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('End early'));
      await tester.pumpAndSettle();

      expect(app.sessions.stored.single.status, SessionStatus.endedEarly);
      expect(find.text('Tuesday Beatdown'), findsOneWidget);
      expect(find.byKey(const Key('master-countdown')), findsNothing);
      expect(find.text('Workout in progress'), findsNothing);
      expect(app.notifications.cancels, 1);
    });

    testWidgets('Finished records a completed workout', (tester) async {
      await startFromHome(tester);
      await tester.tap(find.byTooltip('End workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finished'));
      await tester.pumpAndSettle();
      expect(app.sessions.stored.single.status, SessionStatus.completed);
    });
  });

  group('screen awake', () {
    testWidgets('stays awake during the workout and releases afterwards', (
      tester,
    ) async {
      await startFromHome(tester);
      expect(app.wakelock.enabled, isTrue);
      await tester.tap(find.byTooltip('End workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('End early'));
      await tester.pumpAndSettle();
      expect(app.wakelock.enabled, isFalse);
    });

    testWidgets('is left alone when the setting is off', (tester) async {
      harness(settings: const AppSettings(keepScreenAwake: false));
      await startFromHome(tester);
      expect(app.wakelock.history, isEmpty);
    });
  });

  group('end notification', () {
    testWidgets('asks in context and schedules at the deadline', (
      tester,
    ) async {
      await startFromHome(tester);
      expect(app.notifications.requests, 1);
      expect(app.notifications.scheduled, [
        app.sessions.stored.single.deadlineAtWall,
      ]);
    });

    testWidgets('a refusal does not stop the workout', (tester) async {
      app.notifications.grant = false;
      await startFromHome(tester);
      expect(app.notifications.scheduled, isEmpty);
      expect(textOf(tester, 'master-countdown'), '45:00');
      await next(tester);
      expect(textOf(tester, 'current-activity-name'), 'Mosey');
    });

    testWidgets('a platform failure does not stop the workout', (tester) async {
      app.notifications.throwOnUse = true;
      await startFromHome(tester);
      expect(textOf(tester, 'master-countdown'), '45:00');
    });

    testWidgets('does not ask when the setting is off', (tester) async {
      harness(settings: const AppSettings(endNotificationEnabled: false));
      await startFromHome(tester);
      expect(app.notifications.requests, 0);
    });
  });

  group('resume', () {
    testWidgets('leaving keeps the workout running and Home offers Resume', (
      tester,
    ) async {
      await startFromHome(tester);
      await next(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Workout in progress'), findsOneWidget);
      expect(app.sessions.stored.single.status, SessionStatus.running);
      expect(app.wakelock.enabled, isFalse);

      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'current-activity-name'), 'Mosey');
    });

    testWidgets('time keeps passing while away', (tester) async {
      await startFromHome(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();
      app.clock.advance(const Duration(minutes: 7));
      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'master-countdown'), '38:00');
    });

    testWidgets('Home can end a workout in progress', (tester) async {
      await startFromHome(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('End workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('End early'));
      await tester.pumpAndSettle();

      expect(app.sessions.stored.single.status, SessionStatus.endedEarly);
      expect(find.text('Workout in progress'), findsNothing);
    });

    testWidgets('starting another workout while one runs offers Resume', (
      tester,
    ) async {
      await startFromHome(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Actions for Tuesday Beatdown'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(find.text('A workout is already running'), findsOneWidget);
      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('master-countdown')), findsOneWidget);
    });
  });

  group('start from the builder', () {
    testWidgets('saves first, then starts', (tester) async {
      useTallScreen(tester);
      await app.pump(tester);
      await tester.tap(find.text('Tuesday Beatdown'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('title-field')),
        'Tuesday Edited',
      );
      await tester.tap(find.byTooltip('Start workout'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('master-countdown')), findsOneWidget);
      expect(repo.stored.single.title, 'Tuesday Edited');
      expect(app.sessions.stored.single.planSnapshot.title, 'Tuesday Edited');
    });

    testWidgets('will not start a workout that cannot be saved', (
      tester,
    ) async {
      useTallScreen(tester);
      await app.pump(tester);
      await tester.tap(find.text('New workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Start workout'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a title'), findsOneWidget);
      expect(app.sessions.stored, isEmpty);
    });
  });
}
