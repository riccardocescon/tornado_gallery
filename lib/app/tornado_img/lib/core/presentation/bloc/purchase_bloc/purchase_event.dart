part of 'purchase_bloc.dart';

@Freezed(equal: false)
abstract class PurchaseEvent with _$PurchaseEvent {
  const PurchaseEvent._();

  /// Loads the cached entitlement and starts listening to the store.
  const factory PurchaseEvent.setup() = _Setup;

  /// Fetches the two Pro SKUs with store-formatted prices (paywall entry).
  const factory PurchaseEvent.loadProducts() = _LoadProducts;

  const factory PurchaseEvent.buy({required ProProduct product}) = _Buy;

  /// [silent] restores run on app resume to re-confirm the entitlement; they
  /// must not emit UI states over whatever the user is looking at.
  const factory PurchaseEvent.restore({@Default(false) bool silent}) = _Restore;

  const factory PurchaseEvent.entitlementChanged({
    required ProEntitlement entitlement,
  }) = _EntitlementChanged;
}
