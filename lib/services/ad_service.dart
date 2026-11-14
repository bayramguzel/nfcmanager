import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

/// Unity LevelPlay (Unity Ads) merkezi reklam servisi.
/// Game ID: 800274082 (Android + iOS)
/// Yerlesimler: Banner_Android/iOS, Rewarded_Android/iOS, Interstitial_Android/iOS
class AdService extends ChangeNotifier {
  AdService._internal() {
    loadAdFreeStatus();
  }
  static final AdService instance = AdService._internal();

  static const String androidGameId = '800274082';
  static const String iosGameId = '800274082';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isRewardedLoaded = false;
  bool get isRewardedLoaded => _isRewardedLoaded;

  bool _isRewardedShowing = false;
  bool get isRewardedShowing => _isRewardedShowing;

  bool _isInterstitialLoaded = false;
  bool get isInterstitialLoaded => _isInterstitialLoaded;

  int _initRetries = 0;
  int _rewardedRetries = 0;
  int _interstitialRetries = 0;
  static const int _maxRetries = 5;

  int _successfulReads = 0;

  void _scheduleRetry(void Function() retry, int attempt) {
    if (attempt >= _maxRetries) return;
    final delay = Duration(seconds: 5 * (1 << attempt.clamp(0, 3)));
    Future.delayed(delay, retry);
  }

  DateTime? _adFreeUntil;
  DateTime? get adFreeUntil => _adFreeUntil;

  bool get isAdFree {
    if (_adFreeUntil == null) return false;
    return _adFreeUntil!.isAfter(DateTime.now());
  }

  Duration get adFreeRemaining {
    if (!isAdFree) return Duration.zero;
    return _adFreeUntil!.difference(DateTime.now());
  }

