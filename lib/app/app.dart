import 'package:flutter/material.dart';
import 'package:q_helper/app/router/router.dart';
import 'package:q_helper/app/theme/app_theme.dart';

class QHelperApp extends StatefulWidget {
  const QHelperApp({super.key});

  @override
  State<QHelperApp> createState() => _QHelperAppState();
}

class _QHelperAppState extends State<QHelperApp> {
  final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Q Helper',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: _router,
    );
  }
}
