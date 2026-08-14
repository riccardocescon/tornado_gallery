import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/domain/entities/pro_entitlement.dart';
import 'package:tornado_img_app/core/domain/entities/pro_product.dart';
import 'package:tornado_img_app/core/domain/repositories/purchase_repository.dart';
import 'package:tornado_img_app/core/managers/stream_manager.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

part 'purchase_bloc.freezed.dart';
part 'purchase_event.dart';
part 'purchase_state.dart';

/// App-wide owner of the Pro entitlement. Purchases have no use-case layer, so
/// this talks to [PurchaseRepository] directly (precedent: `HomepageBloc`).
class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  PurchaseBloc({required this.purchaseRepository})
    : super(const PurchaseState.initial()) {
    on<_Setup>(_onSetup);
    on<_LoadProducts>(_onLoadProducts);
    on<_Buy>(_onBuy);
    on<_Restore>(_onRestore);
    on<_EntitlementChanged>(_onEntitlementChanged);
  }

  final PurchaseRepository purchaseRepository;

  StreamManager<ProEntitlement>? _streamManager;

  /// The canonical answer for every gate in the app. Recomputed on read, so an
  /// entitlement whose grace period lapses while the app is open goes stale on
  /// its own.
  bool get isPro => purchaseRepository.entitlement.isPro;

  ProPlan? get plan => isPro ? purchaseRepository.entitlement.plan : null;

  Future<void> _onSetup(_Setup event, Emitter<PurchaseState> emit) async {
    if (_streamManager != null) return;

    _streamManager = StreamManager.fromStream(
      purchaseRepository.entitlementStream,
    );

    // Kicked off, not awaited: a slow or unreachable store must never delay
    // startup. The cached entitlement is already good for the grace period.
    unawaited(purchaseRepository.setup());

    await for (final entitlement in _streamManager!.stream) {
      add(PurchaseEvent.entitlementChanged(entitlement: entitlement));
    }
  }

  void _onEntitlementChanged(
    _EntitlementChanged event,
    Emitter<PurchaseState> emit,
  ) {
    emit(PurchaseState.entitlement(entitlement: event.entitlement));
  }

  Future<void> _onLoadProducts(
    _LoadProducts event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(const PurchaseState.loadingProducts());

    final result = await purchaseRepository.loadProducts();
    result.fold(
      (failure) => emit(PurchaseState.failure(message: failure.message)),
      (products) => emit(PurchaseState.products(products: products)),
    );
  }

  Future<void> _onBuy(_Buy event, Emitter<PurchaseState> emit) async {
    emit(const PurchaseState.purchasing());

    final result = await purchaseRepository.buy(event.product);
    result.fold(
      (failure) {
        appLogger.log('Purchase failed', LogLayer.bloc, error: failure.message);
        emit(PurchaseState.failure(message: failure.message));
      },
      (_) {
        // The store drives the rest; the entitlement lands on the stream.
      },
    );
  }

  Future<void> _onRestore(_Restore event, Emitter<PurchaseState> emit) async {
    if (!event.silent) emit(const PurchaseState.restoring());

    final wasPro = isPro;
    final result = await purchaseRepository.restore();

    if (event.silent) return;

    result.fold(
      (failure) => emit(PurchaseState.failure(message: failure.message)),
      // restorePurchases() returns nothing: anything it finds arrives on the
      // entitlement stream a moment later. Report on what we know now, and let
      // that stream event overwrite this state if it upgrades us.
      (_) => emit(PurchaseState.restored(restoredPro: wasPro || isPro)),
    );
  }

  @override
  Future<void> close() {
    _streamManager?.dispose();
    return super.close();
  }
}
