import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/app/app.dart';

import '../fixtures/app_harness.dart';

void main() {
  testWidgets('app shell shows Q Helper home title', (tester) async {
    await AppHarness().pump(tester);
    expect(find.text('Q Helper'), findsWidgets);
  });

  testWidgets('app uses dark-first theme', (tester) async {
    await AppHarness().pump(tester);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.routerConfig, isNotNull);
    expect(find.byType(QHelperApp), findsOneWidget);
  });
}
