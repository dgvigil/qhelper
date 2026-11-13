import 'package:q_helper/domain/codex/codex_entry.dart';

/// Read-only search over the bundled Exicon and Lexicon.
abstract class CodexIndex {
  List<CodexEntry> search(String query, {CodexKind? kind, int limit = 20});
}

/// Used when the bundled database could not be opened.
class UnavailableCodexIndex implements CodexIndex {
  UnavailableCodexIndex(this.message);

  final String message;

  @override
  List<CodexEntry> search(String query, {CodexKind? kind, int limit = 20}) {
    throw CodexUnavailable(message);
  }
}

class CodexUnavailable implements Exception {
  CodexUnavailable(this.message);

  final String message;

  @override
  String toString() => message;
}
