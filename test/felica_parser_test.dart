import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_expert/services/parsers/felica_parser.dart';

void main() {
  test('Felica parse PMm from hex', () {
    final hex = '0123456789ABCDEF00112233';
    final parsed = FelicaParser.parseFromHex(hex);
    expect(parsed.containsKey('PMm'), true);
    expect(parsed['raw'].toString().isNotEmpty, true);
  });
}
