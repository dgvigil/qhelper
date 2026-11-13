import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/data/codex/codex_importer.dart';
import 'package:q_helper/data/codex/sqlite_codex_index.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('parses quotes, commas, and newlines', () {
    final rows = parseCsv('Title,Text\n"A, B","line1\nline2 ""q"""\n');
    expect(rows, [
      ['Title', 'Text'],
      ['A, B', 'line1\nline2 "q"'],
    ]);
  });

  test('imports the Codex exports, repairs text, and searches them', () {
    final db = sqlite3.openInMemory();
    addTearDown(db.close);
    final report = importCodex(
      db: db,
      exiconCsv: File('tool/codex/source/exicon.csv').readAsStringSync(),
      lexiconCsv: File('tool/codex/source/lexicon.csv').readAsStringSync(),
    );
    expect(report.exicon, 780);
    expect(report.lexicon, 719);
    expect(report.repairedFields, greaterThan(0));

    final index = SqliteCodexIndex(db);
    final mojibake = db.select(
      "SELECT COUNT(*) AS n FROM entries WHERE body LIKE '%â€™%' OR body LIKE '%ï¿½%' OR title LIKE '%â€™%'",
    );
    expect(mojibake.first['n'], 0);

    final field = db.select(
      "SELECT body FROM entries WHERE title = '1st & 10'",
    );
    expect(field.single['body'] as String, contains('11’s'));

    final lineBreak = db.select(
      "SELECT body FROM entries WHERE title = 'All About The Benjamins'",
    );
    final benjamin = lineBreak.single['body'] as String;
    expect(benjamin, contains('\n'));
    expect(benjamin, isNot(contains('<br')));

    final merkins = index.search('What is a Merkin?');
    expect(merkins, isNotEmpty);
    expect(merkins.first.title.toLowerCase(), startsWith('merkin'));
    expect(
      merkins.every(
        (entry) =>
            entry.title.toLowerCase().contains('merkin') ||
            entry.body.toLowerCase().contains('merkin'),
      ),
      isTrue,
    );

    final coupon = index.search(
      'build me a 45-minute beatdown with a coupon',
      kind: null,
    );
    expect(coupon.first.title, 'Coupon');
    expect(coupon.first.body.toLowerCase(), contains('cinder block'));

    expect(index.search('zzzznotaterm'), isEmpty);
  });

  test('the bundled database matches this revision and finds a merkin', () {
    final index = SqliteCodexIndex.openFile('assets/codex/codex.sqlite');
    addTearDown(index.close);
    expect(index.revision(), codexRevision);
    final hits = index.search('merkin');
    expect(hits, isNotEmpty);
    expect(hits.first.title.toLowerCase(), contains('merkin'));
  });
}
