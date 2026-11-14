import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_expert/services/parsers/iso15693_parser.dart';

void main() {
  test('ISO15693 parse example system info', () {
    // Example fake response hex (this is synthetic for unit test)
    final hex = 'E00411223344556677';
    final parsed = Iso15693Parser.parseSystemInfo(hex);
    expect(parsed.containsKey('uid'), true);
    expect(parsed['uid'].toString().length, greaterThan(0));
  });
}
