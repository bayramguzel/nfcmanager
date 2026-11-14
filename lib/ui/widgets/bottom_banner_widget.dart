import 'package:flutter/material.dart';

import 'app_banner_ad.dart';

/// Alt menünün üzerindeki banner alanı.
///
/// Unity banner reklamı yokken [assets/banner.jpg] gösterir,
/// reklam geldiğinde görsel gizlenip reklam gösterilir.
class BottomBannerWidget extends StatelessWidget {
  const BottomBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppBannerAd();
  }
}
