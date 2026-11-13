/// Which F3 list an entry came from.
enum CodexKind {
  /// An exercise, from the Exicon.
  exicon,

  /// A term, from the Lexicon.
  lexicon;

  String get label => switch (this) {
    CodexKind.exicon => 'Exercise',
    CodexKind.lexicon => 'Term',
  };

  static CodexKind parse(String value) => switch (value) {
    'exicon' => CodexKind.exicon,
    'lexicon' => CodexKind.lexicon,
    _ => throw FormatException('Unknown codex kind: $value'),
  };
}

/// One exercise or term from the bundled Codex index.
class CodexEntry {
  const CodexEntry({
    required this.kind,
    required this.title,
    required this.tags,
    required this.body,
  });

  final CodexKind kind;
  final String title;

  /// Tag names joined with `|`, or empty when the source row had none.
  final String tags;
  final String body;

  List<String> get tagList => tags
      .split('|')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList();

  /// A short line for a result list.
  String get preview {
    final flat = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (flat.length <= 160) return flat;
    final cut = flat.lastIndexOf(' ', 160);
    final end = cut > 80 ? cut : 160;
    return '${flat.substring(0, end).trim()}…';
  }
}
