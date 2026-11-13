/// Why a model download did not finish.
enum AssistantDownloadFailure { needsWifi, cancelled, failed }

class AssistantDownloadException implements Exception {
  const AssistantDownloadException(this.failure, this.message);

  final AssistantDownloadFailure failure;
  final String message;

  @override
  String toString() => message;
}

/// Starts [download] only on an unmetered network.
///
/// Cellular data is refused before [download] is called. The download itself
/// is supplied by the caller so this rule can be tested without a network.
Future<void> startAssistantDownload({
  required Future<bool> Function() isUnmetered,
  required Future<void> Function() download,
}) async {
  if (!await isUnmetered()) {
    throw const AssistantDownloadException(
      AssistantDownloadFailure.needsWifi,
      'Connect to Wi-Fi to download the assistant. It is about 2.2 GB.',
    );
  }
  await download();
}
