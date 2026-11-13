import 'package:q_helper/domain/codex/codex_entry.dart';

/// How many Codex entries are pasted into one assistant question.
const ragEntryLimit = 4;

/// How much of each entry body is pasted in.
const ragBodyLimit = 700;

/// Rules for the model. Repeated in the user message because some on-device
/// runtimes ignore a separate system instruction.
const ragSystemInstruction = '''
You help an F3 workout leader, called a Q. Answer only from the reference entries included with the question. If those entries do not contain the answer, say you do not know. Do not invent exercises, counts, or definitions. Write a short answer that can be read on a phone.
''';

/// The user turn: the rules, the retrieved entries, then the question.
String ragUserMessage(String question, List<CodexEntry> entries) {
  final buffer = StringBuffer()
    ..writeln(ragSystemInstruction.trim())
    ..writeln()
    ..writeln('Reference entries:');
  if (entries.isEmpty) {
    buffer.writeln('(none)');
  } else {
    for (final entry in entries.take(ragEntryLimit)) {
      buffer
        ..writeln('[${entry.kind.label}] ${entry.title}')
        ..writeln(_clip(entry.body));
      if (entry.tags.isNotEmpty) {
        buffer.writeln('Tags: ${entry.tagList.join(', ')}');
      }
      buffer.writeln();
    }
  }
  buffer
    ..writeln('Question:')
    ..write(question.trim());
  return buffer.toString();
}

String _clip(String text) {
  final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (flat.length <= ragBodyLimit) return flat;
  final cut = flat.lastIndexOf(' ', ragBodyLimit);
  final end = cut > ragBodyLimit - 80 ? cut : ragBodyLimit;
  return '${flat.substring(0, end).trim()}…';
}
