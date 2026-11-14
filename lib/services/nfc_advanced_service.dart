import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '../core/platform_support.dart';
import 'parsers/emv_parser.dart';
import 'parsers/iso15693_parser.dart';
import 'parsers/mifare_parser.dart';
import 'parsers/felica_parser.dart';
import 'parsers/passport_parser.dart';
import 'parsers/turkish_id_parser.dart';

/// Türk kimlik kartı, banka kartı (EMV), ehliyet (ISO7816) gibi kartları APDU ile okuma için temel servis.
class NfcAdvancedService {
  static const List<Map<String, String>> apduSamples = [
    // Turkish ID Card
    {
      'title': 'Master File Seç',
      'command': '00A40000023F00',
      'desc': 'Kimlik kartı ana dosyasını seçer.',
    },
    {
      'title': 'T.C. Kimlik Uygulaması Seç',
      'command': '00A4040008A000000277010104',
      'desc': 'T.C. Kimlik kartı uygulamasını seçer.',
    },
    {
      'title': 'EF.PERSO Dosyasını Seç',
      'command': '00A4020C020101',
      'desc': 'Kimlik kartı kişisel veri dosyasını seçer.',
    },
    {
      'title': 'Kişisel Verileri Oku',
      'command': '00B00000XX',
      'desc': 'Seçilen dosyadan XX byte veri okur.',
    },
    // Passport (ICAO 9303)
    {
      'title': 'Master File (MF) Seç',
      'command': '00A4000C023F00',
      'desc': 'Pasaport ana dosyasını seçer.',
    },
    {
      'title': 'EF.COM Dosyasını Seç',
      'command': '00A4020C02011E',
      'desc': 'EF.COM dosyasını seçer.',
    },
    {
      'title': 'DG1 (MRZ) Dosyasını Seç',
      'command': '00A4020C020101',
      'desc': 'MRZ bilgisi dosyasını seçer.',
    },
    {
      'title': 'DG1 Verisini Oku',
      'command': '00B00000XX',
      'desc': 'MRZ verisini okur.',
    },
    {
      'title': 'BAC Challenge',
      'command': '0084000008',
      'desc': 'Pasaport BAC için rastgele sayı alır.',
    },
    // EMV Bank Card
    {
      'title': 'EMV Uygulamasını Seç (Visa)',
      'command': '00A4040007A0000000031010',
      'desc': 'Visa EMV uygulamasını seçer.',
    },
    {
      'title': 'Get Processing Options',
      'command': '80A8000002830000',
      'desc': 'EMV işlem başlatma.',
    },
    {
      'title': 'Read Record 1',
      'command': '00B2010C00',
      'desc': 'Kartın temel verilerini okur.',
    },
    {
      'title': 'Get PAN',
      'command': '80CA9F1700',
      'desc': 'Kartın PAN bilgisini okur.',
    },
    // Mifare Classic
    {
      'title': 'Mifare Auth (Key A)',
      'command': 'FF860000050100XX6000',
      'desc': 'Block XX için Key A ile kimlik doğrulama.',
    },
    {
      'title': 'Mifare Block Oku',
      'command': 'FFB000XX10',
      'desc': 'Block XX den 16 byte okur.',
    },
    {
      'title': 'Mifare Block Yaz',
      'command': 'FFD600XX10[16byte]',
      'desc': 'Block XX e 16 byte yazar.',
    },
  ];

