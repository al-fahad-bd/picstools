abstract class AdService {
  Future<void> initialize();
  bool isAdSupported();
  Future<void> showInterstitialAd({required String placement});
  Future<void> showRewardedAd({required String placement, required Function onRewardEarned});
}

class MockAdServiceImpl implements AdService {
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  bool isAdSupported() => _initialized;

  @override
  Future<void> showInterstitialAd({required String placement}) async {
    // Modular interstitial ad trigger boundary
  }

  @override
  Future<void> showRewardedAd({required String placement, required Function onRewardEarned}) async {
    // Modular rewarded ad callback
    onRewardEarned();
  }
}
