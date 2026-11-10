import 'package:q_helper/domain/models/list_equality.dart';
import 'package:q_helper/domain/models/validation.dart';
import 'package:q_helper/domain/models/workout_segment.dart';

class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.title,
    required this.targetDurationSeconds,
    required this.createdAt,
    required this.updatedAt,
    required this.segments,
    this.description,
    this.schemaVersion = currentSchemaVersion,
  });

  static const int currentSchemaVersion = 1;

  final String id;
  final String title;
  final String? description;
  final int targetDurationSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int schemaVersion;
  final List<WorkoutSegment> segments;

  factory WorkoutPlan.fromJson(Map<String, Object?> json) {
    return WorkoutPlan(
      id: json['id']! as String,
      title: json['title']! as String,
      description: json['description'] as String?,
      targetDurationSeconds: json['targetDurationSeconds']! as int,
      createdAt: DateTime.parse(json['createdAt']! as String),
      updatedAt: DateTime.parse(json['updatedAt']! as String),
      schemaVersion: json['schemaVersion']! as int,
      segments: [
        for (final s in json['segments']! as List<Object?>)
          WorkoutSegment.fromJson(s! as Map<String, Object?>),
      ],
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'targetDurationSeconds': targetDurationSeconds,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'schemaVersion': schemaVersion,
    'segments': [for (final s in segments) s.toJson()],
  };

  @override
  bool operator ==(Object other) =>
      other is WorkoutPlan &&
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.targetDurationSeconds == targetDurationSeconds &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.schemaVersion == schemaVersion &&
      listsEqual(other.segments, segments);

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    targetDurationSeconds,
    createdAt,
    updatedAt,
    schemaVersion,
    Object.hashAll(segments),
  );

  WorkoutPlan copyWith({
    String? id,
    String? title,
    String? description,
    int? targetDurationSeconds,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? schemaVersion,
    List<WorkoutSegment>? segments,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDurationSeconds:
          targetDurationSeconds ?? this.targetDurationSeconds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      segments: segments ?? this.segments,
    );
  }

  List<ValidationIssue> validate() => [
    if (title.trim().isEmpty)
      const ValidationIssue('title', 'must not be blank'),
    if (targetDurationSeconds <= 0)
      const ValidationIssue(
        'targetDurationSeconds',
        'must be greater than zero',
      ),
    for (var i = 0; i < segments.length; i++)
      for (final issue in segments[i].validate())
        ValidationIssue('segments[$i].${issue.field}', issue.message),
  ];
}
