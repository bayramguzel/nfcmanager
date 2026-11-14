import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_expert/services/parsers/passport_parser.dart';

void main() {
  test('Passport parse MRZ-like data', () {
    final mrz =
        'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<L898902C36UTO7408122F1204159ZE184226B<<<<<10';
    final hex = mrz.runes
        .map((r) => r.toRadixString(16).padLeft(2, '0'))
        .join();
    final parsed = PassportParser.parseDG1Hex(hex);
    expect(parsed.containsKey('mrz'), true);
    expect((parsed['mrz'] as List).isNotEmpty, true);
  });
}
