import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Local "workout time is up" notification. Best effort: delivery depends on
/// permission and the OS, and the app works fully without it.
abstract interface class EndNotificationService {
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<void> scheduleAt(
    DateTime when, {
    required String title,
    required String body,
  });
  Future<void> cancel();
}

class LocalEndNotificationService implements EndNotificationService {
  LocalEndNotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  static const _id = 1;

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initialized;

  Future<void> _init() => _initialized ??= _plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestSoundPermission: false,
        requestBadgePermission: false,
      ),
    ),
  );

  @override
  Future<bool> hasPermission() async {
    await _init();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) return (await ios.checkPermissions())?.isEnabled ?? false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.areNotificationsEnabled() ?? false;
  }

  @override
  Future<bool> requestPermission() async {
    await _init();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? false;
  }

  @override
  Future<void> scheduleAt(
    DateTime when, {
    required String title,
    required String body,
  }) async {
    await _init();
    await _plugin.zonedSchedule(
      id: _id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when.toUtc(), tz.UTC),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'workout_end',
          'Workout time',
          channelDescription: 'Tells you when the planned workout time is up.',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // Inexact: no exact-alarm permission is requested for v0.1.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel() async {
    await _init();
    await _plugin.cancel(id: _id);
  }
}
