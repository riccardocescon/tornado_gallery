import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tornado_img_app/core/data/datasources/purchase_datasource.dart';
import 'package:tornado_img_app/core/domain/entities/pro_entitlement.dart';
import 'package:tornado_img_app/core/domain/entities/pro_product.dart';
import 'package:tornado_img_app/core/domain/repositories/purchase_repository.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  PurchaseRepositoryImpl({
    PurchaseDatasource? datasource,
    SharedPreferences? preferences,
  }) : _store = datasource ?? PurchaseDatasource(),
       _prefs = preferences ?? prefs;

  static const String _planKey = 'pro_plan';
  static const String _verifiedKey = 'pro_last_verified';

  /// Debug builds preview Pro without a store (the suffixed debug appId gets zero
  /// products from Play). Under `flutter test` this must be OFF, otherwise the
  /// entitlement logic — the thing the premium gates depend on — is untestable.
  static final bool _debugPreview =false &&
      kDebugMode && !Platform.environment.containsKey('FLUTTER_TEST');

  final PurchaseDatasource _store;
  final SharedPreferences _prefs;

  final BehaviorSubject<ProEntitlement> _entitlement =
      BehaviorSubject<ProEntitlement>.seeded(const ProEntitlement.free());

  StreamSubscription<List<PurchaseDetails>>? _purchases;

  /// Store-side products, kept so [buy] can hand the plugin back the exact
  /// [ProductDetails] the store gave us.
  final Map<String, ProductDetails> _details = {};

  @override
  Stream<ProEntitlement> get entitlementStream => _entitlement.stream;

  @override
  ProEntitlement get entitlement => _entitlement.value;

  @override
  Future<Either<PurchaseFailure, Unit>> setup() async {
    // Trust the cache first: the app must work offline, and a Pro user launching
    // in airplane mode should still be Pro (until the grace period lapses).
    _entitlement.add(_readCached());

    _purchases ??= _store.purchases.listen(
      _onPurchases,
      onError:
          (Object e) => appLogger.log(
            'Purchase stream error',
            LogLayer.repository,
            error: e.toString(),
          ),
    );

    try {
      if (!await _store.isAvailable()) {
        return Left(PurchaseFailure.storeUnavailable());
      }
    } catch (e) {
      appLogger.log(
        'Store availability check failed',
        LogLayer.repository,
        error: e.toString(),
      );
      return Left(PurchaseFailure.storeUnavailable());
    }

    return restore();
  }

  @override
  Future<Either<PurchaseFailure, List<ProProduct>>> loadProducts() async {
    // ponytail: debug builds get zero products from the store (suffixed appId),
    // so fake two to preview the paywall. Remove when testing on a Play track.
    if (_debugPreview) return Right(_mockProducts());

    try {
      final products = await _store.queryProducts(Constants.proProductIds);
      if (products.isEmpty) return Left(PurchaseFailure.productsUnavailable());

      _details
        ..clear()
        ..addEntries(products.map((p) => MapEntry(p.id, p)));

      final mapped =
          products.map(_toProProduct).toList()
            // Monthly first, lifetime second — the order the paywall renders them in.
            ..sort((a, b) => a.plan.index.compareTo(b.plan.index));
      return Right(mapped);
    } catch (e) {
      appLogger.log(
        'Error loading Pro products',
        LogLayer.repository,
        error: e.toString(),
      );
      return Left(PurchaseFailure.purchaseError(e.toString()));
    }
  }

  @override
  Future<Either<PurchaseFailure, Unit>> buy(ProProduct product) async {
    try {
      final details = _details[product.id];
      if (details == null) return Left(PurchaseFailure.productsUnavailable());

      await _store.buy(details);
      // The entitlement lands on [entitlementStream] via [_onPurchases]; the
      // store owns the flow from here.
      return const Right(unit);
    } catch (e) {
      appLogger.log(
        'Error buying ${product.id}',
        LogLayer.repository,
        error: e.toString(),
      );
      return Left(PurchaseFailure.purchaseError(e.toString()));
    }
  }

  @override
  Future<Either<PurchaseFailure, Unit>> restore() async {
    try {
      await _store.restore();
      return const Right(unit);
    } catch (e) {
      appLogger.log(
        'Error restoring purchases',
        LogLayer.repository,
        error: e.toString(),
      );
      return Left(PurchaseFailure.purchaseError(e.toString()));
    }
  }

  @override
  Future<void> dispose() async {
    await _purchases?.cancel();
    await _entitlement.close();
  }

  // ── Store events ────────────────────────────────────────────────────────────

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      // A pending purchase owns no entitlement yet, and completing it throws.
      if (purchase.status == PurchaseStatus.pending) continue;

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final plan = _planOf(purchase.productID);
          if (plan != null) _grant(plan);
        case PurchaseStatus.error:
          appLogger.log(
            'Purchase failed for ${purchase.productID}',
            LogLayer.repository,
            error: purchase.error?.message ?? 'unknown',
          );
        case PurchaseStatus.canceled:
        case PurchaseStatus.pending:
          break;
      }

      // Unacknowledged purchases are auto-refunded by Google Play after 3 days,
      // so this has to happen for errors and cancellations too.
      if (purchase.pendingCompletePurchase) {
        try {
          await _store.complete(purchase);
        } catch (e) {
          appLogger.log(
            'Error completing ${purchase.productID}',
            LogLayer.repository,
            error: e.toString(),
          );
        }
      }
    }
  }

  /// The store just confirmed the purchase, so restart the grace clock.
  void _grant(ProPlan plan) {
    final granted = ProEntitlement.active(plan: plan);
    _prefs.setString(_planKey, plan.name);
    _prefs.setInt(_verifiedKey, granted.lastVerified!.millisecondsSinceEpoch);
    _entitlement.add(granted);
  }

  ProEntitlement _readCached() {
    // ponytail: debug-only — pretend the user is on the monthly plan so the
    // upgrade-to-lifetime UI is reachable without a store. Remove for release.
    if (_debugPreview) return ProEntitlement.active(plan: ProPlan.lifetime);

    final plan = _planOfName(_prefs.getString(_planKey));
    final verifiedMs = _prefs.getInt(_verifiedKey);
    if (plan == null || verifiedMs == null) return const ProEntitlement.free();

    // Not filtered by the grace period here on purpose: [ProEntitlement.isPro]
    // re-evaluates the clock on every read, so an entitlement that lapses while
    // the app is open goes stale on its own.
    return ProEntitlement.active(
      plan: plan,
      at: DateTime.fromMillisecondsSinceEpoch(verifiedMs),
    );
  }

  // ── Mapping ─────────────────────────────────────────────────────────────────

  List<ProProduct> _mockProducts() => const [
    ProProduct(
      id: Constants.proMonthlyId,
      title: 'Tornado Gallery Pro (Monthly)',
      description: 'Unlimited images and archives, billed monthly.',
      price: '1,99 €',
      plan: ProPlan.monthly,
    ),
    ProProduct(
      id: Constants.proLifetimeId,
      title: 'Tornado Gallery Pro (Lifetime)',
      description: 'Unlimited images and archives, one-time purchase.',
      price: '19,99 €',
      plan: ProPlan.lifetime,
    ),
  ];

  ProProduct _toProProduct(ProductDetails details) {
    return ProProduct(
      id: details.id,
      title: details.title,
      description: details.description,
      price: details.price,
      plan: _planOf(details.id) ?? ProPlan.lifetime,
    );
  }

  ProPlan? _planOf(String productId) => switch (productId) {
    Constants.proMonthlyId => ProPlan.monthly,
    Constants.proLifetimeId => ProPlan.lifetime,
    _ => null,
  };

  ProPlan? _planOfName(String? name) =>
      ProPlan.values.where((p) => p.name == name).firstOrNull;
}
