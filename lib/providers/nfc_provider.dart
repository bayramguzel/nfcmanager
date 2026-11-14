import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/platform_support.dart';
import '../models/nfc_record.dart';
import '../services/ad_service.dart';
import '../services/nfc_service.dart';

enum NfcStatus { idle, scanning, writing, success, error }

class NfcProvider extends ChangeNotifier {
  void addRecord(NfcRecord record) {
    _history.insert(0, record);
    _saveHistory();
    notifyListeners();
  }

  final NfcService _nfcService = NfcService();

  NfcStatus _status = NfcStatus.idle;
  String _message = 'Ready to scan';
  List<NfcRecord> _history = [];
  NfcRecord? _lastReadRecord;
  bool _isNfcAvailable = false;
  bool _autoScan = false;
  bool _soundEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  Color _themeColor = Colors.teal;
  NfcRecord? _clonedRecord;

  NfcStatus get status => _status;
  String get message => _message;
  List<NfcRecord> get history => _history;
  NfcRecord? get lastReadRecord => _lastReadRecord;
  bool get isNfcAvailable => _isNfcAvailable;
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  Color get themeColor => _themeColor;
  bool get soundEnabled => _soundEnabled;
  NfcRecord? get clonedRecord => _clonedRecord;

  void setClonedRecord(NfcRecord? record) {
    _clonedRecord = record;
    notifyListeners();
  }

  NfcProvider() {
    _loadHistory();
    _loadSettings();
    checkNfcStatus();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    _autoScan = prefs.getBool('auto_scan') ?? false;
    _soundEnabled = prefs.getBool('sound_feedback') ?? true;

    // Language resolution:
    // If user has manually chosen a language, use it.
    // Otherwise, check device language. If supported (en, tr, de, pt), adopt it automatically!
    // This migrates users whose device was de/pt/tr but were previously shown English.
    final hasManualChoice = prefs.getBool('user_manually_set_lang') ?? false;
    final deviceLang = WidgetsBinding
        .instance
        .platformDispatcher
        .locale
        .languageCode
        .toLowerCase();
    const supportedLangs = {'en', 'tr', 'de', 'pt'};

    String langCode;
    if (hasManualChoice) {
      langCode = prefs.getString('language_code') ?? 'en';
    } else {
      if (supportedLangs.contains(deviceLang)) {
        langCode = deviceLang;
      } else {
        langCode = prefs.getString('language_code') ?? 'en';
      }
    }
    _locale = Locale(langCode);

    // Standard theme color: last green color (Colors.teal)
    final colorValue = prefs.getInt('theme_color');
    if (colorValue == null ||
        colorValue == Colors.deepPurple.toARGB32() ||
        colorValue == Colors.deepPurple.value) {
      _themeColor = Colors.teal;
    } else {
      _themeColor = Color(colorValue);
    }

    notifyListeners();
  }

  bool get autoScan => _autoScan;

