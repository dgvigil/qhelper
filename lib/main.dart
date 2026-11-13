import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_helper/app/app.dart';
import 'package:q_helper/app/providers.dart';
import 'package:q_helper/data/assistant/litert_assistant.dart';
import 'package:q_helper/data/codex/bundled_codex.dart';
import 'package:q_helper/data/database/app_database.dart';
import 'package:q_helper/data/database/open_database.dart';
import 'package:q_helper/data/repositories/drift_plan_repository.dart';
import 'package:q_helper/data/repositories/drift_session_repository.dart';
import 'package:q_helper/data/repositories/shared_prefs_settings_repository.dart';
import 'package:q_helper/domain/codex/codex_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<CodexIndex> _openCodex() async {
  try {
    return await openBundledCodexIndex();
  } catch (_) {
    return UnavailableCodexIndex('The exercise list could not be opened.');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase(openAppDatabase());
  final plans = DriftPlanRepository(database);
  final prefs = await SharedPreferences.getInstance();
  final codex = await _openCodex();
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
        codexIndexProvider.overrideWithValue(codex),
        localAssistantProvider.overrideWithValue(LiteRtLmAssistant()),
        modelStoreProvider.overrideWithValue(EdgeAiModelStore()),
      ],
      child: const QHelperApp(),
    ),
  );
}
