import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import '../../services/ad_service.dart';

/// Unity LevelPlay banner reklamını gösteren ortak widget.
///
/// Davranış:
/// - Unity banner'ı yüklenene kadar [assets/banner.jpg] gösterilir.
/// - Reklam geldiğinde (onLoad) promosyon görseli gizlenir, reklam görünür.
/// - Reklam yüklenemezse görsel gösterilmeye devam eder ve reklam yeniden denenir.
/// - Reklamsız mod aktifse hiçbir şey gösterilmez (reklamsız sözüne saygı).
class AppBannerAd extends StatefulWidget {
  /// Reklam yokken assets/banner.jpg gösterilsin mi?
  final bool showAssetFallback;

  /// Banner yüksekliği (piksel).
  final double height;

  const AppBannerAd({
    super.key,
    this.showAssetFallback = true,
    this.height = 52,
  });

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  bool _bannerLoaded = false;
  int _retryKey = 0;
  Timer? _retryTimer;

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _retryKey++;
        });
      }
    });
  }

  Widget _buildFallbackImage() {
    return Image.asset(
      'assets/banner.jpg',
      width: double.infinity,
      height: widget.height,
      fit: BoxFit.fill,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const SizedBox.shrink();
    }

    return ListenableBuilder(
      listenable: AdService.instance,
      builder: (context, _) {
        // Reklamsız mod: hiçbir banner gösterilme.
        if (AdService.instance.isAdFree) {
          _bannerLoaded = false;
          return const SizedBox.shrink();
        }

        // Unity henüz başlamadı: promosyon görseli göster.
        if (!AdService.instance.isInitialized) {
          _bannerLoaded = false;
          return widget.showAssetFallback
              ? _buildFallbackImage()
              : const SizedBox.shrink();
        }

        return SizedBox(
          width: double.infinity,
          height: widget.height,
          child: Stack(
            children: [
              // Reklam kendi doğal boyutunda, ortalanmış olarak yüklenir.
              Positioned.fill(
                child: Center(
                  child: UnityBannerAd(
                    key: ValueKey('banner_$_retryKey'),
                    placementId: AdService.instance.bannerPlacementId,
                    size: BannerSize.standard,
                    onLoad: (placementId) {
                      debugPrint('Unity Banner yüklendi: $placementId');
                      if (mounted) {
                        setState(() {
                          _bannerLoaded = true;
                        });
                      }
                    },
                    onClick: (placementId) {
                      debugPrint('Unity Banner tıklandı: $placementId');
                    },
                    onFailed: (placementId, error, message) {
                      debugPrint(
                        'Unity Banner yüklenemedi: $placementId - $error: $message',
                      );
                      if (mounted) {
                        setState(() {
                          _bannerLoaded = false;
                        });
                      }
                      _scheduleRetry();
                    },
                  ),
                ),
              ),
              // Reklam gelene kadar görsel; reklam gelince gizlenir.
              if (!_bannerLoaded && widget.showAssetFallback)
                Positioned.fill(child: _buildFallbackImage()),
            ],
          ),
        );
      },
    );
  }
}
