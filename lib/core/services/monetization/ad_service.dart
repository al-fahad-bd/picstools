import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'in_app_purchase_service.dart';

abstract class AdService {
  Future<void> initialize();
  bool shouldShowAds();
  String get bannerAdUnitId;
  String get interstitialAdUnitId;
  String get rewardedAdUnitId;
  String get nativeAdUnitId;
  Future<void> loadInterstitialAd();
  Future<void> showInterstitialAd({VoidCallback? onDismissed});
  Future<void> loadRewardedAd();
  Future<void> showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onDismissed,
  });
}

class AdServiceImpl implements AdService {
  final InAppPurchaseService _iapService;

  // ---------------------------------------------------------------------------
  // Google Official Test Ad Unit IDs (Guaranteed safe against AdMob bans)
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  // ---------------------------------------------------------------------------
  static const String _androidTestBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosTestBannerId =
      'ca-app-pub-3940256099942544/2934735716';

  static const String _androidTestInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _iosTestInterstitialId =
      'ca-app-pub-3940256099942544/4411468910';

  static const String _androidTestNativeId =
      'ca-app-pub-3940256099942544/2247696110';
  static const String _iosTestNativeId =
      'ca-app-pub-3940256099942544/3986624511';

  // Rewarded Interstitial format (No "Reward: 10 coins" or "Reward granted" game popups)
  static const String _androidTestRewardedId =
      'ca-app-pub-3940256099942544/5354046379';
  static const String _iosTestRewardedId =
      'ca-app-pub-3940256099942544/6978759866';

  // Production Ad Unit IDs (Configure when ready for store release)
  static const String _prodAndroidBannerId =
      'ca-app-pub-2023704770887121/4039751072';
  static const String? _prodIosBannerId = null;
  static const String _prodAndroidInterstitialId =
      'ca-app-pub-2023704770887121/8378451332';
  static const String? _prodIosInterstitialId = null;
  static const String _prodAndroidNativeId =
      'ca-app-pub-2023704770887121/5442181287';
  static const String? _prodIosNativeId = null;
  static const String? _prodAndroidRewardedId = null;
  static const String? _prodIosRewardedId = null;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isRewardedLoading = false;

  bool _isInitialized = false;

  AdServiceImpl(this._iapService);

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      debugPrint('📢 [AdService] Initializing Google Mobile Ads SDK...');
      await MobileAds.instance.initialize();

