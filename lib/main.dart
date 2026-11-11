import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_helper/app/app.dart';
import 'package:q_helper/app/providers.dart';
import 'package:q_helper/data/database/app_database.dart';
import 'package:q_helper/data/database/open_database.dart';
import 'package:q_helper/data/repositories/drift_plan_repository.dart';
import 'package:q_helper/data/repositories/drift_session_repository.dart';
import 'package:q_helper/data/repositories/shared_prefs_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase(openAppDatabase());
  final plans = DriftPlanRepository(database);
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        planRepositoryProvider.overrideWithValue(plans),
        sessionRepositoryProvider.overrideWithValue(
          DriftSessionRepository(database, plans: plans),
        ),
        settingsRepositoryProvider.overrideWithValue(
          SharedPrefsSettingsRepository(prefs),
        ),
      ],
      child: const QHelperApp(),
    ),
  );
}
