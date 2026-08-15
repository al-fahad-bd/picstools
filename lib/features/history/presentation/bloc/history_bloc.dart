import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/history_service.dart';

// Events
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadHistoryEvent extends HistoryEvent {}

class ClearHistoryEvent extends HistoryEvent {}

class DeleteHistoryItemEvent extends HistoryEvent {
  final String id;
  const DeleteHistoryItemEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryLoadingState extends HistoryState {}

class HistoryLoadedState extends HistoryState {
  final List<HistoryItem> items;
  const HistoryLoadedState(this.items);
  @override
  List<Object?> get props => [items];
}

class HistoryEmptyState extends HistoryState {}

class HistoryErrorState extends HistoryState {
  final String message;
  const HistoryErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC Implementation
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryService historyService;

  HistoryBloc({required this.historyService}) : super(HistoryLoadingState()) {
    on<LoadHistoryEvent>(_onLoadHistory);
    on<ClearHistoryEvent>(_onClearHistory);
    on<DeleteHistoryItemEvent>(_onDeleteItem);
  }

  Future<void> _onLoadHistory(LoadHistoryEvent event, Emitter<HistoryState> emit) async {
    emit(HistoryLoadingState());
    try {
      final items = await historyService.getHistory();
      if (items.isEmpty) {
        emit(HistoryEmptyState());
      } else {
        emit(HistoryLoadedState(items));
      }
    } catch (e) {
      emit(HistoryErrorState('Failed to load history: $e'));
    }
  }

  Future<void> _onClearHistory(ClearHistoryEvent event, Emitter<HistoryState> emit) async {
    try {
      await historyService.clearHistory();
      emit(HistoryEmptyState());
    } catch (e) {
      emit(HistoryErrorState('Failed to clear history: $e'));
    }
  }

  Future<void> _onDeleteItem(DeleteHistoryItemEvent event, Emitter<HistoryState> emit) async {
    try {
      await historyService.deleteHistoryItem(event.id);
      final items = await historyService.getHistory();
      if (items.isEmpty) {
        emit(HistoryEmptyState());
      } else {
        emit(HistoryLoadedState(items));
      }
    } catch (e) {
      emit(HistoryErrorState('Failed to delete history item: $e'));
    }
  }
}
