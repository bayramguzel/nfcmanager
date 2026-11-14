import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/platform_support.dart';

/// Uygulama değerlendirme istemi için merkezi servis.
///
/// Davranış:
/// - Uygulama [minUsesBeforePrompt] kez açıldıktan sonra istem gösterilir.
/// - Android'de özel bir diyalog gösterilir ve kullanıcı "Şimdi Değerlendir"
///   butonuna basarsa bir daha asla gösterilmez.
/// - iOS'ta Apple'ın istediği gibi sistem değerlendirme sayfası
///   (SKStoreReviewController) kullanılır; özel diyalog gösterilmez.
/// - Kullanıcı istemi kapatır veya "Daha Sonra" derse [remindMinDays] -
///   [remindMaxDays] gün sonra tekrar gösterilir.
class ReviewService {
  ReviewService._internal();
  static final ReviewService instance = ReviewService._internal();

  /// Google Play paket adı.
  static const String packageId = 'com.software41.nfcmanager';

  /// İstemin gösterilmesi için gereken minimum uygulama açılışı.
  static const int minUsesBeforePrompt = 3;

  /// Erteleme sonrası hatırlatma için minimum gün.
  static const int remindMinDays = 1;

  /// Erteleme sonrası hatırlatma için maksimum gün.
  static const int remindMaxDays = 2;

  static const String _kOpenCount = 'review_open_count';
  static const String _kRated = 'review_rated';
  static const String _kNextPromptAt = 'review_next_prompt_at';

  bool _shouldShow = false;
  bool get shouldShow => _shouldShow;

  /// Uygulama her açılışında bir kez çağrılmalıdır.
  /// Açılış sayacını artırır ve istemin gösterilip gösterilmeyeceğine karar verir.
  Future<void> registerAppOpen() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Kullanıcı zaten oy verdiyse bir daha gösterme.
      if (prefs.getBool(_kRated) ?? false) {
        _shouldShow = false;
        return;
      }

      final count = (prefs.getInt(_kOpenCount) ?? 0) + 1;
      await prefs.setInt(_kOpenCount, count);

      final nextPromptAt = prefs.getInt(_kNextPromptAt) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      _shouldShow = count >= minUsesBeforePrompt && now >= nextPromptAt;
    } catch (e) {
      debugPrint('ReviewService: registerAppOpen error: $e');
      _shouldShow = false;
    }
  }

  /// iOS: sistem değerlendirme istemini (SKStoreReviewController) gösterir.
  /// Apple, uygulama içi oy istemlerinde bu API'nin kullanılmasını bekler.
  Future<bool> requestIosInAppReview() async {
    try {
      final reviewer = InAppReview.instance;
      if (await reviewer.isAvailable()) {
        await reviewer.requestReview();
        return true;
      }
    } catch (e) {
      debugPrint('ReviewService: in-app review error: $e');
    }
    return false;
  }

  /// Kullanıcı değerlendirme butonuna bastığında çağrılır.
  /// İstem bir daha gösterilmez.
  Future<void> markRated() async {
    _shouldShow = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kRated, true);
      await prefs.remove(_kNextPromptAt);
    } catch (e) {
      debugPrint('ReviewService: markRated error: $e');
    }
  }

  /// Kullanıcı istemi kapatır veya "Daha Sonra" derse çağrılır.
  /// 1-2 gün sonra tekrar hatırlatılır.
  Future<void> remindLater() async {
    _shouldShow = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final days =
          remindMinDays + Random().nextInt(remindMaxDays - remindMinDays + 1);
      final nextPromptAt = DateTime.now()
          .add(Duration(days: days))
          .millisecondsSinceEpoch;
      await prefs.setInt(_kNextPromptAt, nextPromptAt);
    } catch (e) {
      debugPrint('ReviewService: remindLater error: $e');
    }
  }

  /// Uygulamanın mağaza sayfasını açar.
  /// Android'de önce Play Store uygulaması (market://) denenir; iOS'ta App Store
  /// sayfası açılır ve App Store kimliği henüz tanımlı değilse siteye düşer.
  Future<void> openStoreListing() async {
    if (AppPlatform.isIOS) {
      if (await requestIosInAppReview()) return;

      try {
        await launchUrl(
          Uri.parse(AppPlatform.appStoreUrl),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        debugPrint('ReviewService: app store launch error: $e');
      }
      return;
    }

    final marketUri = Uri.parse(
      'market://details?id=$packageId&showAllReviews=true',
    );
    final webUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageId&showAllReviews=true',
    );

    // 1) Google Play uygulamasını doğrudan aç.
    try {
      final opened = await launchUrl(
        marketUri,
        mode: LaunchMode.externalApplication,
      );
      if (opened) return;
    } catch (e) {
      debugPrint('ReviewService: market launch error: $e');
    }

    // 2) Play Store yoksa tarayıcıda aç.
    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('ReviewService: web launch error: $e');
    }
  }
}
