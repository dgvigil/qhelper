import 'package:q_helper/core/platform/cue_service.dart';
import 'package:q_helper/core/platform/end_notification_service.dart';
import 'package:q_helper/core/platform/wakelock_service.dart';

class RecordingFeedbackPlatform implements FeedbackPlatform {
  final List<String> calls = [];

  @override
  Future<void> alertSound() async => calls.add('alertSound');

  @override
  Future<void> clickSound() async => calls.add('clickSound');

  @override
  Future<void> heavyHaptic() async => calls.add('heavyHaptic');

  @override
  Future<void> lightHaptic() async => calls.add('lightHaptic');
}

class RecordingCueService implements CueService {
  final List<CueKind> played = [];

  @override
  Future<void> play(CueKind kind) async => played.add(kind);
}

class FakeWakelock implements WakelockService {
  bool enabled = false;
  final List<bool> history = [];

  @override
  Future<void> enable() async {
    enabled = true;
    history.add(true);
  }

  @override
  Future<void> disable() async {
    enabled = false;
    history.add(false);
  }
}

class FakeEndNotificationService implements EndNotificationService {
  FakeEndNotificationService({this.grant = true, this.alreadyAllowed = false});

  bool grant;
  bool alreadyAllowed;
  bool throwOnUse = false;
  int requests = 0;
  final List<DateTime> scheduled = [];
  int cancels = 0;

  void _maybeThrow() {
    if (throwOnUse) throw StateError('platform failure');
  }

  @override
  Future<bool> hasPermission() async {
    _maybeThrow();
    return alreadyAllowed;
  }

  @override
  Future<bool> requestPermission() async {
    _maybeThrow();
    requests++;
    if (grant) alreadyAllowed = true;
    return grant;
  }

  @override
  Future<void> scheduleAt(
    DateTime when, {
    required String title,
    required String body,
  }) async {
    _maybeThrow();
    scheduled.add(when);
  }

  @override
  Future<void> cancel() async {
    _maybeThrow();
    cancels++;
  }
}
