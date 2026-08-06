import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/entities/pro_entitlement.dart';
import 'package:tornado_img_app/core/domain/entities/pro_product.dart';
import 'package:tornado_img_app/core/domain/repositories/purchase_repository.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/presentation/bloc/purchase_bloc/purchase_bloc.dart';

class _MockPurchaseRepository extends Mock implements PurchaseRepository {}

ProProduct _product(ProPlan plan) => ProProduct(
  id: 'id_${plan.name}',
  title: plan.name,
  description: '',
  price: '1,99 €',
  plan: plan,
);

void main() {
  late _MockPurchaseRepository repo;
  late StreamController<ProEntitlement> entitlements;

  setUpAll(() {
    registerFallbackValue(_product(ProPlan.monthly));
  });

  setUp(() {
    repo = _MockPurchaseRepository();
    entitlements = StreamController<ProEntitlement>.broadcast();

    when(() => repo.entitlementStream).thenAnswer((_) => entitlements.stream);
    when(() => repo.entitlement).thenReturn(const ProEntitlement.free());
    when(() => repo.setup()).thenAnswer((_) async => const Right(unit));
  });

  tearDown(() => entitlements.close());

  PurchaseBloc makeBloc() => PurchaseBloc(purchaseRepository: repo);

  group('isPro / plan delegate to the repository entitlement', () {
    test('free entitlement → not Pro, no plan', () {
      when(() => repo.entitlement).thenReturn(const ProEntitlement.free());
      final bloc = makeBloc();

      expect(bloc.isPro, isFalse);
      expect(bloc.plan, isNull);
    });

    test('active entitlement → Pro, exposes the plan', () {
      when(
        () => repo.entitlement,
      ).thenReturn(ProEntitlement.active(plan: ProPlan.lifetime));
      final bloc = makeBloc();

      expect(bloc.isPro, isTrue);
      expect(bloc.plan, ProPlan.lifetime);
    });
  });

  group('loadProducts', () {
    blocTest<PurchaseBloc, PurchaseState>(
      'emits loadingProducts then products on success',
      build: () {
        when(() => repo.loadProducts()).thenAnswer(
          (_) async => Right([_product(ProPlan.monthly), _product(ProPlan.lifetime)]),
        );
        return makeBloc();
      },
      act: (b) => b.add(const PurchaseEvent.loadProducts()),
      expect: () => [
        const PurchaseState.loadingProducts(),
        PurchaseState.products(
          products: [_product(ProPlan.monthly), _product(ProPlan.lifetime)],
        ),
      ],
    );

    blocTest<PurchaseBloc, PurchaseState>(
      'emits loadingProducts then failure on Left',
      build: () {
        when(() => repo.loadProducts())
            .thenAnswer((_) async => Left(PurchaseFailure.productsUnavailable()));
        return makeBloc();
      },
      act: (b) => b.add(const PurchaseEvent.loadProducts()),
      expect: () => [
        const PurchaseState.loadingProducts(),
        PurchaseState.failure(
          message: PurchaseFailure.productsUnavailable().message,
        ),
      ],
    );
  });

  group('buy', () {
    blocTest<PurchaseBloc, PurchaseState>(
      'emits only purchasing on success — the entitlement lands on the stream',
      build: () {
        when(() => repo.buy(any())).thenAnswer((_) async => const Right(unit));
        return makeBloc();
      },
      act: (b) => b.add(PurchaseEvent.buy(product: _product(ProPlan.monthly))),
      expect: () => [const PurchaseState.purchasing()],
      verify: (_) =>
          verify(() => repo.buy(_product(ProPlan.monthly))).called(1),
    );

    blocTest<PurchaseBloc, PurchaseState>(
      'emits purchasing then failure when the store rejects the buy',
      build: () {
        when(() => repo.buy(any()))
            .thenAnswer((_) async => Left(PurchaseFailure.purchaseError('nope')));
        return makeBloc();
      },
      act: (b) => b.add(PurchaseEvent.buy(product: _product(ProPlan.lifetime))),
      expect: () => [
        const PurchaseState.purchasing(),
        PurchaseState.failure(
          message: PurchaseFailure.purchaseError('nope').message,
        ),
      ],
    );
  });

  group('restore', () {
    blocTest<PurchaseBloc, PurchaseState>(
      'loud restore emits restoring then restored',
      build: () {
        when(() => repo.restore()).thenAnswer((_) async => const Right(unit));
        return makeBloc();
      },
      act: (b) => b.add(const PurchaseEvent.restore()),
      expect: () => [
        const PurchaseState.restoring(),
        const PurchaseState.restored(restoredPro: false),
      ],
    );

    blocTest<PurchaseBloc, PurchaseState>(
      'loud restore reports restoredPro when the entitlement is already Pro',
      build: () {
        when(() => repo.entitlement)
            .thenReturn(ProEntitlement.active(plan: ProPlan.lifetime));
        when(() => repo.restore()).thenAnswer((_) async => const Right(unit));
        return makeBloc();
      },
      act: (b) => b.add(const PurchaseEvent.restore()),
      expect: () => [
        const PurchaseState.restoring(),
        const PurchaseState.restored(restoredPro: true),
      ],
    );

    blocTest<PurchaseBloc, PurchaseState>(
      'loud restore emits failure on Left',
      build: () {
        when(() => repo.restore())
            .thenAnswer((_) async => Left(PurchaseFailure.storeUnavailable()));
        return makeBloc();
      },
      act: (b) => b.add(const PurchaseEvent.restore()),
      expect: () => [
        const PurchaseState.restoring(),
        PurchaseState.failure(
          message: PurchaseFailure.storeUnavailable().message,
        ),
      ],
    );

    blocTest<PurchaseBloc, PurchaseState>(
      'silent restore (app resume) emits nothing over the current UI',
      build: () {
        when(() => repo.restore()).thenAnswer((_) async => const Right(unit));
        return makeBloc();
      },
      act: (b) => b.add(const PurchaseEvent.restore(silent: true)),
      expect: () => const <PurchaseState>[],
      verify: (_) => verify(() => repo.restore()).called(1),
    );
  });

  group('setup wires the entitlement stream into state', () {
    // Fixed timestamp so the pushed entitlement equals the expected one
    // (ProEntitlement is Equatable on plan + lastVerified).
    final active = ProEntitlement.active(plan: ProPlan.monthly, at: DateTime(2026));

    blocTest<PurchaseBloc, PurchaseState>(
      'an entitlement pushed by the store becomes a PurchaseState.entitlement',
      build: makeBloc,
      act: (b) async {
        b.add(const PurchaseEvent.setup());
        await Future<void>.delayed(Duration.zero);
        entitlements.add(active);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [PurchaseState.entitlement(entitlement: active)],
      verify: (_) => verify(() => repo.setup()).called(1),
    );
  });
}
