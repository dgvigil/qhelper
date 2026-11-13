/// TwIL-LM3-Pro INT4, pinned to a Hugging Face commit so a later upload
/// cannot change the file the app downloads.
///
/// The file is about 2.19 GB (2,190,708,656 bytes). It is not part of the
/// app binary.
abstract final class AssistantModel {
  static const fileName = 'TwIL-LM3-Pro_int4.litertlm';
  static const repo = 'webAI-Official/TwIL-LM3-Pro-LiteRT-LM';
  static const revision = 'bb30df2e79d4c05daa63697fd7fa53fe39c0d4fc';
  static const byteSize = 2190708656;
  static const approximateSize = '2.2 GB';

  static const url = 'https://huggingface.co/$repo/resolve/$revision/$fileName';
}
