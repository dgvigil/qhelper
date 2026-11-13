import 'dart:convert';
import 'dart:typed_data';

/// Windows-1252 bytes that are not the same character in Latin-1.
///
/// The Codex export decoded UTF-8 bytes as Windows-1252, so an apostrophe
/// arrived as the three characters "â€™". Encoding those characters back to
/// bytes and decoding as UTF-8 restores the original text.
const _cp1252Byte = <int, int>{
  0x20AC: 0x80, // €
  0x201A: 0x82, // ‚
  0x0192: 0x83, // ƒ
  0x201E: 0x84, // „
  0x2026: 0x85, // …
  0x2020: 0x86, // †
  0x2021: 0x87, // ‡
  0x02C6: 0x88, // ˆ
  0x2030: 0x89, // ‰
  0x0160: 0x8A, // Š
  0x2039: 0x8B, // ‹
  0x0152: 0x8C, // Œ
  0x017D: 0x8E, // Ž
  0x2018: 0x91, // ‘
  0x2019: 0x92, // ’
  0x201C: 0x93, // “
  0x201D: 0x94, // ”
  0x2022: 0x95, // •
  0x2013: 0x96, // –
  0x2014: 0x97, // —
  0x02DC: 0x98, // ˜
  0x2122: 0x99, // ™
  0x0161: 0x9A, // š
  0x203A: 0x9B, // ›
  0x0153: 0x9C, // œ
  0x017E: 0x9E, // ž
  0x0178: 0x9F, // Ÿ
};

/// Restores Codex text that was saved with UTF-8 read as Windows-1252.
///
/// Characters the export already replaced with U+FFFD cannot be recovered.
/// One sitting between two letters becomes an apostrophe; any other
/// replacement character is dropped. `<br>` tags from the export become
/// line breaks.
String repairCodexText(String input) {
  var current = input;
  for (var pass = 0; pass < 2; pass++) {
    final next = _recodeCp1252AsUtf8(current);
    if (next == null || next == current) break;
    current = next;
  }
  current = current.replaceAllMapped(
    RegExp('(?<=[A-Za-z])\uFFFD(?=[A-Za-z])'),
    (_) => "'",
  );
  current = current.replaceAll('\uFFFD', '');
  current = current.replaceAll(
    RegExp(r'<br\s*/?>', caseSensitive: false),
    '\n',
  );
  return current.replaceAll('&amp;', '&').replaceAll('&nbsp;', ' ');
}

String? _recodeCp1252AsUtf8(String input) {
  if (!_needsRepair(input)) return input;
  final decoded = _decode(input);
  if (decoded != null) return decoded;
  // A non-breaking space sometimes survived as "Â" plus a normal space.
  final softened = input.replaceAll('Â ', ' ');
  if (softened == input) return null;
  return _decode(softened);
}

bool _needsRepair(String input) {
  for (final rune in input.runes) {
    if (rune > 127) return true;
  }
  return false;
}

String? _decode(String input) {
  final bytes = BytesBuilder(copy: false);
  for (final rune in input.runes) {
    if (rune < 256) {
      bytes.addByte(rune);
      continue;
    }
    final mapped = _cp1252Byte[rune];
    if (mapped == null) return null;
    bytes.addByte(mapped);
  }
  try {
    return utf8.decode(bytes.toBytes());
  } on FormatException {
    return null;
  }
}
