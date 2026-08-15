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

class PurchaseProEvent extends ProEvent {}

class RestorePurchasesEvent extends ProEvent {}

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
  const ProPurchaseSuccessState(this.message);
  @override
  List<Object?> get props => [message];
}

class ProErrorState extends ProState {
  final String message;
  const ProErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC Implementation
class ProBloc extends Bloc<ProEvent, ProState> {
  final InAppPurchaseService purchaseService;

  ProBloc({required this.purchaseService}) : super(ProInitialState()) {
    on<LoadProStatusEvent>(_onLoadProStatus);
    on<PurchaseProEvent>(_onPurchasePro);
    on<RestorePurchasesEvent>(_onRestorePurchases);
  }

  void _onLoadProStatus(LoadProStatusEvent event, Emitter<ProState> emit) {
    emit(ProLoadedState(isPro: purchaseService.isProUser()));
  }

  Future<void> _onPurchasePro(PurchaseProEvent event, Emitter<ProState> emit) async {
    emit(ProLoadingState());
    try {
      final success = await purchaseService.purchaseProSubscription();
      if (success) {
        emit(const ProPurchaseSuccessState('🎉 Pro subscription activated successfully!'));
      } else {
        emit(const ProErrorState('Purchase was not completed.'));
      }
    } catch (e) {
      emit(ProErrorState('Purchase failed: $e'));
    }
  }

  Future<void> _onRestorePurchases(RestorePurchasesEvent event, Emitter<ProState> emit) async {
    emit(ProLoadingState());
    try {
      final success = await purchaseService.restorePurchases();
      if (success) {
        emit(const ProPurchaseSuccessState('🎉 Purchases restored successfully!'));
      } else {
        emit(const ProErrorState('No previous purchases found to restore.'));
      }
    } catch (e) {
      emit(ProErrorState('Restore failed: $e'));
    }
  }
}
