import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/app/app.dart';
import 'package:q_helper/app/providers.dart';
import 'package:q_helper/app/services/share_service.dart';

import 'package:q_helper/domain/assistant/device_capability.dart';
import 'package:q_helper/domain/assistant/local_assistant.dart';
import 'package:q_helper/domain/codex/codex_index.dart';
import 'package:q_helper/domain/models/app_settings.dart';

import 'fake_assistant.dart';
import 'fake_clock.dart';
import 'fake_platform.dart';
import 'in_memory_plan_repository.dart';
import 'in_memory_session_repository.dart';
import 'in_memory_settings_repository.dart';
import 'memory_codex_index.dart';

class RecordingShareService implements ShareService {
  final List<({String text, String? subject})> shared = [];

  @override
  Future<void> shareText(String text, {String? subject}) async {
    shared.add((text: text, subject: subject));
  }
}

class AppHarness {
  AppHarness({
    InMemoryPlanRepository? repo,
    RecordingShareService? share,
    AppSettings settings = const AppSettings(),
    CodexIndex? codex,
    this.device = const DeviceProfile(totalRamBytes: null),
    ModelStore? models,
    LocalAssistant? assistant,
  }) : repo = repo ?? InMemoryPlanRepository(),
       share = share ?? RecordingShareService(),
       settingsRepo = InMemorySettingsRepository(settings),
       codex = codex ?? MemoryCodexIndex(sampleCodexEntries),
       models = models ?? FakeModelStore(),
       assistant = assistant ?? FakeLocalAssistant('A merkin is in the list.') {
    sessions = InMemorySessionRepository(this.repo, now: () => clock.now);
  }

  final InMemoryPlanRepository repo;
  final RecordingShareService share;
  final InMemorySettingsRepository settingsRepo;
  final CodexIndex codex;
  final DeviceProfile device;
  final ModelStore models;
  final LocalAssistant assistant;
  late final InMemorySessionRepository sessions;
  final FakeClock clock = FakeClock();
  final RecordingCueService cues = RecordingCueService();
  final FakeWakelock wakelock = FakeWakelock();
  final FakeEndNotificationService notifications = FakeEndNotificationService();
  final StreamController<void> ticks = StreamController<void>.broadcast(
    sync: true,
  );
  int _ids = 0;

  /// Moves the fake clock and lets the screen refresh, like the real ticker.
  Future<void> advance(WidgetTester tester, Duration d) async {
    clock.advance(d);
    ticks.add(null);
    await tester.pump();
  }

  Widget scope(Widget child) {
    return ProviderScope(
      overrides: [
        planRepositoryProvider.overrideWithValue(repo),
        shareServiceProvider.overrideWithValue(share),
        idGeneratorProvider.overrideWithValue(() => 'new-${_ids++}'),
        nowProvider.overrideWithValue(() => DateTime.utc(2026, 11, 10, 12)),
        sessionRepositoryProvider.overrideWithValue(sessions),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        appClockProvider.overrideWithValue(clock),
        cueServiceProvider.overrideWithValue(cues),
        wakelockServiceProvider.overrideWithValue(wakelock),
        endNotificationServiceProvider.overrideWithValue(notifications),
        tickStreamProvider.overrideWithValue(ticks.stream),
        codexIndexProvider.overrideWithValue(codex),
        deviceProfileProvider.overrideWith((ref) async => device),
        modelStoreProvider.overrideWithValue(models),
        localAssistantProvider.overrideWithValue(assistant),
      ],
      child: child,
    );
  }

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(scope(const QHelperApp()));
    await tester.pumpAndSettle();
  }

  /// A single screen with the same overrides, for screens reached by a route
  /// the test does not need to walk.
  Widget wrap(Widget child) => scope(MaterialApp(home: child));
}

/// Larger than default so list items and sheets are on screen.
void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 1800);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
