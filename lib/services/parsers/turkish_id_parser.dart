import 'dart:convert';

class TurkishIdParser {
  /// Very small EF.PERSO parser skeleton: try to extract readable UTF-8 parts
  static Map<String, dynamic> parsePersoHex(String hex) {
    final clean = hex.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
    final out = <String, dynamic>{};
    try {
      final bytes = <int>[];
      for (var i = 0; i < clean.length; i += 2) {
        bytes.add(int.parse(clean.substring(i, i + 2), radix: 16));
      }
      // Attempt to find UTF-8 strings inside
      final text = const Utf8Decoder().convert(bytes);
      out['preview'] = text.substring(0, text.length > 200 ? 200 : text.length);
      out['raw'] = clean;
    } catch (e) {
      out['error'] = e.toString();
      out['raw'] = clean;
    }
    return out;
  }
}
