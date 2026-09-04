import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob configuration and helpers.
///
/// The AdMob App ID and ad unit IDs are NOT secrets: they are embedded in every
/// release APK and are publicly discoverable by design. They are safe to commit.
class AdService {
  AdService._();

  /// Live banner ad unit (used on Settings and Day screens).
  static const String _liveBannerAdUnitId =
      'ca-app-pub-8594021229417102/7771230067';

  /// Google's public test banner unit. Always returns a test ad so the
  /// banner can be verified during development without spending live fill.
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/9214589741';

  /// Banner ad unit to use: the live unit in release builds, Google's test
  /// unit in debug/profile builds so the test ID can never be shipped.
  static String get bannerAdUnitId =>
      kReleaseMode ? _liveBannerAdUnitId : _testBannerAdUnitId;

  /// Native Advanced ad unit. Reserved for future use.
  // static const String nativeAdUnitId =
  //     'ca-app-pub-8594021229417102/7101041027';

  static bool _initialized = false;

  /// Initializes the Mobile Ads SDK once. Safe to call multiple times.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await MobileAds.instance.initialize();
    } catch (_) {
      // Ads are best-effort; the app must never crash if ad init fails.
    }
  }

  /// Returns an anchored adaptive banner size that matches the current
  /// screen width (in logical pixels), or the standard banner size if
  /// adaptive sizing is unavailable.
  static Future<AdSize> adaptiveBannerSize(int width) async {
    try {
      final size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            width,
          );
      return size ?? AdSize.banner;
    } catch (_) {
      return AdSize.banner;
    }
  }
}
