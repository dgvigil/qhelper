import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/models/workout_activity.dart';

WorkoutActivity activity({
  String name = 'Merkins',
  ActivityDetails details = const RepsDetails(repetitions: 20),
}) {
  return WorkoutActivity(
    id: 'a1',
    segmentId: 's1',
    sortOrder: 0,
    name: name,
    details: details,
  );
}

void main() {
  group('WorkoutActivity.validate', () {
    test('accepts a reps activity with positive repetitions', () {
      expect(activity().validate(), isEmpty);
    });

    test('rejects zero repetitions', () {
      final issues = activity(details: const RepsDetails(repetitions: 0))
          .validate();
      expect(issues.map((i) => i.field), ['repetitions']);
    });

    test('rejects negative repetitions', () {
      final issues = activity(details: const RepsDetails(repetitions: -5))
          .validate();
      expect(issues.map((i) => i.field), ['repetitions']);
    });

    test('accepts a timed activity with zero rest', () {
      final issues = activity(
        details: const TimedDetails(workSeconds: 40, restSeconds: 0, rounds: 3),
      ).validate();
      expect(issues, isEmpty);
    });

    test('rejects timed work of zero seconds', () {
      final issues = activity(
        details: const TimedDetails(workSeconds: 0, restSeconds: 20, rounds: 3),
      ).validate();
      expect(issues.map((i) => i.field), ['workSeconds']);
    });

    test('rejects negative rest', () {
      final issues = activity(
        details: const TimedDetails(
          workSeconds: 40,
          restSeconds: -1,
          rounds: 3,
        ),
      ).validate();
      expect(issues.map((i) => i.field), ['restSeconds']);
    });

    test('rejects zero rounds', () {
      final issues = activity(
        details: const TimedDetails(
          workSeconds: 40,
          restSeconds: 20,
          rounds: 0,
        ),
      ).validate();
      expect(issues.map((i) => i.field), ['rounds']);
    });

    test('reports every invalid timed field at once', () {
      final issues = activity(
        details: const TimedDetails(workSeconds: 0, restSeconds: -1, rounds: 0),
      ).validate();
      expect(
        issues.map((i) => i.field),
        unorderedEquals(['workSeconds', 'restSeconds', 'rounds']),
      );
    });

    test('accepts free-form instructions', () {
      final issues = activity(
        details: const FreeFormDetails(
          instructions: 'Partner carry to the oak',
        ),
      ).validate();
      expect(issues, isEmpty);
    });

    test('rejects blank free-form instructions', () {
      final issues = activity(
        details: const FreeFormDetails(instructions: '   '),
      ).validate();
      expect(issues.map((i) => i.field), ['instructions']);
    });

    test('rejects a blank name for any kind', () {
      expect(activity(name: ' ').validate().map((i) => i.field), ['name']);
    });

    test('kind reflects the details type', () {
      expect(activity().kind, ActivityKind.reps);
      expect(
        activity(
          details: const TimedDetails(
            workSeconds: 1,
            restSeconds: 0,
            rounds: 1,
          ),
        ).kind,
        ActivityKind.timed,
      );
      expect(
        activity(details: const FreeFormDetails(instructions: 'x')).kind,
        ActivityKind.freeForm,
      );
    });
  });
}