  Future<void> setAutoScan(bool value) async {
    _autoScan = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_scan', value);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_feedback', value);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setBool('user_manually_set_lang', true);
    notifyListeners();
  }

  Future<void> setThemeColor(Color color) async {
    _themeColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_color', color.toARGB32());
    notifyListeners();
  }

  Future<void> checkNfcStatus() async {
    _isNfcAvailable = await _nfcService.isAvailable();
    notifyListeners();
  }

  Future<void> openSettings() async {
    await _nfcService.openNfcSettings();
    await checkNfcStatus();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('nfc_history') ?? [];
    _history = historyJson
        .map((item) => NfcRecord.fromJson(jsonDecode(item)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _history
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList('nfc_history', historyJson);
  }

  void clearHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }

  void deleteRecord(String id) {
    _history.removeWhere((record) => record.id == id);
    _saveHistory();
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _history.indexWhere((record) => record.id == id);
    if (index == -1) return;
    _history[index] = _history[index].copyWith(
      isFavorite: !_history[index].isFavorite,
    );
    if (_lastReadRecord?.id == id) {
      _lastReadRecord = _history[index];
    }
    _saveHistory();
    notifyListeners();
  }

  List<NfcRecord> get favorites =>
      _history.where((record) => record.isFavorite).toList();

  int get totalScans => _history.length;

  int get todayScans {
    final now = DateTime.now();
    return _history
        .where(
          (r) =>
              r.timestamp.year == now.year &&
              r.timestamp.month == now.month &&
              r.timestamp.day == now.day,
        )
        .length;
  }

  Future<void> exportHistoryCsv({Rect? sharePositionOrigin}) async {
    final buffer = StringBuffer(
      'id,type,content,mimeType,timestamp,favorite\n',
    );
    String esc(String v) => '"${v.replaceAll('"', '""')}"';
    for (final r in _history) {
      buffer.writeln(
        '${r.id},${r.type.name},${esc(r.content)},${esc(r.mimeType ?? '')},${r.timestamp.toIso8601String()},${r.isFavorite ? 1 : 0}',
      );
    }
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/nfc_history_export.csv');
    await file.writeAsString(buffer.toString());
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'NFC Manager History Export (CSV)',
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  Future<void> exportHistory({Rect? sharePositionOrigin}) async {
    try {
      final historyJson = _history.map((item) => item.toJson()).toList();
      final jsonString = const JsonEncoder.withIndent(
        '  ',
      ).convert(historyJson);

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/nfc_history_export.json');
      await file.writeAsString(jsonString);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'NFC Manager History Export',
          sharePositionOrigin: sharePositionOrigin,
        ),
      );
    } catch (e) {
      debugPrint('Export error: $e');
      rethrow;
    }
  }

  Future<void> startScan() async {
    if (!await _nfcService.isAvailable()) {
      _message = AppPlatform.isIOS
          ? 'This iPhone does not support NFC scanning'
          : 'NFC is not available on this device';
      _status = NfcStatus.error;
      notifyListeners();
      return;
    }

    _status = NfcStatus.scanning;
    _message = 'Hold your device near an NFC tag';
    notifyListeners();

    await _nfcService.startSession(
      onSessionEnded: _handleSessionEnded,
      onDiscovered: (tag) async {
        final record = _nfcService.parseTag(tag);
        if (record != null) {
          HapticFeedback.mediumImpact();
          if (_soundEnabled) {
            SystemSound.play(SystemSoundType.click);
          }
          await Future.delayed(const Duration(milliseconds: 100));
          HapticFeedback.lightImpact();
          _lastReadRecord = record;
          _history.insert(0, record);
          _saveHistory();
          _status = NfcStatus.success;
          _message = 'Tag read successfully';
          AdService.instance.onSuccessfulRead();
        } else {
          HapticFeedback.heavyImpact();
          _status = NfcStatus.error;
          _message = 'No NDEF data found on tag';
        }
        await _nfcService.stopSession();
        notifyListeners();
      },
      onError: (error) {
        HapticFeedback.heavyImpact();
        _status = NfcStatus.error;
        _message = error;
        notifyListeners();
      },
    );
  }

  Future<void> stopScan() async {
    await _nfcService.stopSession();
    _status = NfcStatus.idle;
    _message = 'Ready to scan';
    notifyListeners();
  }

  Future<void> writeTag(NfcRecord record) async {
    if (!await _nfcService.isAvailable()) {
      _message = AppPlatform.isIOS
          ? 'This iPhone does not support NFC scanning'
          : 'NFC is not available on this device';
      _status = NfcStatus.error;
      notifyListeners();
      return;
    }

    _status = NfcStatus.writing;
    _message = 'Hold your device near a writable NFC tag';
    notifyListeners();

    await _nfcService.startSession(
      onSessionEnded: _handleSessionEnded,
      onDiscovered: (tag) async {
        try {
          await _nfcService.writeRecord(tag, record);
          HapticFeedback.mediumImpact();
          if (_soundEnabled) {
            SystemSound.play(SystemSoundType.click);
          }
          await Future.delayed(const Duration(milliseconds: 100));
          HapticFeedback.lightImpact();
          _status = NfcStatus.success;
          _message = 'Tag written successfully';
        } catch (e) {
          HapticFeedback.heavyImpact();
          _status = NfcStatus.error;
          _message = e.toString();
        }
        await _nfcService.stopSession();
        notifyListeners();
      },
      onError: (error) {
        HapticFeedback.heavyImpact();
        _status = NfcStatus.error;
        _message = error;
        notifyListeners();
      },
    );
  }

  Future<void> eraseTag() async {
    if (!await _nfcService.isAvailable()) {
      _message = AppPlatform.isIOS
          ? 'This iPhone does not support NFC scanning'
          : 'NFC is not available on this device';
      _status = NfcStatus.error;
      notifyListeners();
      return;
    }

    _status = NfcStatus.writing;
    _message = 'Hold your device near an NFC tag to erase';
    notifyListeners();

    await _nfcService.startSession(
      onSessionEnded: _handleSessionEnded,
      onDiscovered: (tag) async {
        try {
          await _nfcService.eraseTag(tag);
          HapticFeedback.mediumImpact();
          if (_soundEnabled) {
            SystemSound.play(SystemSoundType.click);
          }
          _status = NfcStatus.success;
          _message = 'Tag erased successfully';
        } catch (e) {
          HapticFeedback.heavyImpact();
          _status = NfcStatus.error;
          _message = e.toString();
        }
        await _nfcService.stopSession();
        notifyListeners();
      },
      onError: (error) {
        HapticFeedback.heavyImpact();
        _status = NfcStatus.error;
        _message = error;
        notifyListeners();
      },
    );
  }

  Future<void> lockTag() async {
    if (!await _nfcService.isAvailable()) {
      _message = AppPlatform.isIOS
          ? 'This iPhone does not support NFC scanning'
          : 'NFC is not available on this device';
      _status = NfcStatus.error;
      notifyListeners();
      return;
    }

    _status = NfcStatus.writing;
    _message = 'Hold your device near an NFC tag to lock';
    notifyListeners();

    await _nfcService.startSession(
      onSessionEnded: _handleSessionEnded,
      onDiscovered: (tag) async {
        try {
          await _nfcService.lockTag(tag);
          HapticFeedback.mediumImpact();
          if (_soundEnabled) {
            SystemSound.play(SystemSoundType.click);
          }
          _status = NfcStatus.success;
          _message = 'Tag locked successfully (Read-Only)';
        } catch (e) {
          HapticFeedback.heavyImpact();
          _status = NfcStatus.error;
          _message = e.toString();
        }
        await _nfcService.stopSession();
        notifyListeners();
      },
      onError: (error) {
        HapticFeedback.heavyImpact();
        _status = NfcStatus.error;
        _message = error;
        notifyListeners();
      },
    );
  }

  /// iOS reader sheets are dismissed by the system; if no tag was discovered
  /// the UI must fall back to idle instead of staying on "scanning".
  void _handleSessionEnded() {
    if (_status == NfcStatus.scanning || _status == NfcStatus.writing) {
      _status = NfcStatus.idle;
      _message = 'Ready to scan';
      notifyListeners();
    }
  }

  void resetStatus() {
    _status = NfcStatus.idle;
    _message = 'Ready to scan';
    notifyListeners();
  }
}
