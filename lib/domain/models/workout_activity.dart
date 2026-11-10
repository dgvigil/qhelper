import 'package:q_helper/domain/models/validation.dart';

enum ActivityKind { reps, timed, freeForm }

/// Type-specific fields of an activity.
sealed class ActivityDetails {
  const ActivityDetails();

  ActivityKind get kind;

  List<ValidationIssue> validate();

  Map<String, Object?> toJson();

  static ActivityDetails fromJson(Map<String, Object?> json) {
    final kind = ActivityKind.values.byName(json['kind']! as String);
    return switch (kind) {
      ActivityKind.reps => RepsDetails(
        repetitions: json['repetitions']! as int,
      ),
      ActivityKind.timed => TimedDetails(
        workSeconds: json['workSeconds']! as int,
        restSeconds: json['restSeconds']! as int,
        rounds: json['rounds']! as int,
      ),
      ActivityKind.freeForm => FreeFormDetails(
        instructions: json['instructions']! as String,
      ),
    };
  }
}

class RepsDetails extends ActivityDetails {
  const RepsDetails({required this.repetitions});

  final int repetitions;

  @override
  ActivityKind get kind => ActivityKind.reps;

  @override
  List<ValidationIssue> validate() => [
    if (repetitions <= 0)
      const ValidationIssue('repetitions', 'must be greater than zero'),
  ];

  @override
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'repetitions': repetitions,
  };

  @override
  bool operator ==(Object other) =>
      other is RepsDetails && other.repetitions == repetitions;

  @override
  int get hashCode => Object.hash(kind, repetitions);
}

class TimedDetails extends ActivityDetails {
  const TimedDetails({
    required this.workSeconds,
    required this.restSeconds,
    required this.rounds,
  });

  final int workSeconds;
  final int restSeconds;
  final int rounds;

  @override
  ActivityKind get kind => ActivityKind.timed;

  @override
  List<ValidationIssue> validate() => [
    if (workSeconds <= 0)
      const ValidationIssue('workSeconds', 'must be greater than zero'),
    if (restSeconds < 0)
      const ValidationIssue('restSeconds', 'must not be negative'),
    if (rounds <= 0)
      const ValidationIssue('rounds', 'must be greater than zero'),
  ];

  @override
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'workSeconds': workSeconds,
    'restSeconds': restSeconds,
    'rounds': rounds,
  };

  @override
  bool operator ==(Object other) =>
      other is TimedDetails &&
      other.workSeconds == workSeconds &&
      other.restSeconds == restSeconds &&
      other.rounds == rounds;

  @override
  int get hashCode => Object.hash(kind, workSeconds, restSeconds, rounds);
}

class FreeFormDetails extends ActivityDetails {
  const FreeFormDetails({required this.instructions});

  final String instructions;

  @override
  ActivityKind get kind => ActivityKind.freeForm;

  @override
  List<ValidationIssue> validate() => [
    if (instructions.trim().isEmpty)
      const ValidationIssue('instructions', 'must not be blank'),
  ];

  @override
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'instructions': instructions,
  };

  @override
  bool operator ==(Object other) =>
      other is FreeFormDetails && other.instructions == instructions;

  @override
  int get hashCode => Object.hash(kind, instructions);
}

class WorkoutActivity {
  const WorkoutActivity({
    required this.id,
    required this.segmentId,
    required this.sortOrder,
    required this.name,
    required this.details,
    this.notes,
  });

  final String id;
  final String segmentId;
  final int sortOrder;
  final String name;
  final String? notes;
  final ActivityDetails details;

  ActivityKind get kind => details.kind;

  factory WorkoutActivity.fromJson(Map<String, Object?> json) {
    return WorkoutActivity(
      id: json['id']! as String,
      segmentId: json['segmentId']! as String,
      sortOrder: json['sortOrder']! as int,
      name: json['name']! as String,
      notes: json['notes'] as String?,
      details: ActivityDetails.fromJson(
        json['details']! as Map<String, Object?>,
      ),
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'segmentId': segmentId,
    'sortOrder': sortOrder,
    'name': name,
    'notes': notes,
    'details': details.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is WorkoutActivity &&
      other.id == id &&
      other.segmentId == segmentId &&
      other.sortOrder == sortOrder &&
      other.name == name &&
      other.notes == notes &&
      other.details == details;

  @override
  int get hashCode =>
      Object.hash(id, segmentId, sortOrder, name, notes, details);

  WorkoutActivity copyWith({
    String? id,
    String? segmentId,
    int? sortOrder,
    String? name,
    String? notes,
    ActivityDetails? details,
  }) {
    return WorkoutActivity(
      id: id ?? this.id,
      segmentId: segmentId ?? this.segmentId,
      sortOrder: sortOrder ?? this.sortOrder,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      details: details ?? this.details,
    );
  }

  List<ValidationIssue> validate() => [
    if (name.trim().isEmpty) const ValidationIssue('name', 'must not be blank'),
    ...details.validate(),
  ];
}
