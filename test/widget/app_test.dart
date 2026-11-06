import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/app/app.dart';

void main() {
  testWidgets('app shell shows Q Helper home title', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QHelperApp()));
    await tester.pumpAndSettle();

    expect(find.text('Q Helper'), findsWidgets);
  });

  testWidgets('app uses dark-first theme', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QHelperApp()));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
