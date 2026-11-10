import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/models/app_settings.dart';
import 'package:q_helper/domain/services/end_notification_coordinator.dart';

import '../../fixtures/fake_platform.dart';

void main() {
  final now = DateTime.utc(2026, 11, 10, 5, 30);
  final deadline = now.add(const Duration(minutes: 45));

  late FakeEndNotificationService service;
  late AppSettings settings;
  late EndNotificationCoordinator coordinator;

  setUp(() {
    service = FakeEndNotificationService();
    settings = const AppSettings();
    coordinator = EndNotificationCoordinator(
      service: service,
      loadSettings: () async => settings,
      saveSettings: (s) async => settings = s,
      now: () => now,
    );
  });

  test(
    'asks permission the first time and schedules at the deadline',
    () async {
      await coordinator.sessionStarted(deadline);
      expect(service.requests, 1);
      expect(service.scheduled, [deadline]);
      expect(settings.notificationPermissionAsked, isTrue);
    },
  );

  test('never asks twice, and uses existing permission silently', () async {
    await coordinator.sessionStarted(deadline);
    await coordinator.sessionStarted(deadline);
    expect(service.requests, 1);
    expect(service.scheduled, hasLength(2));
  });

  test(
    'when permission is denied nothing is scheduled and nothing throws',
    () async {
      service.grant = false;
      await coordinator.sessionStarted(deadline);
      expect(service.scheduled, isEmpty);
      expect(settings.notificationPermissionAsked, isTrue);
    },
  );

  test('a denied app does not ask again on later workouts', () async {
    service.grant = false;
    await coordinator.sessionStarted(deadline);
    await coordinator.sessionStarted(deadline);
    expect(service.requests, 1);
    expect(service.scheduled, isEmpty);
  });

  test('does nothing when the setting is off', () async {
    settings = const AppSettings(endNotificationEnabled: false);
    await coordinator.sessionStarted(deadline);
    expect(service.requests, 0);
    expect(service.scheduled, isEmpty);
    expect(settings.notificationPermissionAsked, isFalse);
  });

  test('does not schedule a deadline that has already passed', () async {
    await coordinator.sessionStarted(now.subtract(const Duration(minutes: 1)));
    expect(service.scheduled, isEmpty);
  });

  test('platform failures are swallowed', () async {
    service.throwOnUse = true;
    await coordinator.sessionStarted(deadline);
    await coordinator.sessionEnded();
    expect(service.scheduled, isEmpty);
  });

  test('ending a session cancels the notification', () async {
    await coordinator.sessionStarted(deadline);
    await coordinator.sessionEnded();
    expect(service.cancels, 1);
  });
}
