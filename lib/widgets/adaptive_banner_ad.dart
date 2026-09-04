import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:maala_app/services/ad_service.dart';
import 'package:maala_app/services/theme_service.dart';
import 'package:maala_app/theme/app_theme.dart';

/// An anchored adaptive banner ad that blends with the app's dark theme.
///
/// It loads a real banner on devices/accounts that serve ads and renders
/// nothing when there is no fill, so ad failures never break the layout.
class AdaptiveBannerAd extends StatefulWidget {
  const AdaptiveBannerAd({super.key});

  @override
  State<AdaptiveBannerAd> createState() => _AdaptiveBannerAdState();
}

class _AdaptiveBannerAdState extends State<AdaptiveBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _failed = false;
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reading MediaQuery here (not in initState) is required: accessing an
    // inherited widget before initState completes throws a Flutter error.
    if (!_loadStarted) {
      _loadStarted = true;
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    final width = MediaQuery.of(context).size.width;
    try {
      final size = await AdService.adaptiveBannerSize(width.toInt());
      final ad = BannerAd(
        adUnitId: AdService.bannerAdUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted) return;
            setState(() {
              _isLoaded = true;
              _bannerAd = ad as BannerAd;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (!mounted) return;
            setState(() {
              _failed = true;
            });
          },
        ),
      );
      await ad.load();
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.current;

    if (_isLoaded && _bannerAd != null) {
      // Constrain the platform view to the ad's real size. Leaving the
      // AdWidget with an unbounded height (e.g. inside a Column with a
      // Spacer) triggers a "_PlatformViewPlaceholderBox ... infinite size"
      // layout error, so the height must be fixed here.
      final adHeight = _bannerAd!.size.height;
      return Center(
        child: Container(
          height: adHeight.toDouble(),
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadii.medium),
            border: Border.all(color: theme.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }

    if (_failed) {
      // No fill (e.g. test device / not yet approved). Reserve nothing.
      return const SizedBox.shrink();
    }

    // Loading placeholder keeps the layout stable while the ad loads.
    return Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.surfaceElevated.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadii.medium),
        border: Border.all(color: theme.border),
      ),
    );
  }
}
