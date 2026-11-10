import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/models/workout_activity.dart';
import 'package:q_helper/domain/services/plan_edits.dart';

import '../../fixtures/plans.dart';

WorkoutActivity newActivity({String id = 'new', String name = 'Bear Crawl'}) =>
    WorkoutActivity(
      id: id,
      segmentId: 'ignored',
      sortOrder: 99,
      name: name,
      details: const RepsDetails(repetitions: 10),
    );

List<String> names(Iterable<WorkoutActivity> a) => [for (final x in a) x.name];

void main() {
  group('flattenActivities', () {
    test('lists activities across segments in order', () {
      expect(names(flattenActivities(buildPlan())), [
        'SSH',
        'Mosey',
        'Burpee EMOM',
      ]);
    });

    test('orders by sortOrder even if stored out of order', () {
      final plan = buildPlan();
      final shuffled = plan.copyWith(
        segments: [
          plan.segments[1],
          plan.segments[0].copyWith(
            activities: plan.segments[0].activities.reversed.toList(),
          ),
        ],
      );
      expect(names(flattenActivities(shuffled)), [
        'SSH',
        'Mosey',
        'Burpee EMOM',
      ]);
    });

    test('is empty for a plan with no activities', () {
      expect(flattenActivities(buildPlan().copyWith(segments: [])), isEmpty);
    });
  });

  group('replaceActivity', () {
    test('changes only the matching activity', () {
      final plan = buildPlan();
      final edited = plan.segments[0].activities[0].copyWith(name: 'Big SSH');
      final result = replaceActivity(plan, edited);
      expect(names(flattenActivities(result)), [
        'Big SSH',
        'Mosey',
        'Burpee EMOM',
      ]);
      expect(names(flattenActivities(plan)).first, 'SSH');
    });

    test('keeps position and parent of the activity it replaces', () {
      final plan = buildPlan();
      final edited = newActivity(id: 'plan-1-act-1', name: 'Lunge walk');
      final result = replaceActivity(plan, edited);
      final replaced = result.segments[0].activities[1];
      expect(replaced.name, 'Lunge walk');
      expect(replaced.sortOrder, 1);
      expect(replaced.segmentId, 'plan-1-seg-0');
    });

    test('throws for an unknown activity', () {
      expect(
        () => replaceActivity(buildPlan(), newActivity(id: 'missing')),
        throwsStateError,
      );
    });
  });

  group('insertActivity', () {
    test('appends to the end of a segment by default', () {
      final result = insertActivity(buildPlan(), 'plan-1-seg-1', newActivity());
      final acts = result.segments[1].activities;
      expect(names(acts), ['Burpee EMOM', 'Bear Crawl']);
      expect(acts.map((a) => a.sortOrder), [0, 1]);
      expect(acts.last.segmentId, 'plan-1-seg-1');
    });

    test('inserts at an index and renumbers', () {
      final result = insertActivity(
        buildPlan(),
        'plan-1-seg-0',
        newActivity(),
        index: 1,
      );
      final acts = result.segments[0].activities;
      expect(names(acts), ['SSH', 'Bear Crawl', 'Mosey']);
      expect(acts.map((a) => a.sortOrder), [0, 1, 2]);
    });

    test('works for an empty segment', () {
      final plan = buildPlan();
      final empty = plan.copyWith(
        segments: [plan.segments[0].copyWith(activities: []), plan.segments[1]],
      );
      final result = insertActivity(empty, 'plan-1-seg-0', newActivity());
      expect(names(result.segments[0].activities), ['Bear Crawl']);
    });

    test('throws for an unknown segment', () {
      expect(
        () => insertActivity(buildPlan(), 'missing', newActivity()),
        throwsStateError,
      );
    });
  });

  group('removeActivity', () {
    test('removes the activity and renumbers the rest', () {
      final result = removeActivity(buildPlan(), 'plan-1-act-0');
      final acts = result.segments[0].activities;
      expect(names(acts), ['Mosey']);
      expect(acts.single.sortOrder, 0);
    });

    test('leaves the segment in place when it becomes empty', () {
      final result = removeActivity(buildPlan(), 'plan-1-act-2');
      expect(result.segments, hasLength(2));
      expect(result.segments[1].activities, isEmpty);
    });

    test('throws for an unknown activity', () {
      expect(() => removeActivity(buildPlan(), 'missing'), throwsStateError);
    });
  });
}
