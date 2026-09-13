import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/monetization/in_app_purchase_service.dart';

// Events
abstract class ProEvent extends Equatable {
  const ProEvent();
  @override
  List<Object?> get props => [];
}

class LoadProStatusEvent extends ProEvent {}

class RefreshProStatusEvent extends ProEvent {}

class PurchaseProEvent extends ProEvent {
  final String? productId;
  const PurchaseProEvent({this.productId});
  @override
  List<Object?> get props => [productId];
}

class RestorePurchasesEvent extends ProEvent {}

class ManageSubscriptionEvent extends ProEvent {}

// States
abstract class ProState extends Equatable {
  const ProState();
  @override
  List<Object?> get props => [];
}

class ProInitialState extends ProState {}

class ProLoadingState extends ProState {}

class ProLoadedState extends ProState {
  final bool isPro;
  final ProSubscriptionPricing pricing;

  const ProLoadedState({
    required this.isPro,
    this.pricing = const ProSubscriptionPricing(),
  });

  @override
  List<Object?> get props => [isPro, pricing];
}

class ProPurchaseSuccessState extends ProState {
  final String message;
  final bool isPro;
  final ProSubscriptionPricing pricing;

  const ProPurchaseSuccessState(
    this.message, {
    this.isPro = true,
    this.pricing = const ProSubscriptionPricing(),
  });

  @override
  List<Object?> get props => [message, isPro, pricing];
}

class ProErrorState extends ProState {
  final String message;
  final bool isPro;
  final ProSubscriptionPricing pricing;

  const ProErrorState(
    this.message, {
    this.isPro = false,
    this.pricing = const ProSubscriptionPricing(),
  });

  @override
  List<Object?> get props => [message, isPro, pricing];
}

// BLoC Implementation
class ProBloc extends Bloc<ProEvent, ProState> {
  final InAppPurchaseService purchaseService;
  ProSubscriptionPricing _pricing = const ProSubscriptionPricing();

  ProBloc({required this.purchaseService}) : super(ProInitialState()) {
    on<LoadProStatusEvent>(_onLoadProStatus);
    on<RefreshProStatusEvent>(_onRefreshProStatus);
    on<PurchaseProEvent>(_onPurchasePro);
    on<RestorePurchasesEvent>(_onRestorePurchases);
    on<ManageSubscriptionEvent>(_onManageSubscription);

    purchaseService.isProListenable.addListener(_onProStatusChanged);
  }

  void _onProStatusChanged() {
    add(LoadProStatusEvent());
  }

  @override
  Future<void> close() {
    purchaseService.isProListenable.removeListener(_onProStatusChanged);
    return super.close();
  }

  Future<void> _onLoadProStatus(
    LoadProStatusEvent event,
    Emitter<ProState> emit,
  ) async {
    _pricing = await purchaseService.getSubscriptionPricing();
    emit(ProLoadedState(isPro: purchaseService.isProUser(), pricing: _pricing));
  }

  Future<void> _onRefreshProStatus(
    RefreshProStatusEvent event,
    Emitter<ProState> emit,
  ) async {
    try {
      final isPro = await purchaseService.checkSubscriptionStatus();
      _pricing = await purchaseService.getSubscriptionPricing();
      if (isPro) {
        emit(
          ProPurchaseSuccessState(
            '✓ Pro subscription is active.',
            isPro: true,
            pricing: _pricing,
          ),
        );
      } else {
        emit(ProLoadedState(isPro: false, pricing: _pricing));
      }
    } catch (_) {
      emit(ProLoadedState(isPro: purchaseService.isProUser(), pricing: _pricing));
    }
  }

  Future<void> _onPurchasePro(
    PurchaseProEvent event,
    Emitter<ProState> emit,
  ) async {
    emit(ProLoadingState());
    try {
      final success = await purchaseService.purchaseProSubscription(
        productId: event.productId,
      );
      final isPro = purchaseService.isProUser();
      if (success || isPro) {
        emit(
          ProPurchaseSuccessState(
            '🎉 Pro subscription activated successfully!',
            isPro: true,
            pricing: _pricing,
          ),
        );
      } else {
        // User cancelled or dismissed the billing sheet; cleanly reset button
        emit(ProLoadedState(isPro: isPro, pricing: _pricing));
      }
    } catch (e) {
      emit(
        ProErrorState(
          'Purchase failed: $e',
          isPro: purchaseService.isProUser(),
          pricing: _pricing,
        ),
      );
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchasesEvent event,
    Emitter<ProState> emit,
  ) async {
    emit(ProLoadingState());
    try {
      final success = await purchaseService.restorePurchases();
      final isPro = purchaseService.isProUser();
      if (success || isPro) {
        emit(
          ProPurchaseSuccessState(
            '🎉 Purchases restored successfully!',
            isPro: true,
            pricing: _pricing,
          ),
        );
      } else {
        emit(
          ProErrorState(
            'No active subscription found to restore.',
            isPro: isPro,
            pricing: _pricing,
          ),
        );
      }
    } catch (e) {
      emit(
        ProErrorState(
          'Restore failed: $e',
          isPro: purchaseService.isProUser(),
          pricing: _pricing,
        ),
      );
    }
  }

  Future<void> _onManageSubscription(
    ManageSubscriptionEvent event,
    Emitter<ProState> emit,
  ) async {
    await purchaseService.openManageSubscriptions();
  }
}
