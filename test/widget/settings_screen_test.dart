import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/models/app_settings.dart';

import '../fixtures/app_harness.dart';

void main() {
  late AppHarness app;

  Future<void> open(WidgetTester tester, [AppSettings? settings]) async {
    app = AppHarness(settings: settings ?? const AppSettings());
    useTallScreen(tester);
    await app.pump(tester);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
  }

  bool switched(WidgetTester tester, String label) => tester
      .widget<SwitchListTile>(find.widgetWithText(SwitchListTile, label))
      .value;

  group('cue and device preferences', () {
    testWidgets('shows the current values', (tester) async {
      await open(tester, const AppSettings(hapticsEnabled: false));
      expect(switched(tester, 'Sound cues'), isTrue);
      expect(switched(tester, 'Haptic cues'), isFalse);
      expect(switched(tester, 'Keep screen awake during workouts'), isTrue);
      expect(switched(tester, 'End-of-workout notification'), isTrue);
    });

    testWidgets('each switch is saved', (tester) async {
      await open(tester);
      await tester.tap(find.widgetWithText(SwitchListTile, 'Sound cues'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(SwitchListTile, 'Haptic cues'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(
          SwitchListTile,
          'Keep screen awake during workouts',
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(SwitchListTile, 'End-of-workout notification'),
      );
      await tester.pumpAndSettle();

      final s = app.settingsRepo.current;
      expect(s.soundEnabled, isFalse);
      expect(s.hapticsEnabled, isFalse);
      expect(s.keepScreenAwake, isFalse);
      expect(s.endNotificationEnabled, isFalse);
    });

    testWidgets('explains that the phone can silence cues', (tester) async {
      await open(tester);
      expect(find.textContaining('silent and Focus'), findsOneWidget);
    });
  });

  group('default workout length', () {
    testWidgets('can be chosen and is saved', (tester) async {
      await open(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, '60 min'));
      await tester.pumpAndSettle();
      expect(app.settingsRepo.current.defaultMinutes, 60);
    });

    testWidgets('custom minutes can be typed', (tester) async {
      await open(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Custom'));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('default-minutes-field')),
        '50',
      );
      await tester.pumpAndSettle();
      expect(app.settingsRepo.current.defaultMinutes, 50);
    });

    testWidgets('an invalid custom value is not saved', (tester) async {
      await open(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Custom'));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('default-minutes-field')),
        '0',
      );
      await tester.pumpAndSettle();
      expect(app.settingsRepo.current.defaultMinutes, 45);
      expect(find.text('Enter minutes greater than zero'), findsOneWidget);
    });

    testWidgets('a new workout starts at the chosen length', (tester) async {
      await open(tester, const AppSettings(defaultMinutes: 60));
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('New workout'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '60 min'))
            .selected,
        isTrue,
      );
      await tester.enterText(find.byKey(const Key('title-field')), 'Long one');
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();
      expect(app.repo.stored.single.targetDurationSeconds, 3600);
    });
  });

  group('about', () {
    testWidgets('credits the publisher and states independence', (
      tester,
    ) async {
      await open(tester);
      await tester.scrollUntilVisible(
        find.text('Independent community project'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.text('Developed and published by GV5 Technologies LLC'),
        findsOneWidget,
      );
      expect(
        find.textContaining('not affiliated with or endorsed by F3 Nation'),
        findsOneWidget,
      );
    });

    testWidgets('names the license and offers privacy and support links', (
      tester,
    ) async {
      await open(tester);
      await tester.scrollUntilVisible(
        find.text('Privacy policy'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('GPLv3'), findsOneWidget);
      expect(find.text('Privacy policy'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.textContaining('github.com/dgvigil/qhelper'), findsWidgets);
    });
  });
}
