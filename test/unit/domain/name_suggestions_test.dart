import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/services/name_suggestions.dart';

import '../../fixtures/plans.dart';

void main() {
  final plans = [
    buildPlan(id: 'a'),
    buildPlan(id: 'b', title: 'Other', createdAt: DateTime.utc(2026, 1, 1)),
  ];

  test('suggests earlier names containing the text, prefix matches first', () {
    expect(suggestNames(plans, 'S'), ['SSH', 'Mosey']);
  });

  test('ignores case and lists each name once', () {
    expect(suggestNames(plans, 'ssh'), ['SSH']);
  });

  test('lists names in the order they were first used', () {
    expect(suggestNames(plans, 'e'), ['Mosey', 'Burpee EMOM']);
  });

  test('is empty for blank input or no match', () {
    expect(suggestNames(plans, ''), isEmpty);
    expect(suggestNames(plans, '  '), isEmpty);
    expect(suggestNames(plans, 'zzz'), isEmpty);
  });

  test('does not offer the exact text already typed', () {
    expect(suggestNames(plans, 'SSH'), isEmpty);
  });

  test('includes extra names, such as those in the draft', () {
    expect(suggestNames(plans, 'bear', extra: ['Bear Crawl']), ['Bear Crawl']);
  });

  test('limits the number of suggestions', () {
    final many = [for (var i = 0; i < 20; i++) 'Move $i'];
    expect(suggestNames(const [], 'move', extra: many), hasLength(5));
  });
}
