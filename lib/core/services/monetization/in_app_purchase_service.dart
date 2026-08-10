abstract class InAppPurchaseService {
  Future<void> initialize();
  bool isProUser();
  Future<bool> purchaseProSubscription();
  Future<bool> restorePurchases();
}

class MockInAppPurchaseServiceImpl implements InAppPurchaseService {
  bool _isPro = false;

  @override
  Future<void> initialize() async {
    // Modular billing init
  }

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
