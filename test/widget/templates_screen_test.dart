import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/app_harness.dart';
import '../fixtures/in_memory_plan_repository.dart';

void main() {
  late InMemoryPlanRepository repo;
  late AppHarness app;

  setUp(() {
    repo = InMemoryPlanRepository();
    app = AppHarness(repo: repo);
  });

  Future<void> openTemplates(WidgetTester tester) async {
    useTallScreen(tester);
    await app.pump(tester);
    await tester.tap(find.byTooltip('Templates'));
    await tester.pumpAndSettle();
  }

  testWidgets('offers a 45 and a 60 minute template with their outline', (
    tester,
  ) async {
    await openTemplates(tester);
    expect(find.text('45-minute workout'), findsOneWidget);
    expect(find.text('60-minute workout'), findsOneWidget);
    expect(
      find.text(
        'Warm-O-Rama 7 min · The Thang 25 min · Mary 8 min · CoT 5 min',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Warm-O-Rama 8 min · The Thang 35 min · Mary 10 min · CoT 7 min',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'choosing one opens a new workout with those segments and times',
    (tester) async {
      await openTemplates(tester);
      await tester.tap(find.text('60-minute workout'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('title-field')), findsOneWidget);
      expect(find.text('The Thang'), findsOneWidget);
      expect(find.text('35 min'), findsWidgets);
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '60 min'))
            .selected,
        isTrue,
      );
    },
  );

  testWidgets('a template can be edited and saved like any workout', (
    tester,
  ) async {
    await openTemplates(tester);
    await tester.tap(find.text('45-minute workout'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('title-field')), 'My Template');
    await tester.tap(find.byTooltip('Actions for segment Mary'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    final saved = repo.stored.single;
    expect(saved.title, 'My Template');
    expect(saved.targetDurationSeconds, 45 * 60);
    expect(saved.segments.map((s) => s.title), [
      'Warm-O-Rama',
      'The Thang',
      'CoT',
    ]);
    expect(saved.segments.first.estimatedDurationSeconds, 7 * 60);
  });

  testWidgets('back from the builder returns home, not to the templates', (
    tester,
  ) async {
    await openTemplates(tester);
    await tester.tap(find.text('45-minute workout'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('No workouts yet'), findsOneWidget);
  });
}
