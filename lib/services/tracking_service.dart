import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';

import '../core/platform_support.dart';

/// App Tracking Transparency (iOS 14+).
///
/// Unity Ads reads the IDFA for personalised ads, so Apple requires the
/// permission prompt to be shown before any ad SDK is initialised. Android has
/// no equivalent requirement and is skipped entirely.
class TrackingService {
  TrackingService._();

  static Future<void> requestIfNeeded() async {
    if (!AppPlatform.isIOS) return;

    try {
      var status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        // Wait for the first frame so the prompt is not presented over a blank
        // window (iOS drops prompts requested while the app is not active).
        await Future<void>.delayed(const Duration(milliseconds: 400));
        status = await AppTrackingTransparency.requestTrackingAuthorization();
      }
      debugPrint('ATT status: $status');
    } catch (e) {
      // Tracking is optional: ads still load in non-personalised mode.
      debugPrint('ATT request failed: $e');
    }
  }
}
