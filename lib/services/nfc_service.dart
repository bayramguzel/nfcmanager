import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';
import 'package:app_settings/app_settings.dart';
import '../core/platform_support.dart';
import '../models/nfc_record.dart';

class NfcService {
  Future<bool> isAvailable() async {
    final availability = await NfcManager.instance.checkAvailability();
    return availability == NfcAvailability.enabled;
  }

  Future<void> openNfcSettings() async {
    // Android has a dedicated NFC toggle. iOS has no such switch (NFC is only
    // active during a reader session), so the app's settings page is shown.
    await AppSettings.openAppSettings(
      type: AppPlatform.isIOS ? AppSettingsType.settings : AppSettingsType.nfc,
    );
  }

  Future<void> startSession({
    required Function(NfcTag) onDiscovered,
    required Function(String) onError,
    VoidCallback? onSessionEnded,
  }) async {
    var discovered = false;
    try {
      final availability = await NfcManager.instance.checkAvailability();
      if (availability != NfcAvailability.enabled) {
        onError(
          AppPlatform.isIOS
              ? 'This iPhone does not support NFC scanning'
              : 'NFC kullanılamıyor veya devre dışı',
        );
        return;
      }

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          discovered = true;
          onDiscovered(tag);
        },
        // iOS shows its own system sheet with this text; ignored on Android.
        alertMessageIos: 'Hold your iPhone near the NFC tag',
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
      );

      // On iOS the reader sheet closes when the user taps Cancel, so the UI has
      // to leave the scanning state rather than waiting forever.
      if (!discovered) onSessionEnded?.call();
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> stopSession() async {
    await NfcManager.instance.stopSession();
  }

  NfcRecord? parseTag(NfcTag tag) {
    try {
      String content = 'NFC Etiketi Algılandı';
      NfcRecordType type = NfcRecordType.unknown;
      final Map<String, dynamic> metadata = {};

      // Temel etiket özelliklerini çıkar
      metadata.addAll(_extractTagProperties(tag));

      // NDEF kontrolü ve tüm kayıtları decode et
      try {
        final ndef = Ndef.from(tag);
        if (ndef != null) {
          metadata['ndef'] = {
            'yazilabilir': ndef.isWritable,
            'maksimum_boyut': ndef.maxSize,
            'mesaj_mevcut': ndef.cachedMessage != null,
          };

          if (ndef.cachedMessage != null) {
            final message = ndef.cachedMessage!;
            final decodedRecords = _parseNdefMessage(message);
            metadata['ndef']['kayit_sayisi'] = message.records.length;
            metadata['ndef']['kayitlar'] = decodedRecords;

            if (decodedRecords.isNotEmpty) {
              // Kullanıcı dostu içerik oluştur
              final contentParts = <String>[];
              for (final record in decodedRecords) {
                final category = record['kategori'] as String;
                final recordContent = record['icerik'] as String;

                switch (category) {
                  case 'metin':
                    contentParts.add('📝 Metin: $recordContent');
                    type = NfcRecordType.text;
                    break;
                  case 'url':
                    contentParts.add('🔗 Web Adresi: $recordContent');
                    type = NfcRecordType.uri;
                    break;
                  case 'telefon':
                    contentParts.add('📞 Telefon: $recordContent');
                    type = NfcRecordType.uri;
                    break;
                  case 'email':
                    contentParts.add('📧 E-posta: $recordContent');
                    type = NfcRecordType.uri;
                    break;
                  case 'sms':
                    contentParts.add('💬 SMS: $recordContent');
                    type = NfcRecordType.uri;
                    break;
                  case 'konum':
                    contentParts.add('📍 Konum: $recordContent');
                    type = NfcRecordType.uri;
                    break;
                  case 'wifi':
                    contentParts.add('📶 WiFi: $recordContent');
                    type = NfcRecordType.external;
                    break;
                  case 'bluetooth':
                    contentParts.add('🔵 Bluetooth: $recordContent');
                    type = NfcRecordType.external;
                    break;
                  case 'vcard':
                    contentParts.add('👤 Kişi Kartı (vCard):\n$recordContent');
                    type = NfcRecordType.mime;
                    break;
                  case 'takvim':
                    contentParts.add('📅 Takvim (vCalendar):\n$recordContent');
                    type = NfcRecordType.mime;
                    break;
                  case 'json':
                    contentParts.add('🧾 JSON: $recordContent');
                    type = NfcRecordType.mime;
                    break;
                  case 'mime':
                    contentParts.add('📄 Dosya: $recordContent');
                    type = NfcRecordType.mime;
                    break;
                  case 'akilli_poster':
                    contentParts.add('🎯 Akıllı Poster: $recordContent');
                    type = NfcRecordType.smartPoster;
                    break;
                  case 'uygulama':
                    contentParts.add('📱 Uygulama: $recordContent');
                    type = NfcRecordType.external;
                    break;
                  case 'harici':
                    contentParts.add('📦 Harici Kayıt: $recordContent');
                    type = NfcRecordType.external;
                    break;
                  case 'handover':
                    contentParts.add('🔁 El Değiştirme: $recordContent');
                    type = NfcRecordType.external;
                    break;
                  default:
                    contentParts.add('❓ Bilinmeyen: $recordContent');
                }
              }
              content = contentParts.join('\n\n');
            } else {
              content = '📋 NDEF Etiketi (Boş)';
              type = NfcRecordType.text;
            }
          } else {
            content = '📋 NDEF Etiketi (Veri Yok)';
            type = NfcRecordType.text;
          }
        }
      } catch (e) {
        metadata['ndef_hatasi'] = e.toString();
      }

      // Eğer hala yararlı içerik yoksa, mevcut özelliklerin özetini sun
      if (content == 'NFC Etiketi Algılandı' || content.trim().isEmpty) {
        final summary = <String>[];

        if (metadata.containsKey('teknoloji_listesi') &&
            metadata['teknoloji_listesi'] != null) {
          final techList = metadata['teknoloji_listesi'] as List;
          if (techList.isNotEmpty) {
            summary.add('⚙️ Teknolojiler: ${techList.join(', ')}');
          }
        }

        if (metadata.containsKey('standart') && metadata['standart'] != null) {
          summary.add('📊 Standart: ${metadata['standart']}');
        }

        if (metadata.containsKey('uretici') && metadata['uretici'] != null) {
          summary.add('🏭 Üretici: ${metadata['uretici']}');
        }

        if (metadata.containsKey('tip') && metadata['tip'] != null) {
          summary.add('🏷️ Tip: ${metadata['tip']}');
        }

        if (summary.isNotEmpty) {
          content = summary.join('\n');
        } else {
          content =
              '🏷️ Temel NFC Etiketi\n\nBu etiket temel NFC özelliklerini destekliyor ancak NDEF verisi içermiyor.';
        }
      }

      metadata['zaman_damgasi'] = DateTime.now().toIso8601String();

      return NfcRecord(type: type, content: content, metadata: metadata);
    } catch (e) {
      return NfcRecord(
        type: NfcRecordType.unknown,
        content: '❌ Etiket okuma hatası: ${e.toString()}',
      );
    }
  }

