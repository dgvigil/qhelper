import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/services/templates.dart';

void main() {
  final now = DateTime.utc(2026, 11, 10, 5);
  var n = 0;
  String newId() => 'id-${n++}';

  setUp(() => n = 0);

  group('blankPlan', () {
    test('has the default four-segment structure and no activities', () {
      final plan = blankPlan(newId: newId, now: now);
      expect(plan.segments.map((s) => s.title), [
        'Warm-O-Rama',
        'The Thang',
        'Mary',
        'CoT',
      ]);
      expect(plan.segments.every((s) => s.activities.isEmpty), isTrue);
      expect(
        plan.segments.every((s) => s.estimatedDurationSeconds == null),
        isTrue,
      );
    });

    test('defaults to 45 minutes and stamps the time', () {
      final plan = blankPlan(newId: newId, now: now);
      expect(plan.targetDurationSeconds, 45 * 60);
      expect(plan.createdAt, now);
      expect(plan.updatedAt, now);
    });

    test('can start with another duration', () {
      expect(
        blankPlan(newId: newId, now: now, minutes: 30).targetDurationSeconds,
        1800,
      );
    });

    test('needs a title before it is valid and has unique linked ids', () {
      final plan = blankPlan(newId: newId, now: now);
      expect(plan.title, isEmpty);
      expect(plan.validate().map((i) => i.field), ['title']);
      final ids = {plan.id, ...plan.segments.map((s) => s.id)};
      expect(ids, hasLength(5));
      expect(plan.segments.every((s) => s.planId == plan.id), isTrue);
      expect(plan.segments.map((s) => s.sortOrder), [0, 1, 2, 3]);
    });
  });

  group('templatePlan', () {
    for (final minutes in [45, 60]) {
      test('$minutes minutes allocates time that adds up to the target', () {
        final plan = templatePlan(minutes, newId: newId, now: now);
        expect(plan.targetDurationSeconds, minutes * 60);
        final total = plan.segments.fold<int>(
          0,
          (sum, s) => sum + s.estimatedDurationSeconds!,
        );
        expect(total, minutes * 60);
      });

      test('$minutes minutes holds only segment names and times', () {
        final plan = templatePlan(minutes, newId: newId, now: now);
        expect(plan.segments.map((s) => s.title), [
          'Warm-O-Rama',
          'The Thang',
          'Mary',
          'CoT',
        ]);
        expect(plan.segments.every((s) => s.activities.isEmpty), isTrue);
        expect(plan.description, isNull);
      });
    }

    test('the 60 minute template gives The Thang more time than the 45', () {
      final a = templatePlan(45, newId: newId, now: now);
      final b = templatePlan(60, newId: newId, now: now);
      expect(
        b.segments[1].estimatedDurationSeconds,
        greaterThan(a.segments[1].estimatedDurationSeconds!),
      );
    });

    test('rejects an unknown template length', () {
      expect(
        () => templatePlan(50, newId: newId, now: now),
        throwsArgumentError,
      );
    });

    test('lists the available lengths', () {
      expect(templateMinutes, [45, 60]);
    });
  });
}
