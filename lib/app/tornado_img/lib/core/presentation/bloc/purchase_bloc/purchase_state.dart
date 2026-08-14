part of 'purchase_bloc.dart';

@Freezed(equal: false)
abstract class PurchaseState with _$PurchaseState, EquatableMixin {
  const PurchaseState._();

  const factory PurchaseState.initial() = _Initial;

  /// The entitlement changed (bought, restored, or loaded from cache). This is
  /// the only state the rest of the app listens to.
  const factory PurchaseState.entitlement({
    required ProEntitlement entitlement,
  }) = _Entitlement;

  const factory PurchaseState.loadingProducts() = _LoadingProducts;
  const factory PurchaseState.products({required List<ProProduct> products}) =
      _Products;

  const factory PurchaseState.purchasing() = _Purchasing;
  const factory PurchaseState.restoring() = _Restoring;
  const factory PurchaseState.restored({required bool restoredPro}) = _Restored;

  const factory PurchaseState.failure({required String message}) = _Failure;

  @override
  List<Object?> get props => maybeWhen(
    entitlement: (entitlement) => [entitlement],
    products: (products) => [products],
    restored: (restoredPro) => [restoredPro],
    failure: (message) => [message],
    orElse: () => [],
  );
}
