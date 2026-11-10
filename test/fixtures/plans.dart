import 'package:q_helper/domain/models/workout_activity.dart';
import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/models/workout_segment.dart';

final DateTime fixtureTime = DateTime.utc(2026, 11, 10, 5, 30);

/// A valid 45-minute plan with two segments and all three activity kinds.
WorkoutPlan buildPlan({
  String id = 'plan-1',
  String title = 'Tuesday Beatdown',
  int targetDurationSeconds = 2700,
  DateTime? createdAt,
}) {
  final time = createdAt ?? fixtureTime;
  return WorkoutPlan(
    id: id,
    title: title,
    description: 'Legs and lungs',
    targetDurationSeconds: targetDurationSeconds,
    createdAt: time,
    updatedAt: time,
    segments: [
      WorkoutSegment(
        id: '$id-seg-0',
        planId: id,
        title: 'Warm-O-Rama',
        sortOrder: 0,
        estimatedDurationSeconds: 300,
        activities: [
          WorkoutActivity(
            id: '$id-act-0',
            segmentId: '$id-seg-0',
            sortOrder: 0,
            name: 'SSH',
            details: const RepsDetails(repetitions: 25),
          ),
          WorkoutActivity(
            id: '$id-act-1',
            segmentId: '$id-seg-0',
            sortOrder: 1,
            name: 'Mosey',
            notes: 'Around the lot',
            details: const FreeFormDetails(instructions: 'Easy pace, 2 laps'),
          ),
        ],
      ),
      WorkoutSegment(
        id: '$id-seg-1',
        planId: id,
        title: 'The Thang',
        sortOrder: 1,
        activities: [
          WorkoutActivity(
            id: '$id-act-2',
            segmentId: '$id-seg-1',
            sortOrder: 0,
            name: 'Burpee EMOM',
            details: const TimedDetails(
              workSeconds: 40,
              restSeconds: 20,
              rounds: 5,
            ),
          ),
        ],
      ),
    ],
  );
}
