import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/models/workout_activity.dart';
import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/models/workout_segment.dart';
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
        segments: [
          plan.segments[0].copyWith(activities: []),
          plan.segments[1],
        ],
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

  group('segment edits', () {
    WorkoutSegment seg(String id, String title) => WorkoutSegment(
      id: id,
      planId: 'plan-1',
      title: title,
      sortOrder: 99,
      activities: const [],
    );

    List<String> titles(WorkoutPlan p) => [for (final s in p.segments) s.title];

    test('addSegment appends and numbers segments', () {
      final result = addSegment(buildPlan(), seg('s-new', 'Mary'));
      expect(titles(result), ['Warm-O-Rama', 'The Thang', 'Mary']);
      expect(result.segments.map((s) => s.sortOrder), [0, 1, 2]);
      expect(result.segments.last.planId, 'plan-1');
    });

    test('addSegment can insert at an index', () {
      final result = addSegment(buildPlan(), seg('s-new', 'Mary'), index: 1);
      expect(titles(result), ['Warm-O-Rama', 'Mary', 'The Thang']);
      expect(result.segments.map((s) => s.sortOrder), [0, 1, 2]);
    });

    test('renameSegment changes only that title', () {
      final result = renameSegment(buildPlan(), 'plan-1-seg-1', 'Main Event');
      expect(titles(result), ['Warm-O-Rama', 'Main Event']);
      expect(result.segments[1].activities, hasLength(1));
    });

    test('removeSegment drops it with its activities and renumbers', () {
      final result = removeSegment(buildPlan(), 'plan-1-seg-0');
      expect(titles(result), ['The Thang']);
      expect(result.segments.single.sortOrder, 0);
    });

    test('moveSegment reorders and renumbers', () {
      final plan = addSegment(buildPlan(), seg('s3', 'Mary'));
      final result = moveSegment(plan, 2, 0);
      expect(titles(result), ['Mary', 'Warm-O-Rama', 'The Thang']);
      expect(result.segments.map((s) => s.sortOrder), [0, 1, 2]);
    });

    test('moveSegment to the same index changes nothing', () {
      expect(moveSegment(buildPlan(), 1, 1), buildPlan());
    });

    test('segment helpers throw for unknown ids and bad indexes', () {
      expect(() => renameSegment(buildPlan(), 'x', 'y'), throwsStateError);
      expect(() => removeSegment(buildPlan(), 'x'), throwsStateError);
      expect(() => moveSegment(buildPlan(), 5, 0), throwsRangeError);
    });

    test('moveActivity reorders within a segment and renumbers', () {
      final result = moveActivity(buildPlan(), 'plan-1-seg-0', 0, 1);
      expect(names(result.segments[0].activities), ['Mosey', 'SSH']);
      expect(result.segments[0].activities.map((a) => a.sortOrder), [0, 1]);
    });

    test('moveActivity throws for an unknown segment or bad index', () {
      expect(() => moveActivity(buildPlan(), 'x', 0, 1), throwsStateError);
      expect(
        () => moveActivity(buildPlan(), 'plan-1-seg-0', 0, 9),
        throwsRangeError,
      );
    });
  });
}
