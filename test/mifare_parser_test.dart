import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_expert/services/parsers/mifare_parser.dart';

void main() {
  test('Mifare parse block hex', () {
    final hex = '0403020102030405060708090A0B0C0D'; // 16 bytes
    final parsed = MifareParser.parseBlockHex(hex);
    expect(parsed.containsKey('uid'), true);
    expect(parsed['length'], 16);
  });
}
