import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tornado_img_app/core/data/datasources/purchase_datasource.dart';
import 'package:tornado_img_app/core/data/repositories/purchase_repository/purchase_repository_impl.dart';
import 'package:tornado_img_app/core/domain/entities/pro_product.dart';
import 'package:tornado_img_app/core/utils/constants.dart';

class _MockPurchaseDatasource extends Mock implements PurchaseDatasource {}

class _FakePurchaseDetails extends Fake implements PurchaseDetails {
  _FakePurchaseDetails({required this.productID, required this.status});

  @override
  final String productID;
  @override
  final PurchaseStatus status;

  @override
  bool get pendingCompletePurchase => true;
}

void main() {
  late _MockPurchaseDatasource store;
  late StreamController<List<PurchaseDetails>> purchases;
  late SharedPreferences prefs;

  setUpAll(() {
    registerFallbackValue(
      _FakePurchaseDetails(
        productID: Constants.proLifetimeId,
        status: PurchaseStatus.purchased,
      ),
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    store = _MockPurchaseDatasource();
    purchases = StreamController<List<PurchaseDetails>>.broadcast();

    when(() => store.purchases).thenAnswer((_) => purchases.stream);
    when(() => store.isAvailable()).thenAnswer((_) async => true);
    when(() => store.restore()).thenAnswer((_) async {});
    when(() => store.complete(any())).thenAnswer((_) async {});
  });

  tearDown(() => purchases.close());

  PurchaseRepositoryImpl makeRepo() =>
      PurchaseRepositoryImpl(datasource: store, preferences: prefs);

  /// Seeds the cache the way a purchase [age] ago would have left it.
  void seedCachedEntitlement(ProPlan plan, {required Duration age}) {
    SharedPreferences.setMockInitialValues({
      'pro_plan': plan.name,
      'pro_last_verified': DateTime.now().subtract(age).millisecondsSinceEpoch,
    });
  }

  group('store events', () {
    test('a purchased event grants Pro and stamps the grace clock', () async {
      final repo = makeRepo();
      await repo.setup();

      purchases.add([
        _FakePurchaseDetails(
          productID: Constants.proMonthlyId,
          status: PurchaseStatus.purchased,
        ),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(repo.entitlement.isPro, isTrue);
      expect(repo.entitlement.plan, ProPlan.monthly);
      expect(prefs.getString('pro_plan'), 'monthly');
      expect(prefs.getInt('pro_last_verified'), isNotNull);
    });

    test('a restored event grants Pro just like a purchase', () async {
      final repo = makeRepo();
      await repo.setup();

      purchases.add([
        _FakePurchaseDetails(
          productID: Constants.proLifetimeId,
          status: PurchaseStatus.restored,
        ),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(repo.entitlement.isPro, isTrue);
      expect(repo.entitlement.plan, ProPlan.lifetime);
    });

    test('every purchased and restored purchase is completed — Google Play '
        'auto-refunds anything left unacknowledged', () async {
      final repo = makeRepo();
      await repo.setup();

      final bought = _FakePurchaseDetails(
        productID: Constants.proMonthlyId,
        status: PurchaseStatus.purchased,
      );
      final restored = _FakePurchaseDetails(
        productID: Constants.proLifetimeId,
        status: PurchaseStatus.restored,
      );
      purchases.add([bought, restored]);
      await Future<void>.delayed(Duration.zero);

      verify(() => store.complete(bought)).called(1);
      verify(() => store.complete(restored)).called(1);
    });

    test('an unknown product id never grants Pro', () async {
      final repo = makeRepo();
      await repo.setup();

      purchases.add([
        _FakePurchaseDetails(
          productID: 'some_other_product',
          status: PurchaseStatus.purchased,
        ),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(repo.entitlement.isPro, isFalse);
    });

    test(
      'a pending purchase is never completed (completing it throws)',
      () async {
        final repo = makeRepo();
        await repo.setup();

        purchases.add([
          _FakePurchaseDetails(
            productID: Constants.proMonthlyId,
            status: PurchaseStatus.pending,
          ),
        ]);
        await Future<void>.delayed(Duration.zero);

        expect(repo.entitlement.isPro, isFalse);
        verifyNever(() => store.complete(any()));
      },
    );
  });

  group('the 7-day grace period applies to BOTH SKUs', () {
    // The store only ever reports *active* purchases, so a cancelled
    // subscription or a refunded lifetime is detected by absence: no
    // confirmation, the clock runs out, Pro drops.
    for (final plan in ProPlan.values) {
      test('$plan confirmed 6 days ago is still Pro', () async {
        seedCachedEntitlement(plan, age: const Duration(days: 6));
        prefs = await SharedPreferences.getInstance();

        final repo = makeRepo();
        await repo.setup();

        expect(repo.entitlement.isPro, isTrue);
        expect(repo.entitlement.plan, plan);
      });

      test('$plan not confirmed for 8 days drops back to free', () async {
        seedCachedEntitlement(plan, age: const Duration(days: 8));
        prefs = await SharedPreferences.getInstance();

        final repo = makeRepo();
        await repo.setup();

        expect(repo.entitlement.isPro, isFalse);
      });
    }
  });

  test(
    'an offline store keeps the cached entitlement — the app works offline',
    () async {
      seedCachedEntitlement(ProPlan.lifetime, age: const Duration(days: 2));
      prefs = await SharedPreferences.getInstance();
      when(() => store.isAvailable()).thenAnswer((_) async => false);

      final repo = makeRepo();
      final result = await repo.setup();

      expect(
        result.isLeft(),
        isTrue,
        reason: 'reports the store is unavailable',
      );
      expect(
        repo.entitlement.isPro,
        isTrue,
        reason:
            'but must NOT revoke Pro just because the store was unreachable',
      );
    },
  );
}
