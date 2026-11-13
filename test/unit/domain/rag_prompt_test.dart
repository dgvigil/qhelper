import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/codex/codex_entry.dart';
import 'package:q_helper/domain/codex/rag_prompt.dart';

void main() {
  const merkin = CodexEntry(
    kind: CodexKind.exicon,
    title: 'Merkin Jack',
    tags: 'Arms',
    body: 'A merkin with a plank jack.',
  );
  const coupon = CodexEntry(
    kind: CodexKind.lexicon,
    title: 'Coupon',
    tags: '',
    body: 'A weighty item. Most commonly a cinder block.',
  );

  test('puts the retrieved entries and the question in the prompt', () {
    final prompt = ragUserMessage('What is a Merkin?', [merkin]);
    expect(prompt, contains('[Exercise] Merkin Jack'));
    expect(prompt, contains('A merkin with a plank jack.'));
    expect(prompt, contains('Tags: Arms'));
    expect(prompt, contains('Question:\nWhat is a Merkin?'));
    expect(prompt, contains('Do not invent exercises'));
    expect(prompt, isNot(contains('Coupon')));
  });

  test('says when nothing was retrieved', () {
    final prompt = ragUserMessage('What is a zzz?', const []);
    expect(prompt, contains('(none)'));
    expect(prompt, contains('say you do not know'));
  });

  test('clips a long entry and keeps the title', () {
    final long = CodexEntry(
      kind: CodexKind.exicon,
      title: 'Long One',
      tags: '',
      body: List.filled(200, 'word').join(' '),
    );
    final prompt = ragUserMessage('long', [long, coupon]);
    expect(prompt, contains('[Exercise] Long One'));
    expect(prompt, contains('…'));
    expect(prompt.indexOf('Long One'), lessThan(prompt.indexOf('Coupon')));
  });
}
