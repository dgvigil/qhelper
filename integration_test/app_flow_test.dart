import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:q_helper/app/app.dart';
import 'package:q_helper/app/providers.dart';
import 'package:q_helper/app/services/share_service.dart';
import 'package:q_helper/core/platform/cue_service.dart';
import 'package:q_helper/core/platform/end_notification_service.dart';
import 'package:q_helper/core/platform/wakelock_service.dart';
import 'package:q_helper/data/database/app_database.dart';
import 'package:q_helper/data/repositories/drift_plan_repository.dart';
import 'package:q_helper/data/repositories/drift_session_repository.dart';
import 'package:q_helper/data/repositories/shared_prefs_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end flows against the real database on a real or simulated device.
/// Platform side effects that cannot be observed in a test (share sheet,
/// notification prompt, screen lock, sound) are replaced with recorders.
class _RecordingShare implements ShareService {
  final List<String> texts = [];

  @override
  Future<void> shareText(String text, {String? subject}) async =>
      texts.add(text);
}

class _SilentCues implements CueService {
  @override
  Future<void> play(CueKind kind) async {}
}

class _NoWakelock implements WakelockService {
  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}
}

class _DeniedNotifications implements EndNotificationService {
  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> scheduleAt(
    DateTime when, {
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancel() async {}
}

class _Device {
  _Device(this.dir);

  final Directory dir;
  final share = _RecordingShare();
  AppDatabase? _db;

  File get _file => File('${dir.path}/q_helper_test.sqlite');

  /// (Re)launches the app on the same on-disk database, like a relaunch.
  Future<void> launch(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await _db?.close();
    final db = _db = AppDatabase(NativeDatabase(_file));
    final plans = DriftPlanRepository(db);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          planRepositoryProvider.overrideWithValue(plans),
          sessionRepositoryProvider.overrideWithValue(
            DriftSessionRepository(db, plans: plans),
          ),
          settingsRepositoryProvider.overrideWithValue(
            SharedPrefsSettingsRepository(prefs),
          ),
          shareServiceProvider.overrideWithValue(share),
          cueServiceProvider.overrideWithValue(_SilentCues()),
          wakelockServiceProvider.overrideWithValue(_NoWakelock()),
          endNotificationServiceProvider.overrideWithValue(
            _DeniedNotifications(),
          ),
          // The 250 ms repaint ticker would stop pumpAndSettle from settling.
          tickStreamProvider.overrideWithValue(const Stream<void>.empty()),
        ],
        child: const QHelperApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> close() async => _db?.close();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late _Device device;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('q_helper_it_');
    device = _Device(dir);
  });

  tearDown(() async {
    await device.close();
    dir.deleteSync(recursive: true);
  });

  String textOf(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  testWidgets(
    'create, save, restart, reopen, start, edit, pause, finish, export',
    (tester) async {
      await device.launch(tester);
      expect(find.text('No workouts yet'), findsOneWidget);

      // Create and save.
      await tester.tap(find.text('Create your first workout'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('title-field')),
        'Device Test',
      );
      final addButtons = find.textContaining('Add activity');
      await tester.ensureVisible(addButtons.first);
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('activity-name')), 'Merkins');
      await tester.enterText(find.byKey(const Key('reps-field')), '20');
      await tester.tap(find.text('Save activity'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(addButtons.at(1));
      await tester.tap(addButtons.at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Timed'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('activity-name')), 'Burpees');
      await tester.enterText(find.byKey(const Key('work-field')), '30');
      await tester.enterText(find.byKey(const Key('rest-field')), '10');
      await tester.enterText(find.byKey(const Key('rounds-field')), '3');
      await tester.tap(find.text('Save activity'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Device Test'), findsOneWidget);

      // Restart the app: the workout is still there.
      await device.launch(tester);
      expect(find.text('Device Test'), findsOneWidget);
      expect(find.text('45 min · 4 segments · 2 activities'), findsOneWidget);

      // Reopen and start.
      await tester.tap(find.text('Device Test'));
      await tester.pumpAndSettle();
      expect(find.text('Merkins'), findsOneWidget);
      expect(find.text('Burpees'), findsOneWidget);
      await tester.tap(find.byTooltip('Start workout'));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'current-activity-name'), 'Merkins');
      expect(find.text('Time remaining'), findsOneWidget);

      // Edit during the workout (session only).
      await tester.tap(find.byTooltip('Change this workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit this activity'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('reps-field')), '35');
      await tester.tap(find.text('Save activity'));
      await tester.pumpAndSettle();
      expect(find.text('35 reps'), findsOneWidget);

      // Next, start the interval, pause it.
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'current-activity-name'), 'Burpees');
      await tester.tap(find.widgetWithText(FilledButton, 'Start'));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'interval-phase'), 'WORK');
      await tester.tap(find.widgetWithText(OutlinedButton, 'Pause'));
      await tester.pumpAndSettle();
      expect(find.text('Paused'), findsOneWidget);

      // Finish.
      await tester.tap(find.byTooltip('End workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finished'));
      await tester.pumpAndSettle();
      expect(find.text('Workout in progress'), findsNothing);

      // The saved plan kept its original 20 reps; export it.
      await tester.tap(find.byTooltip('Actions for Device Test'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();
      expect(device.share.texts.single, contains('1. Merkins: 20 reps'));
      expect(
        device.share.texts.single,
        contains('30 sec work / 10 sec rest x 3 rounds'),
      );
    },
  );

  testWidgets('a workout survives the app being closed and reopened', (
    tester,
  ) async {
    await device.launch(tester);
    await tester.tap(find.text('Create your first workout'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('title-field')), 'Recover Me');
    final add = find.textContaining('Add activity');
    await tester.ensureVisible(add.first);
    await tester.tap(add.first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('activity-name')), 'One');
    await tester.enterText(find.byKey(const Key('reps-field')), '5');
    await tester.tap(find.text('Save activity'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(add.first);
    await tester.tap(add.first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('activity-name')), 'Two');
    await tester.enterText(find.byKey(const Key('reps-field')), '6');
    await tester.tap(find.text('Save activity'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Start workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
    expect(textOf(tester, 'current-activity-name'), 'Two');

    // Process death and relaunch.
    await device.launch(tester);
    expect(find.text('Workout in progress'), findsOneWidget);
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();
    expect(textOf(tester, 'current-activity-name'), 'Two');

    // End it so it does not linger.
    await tester.tap(find.byTooltip('End workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('End early'));
    await tester.pumpAndSettle();
    expect(find.text('Workout in progress'), findsNothing);
  });
}
