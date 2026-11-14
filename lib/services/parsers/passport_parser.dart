import 'dart:convert';

class PassportParser {
  /// Try to extract MRZ text from a DG1 hex payload
  static Map<String, dynamic> parseDG1Hex(String hex) {
    final clean = hex.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
    final out = <String, dynamic>{};
    try {
      final bytes = <int>[];
      for (var i = 0; i < clean.length; i += 2) {
        bytes.add(int.parse(clean.substring(i, i + 2), radix: 16));
      }
      final s = const Utf8Decoder().convert(bytes);

      // MRZ lines are usually 44 or 30 chars long
      // Look for patterns like P<TUR... or I<TUR...
      final lines = s
          .split(RegExp(r'[\n\r]'))
          .where((l) => l.length >= 30)
          .toList();

      if (lines.isEmpty) {
        // Try to find MRZ in the raw string if split failed
        final mrzMatch = RegExp(r'([A-Z0-9<]{30,44})').allMatches(s);
        if (mrzMatch.isNotEmpty) {
          lines.addAll(mrzMatch.map((m) => m.group(0)!));
        }
      }

      if (lines.isNotEmpty) {
        out['mrz'] = lines;
        out['mrz_lines'] = lines;
        final firstLine = lines[0];
        if (firstLine.startsWith('P<')) {
          out['document_type'] = 'Passport';
          out['issuing_state'] = firstLine.substring(2, 5).replaceAll('<', '');
        } else if (firstLine.startsWith('I<')) {
          out['document_type'] = 'Identity Card';
          out['issuing_state'] = firstLine.substring(2, 5).replaceAll('<', '');
        }

        // Try to extract name (usually after state in first line)
        if (firstLine.length > 5) {
          out['name_raw'] = firstLine
              .substring(5)
              .replaceAll('<<', ' ')
              .replaceAll('<', ' ')
              .trim();
        }
      }

      out['textPreview'] = s.replaceAll(RegExp(r'[^\x20-\x7E]'), '.');
    } catch (e) {
      out['error'] = e.toString();
      out['raw'] = clean;
    }
    return out;
  }
}
