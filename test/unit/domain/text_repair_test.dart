import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/codex/text_repair.dart';

void main() {
  test('restores an apostrophe that was saved as Windows-1252 mojibake', () {
    expect(repairCodexText('11â€™s'), '11’s');
    expect(repairCodexText('partnerâ€™s back'), 'partner’s back');
  });

  test(
    'restores curly quotes, including a closing quote kept as a control',
    () {
      expect(
        repairCodexText('aka â€œOld Man Styleâ€\u009d'),
        'aka “Old Man Style”',
      );
    },
  );

  test('turns a lost character between letters into an apostrophe', () {
    expect(repairCodexText('Peopleï¿½s Chair'), "People's Chair");
  });

  test('drops an orphaned non-breaking-space marker', () {
    expect(
      repairCodexText('feet apart.Â The person'),
      'feet apart. The person',
    );
  });

  test('leaves text that is already decoded alone', () {
    expect(repairCodexText('Q’s watch'), 'Q’s watch');
    expect(repairCodexText('Merkin'), 'Merkin');
  });

  test('turns export line breaks into newlines', () {
    expect(repairCodexText('one<br />two<br>three'), 'one\ntwo\nthree');
  });
}
