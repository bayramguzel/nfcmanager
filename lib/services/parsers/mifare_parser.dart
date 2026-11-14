import 'dart:convert';

class MifareParser {
  /// Try to parse common MIFARE block data
  static Map<String, dynamic> parseBlockHex(String hex) {
    final bytes = _hexToBytes(hex.replaceAll(RegExp(r"[^0-9A-Fa-f]"), ''));
    final out = <String, dynamic>{};
    out['length'] = bytes.length;
    if (bytes.isEmpty) return out;

    // Manufacturer block for typical MIFARE Classic cards (sector 0 block 0)
    if (bytes.length >= 16) {
      // First 4 bytes are often UID (reverse order on some readers)
      final uid = bytes
          .sublist(0, 4)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join('')
          .toUpperCase();
      out['uid'] = uid;
      try {
        out['ascii'] = const Utf8Decoder().convert(
          bytes.where((b) => b >= 32 && b < 127).toList(),
        );
      } catch (_) {}
      out['hex'] = bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join('')
          .toUpperCase();
    }
    return out;
  }

  static List<int> _hexToBytes(String hex) {
    final out = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      final byte = hex.substring(i, i + 2);
      out.add(int.parse(byte, radix: 16));
    }
    return out;
  }
}
