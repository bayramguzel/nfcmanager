import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_expert/services/parsers/passport_parser.dart';
import 'package:nfc_expert/services/parsers/turkish_id_parser.dart';

void main() {
  test('Passport MRZ parse', () {
    final mrz =
        'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<L898902C36UTO7408122F1204159ZE184226B<<<<<10';
    final hex = mrz.runes
        .map((r) => r.toRadixString(16).padLeft(2, '0'))
        .join();
    final parsed = PassportParser.parseDG1Hex(hex);
    expect(parsed.containsKey('mrz'), true);
  });

  test('Turkish ID parser preview', () {
    final sample = '54657374204944'; // 'Test ID' in hex
    final parsed = TurkishIdParser.parsePersoHex(sample);
    expect(parsed.containsKey('preview'), true);
  });
}
