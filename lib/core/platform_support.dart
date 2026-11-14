import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Platform differences that keep the iOS build inside Apple's guidelines
/// while leaving the Android build untouched.
class AppPlatform {
  AppPlatform._();

  // Uses Flutter's target platform instead of dart:io so the iOS branches are
  // testable with `debugDefaultTargetPlatformOverride` and stay web-safe.
  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Android application id (also used by the Google Play listing).
  static const String androidPackageId = 'com.software41.nfcmanager';

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$androidPackageId';

  static const String websiteUrl = 'https://www.41software.com';

  /// Numeric App Store id from App Store Connect.
  ///
  /// Set this once the iOS app exists in App Store Connect; while it is empty
  /// the app falls back to the website instead of sharing a broken store link.
  static const String appStoreId = '';

  static String get appStoreUrl => appStoreId.isEmpty
      ? websiteUrl
      : 'https://apps.apple.com/app/id$appStoreId';

  static bool get hasAppStoreUrl => appStoreId.isNotEmpty;

  /// The localized "share the app" text ships with a Google Play link, which is
  /// meaningless (and review-unfriendly) inside an iOS app.
  static String shareTextFor(String localizedText) {
    if (!isIOS) return localizedText;
    return localizedText.replaceAll(playStoreUrl, appStoreUrl);
  }

  /// iPad requires an anchor rectangle for share sheets; `null` keeps the
  /// iPhone and Android behaviour unchanged.
  static Rect? shareOrigin(BuildContext context) {
    if (!isIOS) return null;
    final box = context.findRenderObject();
    if (box is RenderBox && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    final overlay = Overlay.maybeOf(context)?.context.findRenderObject();
    if (overlay is RenderBox && overlay.hasSize) {
      return overlay.localToGlobal(Offset.zero) & overlay.size;
    }
    return null;
  }
}
