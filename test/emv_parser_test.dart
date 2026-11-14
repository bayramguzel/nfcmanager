import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_expert/services/parsers/emv_parser.dart';

void main() {
  test('EMV parse sample PAN and expiry', () {
    // Example TLV contains 5A (PAN) and 5F24 (expiry)
    final hex = '5A0847617641051200435F2403221231';
    final parsed = EmvParser.parseFromHex(hex);
    expect(parsed.containsKey('PAN'), true);
    expect(parsed.containsKey('ExpirationDate'), true);
    // PAN hex equals expected (masked)
    expect(parsed['PAN']!.contains('476176'), true);
  });
}
