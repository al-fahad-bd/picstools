import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/widgets.dart';

class ProSubscriptionPricing {
  final String annualPriceFormatted;
  final String annualPerMonthFormatted;
  final String monthlyPriceFormatted;
  final double? annualRawPrice;
  final double? monthlyRawPrice;
  final String currencySymbol;
  final String currencyCode;

  const ProSubscriptionPricing({
    this.annualPriceFormatted = r'$17.99',
    this.annualPerMonthFormatted = r'$1.49',
    this.monthlyPriceFormatted = r'$2.99',
    this.annualRawPrice,
    this.monthlyRawPrice,
    this.currencySymbol = r'$',
    this.currencyCode = 'USD',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProSubscriptionPricing &&
          runtimeType == other.runtimeType &&
          annualPriceFormatted == other.annualPriceFormatted &&
          annualPerMonthFormatted == other.annualPerMonthFormatted &&
          monthlyPriceFormatted == other.monthlyPriceFormatted &&
          currencySymbol == other.currencySymbol &&
          currencyCode == other.currencyCode;

  @override
  int get hashCode =>
      annualPriceFormatted.hashCode ^
      annualPerMonthFormatted.hashCode ^
      monthlyPriceFormatted.hashCode ^
      currencySymbol.hashCode ^
      currencyCode.hashCode;
}

abstract class InAppPurchaseService {
  Future<void> initialize();
  bool isProUser();
  void refreshProStatus();
  ValueListenable<bool> get isProListenable;
  Future<bool> purchaseProSubscription({String? productId});
  Future<bool> restorePurchases();
  Future<bool> checkSubscriptionStatus();
  Future<void> openManageSubscriptions();
  Future<ProSubscriptionPricing> getSubscriptionPricing();
  ProSubscriptionPricing get currentPricing;
}

class InAppPurchaseServiceImpl
    with WidgetsBindingObserver
    implements InAppPurchaseService {
  static const String proMonthlySubscriptionId = 'picstools_pro_monthly';
  static const String proYearlySubscriptionId = 'picstools_pro_yearly';
  static const String proSubscriptionId = proMonthlySubscriptionId;
  static const Set<String> allProSubscriptionIds = {
    proMonthlySubscriptionId,
    proYearlySubscriptionId,
  };
  static const String _proPrefKey = 'is_pro_user_cached';
  static const String _playStoreSubUrl =
      'https://play.google.com/store/account/subscriptions?package=com.deltrix.picstools';
  static const String _playStoreSubFallbackUrl =
      'https://play.google.com/store/account/subscriptions';
  static const String _appleSubUrl =
      'https://apps.apple.com/account/subscriptions';

  final InAppPurchase _iap = InAppPurchase.instance;
  final SharedPreferences _prefs;
  final ValueNotifier<bool> _isProNotifier = ValueNotifier<bool>(false);
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isPro = false;
  bool _isSilentChecking = false;
  Completer<bool>? _pendingPurchaseCompleter;

  InAppPurchaseServiceImpl(this._prefs) {
    _isPro = _prefs.getBool(_proPrefKey) ?? false;
    _isProNotifier.value = isProUser();
  }

  @override
  void refreshProStatus() {
    _isProNotifier.value = isProUser();
  }

  @override
  ValueListenable<bool> get isProListenable => _isProNotifier;

  @override
  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);

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

    // Pre-fetch localized pricing so it is ready instantly when paywall opens
    try {
      await getSubscriptionPricing();
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_pendingPurchaseCompleter != null &&
          !_pendingPurchaseCompleter!.isCompleted) {
        // User returned to the app (dismissed Google Play bottom sheet by outside tap or back)
        // Allow a brief 800ms window for any incoming billing stream event
        Future.delayed(const Duration(milliseconds: 800), () {
          if (_pendingPurchaseCompleter != null &&
              !_pendingPurchaseCompleter!.isCompleted) {
            _completePending(_isPro);
          }
        });
      }

      // Automatically verify active subscription in background upon returning to app
      _silentCheckSubscription();
    }
  }

  Future<void> _silentCheckSubscription() async {
    if (_isSilentChecking) return;
    _isSilentChecking = true;
    try {
      debugPrint(
        '🔄 [InAppPurchaseService] App resumed. Verifying subscription status with store...',
      );
      await checkSubscriptionStatus();
    } catch (e) {
      debugPrint(
        '❌ [InAppPurchaseService] Error during silent subscription check on resume: $e',
      );
    } finally {
      _isSilentChecking = false;
    }
  }

  void _completePending(bool result) {
    if (_pendingPurchaseCompleter != null &&
        !_pendingPurchaseCompleter!.isCompleted) {
      _pendingPurchaseCompleter!.complete(result);
    }
  }

  Future<void> _onPurchaseDetails(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (allProSubscriptionIds.contains(purchase.productID) ||
          purchase.productID == proSubscriptionId) {
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
    final hasChanged = _isPro != isPro;
    _isPro = isPro;
    _isProNotifier.value = isPro;
    await _prefs.setBool(_proPrefKey, isPro);
    if (hasChanged) {
      debugPrint(
        '📢 [InAppPurchaseService] Pro status updated: isPro = $isPro',
      );
    }
  }

  @override
  bool isProUser() {
    if (_isPro) return true;
    try {
      final vipStartTime = _prefs.getInt('vip_gift_start_time');
      if (vipStartTime != null) {
        final startTime = DateTime.fromMillisecondsSinceEpoch(vipStartTime);
        if (DateTime.now().difference(startTime).inHours < 24) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

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
          if ((allProSubscriptionIds.contains(purchase.productID) ||
                  purchase.productID == proSubscriptionId) &&
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
  Future<bool> purchaseProSubscription({String? productId}) async {
    // If already Pro or previously purchased, check status first
    if (_isPro) {
      return true;
    }

    final available = await _iap.isAvailable();
    if (!available) {
      return false;
    }

    final targetId = productId ?? proYearlySubscriptionId;

    final ProductDetailsResponse response = await _iap.queryProductDetails({
      targetId,
    });

    if (response.notFoundIDs.contains(targetId) ||
        response.productDetails.isEmpty) {
      debugPrint('Product $targetId not found in store.');
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
        const Duration(seconds: 8),
        onTimeout: () {
          _completePending(_isPro);
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

  ProSubscriptionPricing _cachedPricing = const ProSubscriptionPricing();

  @override
  Future<ProSubscriptionPricing> getSubscriptionPricing() async {
    if (_cachedPricing.annualRawPrice != null &&
        _cachedPricing.monthlyRawPrice != null) {
      return _cachedPricing;
    }

    try {
      final available = await _iap.isAvailable();
      if (!available) {
        return _cachedPricing;
      }

      final ProductDetailsResponse response = await _iap.queryProductDetails(
        allProSubscriptionIds,
      );

      if (response.productDetails.isNotEmpty) {
        ProductDetails? yearly;
        ProductDetails? monthly;

        for (final product in response.productDetails) {
          if (product.id == proYearlySubscriptionId) {
            yearly = product;
          } else if (product.id == proMonthlySubscriptionId) {
            monthly = product;
          }
        }

        String annualFormatted = _cachedPricing.annualPriceFormatted;
        String annualPerMonthFormatted = _cachedPricing.annualPerMonthFormatted;
        String monthlyFormatted = _cachedPricing.monthlyPriceFormatted;
        String symbol = _cachedPricing.currencySymbol;
        String code = _cachedPricing.currencyCode;

        if (yearly != null) {
          annualFormatted = yearly.price;
          symbol = yearly.currencySymbol.isNotEmpty
              ? yearly.currencySymbol
              : yearly.currencyCode;
          code = yearly.currencyCode;

          final perMonth = yearly.rawPrice / 12.0;
          final formattedPerMonthNum = perMonth >= 100
              ? perMonth.toStringAsFixed(0)
              : perMonth.toStringAsFixed(2);

          if (yearly.price.trim().startsWith(symbol)) {
            annualPerMonthFormatted = '$symbol$formattedPerMonthNum';
          } else if (yearly.price.trim().endsWith(symbol)) {
            annualPerMonthFormatted = '$formattedPerMonthNum$symbol';
          } else {
            annualPerMonthFormatted = '$symbol$formattedPerMonthNum';
          }
        }

        if (monthly != null) {
          monthlyFormatted = monthly.price;
          if (symbol == r'$') {
            symbol = monthly.currencySymbol.isNotEmpty
                ? monthly.currencySymbol
                : monthly.currencyCode;
            code = monthly.currencyCode;
          }
        }

        _cachedPricing = ProSubscriptionPricing(
          annualPriceFormatted: annualFormatted,
          annualPerMonthFormatted: annualPerMonthFormatted,
          monthlyPriceFormatted: monthlyFormatted,
          annualRawPrice: yearly?.rawPrice,
          monthlyRawPrice: monthly?.rawPrice,
          currencySymbol: symbol,
          currencyCode: code,
        );
      }
    } catch (e) {
      debugPrint('[InAppPurchaseService] Error fetching localized pricing: $e');
    }

    return _cachedPricing;
  }

  @override
  ProSubscriptionPricing get currentPricing => _cachedPricing;

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    _isProNotifier.dispose();
  }
}

class MockInAppPurchaseServiceImpl implements InAppPurchaseService {
  bool _isPro = false;
  final ValueNotifier<bool> _isProNotifier = ValueNotifier<bool>(false);
  ProSubscriptionPricing _pricing = const ProSubscriptionPricing();

  @override
  ValueListenable<bool> get isProListenable => _isProNotifier;

  @override
  Future<void> initialize() async {}

  @override
  bool isProUser() => _isPro;

  @override
  void refreshProStatus() {
    _isProNotifier.value = _isPro;
  }

  void setProForTesting(bool val) {
    _isPro = val;
    _isProNotifier.value = val;
  }

  void setPricingForTesting(ProSubscriptionPricing pricing) {
    _pricing = pricing;
  }

  @override
  Future<bool> checkSubscriptionStatus() async => _isPro;

  @override
  Future<bool> purchaseProSubscription({String? productId}) async {
    _isPro = true;
    _isProNotifier.value = true;
    return true;
  }

  @override
  Future<bool> restorePurchases() async {
    return _isPro;
  }

  @override
  Future<void> openManageSubscriptions() async {}

  @override
  Future<ProSubscriptionPricing> getSubscriptionPricing() async => _pricing;

  @override
  ProSubscriptionPricing get currentPricing => _pricing;
}
