import 'package:in_app_purchase/in_app_purchase.dart';

export 'package:in_app_purchase/in_app_purchase.dart'
    show ProductDetails, PurchaseDetails, PurchaseStatus;

/// The only file in the app that talks to `in_app_purchase`.
///
/// Deliberately thin: it owns no rules, just the plugin surface, so the store
/// can be faked wholesale in tests and the entitlement logic stays testable
/// without a device.
class PurchaseDatasource {
  PurchaseDatasource({InAppPurchase? iap})
    : _iap = iap ?? InAppPurchase.instance;

  final InAppPurchase _iap;

  /// Purchases, restores and errors, pushed by the store at any time — not only
  /// while a purchase flow is on screen.
  Stream<List<PurchaseDetails>> get purchases => _iap.purchaseStream;

  Future<bool> isAvailable() => _iap.isAvailable();

  Future<List<ProductDetails>> queryProducts(Set<String> ids) async {
    final response = await _iap.queryProductDetails(ids);
    return response.productDetails;
  }

  /// Subscriptions are bought with `buyNonConsumable` too, so both SKUs share
  /// one purchase path.
  Future<void> buy(ProductDetails product) => _iap.buyNonConsumable(
    purchaseParam: PurchaseParam(productDetails: product),
  );

  Future<void> restore() => _iap.restorePurchases();

  /// Must be called for every purchased/restored purchase: Google Play
  /// auto-refunds anything left unacknowledged for 3 days.
  Future<void> complete(PurchaseDetails purchase) =>
      _iap.completePurchase(purchase);
}
