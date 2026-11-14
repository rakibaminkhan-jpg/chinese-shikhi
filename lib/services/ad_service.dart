import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Google sample test ad unit ID. Replace with your own AdMob ID only
  // after the app is approved and you are ready for production testing.
  static const String _androidBannerTestId =
      'ca-app-pub-3940256099942544/6300978111';

  static String get bannerUnitId {
    if (kIsWeb) return '';
    return _androidBannerTestId;
  }

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }
}
