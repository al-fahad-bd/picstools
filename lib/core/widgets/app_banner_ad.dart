import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/service_locator.dart';
import '../services/monetization/ad_service.dart';
import '../services/monetization/in_app_purchase_service.dart';

class AppBannerAd extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsetsGeometry margin;

  const AppBannerAd({
    super.key,
    this.adSize = AdSize.banner,
    this.margin = const EdgeInsets.symmetric(vertical: 4.0),
  });

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _hasFailed = false;

  @override
  void initState() {
    super.initState();
    getIt<InAppPurchaseService>().isProListenable.addListener(
      _onProStatusChanged,
    );
    _initAndLoadAd();
  }

  void _onProStatusChanged() {
    final isPro = getIt<InAppPurchaseService>().isProUser();
    if (isPro) {
      // User is now Pro: immediately dispose and clear any active banner
      _bannerAd?.dispose();
      _bannerAd = null;
      if (mounted) {
        setState(() {
          _isLoaded = false;
          _hasFailed = false;
        });
      }
    } else if (_bannerAd == null) {
      // User reverted to Free: load banner ad
      _initAndLoadAd();
    }
  }

  void _initAndLoadAd() {
    final adService = getIt<AdService>();
    if (!adService.shouldShowAds()) {
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: adService.bannerAdUnitId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _hasFailed = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ [AppBannerAd] Banner failed to load: ${error.message}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isLoaded = false;
              _hasFailed = true;
              _bannerAd = null;
            });
          }
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    getIt<InAppPurchaseService>().isProListenable.removeListener(
      _onProStatusChanged,
    );
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adService = getIt<AdService>();
    if (!adService.shouldShowAds() ||
        _hasFailed ||
        _bannerAd == null ||
        !_isLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin,
      alignment: Alignment.center,
      child: SizedBox(
        width: widget.adSize.width.toDouble(),
        height: widget.adSize.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
