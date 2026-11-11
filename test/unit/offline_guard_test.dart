import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Q Helper is offline-first with no network services. This guard fails if app
/// code starts importing networking libraries, so adding one is a deliberate,
/// reviewed decision (see AGENTS.md and the privacy policy).
void main() {
  test('app code does not use networking libraries', () {
    final banned = RegExp(
      r"import\s+'(package:(http|dio|web_socket_channel|socket_io_client)/|dart:(io)')[^;]*;",
    );
    final networkCalls = RegExp(
      r'HttpClient\(|Socket\.connect|WebSocket\.connect',
    );
    final offenders = <String>[];
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final text = file.readAsStringSync();
      for (final m in banned.allMatches(text)) {
        final line = m.group(0)!;
        // dart:io is allowed only for local files (database location).
        if (line.contains('dart:io') && !networkCalls.hasMatch(text)) continue;
        offenders.add('${file.path}: $line');
      }
      if (networkCalls.hasMatch(text)) {
        offenders.add('${file.path}: network call');
      }
    }
    expect(offenders, isEmpty);
  });

  test('pubspec has no direct networking dependency', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final deps = pubspec.split('dev_dependencies:').first;
    for (final name in [
      'http:',
      'dio:',
      'web_socket_channel:',
      'firebase_',
      'sentry',
      'google_mobile_ads',
    ]) {
      expect(
        deps.contains('  $name') || deps.contains(name),
        isFalse,
        reason: name,
      );
    }
  });
}
