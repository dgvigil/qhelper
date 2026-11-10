import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/data/repositories/shared_prefs_settings_repository.dart';
import 'package:q_helper/domain/models/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPrefsSettingsRepository> repoWith(
  Map<String, Object> values,
) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPrefsSettingsRepository(await SharedPreferences.getInstance());
}

void main() {
  test('defaults when nothing is stored', () async {
    final repo = await repoWith({});
    final s = await repo.load();
    expect(s.defaultMinutes, 45);
    expect(s.soundEnabled, isTrue);
    expect(s.hapticsEnabled, isTrue);
    expect(s.keepScreenAwake, isTrue);
    expect(s.endNotificationEnabled, isTrue);
    expect(s.notificationPermissionAsked, isFalse);
  });

  test('saved values come back', () async {
    final repo = await repoWith({});
    const changed = AppSettings(
      defaultMinutes: 60,
      soundEnabled: false,
      hapticsEnabled: false,
      keepScreenAwake: false,
      endNotificationEnabled: false,
      notificationPermissionAsked: true,
    );
    await repo.save(changed);
    expect(await repo.load(), changed);
  });

  test('values survive a new repository instance (relaunch)', () async {
    final repo = await repoWith({});
    await repo.save(const AppSettings(defaultMinutes: 30));
    final again = SharedPrefsSettingsRepository(
      await SharedPreferences.getInstance(),
    );
    expect((await again.load()).defaultMinutes, 30);
  });

  test('an unusable stored duration falls back to 45', () async {
    final zero = await repoWith({'defaultMinutes': 0});
    expect((await zero.load()).defaultMinutes, 45);
    final negative = await repoWith({'defaultMinutes': -5});
    expect((await negative.load()).defaultMinutes, 45);
  });

  test('settings with different values are not equal', () {
    expect(const AppSettings() == const AppSettings(), isTrue);
    expect(
      const AppSettings() == const AppSettings(soundEnabled: false),
      isFalse,
    );
  });

  test('copyWith changes only what is given', () {
    final s = const AppSettings().copyWith(hapticsEnabled: false);
    expect(s.hapticsEnabled, isFalse);
    expect(s.soundEnabled, isTrue);
    expect(s.defaultMinutes, 45);
  });
}
