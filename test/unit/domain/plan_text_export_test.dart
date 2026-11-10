import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/models/workout_activity.dart';
import 'package:q_helper/domain/services/plan_text_export.dart';

import '../../fixtures/plans.dart';

void main() {
  group('planToText', () {
    test('formats title, target, description, segments, and activities', () {
      expect(planToText(buildPlan()), '''
Tuesday Beatdown
Target duration: 45 min
Legs and lungs

Warm-O-Rama (about 5 min)
1. SSH: 25 reps
2. Mosey: Easy pace, 2 laps
   Notes: Around the lot

The Thang
1. Burpee EMOM: 40 sec work / 20 sec rest x 5 rounds''');
    });

    test('omits the description line when there is none', () {
      final plan = buildPlan();
      final noDesc = plan.copyWith(description: '');
      expect(planToText(noDesc).split('\n')[2], '');
      expect(planToText(noDesc), isNot(contains('Legs')));
    });

    test('omits rest when it is zero', () {
      final plan = buildPlan();
      final seg = plan.segments[1];
      final edited = plan.copyWith(
        segments: [
          plan.segments[0],
          seg.copyWith(
            activities: [
              seg.activities[0].copyWith(
                details: const TimedDetails(
                  workSeconds: 90,
                  restSeconds: 0,
                  rounds: 3,
                ),
              ),
            ],
          ),
        ],
      );
      expect(planToText(edited), contains('1 min 30 sec work x 3 rounds'));
      expect(planToText(edited), isNot(contains('rest')));
    });

    test('uses singular units for one', () {
      final plan = buildPlan();
      final edited = plan.copyWith(
        segments: [
          plan.segments[0].copyWith(
            activities: [
              plan.segments[0].activities[0].copyWith(
                details: const RepsDetails(repetitions: 1),
              ),
            ],
          ),
          plan.segments[1].copyWith(
            activities: [
              plan.segments[1].activities[0].copyWith(
                details: const TimedDetails(
                  workSeconds: 60,
                  restSeconds: 30,
                  rounds: 1,
                ),
              ),
            ],
          ),
        ],
      );
      final text = planToText(edited);
      expect(text, contains('SSH: 1 rep\n'));
      expect(text, contains('1 min work / 30 sec rest x 1 round'));
      expect(text, isNot(contains('rounds')));
    });

    test('says so when a segment has no activities', () {
      final plan = buildPlan();
      final empty = plan.copyWith(
        segments: [plan.segments[0].copyWith(activities: [])],
      );
      expect(
        planToText(empty),
        contains('Warm-O-Rama (about 5 min)\n   (nothing added yet)'),
      );
    });

    test('shows non-whole-minute targets in minutes and seconds', () {
      expect(
        planToText(buildPlan(targetDurationSeconds: 2730)),
        contains('Target duration: 45 min 30 sec'),
      );
    });

    test('keeps activities in sortOrder', () {
      final plan = buildPlan();
      final seg = plan.segments[0];
      final reversed = plan.copyWith(
        segments: [
          seg.copyWith(activities: seg.activities.reversed.toList()),
          plan.segments[1],
        ],
      );
      expect(planToText(reversed), planToText(plan));
    });
  });
}
