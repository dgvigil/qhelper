import 'package:q_helper/domain/assistant/local_assistant.dart';
import 'package:q_helper/domain/assistant/model_download.dart';

class FakeLocalAssistant implements LocalAssistant {
  FakeLocalAssistant(this.reply);

  final String reply;
  String? lastPrompt;
  int releases = 0;

  @override
  Future<String> complete(
    String userMessage, {
    void Function(String token)? onToken,
  }) async {
    lastPrompt = userMessage;
    onToken?.call(reply);
    return reply;
  }

  @override
  Future<void> release() async {
    releases++;
  }
}

class FakeModelStore implements ModelStore {
  FakeModelStore({this.installed = false, this.unmetered = true});

  bool installed;
  bool unmetered;
  var cancelled = false;

  @override
  Future<bool> isInstalled() async => installed;

  @override
  Future<void> download({required void Function(int percent) onProgress}) {
    return startAssistantDownload(
      isUnmetered: () async => unmetered,
      download: () async {
        onProgress(40);
        onProgress(100);
        installed = true;
      },
    );
  }

  @override
  void cancel() {
    cancelled = true;
  }

  @override
  Future<void> delete() async {
    installed = false;
  }
}
