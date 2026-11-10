/// User preferences. Everything is stored on the device.
class AppSettings {
  const AppSettings({
    this.defaultMinutes = 45,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.keepScreenAwake = true,
    this.endNotificationEnabled = true,
    this.notificationPermissionAsked = false,
  });

  /// Length of a new workout, in minutes.
  final int defaultMinutes;
  final bool soundEnabled;
  final bool hapticsEnabled;

  /// Keep the screen on while leading a workout or running the quick timer.
  final bool keepScreenAwake;

  /// Post a local notification when the workout deadline passes.
  final bool endNotificationEnabled;

  /// True once the system permission prompt has been shown, so the app never
  /// asks twice.
  final bool notificationPermissionAsked;

  AppSettings copyWith({
    int? defaultMinutes,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? keepScreenAwake,
    bool? endNotificationEnabled,
    bool? notificationPermissionAsked,
  }) {
    return AppSettings(
      defaultMinutes: defaultMinutes ?? this.defaultMinutes,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      endNotificationEnabled:
          endNotificationEnabled ?? this.endNotificationEnabled,
      notificationPermissionAsked:
          notificationPermissionAsked ?? this.notificationPermissionAsked,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.defaultMinutes == defaultMinutes &&
      other.soundEnabled == soundEnabled &&
      other.hapticsEnabled == hapticsEnabled &&
      other.keepScreenAwake == keepScreenAwake &&
      other.endNotificationEnabled == endNotificationEnabled &&
      other.notificationPermissionAsked == notificationPermissionAsked;

  @override
  int get hashCode => Object.hash(
    defaultMinutes,
    soundEnabled,
    hapticsEnabled,
    keepScreenAwake,
    endNotificationEnabled,
    notificationPermissionAsked,
  );
}
