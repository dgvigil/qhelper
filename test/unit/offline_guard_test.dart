import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Workouts and lookup stay offline. The only network feature is the optional
/// on-device assistant download, which goes through `flutter_edge_ai` after a
/// Wi-Fi check (`lib/data/assistant/`). This guard still fails if app code
/// starts its own HTTP client or adds another networking package.
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
