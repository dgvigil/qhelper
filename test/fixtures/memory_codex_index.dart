import 'package:q_helper/domain/codex/codex_entry.dart';
import 'package:q_helper/domain/codex/codex_index.dart';
import 'package:q_helper/domain/codex/codex_query.dart';

const sampleCodexEntries = <CodexEntry>[
  CodexEntry(
    kind: CodexKind.exicon,
    title: 'Merkin Jack',
    tags: 'Arms',
    body: 'A merkin with a plank jack at the bottom of the merkin.',
  ),
  CodexEntry(
    kind: CodexKind.lexicon,
    title: 'Coupon',
    tags: '',
    body: 'A weighty item utilized by the PAX. Most commonly a cinder block.',
  ),
];

/// A small in-memory index for widget tests. Full-text ranking is covered
/// by the SQLite tests.
class MemoryCodexIndex implements CodexIndex {
  const MemoryCodexIndex(this.entries);

  final List<CodexEntry> entries;

  @override
  List<CodexEntry> search(String query, {CodexKind? kind, int limit = 20}) {
    final keywords = codexKeywords(query);
    if (keywords.isEmpty || limit <= 0) return const [];
    return entries
        .where((entry) {
          if (kind != null && entry.kind != kind) return false;
          final hay = '${entry.title} ${entry.tags} ${entry.body}'
              .toLowerCase();
          return keywords.every(hay.contains);
        })
        .take(limit)
        .toList();
  }
}