  List<Map<String, dynamic>> _parseNdefMessage(dynamic message) {
    final results = <Map<String, dynamic>>[];
    try {
      final records = message.records as List;
      for (final record in records) {
        results.add(_decodeNdefRecord(record));
      }
    } catch (e) {
      // Mesaj parse edilemedi
    }
    return results;
  }

  Map<String, dynamic> _decodeNdefRecord(dynamic record) {
    final Map<String, dynamic> out = {};

    try {
      final typeName = record.typeNameFormat.toString();
      final rawType = String.fromCharCodes(record.type);
      final payload = List<int>.from(record.payload as List<int>);

      out['tnf'] = typeName;
      out['ham_tip'] = rawType;
      out['kimlik'] = record.identifier;
      out['veri_boyutu'] = payload.length;

      final tnf = typeName.toLowerCase();
      String category = 'bilinmeyen';
      String content = '';

      final isWellKnown =
          tnf.contains('wellknown') ||
          rawType == 'T' ||
          rawType == 'U' ||
          rawType == 'H' ||
          rawType.toLowerCase() == 'sp';

      if (isWellKnown) {
        switch (rawType) {
          case 'T': // NFC Forum RTD Text (metin kaydı)
            content = _decodeTextPayload(payload);
            category = 'metin';
            break;
          case 'U': // NFC Forum RTD URI (web, tel, mailto, sms, geo...)
            final fullUri = _decodeUriPayload(payload);
            category = _categorizeUri(fullUri);
            content = _uriDisplay(fullUri, category);
            break;
          case 'H': // RTD Handover Select / Request
            content =
                'NFC El Değiştirme (Handover) kaydı - ${payload.length} byte';
            category = 'handover';
            break;
          case 'Sp':
          case 'sp': // RTD Smart Poster (içinde URI + başlık barındırır)
            content = _parseSmartPoster(payload);
            category = 'akilli_poster';
            break;
          default:
            // Diğer well-known tipler (alternatif metin/uri varyantları vb.)
            content = 'Well-known tip ($rawType) - ${payload.length} byte';
            category = 'wellknown';
        }
      } else if (tnf.contains('mime')) {
        // MIME medya
        final mimeType = rawType;
        out['mime_tipi'] = mimeType;
        final text = _tryUtf8(payload);

        if (mimeType.startsWith('text/vcard') ||
            mimeType == 'text/x-vcard' ||
            mimeType == 'application/vcard' ||
            mimeType == 'application/x-vcard') {
          content = text ?? 'vCard verisi (${payload.length} byte)';
          category = 'vcard';
        } else if (mimeType.startsWith('text/calendar')) {
          content = text ?? 'Takvim verisi (${payload.length} byte)';
          category = 'takvim';
        } else if (mimeType.startsWith('text/')) {
          if (text != null) {
            content = text;
            category = 'metin';
          } else {
            content = 'Metin verisi (${payload.length} byte)';
            category = 'mime';
          }
        } else if (mimeType == 'application/vnd.wfa.wsc') {
          // Wi-Fi Simple Config (WPS/WSC)
          content = _parseWifiConfig(payload);
          category = 'wifi';
        } else if (mimeType == 'application/vnd.bluetooth.ep.oob') {
          // Bluetooth Easy Proximity (OOB) eşleşme verisi
          content = _parseBluetoothOob(payload);
          category = 'bluetooth';
        } else if (mimeType == 'application/json' ||
            mimeType.endsWith('+json')) {
          content = text ?? 'JSON verisi (${payload.length} byte)';
          category = 'json';
        } else if (mimeType == 'application/vnd.android.package-archive') {
          content = text ?? 'Android APK verisi (${payload.length} byte)';
          category = 'uygulama';
        } else if (text != null) {
          content = text;
          category = 'mime';
        } else {
          content = 'İkili veri (${payload.length} byte)';
          out['veri_base64'] = base64Encode(payload);
          category = 'mime';
        }
      } else if (tnf.contains('external')) {
        // Harici tip (android.com:pkg vb.)
        if (rawType.contains('android.com:pkg')) {
          final packageName = _tryUtf8(payload);
          out['paket_adi'] = packageName;
          content = (packageName != null && packageName.isNotEmpty)
              ? 'Android Uygulama: $packageName'
              : 'Android Uygulama Paketi';
          category = 'uygulama';
        } else {
          content = _tryUtf8(payload) ?? String.fromCharCodes(payload);
          category = 'harici';
        }
      } else {
        // Bilinmeyen / ikili
        final text = _tryUtf8(payload);
        if (text != null) {
          content = text;
        } else {
          content = 'İkili veri (${payload.length} byte)';
          out['veri_base64'] = base64Encode(payload);
        }
        category = 'bilinmeyen';
      }

      out['kategori'] = category;
      out['icerik'] = content;
    } catch (e) {
      out['kategori'] = 'hata';
      out['icerik'] = 'Kayıt decode hatası: ${e.toString()}';
    }

    return out;
  }

