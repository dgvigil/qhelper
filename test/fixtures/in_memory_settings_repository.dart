import 'package:q_helper/domain/models/app_settings.dart';
import 'package:q_helper/domain/repositories/settings_repository.dart';

class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([this.current = const AppSettings()]);

  AppSettings current;

  @override
  Future<AppSettings> load() async => current;

  @override
  Future<void> save(AppSettings settings) async => current = settings;
}
