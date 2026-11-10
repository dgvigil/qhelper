import 'package:flutter/services.dart';
import 'package:q_helper/domain/models/app_settings.dart';

/// Moments the UI cues with sound and haptics.
enum CueKind { workStart, restStart, intervalFinished, workoutEnd }

abstract interface class CueService {
  Future<void> play(CueKind kind);
}

/// Low-level feedback, split out so cue choices can be tested.
abstract interface class FeedbackPlatform {
  Future<void> alertSound();
  Future<void> clickSound();
  Future<void> heavyHaptic();
  Future<void> lightHaptic();
}

class FlutterFeedbackPlatform implements FeedbackPlatform {
  const FlutterFeedbackPlatform();

  @override
  Future<void> alertSound() => SystemSound.play(SystemSoundType.alert);

  @override
  Future<void> clickSound() => SystemSound.play(SystemSoundType.click);

  @override
  Future<void> heavyHaptic() => HapticFeedback.heavyImpact();

  @override
  Future<void> lightHaptic() => HapticFeedback.lightImpact();
}

/// Plays system sounds and haptics according to the current settings.
///
/// These are best effort: the OS may silence them (silent switch, Focus, low
/// power), and they are never replayed if missed.
class SystemCueService implements CueService {
  SystemCueService({
    required this._settings,
    this._platform = const FlutterFeedbackPlatform(),
  });

  final AppSettings Function() _settings;
  final FeedbackPlatform _platform;

  @override
  Future<void> play(CueKind kind) async {
    final settings = _settings();
    final gentle = kind == CueKind.restStart;
    try {
      if (settings.soundEnabled) {
        await (gentle ? _platform.clickSound() : _platform.alertSound());
      }
      if (settings.hapticsEnabled) {
        await (gentle ? _platform.lightHaptic() : _platform.heavyHaptic());
      }
    } on Object {
      // Feedback is a courtesy; never let it break a workout.
    }
  }
}
