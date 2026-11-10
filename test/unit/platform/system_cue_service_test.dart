import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/core/platform/cue_service.dart';
import 'package:q_helper/domain/models/app_settings.dart';

import '../../fixtures/fake_platform.dart';

void main() {
  late RecordingFeedbackPlatform platform;

  SystemCueService service(AppSettings settings) =>
      SystemCueService(settings: () => settings, platform: platform);

  setUp(() => platform = RecordingFeedbackPlatform());

  test('plays sound and haptics when both are on', () async {
    await service(const AppSettings()).play(CueKind.workStart);
    expect(platform.calls, ['alertSound', 'heavyHaptic']);
  });

  test('rest start is gentler than work start', () async {
    await service(const AppSettings()).play(CueKind.restStart);
    expect(platform.calls, ['clickSound', 'lightHaptic']);
  });

  test('finish cues are strong', () async {
    await service(const AppSettings()).play(CueKind.intervalFinished);
    expect(platform.calls, ['alertSound', 'heavyHaptic']);
    platform.calls.clear();
    await service(const AppSettings()).play(CueKind.workoutEnd);
    expect(platform.calls, ['alertSound', 'heavyHaptic']);
  });

  test('sound can be turned off', () async {
    await service(const AppSettings(soundEnabled: false))
        .play(CueKind.workStart);
    expect(platform.calls, ['heavyHaptic']);
  });

  test('haptics can be turned off', () async {
    await service(const AppSettings(hapticsEnabled: false))
        .play(CueKind.workStart);
    expect(platform.calls, ['alertSound']);
  });

  test('does nothing with both off', () async {
    await service(const AppSettings(soundEnabled: false, hapticsEnabled: false))
        .play(CueKind.workoutEnd);
    expect(platform.calls, isEmpty);
  });

  test('reads settings at the moment of the cue', () async {
    var settings = const AppSettings();
    final s = SystemCueService(settings: () => settings, platform: platform);
    settings = const AppSettings(soundEnabled: false);
    await s.play(CueKind.workStart);
    expect(platform.calls, ['heavyHaptic']);
  });
}
