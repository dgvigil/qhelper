import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/assistant/device_capability.dart';

void main() {
  test('allows about 8 GB and refuses about 6 GB', () {
    expect(
      const DeviceProfile(totalRamBytes: 8 * 1024 * 1024 * 1024)
          .canRunAssistant,
      isTrue,
    );
    expect(
      const DeviceProfile(totalRamBytes: 7 * 1024 * 1024 * 1024)
          .canRunAssistant,
      isTrue,
    );
    expect(
      const DeviceProfile(totalRamBytes: 6 * 1024 * 1024 * 1024)
          .canRunAssistant,
      isFalse,
    );
    expect(const DeviceProfile(totalRamBytes: null).canRunAssistant, isFalse);
  });

  test('reads MemTotal from proc meminfo as bytes', () {
    const sample = '''
MemFree:        1024 kB
MemTotal:       7864320 kB
MemAvailable:   2048 kB
''';
    expect(parseMemTotalBytes(sample), 7864320 * 1024);
    expect(parseMemTotalBytes('no total here'), isNull);
  });
}
