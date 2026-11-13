import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/assistant/device_capability.dart';
import 'package:q_helper/features/assistant/assistant_screen.dart';

import '../fixtures/app_harness.dart';
import '../fixtures/fake_assistant.dart';

void main() {
  testWidgets('look up finds a term from the list', (tester) async {
    useTallScreen(tester);
    final app = AppHarness();
    await app.pump(tester);

    await tester.tap(find.text('Look up'));
    await tester.pumpAndSettle();
    expect(
      find.text('Type a word from an exercise or a term.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Assistant'), findsNothing);

    await tester.enterText(find.byType(TextField), 'merkin');
    await tester.pumpAndSettle();
    expect(find.text('Merkin Jack'), findsOneWidget);

    await tester.tap(find.text('Merkin Jack'));
    await tester.pumpAndSettle();
    expect(find.text('Exercise'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
  });

  testWidgets('a capable phone can open the assistant from lookup', (
    tester,
  ) async {
    useTallScreen(tester);
    final app = AppHarness(
      device: const DeviceProfile(totalRamBytes: 8 * 1024 * 1024 * 1024),
    );
    await app.pump(tester);
    await tester.tap(find.text('Look up'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Assistant'), findsOneWidget);
  });

  testWidgets('a phone without enough memory does not get the assistant', (
    tester,
  ) async {
    useTallScreen(tester);
    final app = AppHarness();
    await tester.pumpWidget(app.wrap(const AssistantScreen()));
    await tester.pumpAndSettle();
    expect(find.textContaining('enough memory'), findsOneWidget);
    expect(find.text('Download on Wi-Fi'), findsNothing);
  });

  testWidgets('download waits for Wi-Fi and then offers a question', (
    tester,
  ) async {
    useTallScreen(tester);
    final models = FakeModelStore(unmetered: false);
    final assistant = FakeLocalAssistant('A merkin is a push-up.');
    final app = AppHarness(
      device: const DeviceProfile(totalRamBytes: 8 * 1024 * 1024 * 1024),
      models: models,
      assistant: assistant,
    );
    await tester.pumpWidget(app.wrap(const AssistantScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Download on Wi-Fi'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Connect to Wi-Fi'), findsOneWidget);
    expect(models.installed, isFalse);

    models.unmetered = true;
    await tester.tap(find.text('Download on Wi-Fi'));
    await tester.pumpAndSettle();
    expect(find.text('Ask'), findsOneWidget);

    await tester.tap(find.text('What is a Merkin?'));
    await tester.pumpAndSettle();
    expect(find.text('A merkin is a push-up.'), findsOneWidget);
    expect(find.textContaining('Merkin Jack'), findsOneWidget);
    expect(assistant.lastPrompt, contains('[Exercise] Merkin Jack'));
    expect(assistant.lastPrompt, contains('What is a Merkin?'));
  });

  testWidgets('lookup and the assistant fit a small phone at large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    final app = AppHarness(
      device: const DeviceProfile(totalRamBytes: 8 * 1024 * 1024 * 1024),
      models: FakeModelStore(installed: true),
    );
    await app.pump(tester);
    await tester.tap(find.text('Look up'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Assistant'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Ask'), findsOneWidget);
  });
}
