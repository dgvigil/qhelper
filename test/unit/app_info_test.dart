import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/app/app_info.dart';

void main() {
  test('the version shown in About matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)',
      multiLine: true,
    ).firstMatch(pubspec);
    expect(match, isNotNull);
    expect(appVersion, match!.group(1));
  });

  test(
    'the independence notice says Q Helper is not endorsed by F3 Nation',
    () {
      expect(
        independenceNotice,
        contains('not affiliated with or endorsed by F3 Nation'),
      );
    },
  );

  test('the privacy and support links point at the public repository', () {
    expect(privacyPolicyUrl, startsWith('https://github.com/dgvigil/qhelper/'));
    expect(supportUrl, startsWith('https://github.com/dgvigil/qhelper/'));
  });
}
