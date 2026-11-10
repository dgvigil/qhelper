import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_helper/app/app.dart';
import 'package:q_helper/app/providers.dart';
import 'package:q_helper/data/database/app_database.dart';
import 'package:q_helper/data/database/open_database.dart';
import 'package:q_helper/data/repositories/drift_plan_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase(openAppDatabase());
  runApp(
    ProviderScope(
      overrides: [
        planRepositoryProvider.overrideWithValue(DriftPlanRepository(database)),
      ],
      child: const QHelperApp(),
    ),
  );
}
