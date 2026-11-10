import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/models/workout_activity.dart';
import 'package:q_helper/domain/models/workout_plan.dart';

import '../fixtures/app_harness.dart';
import '../fixtures/in_memory_plan_repository.dart';
import '../fixtures/plans.dart';

// Ids handed out by the harness for a new blank workout.
const warm = 'new-1';
const thang = 'new-2';

void main() {
  late InMemoryPlanRepository repo;
  late AppHarness app;

  setUp(() {
    repo = InMemoryPlanRepository();
    app = AppHarness(repo: repo);
  });

  Future<void> openNew(WidgetTester tester) async {
    useTallScreen(tester);
    await app.pump(tester);
    await tester.tap(find.text('New workout'));
    await tester.pumpAndSettle();
  }

  Future<void> enterTitle(WidgetTester tester, String title) async {
    await tester.enterText(find.byKey(const Key('title-field')), title);
    await tester.pump();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();
  }

  Future<void> openAddActivity(WidgetTester tester, String segmentId) async {
    final button = find.byKey(Key('add-activity-$segmentId'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  Future<void> saveActivity(WidgetTester tester) async {
    await tester.tap(find.text('Save activity'));
    await tester.pumpAndSettle();
  }

  Future<void> addRepsActivity(
    WidgetTester tester,
    String segmentId,
    String name,
    String reps,
  ) async {
    await openAddActivity(tester, segmentId);
    await tester.enterText(find.byKey(const Key('activity-name')), name);
    await tester.enterText(find.byKey(const Key('reps-field')), reps);
    await saveActivity(tester);
  }

  WorkoutPlan onlySaved() => repo.stored.single;

  group('new workout', () {
    testWidgets('starts with the default segments and 45 minutes', (
      tester,
    ) async {
      await openNew(tester);
      for (final name in ['Warm-O-Rama', 'The Thang', 'Mary', 'CoT']) {
        expect(find.text(name), findsOneWidget);
      }
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '45 min'))
            .selected,
        isTrue,
      );
    });

    testWidgets('will not save without a title', (tester) async {
      await openNew(tester);
      await save(tester);
      expect(find.text('Enter a title'), findsOneWidget);
      expect(repo.stored, isEmpty);
    });

    testWidgets('saves a titled workout', (tester) async {
      await openNew(tester);
      await enterTitle(tester, 'Thursday Grind');
      await save(tester);
      expect(find.text('Saved'), findsOneWidget);
      expect(onlySaved().title, 'Thursday Grind');
      expect(onlySaved().targetDurationSeconds, 45 * 60);
      expect(onlySaved().segments.map((s) => s.title), [
        'Warm-O-Rama',
        'The Thang',
        'Mary',
        'CoT',
      ]);
    });

    testWidgets('saving twice updates instead of duplicating', (tester) async {
      await openNew(tester);
      await enterTitle(tester, 'First');
      await save(tester);
      await enterTitle(tester, 'Second');
      await save(tester);
      expect(repo.stored, hasLength(1));
      expect(onlySaved().title, 'Second');
    });
  });

  group('duration', () {
    testWidgets('quick choices set the target', (tester) async {
      await openNew(tester);
      await enterTitle(tester, 'Short');
      await tester.tap(find.widgetWithText(ChoiceChip, '30 min'));
      await tester.pump();
      await save(tester);
      expect(onlySaved().targetDurationSeconds, 1800);
    });

    testWidgets('custom minutes can be typed', (tester) async {
      await openNew(tester);
      await enterTitle(tester, 'Long');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Custom'));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('custom-minutes-field')),
        '75',
      );
      await tester.pump();
      await save(tester);
      expect(onlySaved().targetDurationSeconds, 75 * 60);
    });

    testWidgets('custom minutes must be a positive number', (tester) async {
      await openNew(tester);
      await enterTitle(tester, 'Bad');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Custom'));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('custom-minutes-field')),
        '0',
      );
      await tester.pump();
      await save(tester);
      expect(find.text('Enter minutes greater than zero'), findsOneWidget);
      expect(repo.stored, isEmpty);
    });
  });

  group('activities', () {
    testWidgets('adds a reps activity', (tester) async {
      await openNew(tester);
      await addRepsActivity(tester, warm, 'Merkins', '20');
      expect(find.text('Merkins'), findsOneWidget);
      expect(find.text('20 reps'), findsOneWidget);

      await enterTitle(tester, 'Test');
      await save(tester);
      final activity = onlySaved().segments[0].activities.single;
      expect(activity.name, 'Merkins');
      expect(activity.details, const RepsDetails(repetitions: 20));
      expect(activity.segmentId, warm);
    });

    testWidgets('adds a timed activity', (tester) async {
      await openNew(tester);
      await openAddActivity(tester, thang);
      await tester.tap(find.text('Timed'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('activity-name')),
        'Burpee EMOM',
      );
      await tester.enterText(find.byKey(const Key('work-field')), '40');
      await tester.enterText(find.byKey(const Key('rest-field')), '20');
      await tester.enterText(find.byKey(const Key('rounds-field')), '5');
      await tester.enterText(
        find.byKey(const Key('activity-notes')),
        'Go hard',
      );
      await saveActivity(tester);

      expect(find.text('40 sec work / 20 sec rest x 5 rounds'), findsOneWidget);
      await enterTitle(tester, 'Test');
      await save(tester);
      final activity = onlySaved().segments[1].activities.single;
      expect(
        activity.details,
        const TimedDetails(workSeconds: 40, restSeconds: 20, rounds: 5),
      );
      expect(activity.notes, 'Go hard');
    });

    testWidgets('a blank rest means no rest', (tester) async {
      await openNew(tester);
      await openAddActivity(tester, thang);
      await tester.tap(find.text('Timed'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('activity-name')), 'Plank');
      await tester.enterText(find.byKey(const Key('work-field')), '60');
      await tester.enterText(find.byKey(const Key('rounds-field')), '3');
      await saveActivity(tester);
      expect(find.text('1 min work x 3 rounds'), findsOneWidget);
    });

    testWidgets('adds a free-form activity', (tester) async {
      await openNew(tester);
      await openAddActivity(tester, warm);
      await tester.tap(find.text('Free-form'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('activity-name')), 'Mosey');
      await tester.enterText(
        find.byKey(const Key('instructions-field')),
        'Two laps, easy pace',
      );
      await saveActivity(tester);
      expect(find.text('Two laps, easy pace'), findsOneWidget);
    });

    testWidgets('keeps the form open and explains invalid input', (
      tester,
    ) async {
      await openNew(tester);
      await openAddActivity(tester, warm);
      await tester.enterText(find.byKey(const Key('reps-field')), '0');
      await saveActivity(tester);

      expect(find.text('Enter a name'), findsOneWidget);
      expect(find.text('Enter a number greater than zero'), findsOneWidget);
      expect(find.text('Save activity'), findsOneWidget);
    });

    testWidgets('cancelling adds nothing', (tester) async {
      await openNew(tester);
      await openAddActivity(tester, warm);
      await tester.enterText(find.byKey(const Key('activity-name')), 'Ghost');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Ghost'), findsNothing);
    });

    testWidgets('edits an activity', (tester) async {
      await openNew(tester);
      await addRepsActivity(tester, warm, 'Merkins', '20');
      await tester.tap(find.text('Merkins'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('reps-field')), '35');
      await saveActivity(tester);
      expect(find.text('35 reps'), findsOneWidget);
      expect(find.text('20 reps'), findsNothing);
    });

    testWidgets('removes an activity', (tester) async {
      await openNew(tester);
      await addRepsActivity(tester, warm, 'Merkins', '20');
      await tester.tap(find.byTooltip('Actions for Merkins'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(find.text('Merkins'), findsNothing);
    });

    testWidgets('moves an activity down', (tester) async {
      await openNew(tester);
      await addRepsActivity(tester, warm, 'Merkins', '20');
      await addRepsActivity(tester, warm, 'Squats', '30');
      await tester.tap(find.byTooltip('Actions for Merkins'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move down'));
      await tester.pumpAndSettle();

      await enterTitle(tester, 'Order');
      await save(tester);
      expect(onlySaved().segments[0].activities.map((a) => a.name), [
        'Squats',
        'Merkins',
      ]);
    });
  });

  group('segments', () {
    testWidgets('renames a segment and sets its time', (tester) async {
      await openNew(tester);
      await tester.tap(find.byTooltip('Actions for segment The Thang'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('segment-title-field')),
        'Main Event',
      );
      await tester.enterText(
        find.byKey(const Key('segment-minutes-field')),
        '25',
      );
      await tester.tap(find.text('Save segment'));
      await tester.pumpAndSettle();

      expect(find.text('Main Event'), findsOneWidget);
      expect(find.text('25 min'), findsOneWidget);
      await enterTitle(tester, 'Test');
      await save(tester);
      expect(onlySaved().segments[1].title, 'Main Event');
      expect(onlySaved().segments[1].estimatedDurationSeconds, 1500);
    });

    testWidgets('does not accept a blank segment name', (tester) async {
      await openNew(tester);
      await tester.tap(find.byTooltip('Actions for segment Mary'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('segment-title-field')),
        '  ',
      );
      await tester.tap(find.text('Save segment'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a name'), findsOneWidget);
    });

    testWidgets('adds a segment at the end', (tester) async {
      await openNew(tester);
      final add = find.text('Add segment');
      await tester.ensureVisible(add);
      await tester.tap(add);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('segment-title-field')),
        'Finisher',
      );
      await tester.tap(find.text('Save segment'));
      await tester.pumpAndSettle();

      await enterTitle(tester, 'Test');
      await save(tester);
      expect(onlySaved().segments.last.title, 'Finisher');
      expect(onlySaved().segments, hasLength(5));
    });

    testWidgets('removes an empty segment without asking', (tester) async {
      await openNew(tester);
      await tester.tap(find.byTooltip('Actions for segment Mary'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(find.text('Mary'), findsNothing);
    });

    testWidgets('asks before removing a segment that has activities', (
      tester,
    ) async {
      await openNew(tester);
      await addRepsActivity(tester, warm, 'Merkins', '20');
      await tester.tap(find.byTooltip('Actions for segment Warm-O-Rama'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(find.text('Remove "Warm-O-Rama"?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Warm-O-Rama'), findsOneWidget);

      await tester.tap(find.byTooltip('Actions for segment Warm-O-Rama'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
      await tester.pumpAndSettle();
      expect(find.text('Warm-O-Rama'), findsNothing);
      expect(find.text('Merkins'), findsNothing);
    });

    testWidgets('moves a segment up', (tester) async {
      await openNew(tester);
      await tester.tap(find.byTooltip('Actions for segment The Thang'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move up'));
      await tester.pumpAndSettle();
      await enterTitle(tester, 'Order');
      await save(tester);
      expect(onlySaved().segments.map((s) => s.title), [
        'The Thang',
        'Warm-O-Rama',
        'Mary',
        'CoT',
      ]);
      expect(onlySaved().segments.map((s) => s.sortOrder), [0, 1, 2, 3]);
    });
  });

  group('unsaved changes', () {
    testWidgets('leaving a clean workout does not ask', (tester) async {
      await openNew(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsNothing);
      expect(find.text('No workouts yet'), findsOneWidget);
    });

    testWidgets('leaving with edits asks, and keep editing stays', (
      tester,
    ) async {
      await openNew(tester);
      await enterTitle(tester, 'Draft');
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('title-field')), findsOneWidget);
    });

    testWidgets('discard leaves without saving', (tester) async {
      await openNew(tester);
      await enterTitle(tester, 'Draft');
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('title-field')), findsNothing);
      expect(repo.stored, isEmpty);
    });

    testWidgets('after saving, leaving does not ask', (tester) async {
      await openNew(tester);
      await enterTitle(tester, 'Done');
      await save(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsNothing);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('an edit after saving asks again', (tester) async {
      await openNew(tester);
      await enterTitle(tester, 'Done');
      await save(tester);
      await enterTitle(tester, 'Done again');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
    });
  });

  group('existing workout', () {
    setUp(() => repo.seed(buildPlan()));

    testWidgets('opens with its saved content', (tester) async {
      useTallScreen(tester);
      await app.pump(tester);
      await tester.tap(find.text('Tuesday Beatdown'));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<TextField>(find.byKey(const Key('title-field')))
            .controller!
            .text,
        'Tuesday Beatdown',
      );
      expect(find.text('SSH'), findsOneWidget);
      expect(find.text('Mosey'), findsOneWidget);
      expect(find.text('Burpee EMOM'), findsOneWidget);
      expect(find.text('Notes: Around the lot'), findsOneWidget);
    });

    testWidgets('edits are saved and shown on the list', (tester) async {
      useTallScreen(tester);
      await app.pump(tester);
      await tester.tap(find.text('Tuesday Beatdown'));
      await tester.pumpAndSettle();
      await enterTitle(tester, 'Wednesday Beatdown');
      await save(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Wednesday Beatdown'), findsOneWidget);
      expect(find.text('Tuesday Beatdown'), findsNothing);
      expect(repo.stored.single.id, 'plan-1');
    });

    testWidgets('shows a message for a workout that no longer exists', (
      tester,
    ) async {
      useTallScreen(tester);
      await app.pump(tester);
      await tester.tap(find.text('Tuesday Beatdown'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await repo.delete('plan-1');
      // Reopen through a stale list entry.
      expect(find.text('Tuesday Beatdown'), findsOneWidget);
      await tester.tap(find.text('Tuesday Beatdown'));
      await tester.pumpAndSettle();
      expect(find.text('This workout could not be found.'), findsOneWidget);
    });
  });

  group('sharing', () {
    testWidgets('shares the workout as it is on screen', (tester) async {
      await openNew(tester);
      await enterTitle(tester, 'Draft Share');
      await addRepsActivity(tester, warm, 'Merkins', '20');
      await tester.tap(find.byTooltip('Share'));
      await tester.pumpAndSettle();

      expect(app.share.shared, hasLength(1));
      expect(app.share.shared.single.subject, 'Draft Share');
      expect(app.share.shared.single.text, contains('1. Merkins: 20 reps'));
    });
  });

  group('name suggestions', () {
    testWidgets('offers names from earlier workouts and fills the field', (
      tester,
    ) async {
      repo.seed(buildPlan());
      await openNew(tester);
      await openAddActivity(tester, warm);
      await tester.enterText(find.byKey(const Key('activity-name')), 'ss');
      await tester.pumpAndSettle();

      expect(find.text('SSH'), findsOneWidget);
      await tester.tap(find.text('SSH'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('activity-name')))
            .controller!
            .text,
        'SSH',
      );
    });

    testWidgets('offers nothing when nothing matches', (tester) async {
      repo.seed(buildPlan());
      await openNew(tester);
      await openAddActivity(tester, warm);
      await tester.enterText(find.byKey(const Key('activity-name')), 'zzz');
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNothing);
    });
  });
}
