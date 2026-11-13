import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_helper/app/services/share_service.dart';
import 'package:q_helper/core/clock/app_clock.dart';
import 'package:q_helper/core/platform/cue_service.dart';
import 'package:q_helper/core/platform/end_notification_service.dart';
import 'package:q_helper/core/platform/wakelock_service.dart';
import 'package:q_helper/data/assistant/device_memory.dart';
import 'package:q_helper/domain/assistant/device_capability.dart';
import 'package:q_helper/domain/assistant/local_assistant.dart';
import 'package:q_helper/domain/codex/codex_index.dart';
import 'package:q_helper/domain/models/app_settings.dart';
import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/models/workout_session.dart';
import 'package:q_helper/domain/repositories/plan_repository.dart';
import 'package:q_helper/domain/repositories/session_repository.dart';
import 'package:q_helper/domain/repositories/settings_repository.dart';
import 'package:q_helper/domain/services/end_notification_coordinator.dart';
import 'package:uuid/uuid.dart';

/// Must be overridden at the app root with a real repository.
final planRepositoryProvider = Provider<PlanRepository>(
  (ref) => throw UnimplementedError('planRepositoryProvider not overridden'),
);

final idGeneratorProvider = Provider<String Function()>((ref) {
  const uuid = Uuid();
  return uuid.v4;
});

final nowProvider = Provider<DateTime Function()>(
  (ref) =>
      () => DateTime.now().toUtc(),
);

final shareServiceProvider = Provider<ShareService>(
  (ref) => const SharePlusShareService(),
);

/// Saved plans, newest first.
final planListProvider =
    AsyncNotifierProvider<PlanListNotifier, List<WorkoutPlan>>(
      PlanListNotifier.new,
    );

class PlanListNotifier extends AsyncNotifier<List<WorkoutPlan>> {
  PlanRepository get _repo => ref.read(planRepositoryProvider);

  @override
  Future<List<WorkoutPlan>> build() => _repo.list();

  Future<void> _reload() async {
    state = AsyncData(await _repo.list());
  }

  Future<void> duplicate(String id) async {
    await _repo.duplicate(id);
    await _reload();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await _reload();
  }

  /// Creates the plan if new, otherwise updates it.
  Future<WorkoutPlan> save(WorkoutPlan plan) async {
    final exists = await _repo.get(plan.id) != null;
    final saved = exists ? await _repo.update(plan) : await _repo.create(plan);
    await _reload();
    return saved;
  }
}

/// Must be overridden at the app root with a real repository.
final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => throw UnimplementedError('sessionRepositoryProvider not overridden'),
);

/// Must be overridden at the app root with a real repository.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) =>
      throw UnimplementedError('settingsRepositoryProvider not overridden'),
);

final appClockProvider = Provider<AppClock>((ref) => SystemClock());

/// Fires often enough to repaint countdowns. It only triggers repaints; time
/// is always recomputed from the clock.
final tickStreamProvider = Provider<Stream<void>>(
  (ref) =>
      Stream<void>.periodic(const Duration(milliseconds: 250))
          .asBroadcastStream(),
);

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  Future<AppSettings> build() => _repo.load();

  Future<void> save(AppSettings settings) async {
    state = AsyncData(settings);
    await _repo.save(settings);
  }
}

final cueServiceProvider = Provider<CueService>(
  (ref) => SystemCueService(
    settings: () => ref.read(settingsProvider).value ?? const AppSettings(),
  ),
);

final wakelockServiceProvider = Provider<WakelockService>(
  (ref) => const WakelockPlusService(),
);

final endNotificationServiceProvider = Provider<EndNotificationService>(
  (ref) => LocalEndNotificationService(),
);

final endNotificationCoordinatorProvider = Provider<EndNotificationCoordinator>(
  (ref) => EndNotificationCoordinator(
    service: ref.watch(endNotificationServiceProvider),
    loadSettings: () => ref.read(settingsProvider.future),
    saveSettings: (s) => ref.read(settingsProvider.notifier).save(s),
    now: () => ref.read(appClockProvider).now,
  ),
);

/// The workout currently running, if any (offered as Resume on Home).
final activeSessionProvider = FutureProvider<WorkoutSession?>(
  (ref) => ref.watch(sessionRepositoryProvider).findActive(),
);

final deviceMemoryProvider = Provider<DeviceMemory>(
  (ref) => PlatformDeviceMemory(),
);

/// Total RAM, used only to show or hide the on-device assistant.
final deviceProfileProvider = FutureProvider<DeviceProfile>((ref) async {
  final bytes = await ref.watch(deviceMemoryProvider).readBytes();
  return DeviceProfile(totalRamBytes: bytes);
});

/// Overridden in `main` with the bundled database.
final codexIndexProvider = Provider<CodexIndex>(
  (ref) => throw UnimplementedError('codexIndexProvider not overridden'),
);

/// Overridden in `main`. Tests use a fake so the model runtime is not loaded.
final localAssistantProvider = Provider<LocalAssistant>(
  (ref) => throw UnimplementedError('localAssistantProvider not overridden'),
);

/// Overridden in `main`. Tests use a fake so nothing is downloaded.
final modelStoreProvider = Provider<ModelStore>(
  (ref) => throw UnimplementedError('modelStoreProvider not overridden'),
);
