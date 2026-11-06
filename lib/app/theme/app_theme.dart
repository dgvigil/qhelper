import 'package:flutter/material.dart';

/// High-contrast, dark-first theme for outdoor / low-light use.
abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFB300),
      brightness: Brightness.dark,
    ),
    visualDensity: VisualDensity.standard,
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB300)),
  );
}
