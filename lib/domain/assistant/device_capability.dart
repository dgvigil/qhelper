/// About 8 GB of marketed RAM.
///
/// Phones sold as 8 GB often report a little less than 8 GiB to the app.
/// Phones sold as 6 GB, such as an iPhone 15 that is not a Pro, report
/// about 6 GiB or less. 6.5 GiB sits between those two.
const minimumAssistantRamBytes = 6979321856;

class DeviceProfile {
  const DeviceProfile({required this.totalRamBytes});

  /// Null when the platform did not report a total.
  final int? totalRamBytes;

  bool get canRunAssistant =>
      totalRamBytes != null && totalRamBytes! >= minimumAssistantRamBytes;
}

/// Reads `MemTotal` from `/proc/meminfo`. The value is in KiB in the file
/// and in bytes here.
int? parseMemTotalBytes(String meminfo) {
  final match = RegExp(
    r'^MemTotal:\s+(\d+)\s+kB',
    multiLine: true,
  ).firstMatch(meminfo);
  if (match == null) return null;
  final kilobytes = int.tryParse(match.group(1)!);
  if (kilobytes == null) return null;
  return kilobytes * 1024;
}
