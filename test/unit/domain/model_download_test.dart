import 'package:flutter_test/flutter_test.dart';
import 'package:q_helper/domain/assistant/model_download.dart';

void main() {
  test(
    'refuses a download that is not on Wi-Fi and does not start it',
    () async {
      var started = false;
      expect(
        () => startAssistantDownload(
          isUnmetered: () async => false,
          download: () async => started = true,
        ),
        throwsA(
          isA<AssistantDownloadException>().having(
            (error) => error.failure,
            'failure',
            AssistantDownloadFailure.needsWifi,
          ),
        ),
      );
      expect(started, isFalse);
    },
  );

  test('starts a download on Wi-Fi', () async {
    var started = false;
    await startAssistantDownload(
      isUnmetered: () async => true,
      download: () async => started = true,
    );
    expect(started, isTrue);
  });
}