  /// Temel kart tipi tespiti ve ATR/UID okuma
  static Future<Map<String, dynamic>> pollCard({
    bool allowAdvanced = false,
  }) async {
    // Optionally, you can run some of these APDU commands automatically for supported cards
    final result = <String, dynamic>{};
    try {
      final tag = await FlutterNfcKit.poll(
        // `timeout` only applies on Android; iOS uses the system reader sheet.
        timeout: const Duration(seconds: 20),
        iosAlertMessage: 'Hold your iPhone near the card',
        iosMultipleTagMessage: 'More than one card detected. Present one card.',
      );
      result['type'] = tag.type.toString();
      result['standard'] = tag.standard;
      result['atqa'] = tag.atqa;
      result['sak'] = tag.sak;
      result['historicalBytes'] = tag.historicalBytes;
      result['uid'] = tag.id;
      result['nfca'] = tag.ndefAvailable;

      // ISO7816/EMV/Passport/ID APDU probing (attempt several safe probes)
      if (tag.type.toString().toLowerCase().contains('iso7816') ||
          tag.standard.toLowerCase().contains('iso7816') == true) {
        try {
          // Select MF
          final selectMF = await FlutterNfcKit.transceive('00A4000C023F00');
          result['Select MF (3F00)'] = selectMF;
        } catch (e) {
          result['select_mf_error'] = e.toString();
        }

        // Probe AIDs and common EMV/ID commands (best-effort, non-destructive)
        final probes = {
          'Select Turkish ID AID': '00A4040008A0000002471001',
          'Passive Read EF.PERSO (example)': '00A4020C020101',
          'Select Passport (AID MF) (example)': '00A4000C023F00',
          'Select Visa AID': '00A4040007A0000000031010',
          'EMV Get Processing Options': '80A8000002830000',
          'EMV Read Record 1 (safely)': '00B2010C00',
          'DG1 (MRZ) Read (example)': '00A4020C020101',
        };

        final List<String> probesLog = [];
        for (final entry in probes.entries) {
          // Gate sensitive probes behind allowAdvanced flag
          if (!allowAdvanced &&
              (entry.key.toLowerCase().contains('perso') ||
                  entry.key.toLowerCase().contains('dg1'))) {
            result['skipped_${entry.key}'] = 'Advanced probes disabled';
            probesLog.add(
              '${DateTime.now().toIso8601String()} - SKIPPED - ${entry.key}',
            );
            continue;
          }

          try {
            probesLog.add(
              '${DateTime.now().toIso8601String()} - SENT - ${entry.key} -> ${entry.value}',
            );
            final resp = await FlutterNfcKit.transceive(entry.value);
            probesLog.add(
              '${DateTime.now().toIso8601String()} - RECV - ${entry.key} -> $resp',
            );
            result[entry.key] = resp;

            // Try to parse EMV TLV responses for common EMV/read-record probes
            try {
              if (entry.key.toLowerCase().contains('emv') ||
                  entry.key.toLowerCase().contains('read record')) {
                final parsed = EmvParser.parseFromHex(resp);
                if (parsed.isNotEmpty) result['parsed_${entry.key}'] = parsed;
              }

              // Passport DG1 / MRZ probe
              if (entry.key.toLowerCase().contains('dg1') ||
                  entry.key.toLowerCase().contains('mrz')) {
                try {
                  final parsed = PassportParser.parseDG1Hex(resp);
                  result['parsed_${entry.key}'] = parsed;
                } catch (e) {
                  result['parsed_${entry.key}_error'] = e.toString();
                }
              }

              // Turkish ID EF.PERSO example parse
              if (entry.key.toLowerCase().contains('perso')) {
                try {
                  final parsed = TurkishIdParser.parsePersoHex(resp);
                  result['parsed_${entry.key}'] = parsed;
                } catch (e) {
                  result['parsed_${entry.key}_error'] = e.toString();
                }
              }
            } catch (e) {
              result['parsed_${entry.key}_error'] = e.toString();
            }
          } catch (e) {
            result['${entry.key}_error'] = e.toString();
          }
        }
        result['probes_log'] = probesLog;
      }

      // Mifare Classic reading (sector 0, block 0) - safe attempts (no writes)
      // CoreNFC never exposes MIFARE Classic, so its vendor block reads only
      // make sense on Android.
      if (!AppPlatform.isIOS &&
          (tag.type.toString().toLowerCase().contains('mifare_classic') ||
              tag.standard.toLowerCase().contains('mifare') == true)) {
        try {
          // Attempt to read manufacturer block (sector 0 block 0) using vendor command
          try {
            final readBlock0 = await FlutterNfcKit.transceive('FFB000000010');
            result['Mifare Read Block 0'] = readBlock0;
            try {
              final parsed = MifareParser.parseBlockHex(readBlock0);
              result['parsed_Mifare_Block0'] = parsed;
            } catch (e) {
              result['parsed_Mifare_Block0_error'] = e.toString();
            }
          } catch (e) {
            result['Mifare_Block0_error'] = e.toString();
          }

          // Try block 4 (commonly data block) non-destructive read
          try {
            final readBlock4 = await FlutterNfcKit.transceive('FFB000040010');
            result['Mifare Read Block 4'] = readBlock4;
            try {
              result['parsed_Mifare_Block4'] = MifareParser.parseBlockHex(
                readBlock4,
              );
            } catch (e) {
              result['parsed_Mifare_Block4_error'] = e.toString();
            }
          } catch (e) {
            result['Mifare_Block4_error'] = e.toString();
          }
        } catch (e) {
          result['mifare_error'] = e.toString();
        }
      }

      // ISO15693 (NFC-V) probing: Get System Info (0x2) and Read Single Block (0x20) if available
      try {
        if (tag.type.toString().toLowerCase().contains('iso15693') ||
            tag.standard.toLowerCase().contains('iso15693') == true) {
          try {
            // Flags 0x02 (high data rate without address), Command 0x2 (Get System Info)
            final sys = await FlutterNfcKit.transceive('020200');
            result['ISO15693_SystemInfo'] = sys;
            try {
              result['parsed_iso15693_sys'] = Iso15693Parser.parseSystemInfo(
                sys,
              );
            } catch (e) {
              result['parsed_iso15693_sys_error'] = e.toString();
            }
          } catch (e) {
            result['iso15693_sys_error'] = e.toString();
          }

          // Try a safe single block read (block 0) - flags + command + block number
          try {
            final block0 = await FlutterNfcKit.transceive('02002000');
            result['ISO15693_Block0'] = block0;
            result['parsed_iso15693_block0'] = {'hex': block0};
          } catch (e) {
            result['iso15693_block0_error'] = e.toString();
          }
        }
      } catch (e) {
        result['iso15693_error'] = e.toString();
      }

      // FeliCa probing: capture available PMm/system code if present in tag fields
      try {
        if (tag.type.toString().toLowerCase().contains('felica') ||
            tag.standard.toLowerCase().contains('felica') == true) {
          try {
            // FlutterNfcKit may expose ID/historical bytes with PMm or system info
            final id = tag.id;
            result['felica_id'] = id;
            try {
              // Attempt a gentle transceive probe - NOTE: some FeliCa operations require more complex framing
              final probe = await FlutterNfcKit.transceive('00');
              result['felica_probe'] = probe;
              result['parsed_felica'] = FelicaParser.parseFromHex(probe);
            } catch (e) {
              // some devices may reject raw probe; fall back to parse ID
              result['felica_probe_error'] = e.toString();
              result['parsed_felica'] = FelicaParser.parseFromHex(id);
            }
          } catch (e) {
            result['felica_error'] = e.toString();
          }
        }
      } catch (e) {
        result['felica_top_error'] = e.toString();
      }

      // Passport (ICAO 9303) probing: try to select MF and EF.COM
      if (allowAdvanced) {
        try {
          // Select MF (3F00)
          await FlutterNfcKit.transceive('00A4000C023F00');
          // Select EF.COM (011E)
          final efCom = await FlutterNfcKit.transceive('00A4020C02011E');
          if (!efCom.startsWith('6')) {
            result['Passport_EF_COM'] = efCom;
            // Try to read DG1 (MRZ) - 0101
            await FlutterNfcKit.transceive('00A4020C020101');
            final dg1 = await FlutterNfcKit.transceive('00B000005F');
            result['Passport_DG1'] = dg1;
            result['parsed_passport'] = PassportParser.parseDG1Hex(dg1);
          }
        } catch (_) {
          // Not a passport or BAC required
        }

        // Turkish ID Card probing
        try {
          // Select T.C. Kimlik Uygulaması (A000000277010104)
          final selectApp = await FlutterNfcKit.transceive(
            '00A4040008A000000277010104',
          );
          if (!selectApp.startsWith('6')) {
            result['TurkishID_AppSelected'] = selectApp;
            // Select EF.PERSO (0101)
            await FlutterNfcKit.transceive('00A4020C020101');
            // Read first 32 bytes
            final perso = await FlutterNfcKit.transceive('00B0000020');
            result['TurkishID_EF_PERSO'] = perso;
            result['parsed_turkish_id'] = TurkishIdParser.parsePersoHex(perso);
          }
        } catch (_) {
          // Not a Turkish ID
        }
      }

      // ISO14443 Type A (NFC-A) - try reading NDEF
      if (tag.ndefAvailable == true) {
        final ndefResult = await FlutterNfcKit.readNDEFRecords();
        result['ndefRecords'] = ndefResult.map((r) => r.toString()).toList();
      }

      return result;
    } catch (e) {
      result['error'] = e.toString();
      return result;
    }
  }

  /// APDU komutu gönder (ör: kimlik, ehliyet, banka kartı için)
  static Future<String> sendApdu(String hexCommand) async {
    try {
      final response = await FlutterNfcKit.transceive(hexCommand);
      return response;
    } catch (e) {
      return 'APDU error: ${e.toString()}';
    }
  }

  /// Kartı bırak
  static Future<void> finish() async {
    await FlutterNfcKit.finish();
  }
}
