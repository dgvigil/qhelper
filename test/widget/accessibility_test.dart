import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/app_harness.dart';
import '../fixtures/in_memory_plan_repository.dart';
import '../fixtures/plans.dart';

/// Phase 6 accessibility pass: every screen must stay usable on a small phone
/// at large text sizes, with labeled controls, large enough tap targets, and
/// readable contrast.
void main() {
  late InMemoryPlanRepository repo;
  late AppHarness app;

  setUp(() {
    repo = InMemoryPlanRepository()..seed(buildPlan());
    app = AppHarness(repo: repo);
  });

  void smallPhone(WidgetTester tester, {double textScale = 1}) {
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
  }

  Future<void> toHome(WidgetTester tester) => app.pump(tester);

  Future<void> toBuilder(WidgetTester tester) async {
    await app.pump(tester);
    await tester.tap(find.text('Tuesday Beatdown'));
    await tester.pumpAndSettle();
  }

  Future<void> toNewBuilder(WidgetTester tester) async {
    await app.pump(tester);
    await tester.tap(find.text('New workout'));
    await tester.pumpAndSettle();
  }

  Future<void> toLive(WidgetTester tester, {bool timed = false}) async {
    await app.pump(tester);
    await tester.tap(find.byTooltip('Actions for Tuesday Beatdown'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    if (timed) {
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();
    }
  }

  Future<void> toQuick(WidgetTester tester) async {
    await app.pump(tester);
    await tester.tap(find.byTooltip('Quick timer'));
    await tester.pumpAndSettle();
  }

  Future<void> toSettings(WidgetTester tester) async {
    await app.pump(tester);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
  }

  Future<void> toTemplates(WidgetTester tester) async {
    await app.pump(tester);
    await tester.tap(find.byTooltip('Templates'));
    await tester.pumpAndSettle();
  }

  final screens = <String, Future<void> Function(WidgetTester)>{};

  void register() {
    screens['Home'] = toHome;
    screens['Builder (existing)'] = toBuilder;
    screens['Builder (new)'] = toNewBuilder;
    screens['Live (reps)'] = (t) => toLive(t);
    screens['Live (timed)'] = (t) => toLive(t, timed: true);
    screens['Quick timer'] = toQuick;
    screens['Settings'] = toSettings;
    screens['Templates'] = toTemplates;
  }

  register();

  group('large text on a small phone', () {
    for (final scale in [1.0, 2.0]) {
      for (final entry in screens.entries) {
        testWidgets('${entry.key} at ${scale}x has no overflow', (
          tester,
        ) async {
          smallPhone(tester, textScale: scale);
          await entry.value(tester);
          // Overflow throws a FlutterError and fails the test on its own.
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('tap targets and labels', () {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} meets tap size and label guidelines', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        smallPhone(tester);
        await entry.value(tester);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    }
  });

  group('contrast', () {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} has readable text contrast', (tester) async {
        final handle = tester.ensureSemantics();
        smallPhone(tester);
        await entry.value(tester);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }
  });

  group('screen reader', () {
    testWidgets('the live countdown is announced in whole minutes', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      smallPhone(tester);
      await toLive(tester);
      expect(
        find.bySemanticsLabel('Time remaining: 45 minutes'),
        findsOneWidget,
      );
      await app.advance(tester, const Duration(seconds: 20));
      // Label changes once a minute, not every second.
      expect(
        find.bySemanticsLabel('Time remaining: 45 minutes'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('overtime is announced', (tester) async {
      final handle = tester.ensureSemantics();
      smallPhone(tester);
      await toLive(tester);
      await app.advance(tester, const Duration(minutes: 46));
      expect(find.bySemanticsLabel('Overtime'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('icon buttons have spoken labels', (tester) async {
      final handle = tester.ensureSemantics();
      smallPhone(tester);
      await toHome(tester);
      for (final name in ['Quick timer', 'Settings', 'Templates']) {
        final data = tester
            .getSemantics(find.byTooltip(name))
            .getSemanticsData();
        expect('${data.label} ${data.tooltip}', contains(name));
      }
      handle.dispose();
    });
  });
}
