import 'package:q_helper/domain/models/workout_plan.dart';

abstract interface class PlanRepository {
  /// Validates and stores [plan]. Throws `PlanValidationException` if invalid.
  Future<WorkoutPlan> create(WorkoutPlan plan);

  Future<WorkoutPlan?> get(String id);

  /// Most recently updated first.
  Future<List<WorkoutPlan>> list();

  /// Replaces the stored plan, keeping its original `createdAt` and stamping
  /// a new `updatedAt`. Throws `StateError` if the plan does not exist.
  Future<WorkoutPlan> update(WorkoutPlan plan);

  /// Deleting a missing plan is a no-op.
  Future<void> delete(String id);

  /// Stores a copy with new ids and a "(copy)" title.
  /// Throws `StateError` if [id] does not exist.
  Future<WorkoutPlan> duplicate(String id);
}
