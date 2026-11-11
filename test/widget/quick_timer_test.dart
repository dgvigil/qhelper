import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/core/platform/cue_service.dart';
import 'package:q_helper/domain/models/app_settings.dart';

import '../fixtures/app_harness.dart';

Duration s(int seconds) => Duration(seconds: seconds);

void main() {
  late AppHarness app;

  Future<void> open(WidgetTester tester, {AppSettings? settings}) async {
    app = AppHarness(settings: settings ?? const AppSettings());
    useTallScreen(tester);
    await app.pump(tester);
    await tester.tap(find.byTooltip('Quick timer'));
    await tester.pumpAndSettle();
  }

  String textOf(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  Future<void> enter(WidgetTester tester, String key, String value) async {
    await tester.enterText(find.byKey(Key(key)), value);
    await tester.pump();
  }

  testWidgets('starts with sensible defaults and no saved plan needed', (
    tester,
  ) async {
    await open(tester);
    expect(textOf(tester, 'interval-phase'), 'READY');
    expect(textOf(tester, 'interval-time'), '0:40');
    expect(textOf(tester, 'interval-round'), 'Round 1 of 5');
    expect(app.repo.stored, isEmpty);
    expect(app.sessions.stored, isEmpty);
  });

  testWidgets('runs work and rest with cues, then finishes', (tester) async {
    await open(tester);
    await enter(tester, 'quick-work', '10');
    await enter(tester, 'quick-rest', '5');
    await enter(tester, 'quick-rounds', '2');
    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await tester.pump();
    expect(textOf(tester, 'interval-phase'), 'WORK');
    expect(app.cues.played, [CueKind.workStart]);

    await app.advance(tester, s(10));
    expect(textOf(tester, 'interval-phase'), 'REST');
    expect(app.cues.played.last, CueKind.restStart);

    await app.advance(tester, s(5));
    expect(textOf(tester, 'interval-round'), 'Round 2 of 2');
    expect(app.cues.played.last, CueKind.workStart);

    await app.advance(tester, s(10));
    expect(textOf(tester, 'interval-phase'), 'DONE');
    expect(app.cues.played.last, CueKind.intervalFinished);
  });

  testWidgets('pause holds the time and resume continues', (tester) async {
    await open(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await tester.pump();
    await app.advance(tester, s(10));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Pause'));
    await tester.pump();
    await app.advance(tester, s(30));
    expect(textOf(tester, 'interval-time'), '0:30');

    await tester.tap(find.widgetWithText(FilledButton, 'Resume'));
    await tester.pump();
    await app.advance(tester, s(10));
    expect(textOf(tester, 'interval-time'), '0:20');
  });

  testWidgets('reset returns to ready and unlocks the settings', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await tester.pump();
    await app.advance(tester, s(15));
    expect(
      tester.widget<TextField>(find.byKey(const Key('quick-work'))).enabled,
      isFalse,
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Reset'));
    await tester.pump();
    expect(textOf(tester, 'interval-phase'), 'READY');
    expect(textOf(tester, 'interval-time'), '0:40');
    expect(
      tester.widget<TextField>(find.byKey(const Key('quick-work'))).enabled,
      isTrue,
    );
  });

  testWidgets('a long suspension lands in the right phase without a cue', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await tester.pump();
    app.cues.played.clear();
    app.clock.suspend(s(95));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(textOf(tester, 'interval-phase'), 'WORK');
    expect(textOf(tester, 'interval-round'), 'Round 2 of 5');
    expect(app.cues.played, isEmpty);
  });

  group('validation', () {
    testWidgets('will not start with zero work time', (tester) async {
      await open(tester);
      await enter(tester, 'quick-work', '0');
      await tester.tap(find.widgetWithText(FilledButton, 'Start'));
      await tester.pump();
      expect(find.text('Enter a number greater than zero'), findsOneWidget);
      expect(textOf(tester, 'interval-phase'), 'READY');
    });

    testWidgets('will not start with zero rounds', (tester) async {
      await open(tester);
      await enter(tester, 'quick-rounds', '');
      await tester.tap(find.widgetWithText(FilledButton, 'Start'));
      await tester.pump();
      expect(find.text('Enter a number greater than zero'), findsOneWidget);
    });

    testWidgets('a blank rest means no rest', (tester) async {
      await open(tester);
      await enter(tester, 'quick-rest', '');
      await enter(tester, 'quick-rounds', '2');
      await tester.tap(find.widgetWithText(FilledButton, 'Start'));
      await tester.pump();
      await app.advance(tester, s(40));
      expect(textOf(tester, 'interval-phase'), 'WORK');
      expect(textOf(tester, 'interval-round'), 'Round 2 of 2');
    });
  });

  group('screen awake', () {
    testWidgets('stays awake while open and releases on leaving', (
      tester,
    ) async {
      await open(tester);
      expect(app.wakelock.enabled, isTrue);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(app.wakelock.enabled, isFalse);
    });

    testWidgets('is left alone when the setting is off', (tester) async {
      await open(tester, settings: const AppSettings(keepScreenAwake: false));
      expect(app.wakelock.history, isEmpty);
    });
  });
}
