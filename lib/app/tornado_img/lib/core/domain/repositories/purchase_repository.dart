import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/entities/pro_entitlement.dart';
import 'package:tornado_img_app/core/domain/entities/pro_product.dart';
import 'package:tornado_img_app/core/failures/failures.dart';

/// Purchases have no use-case layer (they would be 1:1 pass-throughs), so this
/// repository is the outermost boundary and returns [Either] itself.
abstract class PurchaseRepository {
  /// The current entitlement, replayed to every new listener and updated
  /// whenever the store reports a purchase, a restore, or the grace period
  /// lapses.
  Stream<ProEntitlement> get entitlementStream;

  /// Last value pushed on [entitlementStream]. Cheap enough for guards that
  /// can't be reactive (e.g. a bloc event handler).
  ProEntitlement get entitlement;

  /// Loads the cached entitlement, starts listening to the store and asks it to
  /// re-confirm what the user owns. Safe to call more than once.
  Future<Either<PurchaseFailure, Unit>> setup();

  /// The two Pro SKUs, priced by the store.
  Future<Either<PurchaseFailure, List<ProProduct>>> loadProducts();

  /// Opens the store's purchase flow. The resulting entitlement arrives on
  /// [entitlementStream], not in the return value.
  Future<Either<PurchaseFailure, Unit>> buy(ProProduct product);

  /// Re-confirms the entitlement with the store. Restored purchases also arrive
  /// on [entitlementStream].
  Future<Either<PurchaseFailure, Unit>> restore();

  Future<void> dispose();
}
