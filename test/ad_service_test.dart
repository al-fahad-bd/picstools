import 'package:flutter_test/flutter_test.dart';
import 'package:picstools/core/services/monetization/ad_service.dart';
import 'package:picstools/core/services/monetization/in_app_purchase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdService Anti-Ban Safeguards & Pro Gatekeeper Tests', () {
    late MockInAppPurchaseServiceImpl mockIap;
    late AdServiceImpl adService;

    setUp(() {
      mockIap = MockInAppPurchaseServiceImpl();
      adService = AdServiceImpl(mockIap);
    });

    test('Free users receive ads (shouldShowAds == true)', () {
      mockIap.setProForTesting(false);
      expect(adService.shouldShowAds(), isTrue);
    });

    test('Pro users NEVER receive ads (shouldShowAds == false)', () {
      mockIap.setProForTesting(true);
      expect(adService.shouldShowAds(), isFalse);
    });

    test('Debug/testing mode ALWAYS returns official Google Test Ad Unit IDs', () {
      // Official Google Sample Ad Unit IDs for Banner
      expect(
        adService.bannerAdUnitId,
        anyOf(
          equals('ca-app-pub-3940256099942544/6300978111'), // Android
          equals('ca-app-pub-3940256099942544/2934735716'), // iOS
        ),
      );

      // Official Google Sample Ad Unit IDs for Interstitial
      expect(
        adService.interstitialAdUnitId,
        anyOf(
          equals('ca-app-pub-3940256099942544/1033173712'), // Android
          equals('ca-app-pub-3940256099942544/4411468910'), // iOS
        ),
      );

      // Official Google Sample Ad Unit IDs for Rewarded Interstitial
      expect(
        adService.rewardedAdUnitId,
        anyOf(
          equals('ca-app-pub-3940256099942544/5354046379'), // Android
          equals('ca-app-pub-3940256099942544/6978759866'), // iOS
        ),
      );
    });

    test('showRewardedAd immediately rewards Pro users without showing ad', () async {
      mockIap.setProForTesting(true);
      bool rewarded = false;
      await adService.showRewardedAd(
        onRewarded: () {
          rewarded = true;
        },
      );
      expect(rewarded, isTrue);
    });

    test('MockAdService correctly handles rewarded ads for tests', () async {
      final mockAdService = MockAdServiceImpl();
      bool rewarded = false;
      await mockAdService.showRewardedAd(
        onRewarded: () {
          rewarded = true;
        },
      );
      expect(rewarded, isTrue);
    });
  });
}
