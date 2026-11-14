import 'dart:convert';

class Iso15693Parser {
  /// Parse a hex response (bytes) from ISO15693 Get System Info (or Read Single Block) into readable map
  static Map<String, dynamic> parseSystemInfo(String hex) {
    final bytes = _hexToBytes(hex.replaceAll(RegExp(r"[^0-9A-Fa-f]"), ''));
    final Map<String, dynamic> out = {};
    if (bytes.isEmpty) return out;

    // Typical Get System Info Response (UID + DSFID + AFI + CRC etc depends on device)
    // We'll attempt to decode common fields: DSFID (1 byte), UID (8 bytes at end), maybe block size & number
    try {
      // heuristic: UID is often 8 bytes ending the response
      if (bytes.length >= 8) {
        final uid = bytes
            .sublist(bytes.length - 8)
            .reversed
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join('')
            .toUpperCase();
        out['uid'] = uid;
      }
      // DSFID often at first or second position in some tag responses
      if (bytes.length >= 9) {
        out['dsfid'] = bytes[0].toRadixString(16).padLeft(2, '0');
      }
      // Try to find block size and number via common info positions (not standardized across all readers)
      if (bytes.length >= 11) {
        out['rawBytes'] = bytes
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join(' ');
      }
    } catch (_) {
      out['raw'] = base64Encode(bytes);
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
