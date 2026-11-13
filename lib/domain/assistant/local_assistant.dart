/// One on-device completion. Implementations load a model; tests use a fake.
abstract class LocalAssistant {
  Future<String> complete(
    String userMessage, {
    void Function(String token)? onToken,
  });

  /// Drops a loaded model so the rest of the app can use the memory.
  Future<void> release();
}

/// Whether the model file is on the phone, and the download controls.
abstract class ModelStore {
  Future<bool> isInstalled();

  /// Reports percent from 0 to 100.
  Future<void> download({required void Function(int percent) onProgress});

  void cancel();

  Future<void> delete();
}
