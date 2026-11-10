import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_helper/app/services/share_service.dart';
import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/repositories/plan_repository.dart';
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
