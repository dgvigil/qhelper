import 'dart:io';

import 'package:q_helper/data/codex/codex_importer.dart';
import 'package:sqlite3/sqlite3.dart';

/// Rebuilds the bundled Codex database from the CSV exports.
///
/// ```
/// dart run tool/import_codex.dart \
///   tool/codex/source/exicon.csv \
///   tool/codex/source/lexicon.csv \
///   assets/codex/codex.sqlite
/// ```
void main(List<String> args) {
  if (args.length != 3) {
    stderr.writeln(
      'Usage: dart run tool/import_codex.dart <exicon.csv> <lexicon.csv> <out.sqlite>',
    );
    exitCode = 64;
    return;
  }
  final out = File(args[2]);
  out.parent.createSync(recursive: true);
  if (out.existsSync()) out.deleteSync();
  final db = sqlite3.open(out.path);
  try {
    final report = importCodex(
      db: db,
      exiconCsv: File(args[0]).readAsStringSync(),
      lexiconCsv: File(args[1]).readAsStringSync(),
    );
    stdout.writeln(
      'Wrote ${out.path}: ${report.exicon} exercises, '
      '${report.lexicon} terms, ${report.repairedFields} fields repaired. '
      'Revision $codexRevision.',
    );
  } finally {
    db.close();
  }
}
