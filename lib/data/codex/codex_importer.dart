import 'package:q_helper/domain/codex/codex_entry.dart';
import 'package:q_helper/domain/codex/text_repair.dart';
import 'package:sqlite3/sqlite3.dart';

/// Bump this when the bundled database is rebuilt, then run
/// `tool/import_codex.dart`. The app recopies the asset when it changes.
const codexRevision = '2026-11-13';

class CodexImportReport {
  const CodexImportReport({
    required this.exicon,
    required this.lexicon,
    required this.repairedFields,
  });

  final int exicon;
  final int lexicon;
  final int repairedFields;
}

/// Builds an FTS5 database from the Exicon and Lexicon CSV exports.
CodexImportReport importCodex({
  required Database db,
  required String exiconCsv,
  required String lexiconCsv,
  String revision = codexRevision,
}) {
  db.execute('DROP TABLE IF EXISTS entries_fts');
  db.execute('DROP TABLE IF EXISTS entries');
  db.execute('DROP TABLE IF EXISTS meta');
  db.execute('''
    CREATE TABLE meta (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE entries (
      id INTEGER PRIMARY KEY,
      kind TEXT NOT NULL,
      title TEXT NOT NULL,
      tags TEXT NOT NULL,
      body TEXT NOT NULL
    )
  ''');
  db.execute('''
    CREATE VIRTUAL TABLE entries_fts USING fts5(
      title,
      tags,
      body,
      content='entries',
      content_rowid='id',
      tokenize='unicode61 remove_diacritics 2'
    )
  ''');

  final repaired = <int>[0];
  db.execute('BEGIN');
  try {
    final exicon = _insert(
      db,
      kind: CodexKind.exicon,
      rows: parseCsv(exiconCsv),
      titleIndex: 0,
      tagsIndex: 1,
      bodyIndex: 2,
      repaired: repaired,
    );
    final lexicon = _insert(
      db,
      kind: CodexKind.lexicon,
      rows: parseCsv(lexiconCsv),
      titleIndex: 0,
      tagsIndex: null,
      bodyIndex: 1,
      repaired: repaired,
    );
    db.execute("INSERT INTO entries_fts(entries_fts) VALUES('rebuild')");
    db.execute("INSERT INTO meta (key, value) VALUES ('revision', ?)", [
      revision,
    ]);
    db.execute('COMMIT');
    return CodexImportReport(
      exicon: exicon,
      lexicon: lexicon,
      repairedFields: repaired[0],
    );
  } catch (_) {
    db.execute('ROLLBACK');
    rethrow;
  }
}

int _insert(
  Database db, {
  required CodexKind kind,
  required List<List<String>> rows,
  required int titleIndex,
  required int? tagsIndex,
  required int bodyIndex,
  required List<int> repaired,
}) {
  var count = 0;
  for (var i = 0; i < rows.length; i++) {
    final row = rows[i];
    if (row.isEmpty) continue;
    final rawTitle = row[titleIndex].trim();
    if (i == 0 && rawTitle.toLowerCase() == 'title') continue;
    if (rawTitle.isEmpty) continue;
    final title = _field(rawTitle, repaired);
    final tags = tagsIndex != null && tagsIndex < row.length
        ? _field(row[tagsIndex].trim(), repaired)
        : '';
    final body = bodyIndex < row.length
        ? _field(row[bodyIndex].trim(), repaired)
        : '';
    db.execute(
      'INSERT INTO entries (kind, title, tags, body) VALUES (?, ?, ?, ?)',
      [kind.name, title, tags, body],
    );
    count++;
  }
  return count;
}

String _field(String raw, List<int> repaired) {
  final fixed = repairCodexText(raw);
  if (fixed != raw) repaired[0]++;
  return fixed;
}

/// A small CSV reader for quoted fields, embedded commas, quotes, and newlines.
List<List<String>> parseCsv(String input) {
  var source = input;
  if (source.startsWith('\uFEFF')) source = source.substring(1);
  source = source.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  final rows = <List<String>>[];
  final row = <String>[];
  final field = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < source.length; i++) {
    final char = source[i];
    if (inQuotes) {
      if (char == '"') {
        if (i + 1 < source.length && source[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(char);
      }
      continue;
    }
    if (char == '"') {
      inQuotes = true;
    } else if (char == ',') {
      row.add(field.toString());
      field.clear();
    } else if (char == '\n') {
      row.add(field.toString());
      field.clear();
      if (row.length != 1 || row.single.isNotEmpty) {
        rows.add(List<String>.of(row));
      }
      row.clear();
    } else {
      field.write(char);
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) {
    row.add(field.toString());
    rows.add(List<String>.of(row));
  }
  return rows;
}
