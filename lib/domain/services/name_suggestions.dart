import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/services/plan_edits.dart';

/// Exercise names the Q has used before that match [query].
///
/// Suggestions come only from the Q's own plans (plus [extra], such as the
/// plan being edited). Prefix matches come first. At most [limit] are
/// returned, and the exact text already typed is not offered back (a
/// different capitalization is, so the Q can pick the familiar spelling).
List<String> suggestNames(
  List<WorkoutPlan> plans,
  String query, {
  Iterable<String> extra = const [],
  int limit = 5,
}) {
  final text = query.trim().toLowerCase();
  if (text.isEmpty) return const [];

  final seen = <String>{};
  final names = <String>[];
  void add(String name) {
    final clean = name.trim();
    if (clean.isNotEmpty && seen.add(clean.toLowerCase())) names.add(clean);
  }

  for (final plan in plans) {
    for (final activity in flattenActivities(plan)) {
      add(activity.name);
    }
  }
  extra.forEach(add);

  bool starts(String n) => n.toLowerCase().startsWith(text);
  bool contains(String n) => n.toLowerCase().contains(text);
  final matches = [
    ...names.where(starts),
    ...names.where((n) => !starts(n) && contains(n)),
  ].where((n) => n != query.trim());
  return matches.take(limit).toList();
}
