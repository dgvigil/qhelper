import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/app_harness.dart';
import '../fixtures/in_memory_plan_repository.dart';
import '../fixtures/plans.dart';

void main() {
  late InMemoryPlanRepository repo;
  late AppHarness app;

  setUp(() {
    repo = InMemoryPlanRepository();
    app = AppHarness(repo: repo);
  });

  group('empty state', () {
    testWidgets('invites the first workout', (tester) async {
      useTallScreen(tester);
      await app.pump(tester);
      expect(find.text('No workouts yet'), findsOneWidget);
      expect(find.text('Create your first workout'), findsOneWidget);
    });
  });

  group('saved workouts', () {
    setUp(() {
      repo.seed(buildPlan(title: 'Tuesday Beatdown'));
      repo.seed(
        buildPlan(
          id: 'plan-2',
          title: 'Saturday Ruck',
          targetDurationSeconds: 3600,
          createdAt: DateTime.utc(2026, 11, 11),
        ),
      );
    });

    testWidgets('lists each plan with a short summary', (tester) async {
      useTallScreen(tester);
      await app.pump(tester);
      expect(find.text('Tuesday Beatdown'), findsOneWidget);
      expect(find.text('Saturday Ruck'), findsOneWidget);
      expect(find.text('45 min · 2 segments · 3 activities'), findsOneWidget);
      expect(find.text('60 min · 2 segments · 3 activities'), findsOneWidget);
      expect(find.text('No workouts yet'), findsNothing);
    });

    testWidgets('shows the most recently updated plan first', (tester) async {
      useTallScreen(tester);
      await app.pump(tester);
      final first = tester.getTopLeft(find.text('Saturday Ruck')).dy;
      final second = tester.getTopLeft(find.text('Tuesday Beatdown')).dy;
      expect(first, lessThan(second));
    });

    testWidgets('duplicate adds a copy and keeps the original', (tester) async {
      useTallScreen(tester);
      await app.pump(tester);
      await tester.tap(find.byTooltip('Actions for Tuesday Beatdown'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Duplicate'));
      await tester.pumpAndSettle();

      expect(find.text('Tuesday Beatdown (copy)'), findsOneWidget);
      expect(find.text('Tuesday Beatdown'), findsOneWidget);
      expect(repo.stored, hasLength(3));
    });

    testWidgets('delete asks first and can be cancelled', (tester) async {
      useTallScreen(tester);
      await app.pump(tester);
      await tester.tap(find.byTooltip('Actions for Tuesday Beatdown'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete "Tuesday Beatdown"?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Tuesday Beatdown'), findsOneWidget);
      expect(repo.stored, hasLength(2));
    });

    testWidgets('confirming delete removes the plan', (tester) async {
      useTallScreen(tester);
      await app.pump(tester);
      await tester.tap(find.byTooltip('Actions for Tuesday Beatdown'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Tuesday Beatdown'), findsNothing);
      expect(find.text('Saturday Ruck'), findsOneWidget);
      expect(repo.stored.map((p) => p.id), ['plan-2']);
    });

    testWidgets('deleting the last plan shows the empty state', (tester) async {
      repo.stored
          .where((p) => p.id == 'plan-2')
          .forEach((p) => repo.delete(p.id));
      useTallScreen(tester);
      await app.pump(tester);
      await tester.tap(find.byTooltip('Actions for Tuesday Beatdown'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(find.text('No workouts yet'), findsOneWidget);
    });

    testWidgets('share sends the plan as plain text', (tester) async {
      useTallScreen(tester);
      await app.pump(tester);
      await tester.tap(find.byTooltip('Actions for Tuesday Beatdown'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      expect(app.share.shared, hasLength(1));
      expect(app.share.shared.single.subject, 'Tuesday Beatdown');
      expect(
        app.share.shared.single.text,
        startsWith('Tuesday Beatdown\nTarget duration: 45 min'),
      );
    });
  });

  testWidgets('home offers create and templates', (tester) async {
    useTallScreen(tester);
    await app.pump(tester);
    expect(find.text('New workout'), findsOneWidget);
    expect(find.byTooltip('Templates'), findsOneWidget);
  });
}
