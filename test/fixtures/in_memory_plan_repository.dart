import 'package:q_helper/domain/models/validation.dart';
import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/repositories/plan_repository.dart';

/// Simple in-memory repository for widget tests. Mirrors the contract of the
/// Drift implementation (validation, kept createdAt, copy titles).
class InMemoryPlanRepository implements PlanRepository {
  InMemoryPlanRepository({DateTime Function()? now, String Function()? newId})
    : _now = now ?? (() => DateTime.utc(2026, 11, 10, 12)),
      _newId = newId ?? (() => 'copy-${_counter++}');

  static int _counter = 0;

  final DateTime Function() _now;
  final String Function() _newId;
  final Map<String, WorkoutPlan> _plans = {};

  List<WorkoutPlan> get stored => _plans.values.toList();

  void seed(WorkoutPlan plan) => _plans[plan.id] = plan;

  void _validate(WorkoutPlan plan) {
    final issues = plan.validate();
    if (issues.isNotEmpty) throw PlanValidationException(issues);
  }

  @override
  Future<WorkoutPlan> create(WorkoutPlan plan) async {
    _validate(plan);
    _plans[plan.id] = plan;
    return plan;
  }

  @override
  Future<WorkoutPlan?> get(String id) async => _plans[id];

  @override
  Future<List<WorkoutPlan>> list() async =>
      _plans.values.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  @override
  Future<WorkoutPlan> update(WorkoutPlan plan) async {
    _validate(plan);
    final existing = _plans[plan.id];
    if (existing == null) throw StateError('Plan ${plan.id} does not exist');
    final saved = plan.copyWith(
      createdAt: existing.createdAt,
      updatedAt: _now(),
    );
    _plans[plan.id] = saved;
    return saved;
  }

  @override
  Future<void> delete(String id) async => _plans.remove(id);

  @override
  Future<WorkoutPlan> duplicate(String id) async {
    final source = _plans[id];
    if (source == null) throw StateError('Plan $id does not exist');
    final planId = _newId();
    final copy = source.copyWith(
      id: planId,
      title: '${source.title} (copy)',
      createdAt: _now(),
      updatedAt: _now(),
      segments: [
        for (final s in source.segments)
          s.copyWith(
            id: _newId(),
            planId: planId,
            activities: [
              for (final a in s.activities) a.copyWith(id: _newId()),
            ],
          ),
      ],
    );
    _plans[planId] = copy;
    return copy;
  }
}
