import 'package:wakelock_plus/wakelock_plus.dart';

/// Keeps the screen on during a workout.
abstract interface class WakelockService {
  Future<void> enable();
  Future<void> disable();
}

class WakelockPlusService implements WakelockService {
  const WakelockPlusService();

  @override
  Future<void> enable() async {
    try {
      await WakelockPlus.enable();
    } on Object {
      // Not critical.
    }
  }

  @override
  Future<void> disable() async {
    try {
      await WakelockPlus.disable();
    } on Object {
      // Not critical.
    }
  }
}
