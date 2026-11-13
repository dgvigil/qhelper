import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_litertlm/flutter_edge_ai_litertlm.dart';
import 'package:q_helper/data/assistant/unmetered_network.dart';
import 'package:q_helper/domain/assistant/assistant_model.dart';
import 'package:q_helper/domain/assistant/local_assistant.dart';
import 'package:q_helper/domain/assistant/model_download.dart';
import 'package:q_helper/domain/codex/rag_prompt.dart';

Future<void>? _edgeAiInit;

/// Loads the LiteRT-LM engine once. A failed attempt can be retried.
Future<void> ensureEdgeAi() {
  return _edgeAiInit ??= _initializeEdgeAi();
}

Future<void> _initializeEdgeAi() async {
  try {
    await FlutterEdgeAi.initialize(inferenceEngines: const [LiteRtLmEngine()]);
  } catch (error) {
    _edgeAiInit = null;
    rethrow;
  }
}

/// On-device chat through flutter_edge_ai's LiteRT-LM engine.
///
/// TwIL-LM3-Pro is a `.litertlm` bundle. The same engine runs on Android
/// (GPU via OpenCL, falling back to CPU) and on iOS (Metal on a device,
/// CPU on the simulator). Thinking is off so a short question is more
/// likely to finish with an answer.
class LiteRtLmAssistant implements LocalAssistant {
  @override
  Future<String> complete(
    String userMessage, {
    void Function(String token)? onToken,
  }) async {
    await ensureEdgeAi();
    if (!await FlutterEdgeAi.isModelInstalled(AssistantModel.fileName)) {
      throw StateError('The assistant model is not downloaded.');
    }
    final model = await FlutterEdgeAi.getActiveModel(
      maxTokens: 4096,
      preferredBackend: PreferredBackend.gpu,
    );
    final chat = await model.openChat(
      enableThinking: false,
      maxOutputTokens: 1024,
      temperature: 0,
      topK: 1,
      systemInstruction: ragSystemInstruction,
      modelType: ModelType.general,
    );
    try {
      await chat.addQueryChunk(Message.text(text: userMessage, isUser: true));
      final buffer = StringBuffer();
      await for (final response in chat.generateChatResponseAsync()) {
        if (response is TextResponse) {
          buffer.write(response.token);
          onToken?.call(response.token);
        }
      }
      return buffer.toString();
    } finally {
      await chat.close();
    }
  }

  @override
  Future<void> release() async {
    if (_edgeAiInit == null) return;
    try {
      if (FlutterEdgeAi.activeModelSpec != null) {
        final model = await FlutterEdgeAi.getActiveModel();
        await model.close();
      }
    } catch (_) {
      // The next question loads the model again.
    }
  }
}

/// Downloads TwIL-LM3-Pro on Wi-Fi and deletes it on request.
class EdgeAiModelStore implements ModelStore {
  EdgeAiModelStore({Future<bool> Function()? isUnmetered})
    : _isUnmetered = isUnmetered ?? isUnmeteredNetwork;

  final Future<bool> Function() _isUnmetered;
  CancelToken? _cancel;

  @override
  Future<bool> isInstalled() async {
    await ensureEdgeAi();
    return FlutterEdgeAi.isModelInstalled(AssistantModel.fileName);
  }

  @override
  Future<void> download({required void Function(int percent) onProgress}) {
    return startAssistantDownload(
      isUnmetered: _isUnmetered,
      download: () async {
        await ensureEdgeAi();
        final token = CancelToken();
        _cancel = token;
        try {
          await FlutterEdgeAi.installModel(
                modelType: ModelType.general,
                fileType: ModelFileType.litertlm,
              )
              .fromNetwork(
                AssistantModel.url,
                filename: AssistantModel.fileName,
                expectedSize: AssistantModel.byteSize,
              )
              .withProgress(onProgress)
              .withCancelToken(token)
              .install();
        } on DownloadCancelledException {
          throw const AssistantDownloadException(
            AssistantDownloadFailure.cancelled,
            'Download cancelled.',
          );
        } finally {
          if (identical(_cancel, token)) _cancel = null;
        }
      },
    );
  }

  @override
  void cancel() {
    _cancel?.cancel('Cancelled by the Q.');
  }

  @override
  Future<void> delete() async {
    cancel();
    await ensureEdgeAi();
    if (await FlutterEdgeAi.isModelInstalled(AssistantModel.fileName)) {
      await FlutterEdgeAi.uninstallModel(AssistantModel.fileName);
    }
  }
}
