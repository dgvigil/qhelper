import 'package:q_helper/domain/models/app_settings.dart';
import 'package:q_helper/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsSettingsRepository implements SettingsRepository {
  SharedPrefsSettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _defaults = AppSettings();

  @override
  Future<AppSettings> load() async {
    final minutes = _prefs.getInt('defaultMinutes');
    return AppSettings(
      defaultMinutes: minutes != null && minutes > 0
          ? minutes
          : _defaults.defaultMinutes,
      soundEnabled: _prefs.getBool('soundEnabled') ?? _defaults.soundEnabled,
      hapticsEnabled:
          _prefs.getBool('hapticsEnabled') ?? _defaults.hapticsEnabled,
      keepScreenAwake:
          _prefs.getBool('keepScreenAwake') ?? _defaults.keepScreenAwake,
      endNotificationEnabled:
          _prefs.getBool('endNotificationEnabled') ??
          _defaults.endNotificationEnabled,
      notificationPermissionAsked:
          _prefs.getBool('notificationPermissionAsked') ??
          _defaults.notificationPermissionAsked,
    );
  }

  @override
  Future<void> save(AppSettings s) async {
    await _prefs.setInt('defaultMinutes', s.defaultMinutes);
    await _prefs.setBool('soundEnabled', s.soundEnabled);
    await _prefs.setBool('hapticsEnabled', s.hapticsEnabled);
    await _prefs.setBool('keepScreenAwake', s.keepScreenAwake);
    await _prefs.setBool('endNotificationEnabled', s.endNotificationEnabled);
    await _prefs.setBool(
      'notificationPermissionAsked',
      s.notificationPermissionAsked,
    );
  }
}
