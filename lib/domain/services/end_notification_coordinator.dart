import 'package:q_helper/core/platform/end_notification_service.dart';
import 'package:q_helper/domain/models/app_settings.dart';

/// Decides when to ask for notification permission and when to schedule or
/// cancel the end-of-workout notification.
///
/// The permission prompt appears only when a workout starts (in context), at
/// most once. Refusal, a disabled setting, or any platform error leaves the
/// workout running normally.
class EndNotificationCoordinator {
  EndNotificationCoordinator({
    required this._service,
    required this._loadSettings,
    required this._saveSettings,
    DateTime Function()? now,
  }) : _now = now ?? (() => DateTime.now().toUtc());

  final EndNotificationService _service;
  final Future<AppSettings> Function() _loadSettings;
  final Future<void> Function(AppSettings) _saveSettings;
  final DateTime Function() _now;

  Future<void> sessionStarted(DateTime deadline) async {
    try {
      final settings = await _loadSettings();
      if (!settings.endNotificationEnabled) return;

      final bool allowed;
      if (settings.notificationPermissionAsked) {
        allowed = await _service.hasPermission();
      } else {
        await _saveSettings(
          settings.copyWith(notificationPermissionAsked: true),
        );
        allowed = await _service.requestPermission();
      }
      if (!allowed || !deadline.isAfter(_now())) return;

      await _service.scheduleAt(
        deadline,
        title: 'Time is up',
        body: 'The planned workout time has ended.',
      );
    } on Object {
      // Notifications are a courtesy; never disturb the workout.
    }
  }

  Future<void> sessionEnded() async {
    try {
      await _service.cancel();
    } on Object {
      // Nothing to do.
    }
  }
}
