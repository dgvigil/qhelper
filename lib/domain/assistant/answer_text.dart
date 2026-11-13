/// Removes a reasoning block so the Q sees the answer.
///
/// TwIL models may emit a `<think>` or `<thought>` block before the answer.
/// The on-device runtime is asked not to, and this is a second line of defense.
String stripReasoning(String raw) {
  var text = raw.replaceAll(
    RegExp('<think>[\\s\\S]*?</think>', caseSensitive: false),
    '',
  );
  text = text.replaceAll(
    RegExp('<thought>[\\s\\S]*?</thought>', caseSensitive: false),
    '',
  );
  text = text.replaceAll(
    RegExp('^[\\s\\S]*</think>', caseSensitive: false),
    '',
  );
  text = text.replaceAll(RegExp('</?think>', caseSensitive: false), '');
  text = text.replaceAll(RegExp('</?thought>', caseSensitive: false), '');
  return text.trim();
}
