import 'dart:io';

import 'package:flutter/services.dart';
import 'package:q_helper/domain/assistant/device_capability.dart';

const deviceMemoryChannelName = 'com.gv5technologies.qhelper/device';

/// Total RAM, or null when this platform does not report it.
abstract class DeviceMemory {
  Future<int?> readBytes();
}

class PlatformDeviceMemory implements DeviceMemory {
  PlatformDeviceMemory({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(deviceMemoryChannelName);

  final MethodChannel _channel;

  @override
  Future<int?> readBytes() async {
    if (Platform.isIOS) {
      try {
        final value = await _channel.invokeMethod<Object>('physicalMemory');
        if (value is int) return value;
        if (value is String) return int.tryParse(value);
      } catch (_) {
        return null;
      }
      return null;
    }
    if (Platform.isAndroid || Platform.isLinux) {
      try {
        return parseMemTotalBytes(File('/proc/meminfo').readAsStringSync());
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
