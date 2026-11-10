import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/models/workout_activity.dart';
import 'package:q_helper/domain/models/workout_segment.dart';

import '../../fixtures/plans.dart';

void main() {
  group('WorkoutPlan.validate', () {
    test('accepts a complete valid plan', () {
      expect(buildPlan().validate(), isEmpty);
    });

    test('rejects a blank title', () {
      expect(buildPlan(title: '  ').validate().map((i) => i.field), ['title']);
    });

    test('rejects a zero or negative target duration', () {
      expect(
        buildPlan(targetDurationSeconds: 0).validate().map((i) => i.field),
        ['targetDurationSeconds'],
      );
      expect(
        buildPlan(targetDurationSeconds: -60).validate().map((i) => i.field),
        ['targetDurationSeconds'],
      );
    });

    test('rejects a blank segment title with its position', () {
      final plan = buildPlan();
      final bad = plan.copyWith(
        segments: [
          plan.segments[0].copyWith(title: ''),
          plan.segments[1],
        ],
      );
      expect(bad.validate().map((i) => i.field), ['segments[0].title']);
    });

    test('rejects a non-positive segment estimate', () {
      final plan = buildPlan();
      final bad = plan.copyWith(
        segments: [
          plan.segments[0],
          plan.segments[1].copyWith(estimatedDurationSeconds: 0),
        ],
      );
      expect(bad.validate().map((i) => i.field), [
        'segments[1].estimatedDurationSeconds',
      ]);
    });

    test('reports nested activity problems with their full path', () {
      final plan = buildPlan();
      final badActivity = plan.segments[0].activities[1].copyWith(
        details: const RepsDetails(repetitions: 0),
      );
      final bad = plan.copyWith(
        segments: [
          plan.segments[0].copyWith(
            activities: [plan.segments[0].activities[0], badActivity],
          ),
          plan.segments[1],
        ],
      );
      expect(bad.validate().map((i) => i.field), [
        'segments[0].activities[1].repetitions',
      ]);
    });

    test('allows a plan with no segments', () {
      expect(
        buildPlan().copyWith(segments: <WorkoutSegment>[]).validate(),
        isEmpty,
      );
    });

    test('collects issues from every level in one pass', () {
      final plan = buildPlan(title: '', targetDurationSeconds: 0);
      final bad = plan.copyWith(
        segments: [
          plan.segments[0].copyWith(title: ' '),
          plan.segments[1],
        ],
      );
      expect(
        bad.validate().map((i) => i.field),
        unorderedEquals([
          'title',
          'targetDurationSeconds',
          'segments[0].title',
        ]),
      );
    });
  });
}
