import 'package:q_helper/domain/models/list_equality.dart';
import 'package:q_helper/domain/models/validation.dart';
import 'package:q_helper/domain/models/workout_activity.dart';

class WorkoutSegment {
  const WorkoutSegment({
    required this.id,
    required this.planId,
    required this.title,
    required this.sortOrder,
    required this.activities,
    this.estimatedDurationSeconds,
  });

  final String id;
  final String planId;
  final String title;
  final int sortOrder;
  final int? estimatedDurationSeconds;
  final List<WorkoutActivity> activities;

  factory WorkoutSegment.fromJson(Map<String, Object?> json) {
    return WorkoutSegment(
      id: json['id']! as String,
      planId: json['planId']! as String,
      title: json['title']! as String,
      sortOrder: json['sortOrder']! as int,
      estimatedDurationSeconds: json['estimatedDurationSeconds'] as int?,
      activities: [
        for (final a in json['activities']! as List<Object?>)
          WorkoutActivity.fromJson(a! as Map<String, Object?>),
      ],
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'planId': planId,
    'title': title,
    'sortOrder': sortOrder,
    'estimatedDurationSeconds': estimatedDurationSeconds,
    'activities': [for (final a in activities) a.toJson()],
  };

  @override
  bool operator ==(Object other) =>
      other is WorkoutSegment &&
      other.id == id &&
      other.planId == planId &&
      other.title == title &&
      other.sortOrder == sortOrder &&
      other.estimatedDurationSeconds == estimatedDurationSeconds &&
      listsEqual(other.activities, activities);

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    title,
    sortOrder,
    estimatedDurationSeconds,
    Object.hashAll(activities),
  );

  WorkoutSegment copyWith({
    String? id,
    String? planId,
    String? title,
    int? sortOrder,
    int? estimatedDurationSeconds,
    List<WorkoutActivity>? activities,
  }) {
    return WorkoutSegment(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      title: title ?? this.title,
      sortOrder: sortOrder ?? this.sortOrder,
      estimatedDurationSeconds:
          estimatedDurationSeconds ?? this.estimatedDurationSeconds,
      activities: activities ?? this.activities,
    );
  }

  List<ValidationIssue> validate() {
    final estimate = estimatedDurationSeconds;
    return [
      if (title.trim().isEmpty)
        const ValidationIssue('title', 'must not be blank'),
      if (estimate != null && estimate <= 0)
        const ValidationIssue(
          'estimatedDurationSeconds',
          'must be greater than zero',
        ),
      for (var i = 0; i < activities.length; i++)
        for (final issue in activities[i].validate())
          ValidationIssue('activities[$i].${issue.field}', issue.message),
    ];
  }
}
