import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:q_helper/data/codex/codex_importer.dart';
import 'package:q_helper/data/codex/sqlite_codex_index.dart';

const codexAssetPath = 'assets/codex/codex.sqlite';

/// Copies the bundled database into app storage and opens it read-only.
///
/// The copy is replaced when [codexRevision] changes.
Future<SqliteCodexIndex> openBundledCodexIndex() async {
  final dir = await getApplicationSupportDirectory();
  final file = File(p.join(dir.path, 'codex.sqlite'));
  final data = await rootBundle.load(codexAssetPath);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  if (!file.existsSync() || !_revisionMatches(file)) {
    await file.writeAsBytes(bytes, flush: true);
  }
  return SqliteCodexIndex.openFile(file.path);
}

bool _revisionMatches(File file) {
  SqliteCodexIndex? index;
  try {
    index = SqliteCodexIndex.openFile(file.path);
    return index.revision() == codexRevision;
  } catch (_) {
    return false;
  } finally {
    index?.close();
  }
}