      // Configure test device policy to protect developer AdMob accounts
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: <String>[
            // Test device IDs can be registered here if needed
          ],
        ),
      );
      _isInitialized = true;
      debugPrint(
        '📢 [AdService] Google Mobile Ads SDK initialized successfully.',
      );

      // Preload the ads so they are immediately available
      if (shouldShowAds()) {
        loadInterstitialAd();
        loadRewardedAd();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [AdService] MobileAds initialization failed: $e');
      debugPrint('❌ [AdService] StackTrace: $stackTrace');
    }
  }

  /// Gatekeeper: Never show ads to Pro users or if ads disabled
  @override
  bool shouldShowAds() {
    // If user has unlocked Pro subscription, NEVER show any ads
    if (_iapService.isProUser()) {
      return false;
    }
    return true;
  }

  /// Strict Anti-Ban Guardrail:
  /// Always returns official Google test ad unit IDs in debug mode,
  /// or when production ad unit IDs are not yet configured.
  @override
  String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid ? _androidTestBannerId : _iosTestBannerId;
    }
    if (Platform.isAndroid) {
      return _prodAndroidBannerId;
    }
    return _prodIosBannerId ?? _iosTestBannerId;
  }

  @override
  String get interstitialAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? _androidTestInterstitialId
          : _iosTestInterstitialId;
    }
    if (Platform.isAndroid) {
      return _prodAndroidInterstitialId;
    }
    return _prodIosInterstitialId ?? _iosTestInterstitialId;
  }

  @override
  String get rewardedAdUnitId {
    if (kDebugMode ||
        _prodAndroidRewardedId == null ||
        _prodIosRewardedId == null) {
      return Platform.isAndroid ? _androidTestRewardedId : _iosTestRewardedId;
    }
    return Platform.isAndroid ? _prodAndroidRewardedId! : _prodIosRewardedId!;
  }

  @override
  String get nativeAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid ? _androidTestNativeId : _iosTestNativeId;
    }
    if (Platform.isAndroid) {
      return _prodAndroidNativeId;
    }
    return _prodIosNativeId ?? _iosTestNativeId;
  }

  @override
  Future<void> loadInterstitialAd() async {
    if (!shouldShowAds() || _isInterstitialLoading || _interstitialAd != null) {
      return;
    }

    _isInterstitialLoading = true;
    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('📢 [AdService] Interstitial Ad loaded successfully.');
            _interstitialAd = ad;
            _isInterstitialLoading = false;
          },
          onAdFailedToLoad: (error) {
            debugPrint(
              '❌ [AdService] Interstitial Ad failed to load: ${error.message}',
            );
            _interstitialAd = null;
            _isInterstitialLoading = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ [AdService] Error loading interstitial: $e');
      _isInterstitialLoading = false;
    }
  }

  @override
  Future<void> showInterstitialAd({VoidCallback? onDismissed}) async {
    if (!shouldShowAds()) {
      onDismissed?.call();
      return;
    }

    if (_interstitialAd == null) {
      onDismissed?.call();
      loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('📢 [AdService] Interstitial Ad dismissed.');
        ad.dispose();
        _interstitialAd = null;
        onDismissed?.call();
        loadInterstitialAd(); // Preload next
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
          '❌ [AdService] Interstitial Ad failed to show: ${error.message}',
        );
        ad.dispose();
        _interstitialAd = null;
        onDismissed?.call();
        loadInterstitialAd();
      },
    );

    await _interstitialAd!.show();
  }

  @override
  Future<void> loadRewardedAd() async {
    if (!shouldShowAds() ||
        _isRewardedLoading ||
        _rewardedInterstitialAd != null) {
      return;
    }

    _isRewardedLoading = true;
    try {
      await RewardedInterstitialAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint(
              '📢 [AdService] Rewarded Interstitial Ad loaded successfully.',
            );
            _rewardedInterstitialAd = ad;
            _isRewardedLoading = false;
          },
          onAdFailedToLoad: (error) {
            debugPrint(
              '❌ [AdService] Rewarded Interstitial Ad failed to load: ${error.message}',
            );
            _rewardedInterstitialAd = null;
            _isRewardedLoading = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ [AdService] Error loading rewarded interstitial ad: $e');
      _isRewardedLoading = false;
    }
  }

  @override
  Future<void> showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onDismissed,
  }) async {
    if (!shouldShowAds()) {
      onRewarded();
      onDismissed?.call();
      return;
    }

    if (_rewardedInterstitialAd == null) {
      // If not yet loaded or offline, proceed with download gracefully and preload next
      onRewarded();
      onDismissed?.call();
      loadRewardedAd();
      return;
    }

    bool earnedReward = false;
    _rewardedInterstitialAd!
        .fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('📢 [AdService] Rewarded Interstitial Ad dismissed.');
        ad.dispose();
        _rewardedInterstitialAd = null;
        if (earnedReward) {
          onRewarded();
        }
        onDismissed?.call();
        loadRewardedAd(); // Preload next
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
          '❌ [AdService] Rewarded Interstitial Ad failed to show: ${error.message}',
        );
        ad.dispose();
        _rewardedInterstitialAd = null;
        onRewarded(); // Graceful fallback
        onDismissed?.call();
        loadRewardedAd();
      },
    );

    await _rewardedInterstitialAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('🎉 [AdService] Rewarded ad completed cleanly.');
        earnedReward = true;
      },
    );
  }
}

class MockAdServiceImpl implements AdService {
  @override
  Future<void> initialize() async {}

  @override
  bool shouldShowAds() => false;

  @override
  String get bannerAdUnitId => 'mock_banner_unit_id';

  @override
  String get interstitialAdUnitId => 'mock_interstitial_unit_id';

  @override
  String get rewardedAdUnitId => 'mock_rewarded_unit_id';

  @override
  String get nativeAdUnitId => 'mock_native_unit_id';

  @override
  Future<void> loadInterstitialAd() async {}

  @override
  Future<void> showInterstitialAd({VoidCallback? onDismissed}) async {
    onDismissed?.call();
  }

  @override
  Future<void> loadRewardedAd() async {}

  @override
  Future<void> showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onDismissed,
  }) async {
    onRewarded();
    onDismissed?.call();
  }
}
