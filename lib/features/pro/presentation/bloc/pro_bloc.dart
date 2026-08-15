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

class PurchaseProEvent extends ProEvent {}

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
  const ProLoadedState({required this.isPro});
  @override
  List<Object?> get props => [isPro];
}

class ProPurchaseSuccessState extends ProState {
  final String message;
  final bool isPro;
  const ProPurchaseSuccessState(this.message, {this.isPro = true});
  @override
  List<Object?> get props => [message, isPro];
}

class ProErrorState extends ProState {
  final String message;
  final bool isPro;
  const ProErrorState(this.message, {this.isPro = false});
  @override
  List<Object?> get props => [message, isPro];
}

// BLoC Implementation
class ProBloc extends Bloc<ProEvent, ProState> {
  final InAppPurchaseService purchaseService;

  ProBloc({required this.purchaseService}) : super(ProInitialState()) {
    on<LoadProStatusEvent>(_onLoadProStatus);
    on<RefreshProStatusEvent>(_onRefreshProStatus);
    on<PurchaseProEvent>(_onPurchasePro);
    on<RestorePurchasesEvent>(_onRestorePurchases);
    on<ManageSubscriptionEvent>(_onManageSubscription);
  }

  void _onLoadProStatus(LoadProStatusEvent event, Emitter<ProState> emit) {
    emit(ProLoadedState(isPro: purchaseService.isProUser()));
  }

  Future<void> _onRefreshProStatus(
    RefreshProStatusEvent event,
    Emitter<ProState> emit,
  ) async {
    try {
      final isPro = await purchaseService.checkSubscriptionStatus();
      if (isPro) {
        emit(
          const ProPurchaseSuccessState(
            '✓ Pro subscription is active.',
            isPro: true,
          ),
        );
      } else {
        emit(const ProLoadedState(isPro: false));
      }
    } catch (_) {
      emit(ProLoadedState(isPro: purchaseService.isProUser()));
    }
  }

  Future<void> _onPurchasePro(
    PurchaseProEvent event,
    Emitter<ProState> emit,
  ) async {
    emit(ProLoadingState());
    try {
      final success = await purchaseService.purchaseProSubscription();
      final isPro = purchaseService.isProUser();
      if (success || isPro) {
        emit(
          const ProPurchaseSuccessState(
            '🎉 Pro subscription activated successfully!',
            isPro: true,
          ),
        );
      } else {
        emit(
          ProErrorState(
            'Purchase was cancelled or not completed.',
            isPro: isPro,
          ),
        );
      }
    } catch (e) {
      emit(
        ProErrorState(
          'Purchase failed: $e',
          isPro: purchaseService.isProUser(),
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
          const ProPurchaseSuccessState(
            '🎉 Purchases restored successfully!',
            isPro: true,
          ),
        );
      } else {
        emit(
          ProErrorState(
            'No active subscription found to restore.',
            isPro: isPro,
          ),
        );
      }
    } catch (e) {
      emit(
        ProErrorState('Restore failed: $e', isPro: purchaseService.isProUser()),
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