  /// RTD Text kaydının payload'ını çözer (durum bayrağı + dil + metin).
  String _decodeTextPayload(List<int> payload) {
    if (payload.isEmpty) return '';
    final status = payload[0];
    final isUtf16 = (status & 0x80) != 0;
    final langLen = status & 0x3F;
    final start = 1 + langLen;
    if (start > payload.length) return '';
    final bytes = payload.sublist(start);
    if (isUtf16) {
      return String.fromCharCodes(bytes);
    }
    return _tryUtf8(bytes) ?? String.fromCharCodes(bytes);
  }

  /// RTD URI kaydının payload'ını (öneki + adres) çözer.
  String _decodeUriPayload(List<int> payload) {
    if (payload.isEmpty) return '';
    final prefixCode = payload[0];
    final uriBytes = payload.sublist(1);
    final uriStr = _tryUtf8(uriBytes) ?? String.fromCharCodes(uriBytes);
    return '${_getUriPrefix(prefixCode)}$uriStr';
  }

  String? _tryUtf8(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return null;
    }
  }

  /// URI'ye göre kategori belirler (telefon, e-posta, sms, konum, web...).
  String _categorizeUri(String uri) {
    final lower = uri.toLowerCase();
    if (lower.startsWith('tel:')) return 'telefon';
    if (lower.startsWith('mailto:')) return 'email';
    if (lower.startsWith('sms:') ||
        lower.startsWith('smsto:') ||
        lower.startsWith('mms:')) {
      return 'sms';
    }
    if (lower.startsWith('geo:') ||
        lower.contains('maps.google.') ||
        lower.contains('maps.apple.')) {
      return 'konum';
    }
    return 'url';
  }

  String _uriDisplay(String uri, String category) {
    if (category == 'telefon' && uri.startsWith('tel:')) {
      return uri.substring(4);
    }
    if (category == 'email' && uri.startsWith('mailto:')) {
      return uri.substring(7);
    }
    return uri;
  }

  String _hexOf(List<int> bytes) {
    return bytes
        .map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
  }

  /// Wi-Fi Simple Configuration (WPS / WSC) TLV verisini çözümler.
  String _parseWifiConfig(List<int> data) {
    String? ssid;
    String? networkKey;
    String? auth;
    String? encryption;

    int i = 0;
    while (i + 4 <= data.length) {
      final tag = (data[i] << 8) | data[i + 1];
      final len = (data[i + 2] << 8) | data[i + 3];
      final start = i + 4;
      final end = start + len;
      if (end > data.length) break;
      final value = data.sublist(start, end);

      switch (tag) {
        case 0x1045: // SSID
          ssid = _tryUtf8(value) ?? _hexOf(value);
          break;
        case 0x1027: // Network Key (şifre)
          networkKey = _tryUtf8(value) ?? _hexOf(value);
          break;
        case 0x1003: // Authentication Type
          auth = _wifiFlagName(value, const {
            0x0001: 'Open',
            0x0002: 'WPA2-Personal',
            0x0004: 'Shared',
            0x0008: 'WPA-Enterprise',
            0x0010: 'WPA2-Enterprise',
            0x0020: 'WPA-Personal',
          });
          break;
        case 0x1004: // Encryption Type
          encryption = _wifiFlagName(value, const {
            0x0001: 'WEP',
            0x0002: 'TKIP',
            0x0004: 'AES (CCMP)',
            0x0008: 'AES+TKIP',
            0x0010: 'None',
          });
          break;
      }
      i = end;
    }

    // SSID etiketi bulunamadıysa en uzun yazdırılabilir dizeyi SSID olarak dene.
    ssid ??= _longestPrintable(data);

    if (ssid == null && networkKey == null) {
      return 'WiFi Yapılandırma Verisi (${data.length} byte)';
    }

    final buffer = StringBuffer('📶 Wi-Fi Ağı');
    if (ssid != null && ssid.isNotEmpty) buffer.write('\nSSID: $ssid');
    if (auth != null) buffer.write('\nGüvenlik: $auth');
    if (encryption != null) buffer.write('\nŞifreleme: $encryption');
    if (networkKey != null && networkKey.isNotEmpty) {
      buffer.write('\nŞifre: $networkKey');
    }
    buffer.write('\nBoyut: ${data.length} byte');
    return buffer.toString();
  }

  String _wifiFlagName(List<int> value, Map<int, String> names) {
    if (value.length < 2) return _hexOf(value);
    final flags = (value[0] << 8) | value[1];
    final matched = <String>[];
    names.forEach((flag, name) {
      if (flags & flag != 0) matched.add(name);
    });
    return matched.isEmpty ? _hexOf(value) : matched.join(' / ');
  }

  String? _longestPrintable(List<int> data) {
    String? best;
    final current = StringBuffer();
    for (final byte in data) {
      if (byte >= 0x20 && byte <= 0x7E) {
        current.writeCharCode(byte);
      } else {
        if (current.length >= 3) {
          final value = current.toString();
          if (best == null || value.length > best.length) best = value;
        }
        current.clear();
      }
    }
    if (current.length >= 3) {
      final value = current.toString();
      if (best == null || value.length > best.length) best = value;
    }
    return best;
  }

  /// Bluetooth Easy Proximity (OOB) verisini çözer (MAC + TLV alanlar).
  String _parseBluetoothOob(List<int> payload) {
    if (payload.length < 6) {
      return 'Bluetooth OOB verisi (${payload.length} byte)';
    }
    final address = List.generate(
      6,
      (i) => payload[5 - i].toRadixString(16).padLeft(2, '0'),
    ).join(':').toUpperCase();

    final buffer = StringBuffer('🔵 Bluetooth Eşleşme (OOB)');
    buffer.write('\nMAC: $address');
    final name = _longestPrintable(payload);
    if (name != null) buffer.write('\nCihaz: $name');
    buffer.write('\nBoyut: ${payload.length} byte');
    return buffer.toString();
  }

  /// Smart Poster payload'ı, içinde NDEF mesajı barındırır; içindeki
  /// URI/metin kayıtlarını çözümler.
  String _parseSmartPoster(List<int> payload) {
    final nested = _parseRawNdefMessage(payload);
    if (nested.isEmpty) {
      return 'Akıllı Poster Verisi (${payload.length} byte)';
    }

    final parts = <String>[];
    for (final record in nested) {
      final recordCategory = record['kategori'];
      final recordContent = record['icerik'];
      switch (recordCategory) {
        case 'url':
          parts.add('🔗 $recordContent');
          break;
        case 'telefon':
          parts.add('📞 $recordContent');
          break;
        case 'sms':
          parts.add('💬 $recordContent');
          break;
        case 'konum':
          parts.add('📍 $recordContent');
          break;
        case 'metin':
          parts.add('📝 $recordContent');
          break;
        default:
          parts.add('🏷️ $recordContent');
      }
    }
    return parts.join('\n');
  }

  /// Ham NDEF mesaj baytlarını tek tek kayıtlara ayırır (SR/ME bayrakları dahil).
  List<Map<String, dynamic>> _parseRawNdefMessage(List<int> data) {
    final results = <Map<String, dynamic>>[];
    int i = 0;

    while (i + 3 <= data.length) {
      final flags = data[i];
      final isShortRecord = (flags & 0x20) != 0;
      final isEnd = (flags & 0x40) != 0;
      final typeLen = data[i + 1];
      final idLen = data[i + 2];

      int headerLen;
      int payloadLen;
      if (isShortRecord) {
        if (i + 4 > data.length) break;
        payloadLen = data[i + 3];
        headerLen = 4;
      } else {
        if (i + 5 > data.length) break;
        payloadLen = (data[i + 3] << 8) | data[i + 4];
        headerLen = 5;
      }

      final typeStart = i + headerLen;
      final payloadStart = typeStart + typeLen + idLen;
      final nextIndex = payloadStart + payloadLen;
      if (typeStart + typeLen > data.length || nextIndex > data.length) break;

      final type = String.fromCharCodes(
        data.sublist(typeStart, typeStart + typeLen),
      );
      final payload = data.sublist(payloadStart, nextIndex);

      String category = 'bilinmeyen';
      String content = '';
      if (type == 'U') {
        final fullUri = _decodeUriPayload(payload);
        category = _categorizeUri(fullUri);
        content = _uriDisplay(fullUri, category);
      } else if (type == 'T') {
        content = _decodeTextPayload(payload);
        category = 'metin';
      } else {
        content = _tryUtf8(payload) ?? 'İkili veri (${payload.length} byte)';
      }

      results.add({'kategori': category, 'icerik': content, 'tip': type});
      i = nextIndex;
      if (isEnd) break;
    }

    return results;
  }

  Map<String, dynamic> _extractTagProperties(NfcTag tag) {
    final Map<String, dynamic> out = {};

    try {
      final tagString = tag.toString();
      out['ham_veri'] = tagString;

      // Extract UID/identifier
      try {
        final ndef = Ndef.from(tag);
        if (ndef != null && ndef.additionalData['identifier'] != null) {
          final idList = ndef.additionalData['identifier'];
          if (idList is List) {
            out['uid'] = idList
                .map(
                  (e) => (e as int)
                      .toRadixString(16)
                      .padLeft(2, '0')
                      .toUpperCase(),
                )
                .join(':');
          }
        }
      } catch (_) {}

      if (out['uid'] == null) {
        final idMatch = RegExp(
          r'identifier:\s*\[([0-9,\s]+)\]',
        ).firstMatch(tagString);
        if (idMatch != null) {
          final bytes = idMatch
              .group(1)!
              .split(',')
              .map((s) => int.tryParse(s.trim()) ?? 0)
              .toList();
          out['uid'] = bytes
              .map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
              .join(':');
        }
      }

      // Temel teknoloji listesi
      out['teknoloji_listesi'] = <String>[];

      // iOS exposes typed CoreNFC wrappers instead of the Android technology
      // names parsed below, so read them separately.
      _extractIosTagProperties(tag, out);

      // Tag string'inden teknoloji bilgilerini çıkarmaya çalış
      if (tagString.contains('NfcA')) {
        (out['teknoloji_listesi'] as List).add('NFC-A');
        out['standart'] = 'ISO 14443 Type A';
      }
      if (tagString.contains('NfcB')) {
        (out['teknoloji_listesi'] as List).add('NFC-B');
        out['standart'] = 'ISO 14443 Type B';
      }
      if (tagString.contains('NfcF')) {
        (out['teknoloji_listesi'] as List).add('NFC-F');
        out['standart'] = 'JIS X 6319-4 (FeliCa)';
      }
      if (tagString.contains('NfcV')) {
        (out['teknoloji_listesi'] as List).add('NFC-V');
        out['standart'] = 'ISO 15693';
      }
      if (tagString.contains('IsoDep')) {
        (out['teknoloji_listesi'] as List).add('ISO-DEP');
        out['standart'] = 'ISO 14443-4';
      }
      if (tagString.contains('MifareClassic')) {
        (out['teknoloji_listesi'] as List).add('MIFARE Classic');
        out['uretici'] = 'NXP Semiconductors';
        out['tip'] = 'MIFARE Classic';
      }
      if (tagString.contains('MifareUltralight')) {
        (out['teknoloji_listesi'] as List).add('MIFARE Ultralight');
        out['uretici'] = 'NXP Semiconductors';
        out['tip'] = 'MIFARE Ultralight';
      }
      if (tagString.toLowerCase().contains('desfire')) {
        (out['teknoloji_listesi'] as List).add('MIFARE DESFire');
        out['uretici'] = 'NXP Semiconductors';
        out['tip'] = 'MIFARE DESFire (ISO 14443-4)';
      }
      if (tagString.toLowerCase().contains('ntag')) {
        (out['teknoloji_listesi'] as List).add('NTAG');
        out['uretici'] = 'NXP Semiconductors';
        out['tip'] = 'NTAG (NFC Type 2 Tag)';
      }
      if (tagString.toLowerCase().contains('st25')) {
        (out['teknoloji_listesi'] as List).add('ST25 (NFC-V)');
        out['uretici'] = 'STMicroelectronics';
        out['tip'] = 'ST25 / ISO 15693';
      }
      if (tagString.contains('NfcBarcode') ||
          tagString.toLowerCase().contains('barcode')) {
        (out['teknoloji_listesi'] as List).add('NFC Barcode');
        out['tip'] = 'NFC Barcode (ISO/IEC 15415)';
      }
      if (tagString.contains('NdefFormatable')) {
        (out['teknoloji_listesi'] as List).add('NDEF Formatable');
      }
      if (tagString.contains('Ndef')) {
        out['ndef_destegi'] = true;
      }
    } catch (e) {
      out['etiket_veri_hatasi'] = e.toString();
    }

    return out;
  }

  /// iOS: CoreNFC tag wrappers (Iso7816, MiFare, FeliCa, Iso15693, Ndef).
  /// These `from` factories simply return null on other platforms, so the
  /// method is safe to call everywhere.
  void _extractIosTagProperties(NfcTag tag, Map<String, dynamic> out) {
    final techList = (out['teknoloji_listesi'] as List).cast<String>();

    final iso7816 = Iso7816Ios.from(tag);
    if (iso7816 != null) {
      techList.add('ISO 7816 (ISO-DEP)');
      out['standart'] = 'ISO 14443-4 (ISO 7816)';
      out['uid'] ??= _hexBytes(iso7816.identifier);
      if (iso7816.initialSelectedAID.isNotEmpty) {
        out['secili_aid'] = iso7816.initialSelectedAID;
      }
    }

    final mifare = MiFareIos.from(tag);
    if (mifare != null) {
      final family = mifare.mifareFamily.name.toUpperCase();
      techList.add('MIFARE $family');
      out['standart'] = 'ISO 14443 Type A';
      out['uretici'] = 'NXP Semiconductors';
      out['tip'] = 'MIFARE $family (NFC Type 2)';
      out['uid'] ??= _hexBytes(mifare.identifier);
    }

    final felica = FeliCaIos.from(tag);
    if (felica != null) {
      techList.add('FeliCa');
      out['standart'] = 'JIS X 6319-4 (FeliCa)';
      out['uid'] ??= _hexBytes(felica.currentIDm);
      out['felica_system_kodu'] = _hexBytes(felica.currentSystemCode);
    }

    final iso15693 = Iso15693Ios.from(tag);
    if (iso15693 != null) {
      techList.add('ISO 15693 (NFC-V)');
      out['standart'] = 'ISO 15693';
      out['uid'] ??= _hexBytes(iso15693.identifier);
    }

    final ndef = NdefIos.from(tag);
    if (ndef != null) {
      out['ndef_destegi'] = true;
      out['ndef_durumu'] = ndef.status.name;
    }
  }

  String _hexBytes(List<int> bytes) => bytes
      .map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
      .join(':');

  String _getUriPrefix(int prefixCode) {
    const prefixes = [
      '',
      'http://www.',
      'https://www.',
      'http://',
      'https://',
      'tel:',
      'mailto:',
      'ftp://anonymous:anonymous@',
      'ftp://ftp.',
      'ftps://',
      'sftp://',
      'smb://',
      'nfs://',
      'ftp://',
      'dav://',
      'news:',
      'telnet://',
      'imap:',
      'rtsp://',
      'urn:',
      'pop:',
      'sip:',
      'sips:',
      'tftp:',
      'btspp://',
      'btl2cap://',
      'btgoep://',
      'tcpobex://',
      'irdaobex://',
      'file://',
      'urn:epc:id:',
      'urn:epc:tag:',
      'urn:epc:pat:',
      'urn:epc:raw:',
      'urn:epc:',
      'urn:nfc:',
    ];

    if (prefixCode >= 0 && prefixCode < prefixes.length) {
      return prefixes[prefixCode];
    }
    return '';
  }

  Map<String, dynamic> getTagInfo(NfcTag tag) {
    final tagData = <String, dynamic>{};

    try {
      // Temel etiket özelliklerini çıkar
      tagData.addAll(_extractTagProperties(tag));

      // NDEF kontrolü ve decode edilmiş kayıtları dahil et
      try {
        final ndef = Ndef.from(tag);
        if (ndef != null) {
          tagData['ndef'] = {
            'yazilabilir': ndef.isWritable,
            'maksimum_boyut': ndef.maxSize,
            'mesaj_mevcut': ndef.cachedMessage != null,
          };

          if (ndef.cachedMessage != null) {
            final message = ndef.cachedMessage!;
            tagData['ndef']['kayit_sayisi'] = message.records.length;
            tagData['ndef']['kayitlar'] = _parseNdefMessage(message);
          }
        }
      } catch (e) {
        tagData['ndef_hatasi'] = e.toString();
      }

      // Zaman damgası ekle
      tagData['zaman_damgasi'] = DateTime.now().toIso8601String();
    } catch (e) {
      tagData['hata'] = e.toString();
    }

    return tagData;
  }

  NdefRecord _createNdefRecord(NfcRecord record) {
    switch (record.type) {
      case NfcRecordType.text:
        final langBytes = utf8.encode('en');
        final textBytes = utf8.encode(record.content);
        final payload = Uint8List(1 + langBytes.length + textBytes.length);
        payload[0] = langBytes.length & 0x3F;
        payload.setRange(1, 1 + langBytes.length, langBytes);
        payload.setRange(1 + langBytes.length, payload.length, textBytes);
        return NdefRecord(
          typeNameFormat: TypeNameFormat.wellKnown,
          type: Uint8List.fromList([0x54]), // 'T'
          identifier: Uint8List(0),
          payload: payload,
        );

      case NfcRecordType.uri:
        // NFC Forum URI Identifier Code tablosu ile sıkıştırma.
        const prefixCodes = <String, int>{
          'http://www.': 0x01,
          'https://www.': 0x02,
          'http://': 0x03,
          'https://': 0x04,
          'tel:': 0x05,
          'mailto:': 0x06,
          'ftp://anonymous:anonymous@': 0x07,
          'ftp://ftp.': 0x08,
          'ftps://': 0x09,
          'sftp://': 0x0A,
          'smb://': 0x0B,
          'nfs://': 0x0C,
          'ftp://': 0x0D,
          'dav://': 0x0E,
          'news:': 0x0F,
          'telnet://': 0x10,
          'imap:': 0x11,
          'rtsp://': 0x12,
          'urn:': 0x13,
          'pop:': 0x14,
          'sip:': 0x15,
          'sips:': 0x16,
          'tftp:': 0x17,
          'btspp://': 0x18,
          'btl2cap://': 0x19,
          'btgoep://': 0x1A,
          'tcpobex://': 0x1B,
          'irdaobex://': 0x1C,
          'file://': 0x1D,
        };

        final uri = record.content;
        int prefixCode = 0x00;
        String uriBody = uri;

        // En uzun eşleşen öneki kullan (www. içeren adreslerde doğru sonuç).
        final sortedPrefixes = prefixCodes.keys.toList()
          ..sort((a, b) => b.length.compareTo(a.length));
        for (final prefix in sortedPrefixes) {
          if (uri.startsWith(prefix)) {
            prefixCode = prefixCodes[prefix]!;
            uriBody = uri.substring(prefix.length);
            break;
          }
        }

        final bodyBytes = utf8.encode(uriBody);
        final payload = Uint8List(1 + bodyBytes.length);
        payload[0] = prefixCode;
        payload.setRange(1, payload.length, bodyBytes);

        return NdefRecord(
          typeNameFormat: TypeNameFormat.wellKnown,
          type: Uint8List.fromList([0x55]), // 'U'
          identifier: Uint8List(0),
          payload: payload,
        );

      case NfcRecordType.mime:
        final mimeType = record.mimeType?.isNotEmpty == true
            ? record.mimeType!
            : 'text/plain';
        final typeBytes = Uint8List.fromList(utf8.encode(mimeType));
        final payload = Uint8List.fromList(utf8.encode(record.content));
        return NdefRecord(
          typeNameFormat: TypeNameFormat.media,
          type: typeBytes,
          identifier: Uint8List(0),
          payload: payload,
        );

      case NfcRecordType.external:
        final extType = record.mimeType?.isNotEmpty == true
            ? record.mimeType!
            : 'android.com:pkg';
        final typeBytes = Uint8List.fromList(utf8.encode(extType));
        final payload = Uint8List.fromList(utf8.encode(record.content));
        return NdefRecord(
          typeNameFormat: TypeNameFormat.external,
          type: typeBytes,
          identifier: Uint8List(0),
          payload: payload,
        );

      default:
        final textBytes = utf8.encode(record.content);
        return NdefRecord(
          typeNameFormat: TypeNameFormat.unknown,
          type: Uint8List(0),
          identifier: Uint8List(0),
          payload: Uint8List.fromList(textBytes),
        );
    }
  }

  /// Yazılacak kayda göre (tek veya Smart Poster gibi çoklu) NDEF
  /// kayıtlarını oluşturur.
  List<NdefRecord> _createNdefRecords(NfcRecord record) {
    // Smart Poster: içinde URI (+ içerik tipi) barındıran tek bir NDEF mesajı.
    if (record.type == NfcRecordType.smartPoster) {
      final uriRecord = _createNdefRecord(
        NfcRecord(type: NfcRecordType.uri, content: record.content),
      );

      final typeRecord = NdefRecord(
        typeNameFormat: TypeNameFormat.media,
        type: Uint8List.fromList(
          utf8.encode(
            record.mimeType?.isNotEmpty == true
                ? record.mimeType!
                : 'text/html',
          ),
        ),
        identifier: Uint8List(0),
        payload: Uint8List(0),
      );

      final smartPosterRecord = NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: Uint8List.fromList('sp'.codeUnits),
        identifier: Uint8List(0),
        payload: _concatNdefRecords([uriRecord, typeRecord]),
      );

      return [smartPosterRecord];
    }

    return [_createNdefRecord(record)];
  }

  /// Birden fazla NDEF kaydını ham NDEF mesaj baytlarına dönüştürür.
  Uint8List _concatNdefRecords(List<NdefRecord> records) {
    final builder = BytesBuilder(copy: false);

    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      final payload = record.payload;
      final isShortRecord = payload.length <= 255;

      int flags = _tnfValue(record.typeNameFormat);
      if (i == 0) flags |= 0x80; // MB: mesajın ilk kaydı
      if (i == records.length - 1) flags |= 0x40; // ME: mesajın son kaydı
      if (isShortRecord) flags |= 0x20; // SR: kısa kayıt

      builder.addByte(flags);
      builder.addByte(record.type.length);
      builder.addByte(record.identifier.length);
      if (isShortRecord) {
        builder.addByte(payload.length);
      } else {
        builder.addByte((payload.length >> 8) & 0xFF);
        builder.addByte(payload.length & 0xFF);
      }
      builder.add(record.type);
      builder.add(record.identifier);
      builder.add(payload);
    }

    return builder.takeBytes();
  }

  int _tnfValue(TypeNameFormat format) {
    switch (format) {
      case TypeNameFormat.empty:
        return 0x00;
      case TypeNameFormat.wellKnown:
        return 0x01;
      case TypeNameFormat.media:
        return 0x02;
      case TypeNameFormat.absoluteUri:
        return 0x03;
      case TypeNameFormat.external:
        return 0x04;
      case TypeNameFormat.unknown:
        return 0x05;
      case TypeNameFormat.unchanged:
        return 0x06;
    }
  }

  Future<void> writeRecord(NfcTag tag, NfcRecord record) async {
    final ndef = Ndef.from(tag);
    if (ndef == null) {
      throw Exception('Tag does not support NDEF or is unformatted.');
    }
    if (!ndef.isWritable) {
      throw Exception('This NFC tag is write-protected (read-only).');
    }

    final message = NdefMessage(records: _createNdefRecords(record));

    if (message.byteLength > ndef.maxSize) {
      throw Exception(
        'Data size (${message.byteLength} bytes) exceeds tag capacity (${ndef.maxSize} bytes).',
      );
    }

    await ndef.write(message: message);
  }

  Future<void> eraseTag(NfcTag tag) async {
    final ndef = Ndef.from(tag);
    if (ndef == null) {
      throw Exception('Tag does not support NDEF or is unformatted.');
    }
    if (!ndef.isWritable) {
      throw Exception('This NFC tag is write-protected (read-only).');
    }

    final emptyRecord = NdefRecord(
      typeNameFormat: TypeNameFormat.empty,
      type: Uint8List(0),
      identifier: Uint8List(0),
      payload: Uint8List(0),
    );
    await ndef.write(message: NdefMessage(records: [emptyRecord]));
  }

  Future<void> lockTag(NfcTag tag) async {
    final ndef = Ndef.from(tag);
    if (ndef == null) {
      throw Exception('Tag does not support NDEF or is unformatted.');
    }
    if (!ndef.isWritable) {
      throw Exception('This NFC tag is already read-only.');
    }
    await ndef.writeLock();
  }
}
