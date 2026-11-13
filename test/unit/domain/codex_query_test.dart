import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/codex/codex_query.dart';

void main() {
  test('keeps the exercise word in a definition question', () {
    expect(codexKeywords('What is a Merkin?'), ['merkin']);
    expect(ftsMatchQuery('What is a Merkin?'), '"merkin"*');
  });

  test('keeps coupon and beatdown from a workout request', () {
    expect(codexKeywords('build me a 45-minute beatdown with a coupon'), [
      'beatdown',
      'coupon',
    ]);
  });

  test('drops punctuation so a search cannot break the index query', () {
    expect(ftsMatchQuery('merkin!!!'), '"merkin"*');
    expect(ftsMatchQuery('???'), isNull);
    expect(ftsMatchQuery('  '), isNull);
  });
}
