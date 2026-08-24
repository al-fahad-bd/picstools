import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/neo_colors.dart';
import '../services/service_locator.dart';
import '../services/monetization/ad_service.dart';
import '../services/monetization/in_app_purchase_service.dart';

class AppNativeAd extends StatefulWidget {
  final TemplateType templateType;
  final EdgeInsetsGeometry margin;

  const AppNativeAd({
    super.key,
    this.templateType = TemplateType.medium,
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
  });

  @override
  State<AppNativeAd> createState() => _AppNativeAdState();
}

class _AppNativeAdState extends State<AppNativeAd> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _hasFailed = false;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    getIt<InAppPurchaseService>().isProListenable.addListener(
      _onProStatusChanged,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_nativeAd == null && !_hasFailed) {
      _initAndLoadAd();
    }
  }

  void _onProStatusChanged() {
    final isPro = getIt<InAppPurchaseService>().isProUser();
    if (isPro) {
      _nativeAd?.dispose();
      _nativeAd = null;
      if (mounted) {
        setState(() {
          _isLoaded = false;
          _hasFailed = false;
        });
      }
    } else if (_nativeAd == null) {
      _initAndLoadAd();
    }
  }

  void _initAndLoadAd() {
    final adService = getIt<AdService>();
    if (!adService.shouldShowAds()) {
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    _nativeAd = NativeAd(
      adUnitId: adService.nativeAdUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.templateType,
        mainBackgroundColor: isDark
            ? NeoColors.darkSurface
            : NeoColors.lightSurface,
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: NeoColors.purple,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: isDark ? Colors.white : NeoColors.borderLight,
          style: NativeTemplateFontStyle.bold,
          size: 15.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: isDark ? Colors.white70 : Colors.black87,
          style: NativeTemplateFontStyle.normal,
          size: 13.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: isDark ? Colors.white54 : Colors.black54,
          style: NativeTemplateFontStyle.normal,
          size: 11.0,
        ),
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _hasFailed = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            '❌ [AppNativeAd] Native Ad failed to load: ${error.message}',
          );
          ad.dispose();
          if (mounted) {
            setState(() {
              _isLoaded = false;
              _hasFailed = true;
              _nativeAd = null;
            });
          }
        },
      ),
    );

    _nativeAd?.load();
  }

  @override
  void dispose() {
    getIt<InAppPurchaseService>().isProListenable.removeListener(
      _onProStatusChanged,
    );
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adService = getIt<AdService>();
    if (!adService.shouldShowAds() ||
        _hasFailed ||
        !_isLoaded ||
        _isDismissed ||
        _nativeAd == null) {
      return const SizedBox.shrink();
    }

    final double height = widget.templateType == TemplateType.medium
        ? 320
        : 100;

    return Padding(
      padding: widget.margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            SizedBox(
              height: height,
              child: AdWidget(ad: _nativeAd!),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isDismissed = true;
                    });
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
