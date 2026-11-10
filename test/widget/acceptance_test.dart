import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/app_harness.dart';

/// Phase 4 exit gate: a Q with no developer help can build, save, reopen,
/// duplicate, and share a complete workout.
void main() {
  testWidgets('build, save, reopen, duplicate, and share a workout', (
    tester,
  ) async {
    final app = AppHarness();
    useTallScreen(tester);
    await app.pump(tester);

    // Start from nothing.
    expect(find.text('No workouts yet'), findsOneWidget);
    await tester.tap(find.text('Create your first workout'));
    await tester.pumpAndSettle();

    // Title and length.
    await tester.enterText(
      find.byKey(const Key('title-field')),
      'Friday Grind',
    );
    await tester.tap(find.widgetWithText(ChoiceChip, '60 min'));
    await tester.pump();

    // A reps activity in Warm-O-Rama.
    await tester.tap(find.byKey(const Key('add-activity-new-1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('activity-name')), 'SSH');
    await tester.enterText(find.byKey(const Key('reps-field')), '25');
    await tester.tap(find.text('Save activity'));
    await tester.pumpAndSettle();

    // A timed activity in The Thang.
    await tester.tap(find.byKey(const Key('add-activity-new-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Timed'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('activity-name')), 'Burpees');
    await tester.enterText(find.byKey(const Key('work-field')), '40');
    await tester.enterText(find.byKey(const Key('rest-field')), '20');
    await tester.enterText(find.byKey(const Key('rounds-field')), '4');
    await tester.tap(find.text('Save activity'));
    await tester.pumpAndSettle();

    // Save, then go back home.
    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Friday Grind'), findsOneWidget);
    expect(find.text('60 min · 4 segments · 2 activities'), findsOneWidget);

    // Reopen: everything is still there.
    await tester.tap(find.text('Friday Grind'));
    await tester.pumpAndSettle();
    expect(find.text('SSH'), findsOneWidget);
    expect(find.text('25 reps'), findsOneWidget);
    expect(find.text('Burpees'), findsOneWidget);
    expect(find.text('40 sec work / 20 sec rest x 4 rounds'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Duplicate.
    await tester.tap(find.byTooltip('Actions for Friday Grind'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duplicate'));
    await tester.pumpAndSettle();
    expect(find.text('Friday Grind (copy)'), findsOneWidget);
    expect(find.text('Friday Grind'), findsOneWidget);

    // Share the copy.
    await tester.tap(find.byTooltip('Actions for Friday Grind (copy)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();

    final shared = app.share.shared.single;
    expect(shared.subject, 'Friday Grind (copy)');
    expect(shared.text, '''
Friday Grind (copy)
Target duration: 60 min

Warm-O-Rama
1. SSH: 25 reps

The Thang
1. Burpees: 40 sec work / 20 sec rest x 4 rounds

Mary
   (nothing added yet)

CoT
   (nothing added yet)''');
  });
}
