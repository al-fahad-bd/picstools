import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class InAppPurchaseService {
  Future<void> initialize();
  bool isProUser();
  Future<bool> purchaseProSubscription();
  Future<bool> restorePurchases();
  Future<bool> checkSubscriptionStatus();
  Future<void> openManageSubscriptions();
}

class InAppPurchaseServiceImpl implements InAppPurchaseService {
  static const String proSubscriptionId = 'picstools_pro_monthly';
  static const String _proPrefKey = 'is_pro_user_cached';
  static const String _playStoreSubUrl =
      'https://play.google.com/store/account/subscriptions?package=com.deltrix.picstools&sku=picstools_pro_monthly';
  static const String _playStoreSubFallbackUrl =
      'https://play.google.com/store/account/subscriptions';
  static const String _appleSubUrl =
      'https://apps.apple.com/account/subscriptions';

  final InAppPurchase _iap = InAppPurchase.instance;
  final SharedPreferences _prefs;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isPro = false;
  Completer<bool>? _pendingPurchaseCompleter;

  InAppPurchaseServiceImpl(this._prefs) {
    _isPro = _prefs.getBool(_proPrefKey) ?? false;
  }

  @override
  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('InAppPurchaseService: Store is not available');
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseDetails,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        debugPrint('InAppPurchaseService error: $error');
        _completePending(false);
      },
    );

    // Initial silent check to verify active subscription status
    try {
      await checkSubscriptionStatus();
    } catch (_) {}
  }

  void _completePending(bool result) {
    if (_pendingPurchaseCompleter != null &&
        !_pendingPurchaseCompleter!.isCompleted) {
      _pendingPurchaseCompleter!.complete(result);
    }
  }

  Future<void> _onPurchaseDetails(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID == proSubscriptionId) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          await _setProUser(true);

          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }

          _completePending(true);
        } else if (purchase.status == PurchaseStatus.error ||
            purchase.status == PurchaseStatus.canceled) {
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          _completePending(false);
        }
      }
    }
  }

  Future<void> _setProUser(bool isPro) async {
    _isPro = isPro;
    await _prefs.setBool(_proPrefKey, isPro);
  }

  @override
  bool isProUser() => _isPro;

  @override
  Future<bool> checkSubscriptionStatus() async {
    final available = await _iap.isAvailable();
    if (!available) {
      return _isPro;
    }

    bool activeProFound = false;
    StreamSubscription<List<PurchaseDetails>>? tempSub;

    try {
      tempSub = _iap.purchaseStream.listen((purchases) {
        for (final purchase in purchases) {
          if (purchase.productID == proSubscriptionId &&
              (purchase.status == PurchaseStatus.purchased ||
                  purchase.status == PurchaseStatus.restored)) {
            activeProFound = true;
          }
        }
      });

      await _iap.restorePurchases();
      // Allow Google Play / StoreKit billing stream time to emit active purchases
      await Future.delayed(const Duration(milliseconds: 1500));
      await tempSub.cancel();

      if (activeProFound) {
        await _setProUser(true);
      } else {
        // No active purchase returned from the store - update cache and state
        await _setProUser(false);
      }
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
      await tempSub?.cancel();
    }

    return _isPro;
  }

  @override
  Future<bool> purchaseProSubscription() async {
    // If already Pro or previously purchased, check status first
    if (_isPro) {
      return true;
    }

    final available = await _iap.isAvailable();
    if (!available) {
      return false;
    }

    final ProductDetailsResponse response =
        await _iap.queryProductDetails({proSubscriptionId});

    if (response.notFoundIDs.contains(proSubscriptionId) ||
        response.productDetails.isEmpty) {
      debugPrint('Product $proSubscriptionId not found in store.');
      return false;
    }

    final ProductDetails productDetails = response.productDetails.first;
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );

    _pendingPurchaseCompleter = Completer<bool>();

    try {
      final buyStarted = await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!buyStarted) {
        return false;
      }

      // Safe timeout so UI spinner does not hang indefinitely if sheet is dismissed
      return await _pendingPurchaseCompleter!.future.timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          return _isPro;
        },
      );
    } catch (e) {
      debugPrint('Purchase error: $e');
      _completePending(false);
      return false;
    }
  }

  @override
  Future<bool> restorePurchases() async {
    return await checkSubscriptionStatus();
  }

  @override
  Future<void> openManageSubscriptions() async {
    try {
      final Uri url;
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        url = Uri.parse(_appleSubUrl);
      } else {
        url = Uri.parse(_playStoreSubUrl);
      }

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        final fallbackUrl = Uri.parse(_playStoreSubFallbackUrl);
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Failed to open subscription manager: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}

class MockInAppPurchaseServiceImpl implements InAppPurchaseService {
  bool _isPro = false;

  @override
  Future<void> initialize() async {}

  @override
  bool isProUser() => _isPro;

  @override
  Future<bool> checkSubscriptionStatus() async => _isPro;

  @override
  Future<bool> purchaseProSubscription() async {
    _isPro = true;
    return true;
  }

  @override
  Future<bool> restorePurchases() async {
    return _isPro;
  }

  @override
  Future<void> openManageSubscriptions() async {}
}
