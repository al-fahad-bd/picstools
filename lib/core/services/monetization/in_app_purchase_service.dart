import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class InAppPurchaseService {
  Future<void> initialize();
  bool isProUser();
  Future<bool> purchaseProSubscription();
  Future<bool> restorePurchases();
}

class InAppPurchaseServiceImpl implements InAppPurchaseService {
  static const String proSubscriptionId = 'picstools_pro_monthly';
  static const String _proPrefKey = 'is_pro_user_cached';

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
        if (_pendingPurchaseCompleter != null &&
            !_pendingPurchaseCompleter!.isCompleted) {
          _pendingPurchaseCompleter!.complete(false);
        }
      },
    );
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

          if (_pendingPurchaseCompleter != null &&
              !_pendingPurchaseCompleter!.isCompleted) {
            _pendingPurchaseCompleter!.complete(true);
          }
        } else if (purchase.status == PurchaseStatus.error ||
            purchase.status == PurchaseStatus.canceled) {
          if (_pendingPurchaseCompleter != null &&
              !_pendingPurchaseCompleter!.isCompleted) {
            _pendingPurchaseCompleter!.complete(false);
          }
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
  Future<bool> purchaseProSubscription() async {
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
    final buyStarted = await _iap.buyNonConsumable(
      purchaseParam: purchaseParam,
    );

    if (!buyStarted) {
      return false;
    }

    return _pendingPurchaseCompleter!.future.timeout(
      const Duration(minutes: 3),
      onTimeout: () => false,
    );
  }

  @override
  Future<bool> restorePurchases() async {
    final available = await _iap.isAvailable();
    if (!available) {
      return false;
    }

    try {
      await _iap.restorePurchases();
      return _isPro;
    } catch (e) {
      debugPrint('Failed to restore purchases: $e');
      return false;
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
  Future<bool> purchaseProSubscription() async {
    _isPro = true;
    return true;
  }

  @override
  Future<bool> restorePurchases() async {
    return _isPro;
  }
}
