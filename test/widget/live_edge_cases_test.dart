import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/models/workout_plan.dart';

import '../fixtures/app_harness.dart';
import '../fixtures/in_memory_plan_repository.dart';
import '../fixtures/plans.dart';

/// Phase 6 defect hunting: unusual but possible workouts.
void main() {
  late InMemoryPlanRepository repo;
  late AppHarness app;

  setUp(() {
    repo = InMemoryPlanRepository();
    app = AppHarness(repo: repo);
  });

  Future<void> startPlan(WidgetTester tester, String title) async {
    await app.pump(tester);
    await tester.tap(find.byTooltip('Actions for $title'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
  }

  WorkoutPlan withoutActivities() {
    final plan = buildPlan(id: 'empty', title: 'Empty Plan');
    return plan.copyWith(
      segments: [for (final s in plan.segments) s.copyWith(activities: [])],
    );
  }

  testWidgets('a workout with no activities can still be run and filled in', (
    tester,
  ) async {
    useTallScreen(tester);
    repo.seed(withoutActivities());
    await startPlan(tester, 'Empty Plan');

    expect(find.textContaining('no activities'), findsOneWidget);
    expect(find.byKey(const Key('master-countdown')), findsOneWidget);

    await tester.tap(find.byTooltip('Change this workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add activity'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('activity-name')), 'Plank');
    await tester.enterText(find.byKey(const Key('reps-field')), '1');
    await tester.tap(find.text('Save activity'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const Key('current-activity-name'))).data,
      'Plank',
    );
  });

  testWidgets('a workout with no segments cannot have an activity added', (
    tester,
  ) async {
    useTallScreen(tester);
    repo.seed(buildPlan(id: 'bare', title: 'Bare Plan').copyWith(segments: []));
    await startPlan(tester, 'Bare Plan');

    await tester.tap(find.byTooltip('Change this workout'));
    await tester.pumpAndSettle();
    final add = tester.widget<PopupMenuItem<String>>(
      find.widgetWithText(PopupMenuItem<String>, 'Add activity'),
    );
    expect(add.enabled, isFalse);
  });

  testWidgets('a one hour countdown stays on one line at large text', (
    tester,
  ) async {
    repo.seed(buildPlan(targetDurationSeconds: 3600));
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await startPlan(tester, 'Tuesday Beatdown');

    final countdown = tester.getSize(find.byKey(const Key('master-countdown')));
    final fontSize = Theme.of(
      tester.element(find.byKey(const Key('master-countdown'))),
    ).textTheme.displayLarge!.fontSize!;
    // One line is about 1.2 x font size x text scale; a wrapped line is double.
    expect(countdown.height, lessThan(fontSize * 2 * 1.5));
    expect(tester.getSize(find.byType(Scaffold)).width, 360);
  });
}
