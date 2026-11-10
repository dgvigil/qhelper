import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/app/app.dart';
import 'package:q_helper/app/providers.dart';
import 'package:q_helper/app/services/share_service.dart';

import 'in_memory_plan_repository.dart';

class RecordingShareService implements ShareService {
  final List<({String text, String? subject})> shared = [];

  @override
  Future<void> shareText(String text, {String? subject}) async {
    shared.add((text: text, subject: subject));
  }
}

class AppHarness {
  AppHarness({InMemoryPlanRepository? repo, RecordingShareService? share})
    : repo = repo ?? InMemoryPlanRepository(),
      share = share ?? RecordingShareService();

  final InMemoryPlanRepository repo;
  final RecordingShareService share;
  int _ids = 0;

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          planRepositoryProvider.overrideWithValue(repo),
          shareServiceProvider.overrideWithValue(share),
          idGeneratorProvider.overrideWithValue(() => 'new-${_ids++}'),
          nowProvider.overrideWithValue(() => DateTime.utc(2026, 11, 10, 12)),
        ],
        child: const QHelperApp(),
      ),
    );
    await tester.pumpAndSettle();
  }
}

/// Larger than default so list items and sheets are on screen.
void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 1800);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