  String get formattedRemainingTime {
    if (!isAdFree) return '';
    final rem = adFreeRemaining;
    final hours = rem.inHours;
    final minutes = rem.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours sa $minutes dk';
    }
    final seconds = rem.inSeconds.remainder(60);
    return '$minutes dk $seconds sn';
  }

  Future<void> loadAdFreeStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryMillis = prefs.getInt('ad_free_until');
      if (expiryMillis != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryMillis);
        if (expiryDate.isAfter(DateTime.now())) {
          _adFreeUntil = expiryDate;
          notifyListeners();
        } else {
          _adFreeUntil = null;
          await prefs.remove('ad_free_until');
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading ad-free status: $e');
    }
  }

  /// Adds ad-free hours (capped at maximum 48 hours from now)
  Future<void> addAdFreeHours([int hours = 24]) async {
    final now = DateTime.now();
    DateTime newExpiry;
    if (isAdFree && _adFreeUntil != null) {
      newExpiry = _adFreeUntil!.add(Duration(hours: hours));
    } else {
      newExpiry = now.add(Duration(hours: hours));
    }

    // Cap at maximum 48 hours from now
    final maxAllowed = now.add(const Duration(hours: 48));
    if (newExpiry.isAfter(maxAllowed)) {
      newExpiry = maxAllowed;
    }

    _adFreeUntil = newExpiry;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('ad_free_until', newExpiry.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error saving ad-free status: $e');
    }
  }

  String get gameId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosGameId;
    }
    return androidGameId;
  }

  String get bannerPlacementId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Banner_iOS';
    }
    return 'Banner_Android';
  }

  String get rewardedPlacementId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Rewarded_iOS';
    }
    return 'Rewarded_Android';
  }

  String get interstitialPlacementId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Interstitial_iOS';
    }
    return 'Interstitial_Android';
  }

  /// Initialize Unity Ads SDK
  Future<void> init({bool testMode = false}) async {
    if (kIsWeb) return;

    try {
      await loadAdFreeStatus();
      await UnityAds.init(
        gameId: gameId,
        testMode: testMode,
        onComplete: () {
          _isInitialized = true;
          _initRetries = 0;
          debugPrint('Unity Ads: Başlatma başarılı (Game ID: $gameId)');
          loadRewardedAd();
          loadInterstitialAd();
          notifyListeners();
        },
        onFailed: (error, message) {
          _isInitialized = false;
          debugPrint('Unity Ads: Başlatma hatası - $error: $message');
          notifyListeners();
          _initRetries++;
          _scheduleRetry(() => init(testMode: testMode), _initRetries);
        },
      );
    } catch (e) {
      debugPrint('Unity Ads Init Exception: $e');
    }
  }

  /// Preload Rewarded Ad
  void loadRewardedAd() {
    if (kIsWeb) return;

    UnityAds.load(
      placementId: rewardedPlacementId,
      onComplete: (placementId) {
        debugPrint('Unity Ads: Ödüllü hazır ($placementId)');
        _isRewardedLoaded = true;
        _rewardedRetries = 0;
        notifyListeners();
      },
      onFailed: (placementId, error, message) {
        debugPrint(
          'Unity Ads: Ödüllü yüklenemedi ($placementId) - $error: $message',
        );
        _isRewardedLoaded = false;
        notifyListeners();
        _rewardedRetries++;
        _scheduleRetry(loadRewardedAd, _rewardedRetries);
      },
    );
  }

  /// Show Rewarded Ad with callbacks
  void showRewardedAd({
    required VoidCallback onReward,
    VoidCallback? onFailed,
    VoidCallback? onSkipped,
    VoidCallback? onStart,
  }) {
    if (kIsWeb) {
      onFailed?.call();
      return;
    }

    if (!_isRewardedLoaded || _isRewardedShowing) {
      loadRewardedAd();
      onFailed?.call();
      return;
    }

    _isRewardedShowing = true;

    UnityAds.showVideoAd(
      placementId: rewardedPlacementId,
      onStart: (placementId) {
        debugPrint('Unity Ads: Ödüllü başladı - $placementId');
        onStart?.call();
      },
      onClick: (placementId) {
        debugPrint('Unity Ads: Ödüllü tıklandı - $placementId');
      },
      onSkipped: (placementId) {
        debugPrint('Unity Ads: Ödüllü atlandı - $placementId');
        _isRewardedShowing = false;
        _isRewardedLoaded = false;
        loadRewardedAd();
        notifyListeners();
        onSkipped?.call();
      },
      onComplete: (placementId) {
        debugPrint('Unity Ads: Ödüllü tamamlandı, ödül veriliyor - $placementId');
        _isRewardedShowing = false;
        _isRewardedLoaded = false;
        loadRewardedAd();
        notifyListeners();
        onReward();
      },
      onFailed: (placementId, error, message) {
        debugPrint(
          'Unity Ads: Ödüllü gösterilemedi ($placementId) - $error: $message',
        );
        _isRewardedShowing = false;
        _isRewardedLoaded = false;
        loadRewardedAd();
        notifyListeners();
        onFailed?.call();
      },
    );
  }

  /// Preload Interstitial Ad
  void loadInterstitialAd() {
    if (kIsWeb) return;

    UnityAds.load(
      placementId: interstitialPlacementId,
      onComplete: (placementId) {
        debugPrint('Unity Ads: Geçiş reklamı hazır ($placementId)');
        _isInterstitialLoaded = true;
        _interstitialRetries = 0;
        notifyListeners();
      },
      onFailed: (placementId, error, message) {
        debugPrint(
          'Unity Ads: Geçiş reklamı yüklenemedi ($placementId) - $error: $message',
        );
        _isInterstitialLoaded = false;
        notifyListeners();
        _interstitialRetries++;
        _scheduleRetry(loadInterstitialAd, _interstitialRetries);
      },
    );
  }

  /// Her 3 basarili okumada bir gecis reklami goster (ad-free'ye saygili).
  void onSuccessfulRead() {
    _successfulReads++;
    if (_successfulReads % 3 == 0) {
      showInterstitialAd();
    }
  }

  /// Show Interstitial Ad
  void showInterstitialAd({
    VoidCallback? onComplete,
    VoidCallback? onFailed,
  }) {
    // If ad-free mode is active, do not display interstitial ad
    if (isAdFree) {
      onComplete?.call();
      return;
    }

    if (kIsWeb || !_isInterstitialLoaded) {
      loadInterstitialAd();
      onFailed?.call();
      return;
    }

    UnityAds.showVideoAd(
      placementId: interstitialPlacementId,
      onComplete: (placementId) {
        _isInterstitialLoaded = false;
        loadInterstitialAd();
        notifyListeners();
        onComplete?.call();
      },
      onSkipped: (placementId) {
        _isInterstitialLoaded = false;
        loadInterstitialAd();
        notifyListeners();
        onComplete?.call();
      },
      onFailed: (placementId, error, message) {
        _isInterstitialLoaded = false;
        loadInterstitialAd();
        notifyListeners();
        onFailed?.call();
      },
    );
  }
}
