import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/models/workout_plan.dart';

import '../../fixtures/plans.dart';

WorkoutPlan roundTrip(WorkoutPlan plan) {
  final text = jsonEncode(plan.toJson());
  return WorkoutPlan.fromJson(jsonDecode(text) as Map<String, Object?>);
}

void main() {
  group('WorkoutPlan JSON', () {
    test('round-trips a plan with every activity kind', () {
      final plan = buildPlan();
      expect(roundTrip(plan), plan);
    });

    test('round-trips a plan with all optional fields absent', () {
      final full = buildPlan(id: 'plan-2', targetDurationSeconds: 3600);
      final sparse = WorkoutPlan(
        id: full.id,
        title: 'Bare',
        targetDurationSeconds: 1800,
        createdAt: full.createdAt,
        updatedAt: full.updatedAt,
        segments: [full.segments[1].copyWith(planId: full.id, id: 's')],
      );
      expect(sparse.description, isNull);
      expect(roundTrip(sparse), sparse);
    });

    test('preserves times as exact instants', () {
      final plan = buildPlan(createdAt: DateTime.utc(2026, 1, 2, 3, 4, 5, 678));
      final copy = roundTrip(plan);
      expect(copy.createdAt, plan.createdAt);
      expect(copy.createdAt.isUtc, isTrue);
    });

    test('plans with different content are not equal', () {
      expect(buildPlan() == buildPlan(title: 'Other'), isFalse);
      expect(buildPlan() == buildPlan(), isTrue);
    });

    test('preserves segment and activity order', () {
      final copy = roundTrip(buildPlan());
      expect(copy.segments.map((s) => s.title), ['Warm-O-Rama', 'The Thang']);
      expect(copy.segments[0].activities.map((a) => a.name), ['SSH', 'Mosey']);
    });
  });
}
