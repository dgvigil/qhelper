import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/assistant/answer_text.dart';

void main() {
  test('hides a think block and keeps the answer', () {
    expect(
      stripReasoning('<think>push-up?</think>\nA merkin is a push-up.'),
      'A merkin is a push-up.',
    );
  });

  test('hides a thought block and an unclosed think block', () {
    expect(
      stripReasoning('<thought>hmm</thought>Coupon: a block.'),
      'Coupon: a block.',
    );
    expect(stripReasoning('reasoning</think>Done.'), 'Done.');
  });

  test('leaves an answer that has no reasoning block', () {
    expect(stripReasoning('  Short answer.  '), 'Short answer.');
  });
}
