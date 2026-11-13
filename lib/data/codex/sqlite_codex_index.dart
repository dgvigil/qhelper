import 'package:q_helper/domain/codex/codex_entry.dart';
import 'package:q_helper/domain/codex/codex_index.dart';
import 'package:q_helper/domain/codex/codex_query.dart';
import 'package:sqlite3/sqlite3.dart';

/// Full-text search over a Codex database built by [importCodex].
class SqliteCodexIndex implements CodexIndex {
  SqliteCodexIndex(this._db);

  final Database _db;

  factory SqliteCodexIndex.openFile(String path) {
    return SqliteCodexIndex(sqlite3.open(path, mode: OpenMode.readOnly));
  }

  void close() => _db.close();

  String? revision() {
    final rows = _db.select("SELECT value FROM meta WHERE key = 'revision'");
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  @override
  List<CodexEntry> search(String query, {CodexKind? kind, int limit = 20}) {
    final match = ftsMatchQuery(query);
    if (match == null || limit <= 0) return const [];
    final keywords = codexKeywords(query);

    final rows = kind == null
        ? _db.select(
            '''
            SELECT e.kind, e.title, e.tags, e.body
            FROM entries_fts
            JOIN entries e ON e.id = entries_fts.rowid
            WHERE entries_fts MATCH ?
            ORDER BY bm25(entries_fts, 10.0, 4.0, 1.0)
            LIMIT ?
            ''',
            [match, limit],
          )
        : _db.select(
            '''
            SELECT e.kind, e.title, e.tags, e.body
            FROM entries_fts
            JOIN entries e ON e.id = entries_fts.rowid
            WHERE entries_fts MATCH ? AND e.kind = ?
            ORDER BY bm25(entries_fts, 10.0, 4.0, 1.0)
            LIMIT ?
            ''',
            [match, kind.name, limit],
          );

    final ranked = <({int index, CodexEntry entry})>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      ranked.add((
        index: i,
        entry: CodexEntry(
          kind: CodexKind.parse(row['kind'] as String),
          title: row['title'] as String,
          tags: row['tags'] as String,
          body: row['body'] as String,
        ),
      ));
    }
    ranked.sort((a, b) {
      final byTitle = _titleRank(
        a.entry.title,
        keywords,
      ).compareTo(_titleRank(b.entry.title, keywords));
      if (byTitle != 0) return byTitle;
      return a.index.compareTo(b.index);
    });
    return [for (final row in ranked) row.entry];
  }
}

/// 0 when the title is one of the keywords, 1 when it starts with one, else 2.
int _titleRank(String title, List<String> keywords) {
  final normalized = title.toLowerCase();
  var best = 2;
  for (final keyword in keywords) {
    if (normalized == keyword) return 0;
    if (normalized.startsWith(keyword) && best > 1) best = 1;
  }
  return best;
}
