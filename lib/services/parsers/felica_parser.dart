class FelicaParser {
  /// Parse a synthetic felica response (PMm or System Code) from hex
  static Map<String, dynamic> parseFromHex(String hex) {
    final clean = hex.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
    final out = <String, dynamic>{};
    if (clean.length >= 12) {
      // PMm is 8 bytes (16 hex) in many responses; we'll attempt to find 8-byte sequence
      final bytes = <String>[];
      for (var i = 0; i + 2 <= clean.length; i += 2) {
        bytes.add(clean.substring(i, i + 2));
      }
      if (bytes.length >= 8) {
        final pmm = bytes.sublist(0, 8).join('').toUpperCase();
        out['PMm'] = pmm;
      }
    }
    out['raw'] = clean;
    return out;
  }
}
