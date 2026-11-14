import 'dart:convert';

class EmvParser {
  /// Parse a hex string (like "6F1A840E...") into a map of known EMV tags.
  /// Returns a map with human readable keys when possible.
  static Map<String, String> parseFromHex(String hex) {
    final bytes = _hexToBytes(hex.replaceAll(RegExp(r"[^0-9A-Fa-f]"), ''));
    return _parseTlv(
      bytes,
    ).map((k, v) => MapEntry(_prettyTag(k), _formatValue(k, v)));
  }

  static List<int> _hexToBytes(String hex) {
    final out = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      final byte = hex.substring(i, i + 2);
      out.add(int.parse(byte, radix: 16));
    }
    return out;
  }

  /// Very small TLV parser sufficient for EMV: returns map of tag (hex) -> value bytes
  static Map<String, List<int>> _parseTlv(List<int> data) {
    final Map<String, List<int>> out = {};
    var i = 0;
    while (i < data.length) {
      // read tag (could be multi-byte)
      final tagStart = i;
      i++;
      if ((data[tagStart] & 0x1F) == 0x1F) {
        // multi-byte tag
        while (i < data.length && (data[i] & 0x80) == 0x80) {
          i++;
        }
        i++; // include last tag byte
      }
      final tagBytes = data.sublist(tagStart, i);
      final tagHex = tagBytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join('')
          .toUpperCase();

      // length
      var length = data[i++];
      if ((length & 0x80) == 0x80) {
        final numBytes = length & 0x7F;
        length = 0;
        for (var k = 0; k < numBytes; k++) {
          length = (length << 8) | data[i++];
        }
      }

      // value
      final value = data.sublist(i, i + length);
      i += length;

      out[tagHex] = value;
    }
    return out;
  }

  static String _prettyTag(String tag) {
    const names = {
      '4F': 'ApplicationIdentifier',
      '50': 'ApplicationLabel',
      '57': 'Track2Equivalent',
      '5A': 'PAN',
      '5F20': 'CardholderName',
      '5F24': 'ExpirationDate',
      '5F25': 'EffectiveDate',
      '5F28': 'IssuerCountryCode',
      '5F2D': 'LanguagePreference',
      '5F30': 'ServiceCode',
      '5F34': 'PANSequenceNumber',
      '6F': 'FCI_Template',
      '84': 'DFName',
      '8E': 'CVM_List',
      '9F02': 'AmountAuthorized',
      '9F03': 'AmountOther',
      '9F06': 'AID',
      '9F07': 'ApplicationUsageControl',
      '9F08': 'ApplicationVersionNumber',
      '9F09': 'TerminalVersionNumber',
      '9F10': 'IssuerApplicationData',
      '9F11': 'IssuerCodeTableIndex',
      '9F12': 'ApplicationPreferredName',
      '9F1A': 'TerminalCountryCode',
      '9F1E': 'InterfaceDeviceSerialNumber',
      '9F26': 'ApplicationCryptogram',
      '9F27': 'CryptogramInformationData',
      '9F36': 'ATC',
      '9F37': 'UnpredictableNumber',
      '9F4D': 'LogEntry',
      'BF0C': 'FCI_IssuerDiscretionaryData',
    };
    return names[tag] ?? tag;
  }

  static String _formatValue(String tag, List<int> v) {
    try {
      if (tag == '5A' || tag == '57') {
        // numeric / track2 style
        var hex = v
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join('')
            .toUpperCase();
        if (tag == '5A') {
          // Mask PAN for security if it's long
          if (hex.length > 10) {
            return '${hex.substring(0, 6)}******${hex.substring(hex.length - 4)}';
          }
        }
        return hex;
      }
      if (tag == '5F24' || tag == '5F25') {
        // YYMMDD or YYMM
        final txt = v.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
        if (txt.length >= 4) {
          return '${txt.substring(2, 4)}/${txt.substring(0, 2)} (MM/YY)';
        }
        return txt;
      }
      if (tag == '5F2D') {
        return utf8.decode(v);
      }
      if (tag == '50' || tag == '9F12' || tag == '5F20') {
        return utf8.decode(v).trim();
      }
      // try utf8 for others if it looks like text
      if (v.every((b) => b >= 32 && b <= 126)) {
        return utf8.decode(v).trim();
      }
      return v
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join('')
          .toUpperCase();
    } catch (_) {
      return v
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join('')
          .toUpperCase();
    }
  }
}
