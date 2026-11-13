/// Words that do not help find an exercise or a term.
const codexStopWords = <String>{
  'what',
  'whats',
  'who',
  'how',
  'why',
  'when',
  'where',
  'is',
  'are',
  'was',
  'were',
  'a',
  'an',
  'the',
  'me',
  'my',
  'i',
  'you',
  'your',
  'we',
  'our',
  'with',
  'for',
  'and',
  'or',
  'of',
  'to',
  'do',
  'does',
  'can',
  'please',
  'into',
  'from',
  'that',
  'this',
  'it',
  'on',
  'in',
  'at',
  'be',
  'build',
  'make',
  'give',
  'minute',
  'minutes',
  'min',
};

/// Words worth searching for, in order, with duplicates removed.
///
/// Digits-only tokens are dropped so "45" in "45-minute" does not have to
/// appear in an entry. Tokens shorter than three letters are dropped.
List<String> codexKeywords(String raw) {
  final words = raw.toLowerCase().split(RegExp(r'[^a-z0-9]+'));
  final kept = <String>[];
  final seen = <String>{};
  for (final word in words) {
    if (word.length < 3) continue;
    if (RegExp(r'^\d+$').hasMatch(word)) continue;
    if (codexStopWords.contains(word)) continue;
    if (seen.add(word)) kept.add(word);
    if (kept.length == 8) break;
  }
  return kept;
}

/// An FTS5 MATCH string, or null when [raw] has nothing to search for.
///
/// Each keyword is a prefix query so "merk" can find "Merkin".
String? ftsMatchQuery(String raw) {
  final keywords = codexKeywords(raw);
  if (keywords.isEmpty) return null;
  return keywords.map((word) => '"$word"*').join(' OR ');
}
