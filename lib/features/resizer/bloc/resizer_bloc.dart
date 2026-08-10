import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image/image.dart' as img;
import '../services/image_resizer_service.dart';
import '../../../core/services/history_service.dart';

// Events
abstract class ResizerEvent extends Equatable {
  const ResizerEvent();
  @override
  List<Object?> get props => [];
}

class SelectResizeImagesEvent extends ResizerEvent {
  final List<File> files;
  const SelectResizeImagesEvent(this.files);
  @override
  List<Object?> get props => [files];
}

class UpdateDimensionsEvent extends ResizerEvent {
  final int width;
  final int height;
  const UpdateDimensionsEvent(this.width, this.height);
  @override
  List<Object?> get props => [width, height];
}

class ToggleMaintainAspectRatioEvent extends ResizerEvent {}

class SetPercentageResizeEvent extends ResizerEvent {
  final double percentage; // 10.0 to 100.0
  const SetPercentageResizeEvent(this.percentage);
  @override
  List<Object?> get props => [percentage];
}

class StartResizeEvent extends ResizerEvent {}

class ResetResizerEvent extends ResizerEvent {}

// States
abstract class ResizerState extends Equatable {
  const ResizerState();
  @override
  List<Object?> get props => [];
}

class ResizerInitialState extends ResizerState {}

class ResizerConfiguredState extends ResizerState {
  final List<File> files;
  final int originalWidth;
  final int originalHeight;
  final int targetWidth;
  final int targetHeight;
  final bool maintainAspectRatio;
  final double percentage;

  const ResizerConfiguredState({
    required this.files,
    required this.originalWidth,
    required this.originalHeight,
    required this.targetWidth,
    required this.targetHeight,
    this.maintainAspectRatio = true,
    this.percentage = 100.0,
  });

  ResizerConfiguredState copyWith({
    List<File>? files,
    int? originalWidth,
    int? originalHeight,
    int? targetWidth,
    int? targetHeight,
    bool? maintainAspectRatio,
    double? percentage,
  }) {
    return ResizerConfiguredState(
      files: files ?? this.files,
      originalWidth: originalWidth ?? this.originalWidth,
      originalHeight: originalHeight ?? this.originalHeight,
      targetWidth: targetWidth ?? this.targetWidth,
      targetHeight: targetHeight ?? this.targetHeight,
      maintainAspectRatio: maintainAspectRatio ?? this.maintainAspectRatio,
      percentage: percentage ?? this.percentage,
    );
  }

  @override
  List<Object?> get props => [
        files,
        originalWidth,
        originalHeight,
        targetWidth,
        targetHeight,
        maintainAspectRatio,
        percentage,
      ];
}

class ResizerProcessingState extends ResizerState {
  final int currentIndex;
  final int totalCount;
  final double progress;

  const ResizerProcessingState({
    required this.currentIndex,
    required this.totalCount,
    required this.progress,
  });

  @override
  List<Object?> get props => [currentIndex, totalCount, progress];
}

class ResizerSuccessState extends ResizerState {
  final List<ResizeResult> results;
  const ResizerSuccessState(this.results);
  @override
  List<Object?> get props => [results];
}

class ResizerErrorState extends ResizerState {
  final String message;
  const ResizerErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

class ResizerBloc extends Bloc<ResizerEvent, ResizerState> {
  final ImageResizerService resizerService;
  final HistoryService historyService;

  ResizerBloc({
    required this.resizerService,
    required this.historyService,
  }) : super(ResizerInitialState()) {
    on<SelectResizeImagesEvent>(_onSelectImages);
    on<UpdateDimensionsEvent>(_onUpdateDimensions);
    on<ToggleMaintainAspectRatioEvent>(_onToggleAspectRatio);
    on<SetPercentageResizeEvent>(_onSetPercentage);
    on<StartResizeEvent>(_onStartResize);
    on<ResetResizerEvent>(_onReset);
  }

  Future<void> _onSelectImages(SelectResizeImagesEvent event, Emitter<ResizerState> emit) async {
    if (event.files.isEmpty) return;
    int origW = 1080;
    int origH = 1080;

    try {
      final bytes = await event.files.first.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        origW = decoded.width;
        origH = decoded.height;
      }
    } catch (_) {}

    emit(ResizerConfiguredState(
      files: event.files,
      originalWidth: origW,
      originalHeight: origH,
      targetWidth: origW,
      targetHeight: origH,
    ));
  }

  void _onUpdateDimensions(UpdateDimensionsEvent event, Emitter<ResizerState> emit) {
    if (state is ResizerConfiguredState) {
      final current = state as ResizerConfiguredState;
      emit(current.copyWith(
        targetWidth: event.width,
        targetHeight: event.height,
      ));
    }
  }

  void _onToggleAspectRatio(ToggleMaintainAspectRatioEvent event, Emitter<ResizerState> emit) {
    if (state is ResizerConfiguredState) {
      final current = state as ResizerConfiguredState;
      emit(current.copyWith(maintainAspectRatio: !current.maintainAspectRatio));
    }
  }

  void _onSetPercentage(SetPercentageResizeEvent event, Emitter<ResizerState> emit) {
    if (state is ResizerConfiguredState) {
      final current = state as ResizerConfiguredState;
      final newW = (current.originalWidth * (event.percentage / 100.0)).round();
      final newH = (current.originalHeight * (event.percentage / 100.0)).round();
      emit(current.copyWith(
        targetWidth: newW,
        targetHeight: newH,
        percentage: event.percentage,
      ));
    }
  }

  Future<void> _onStartResize(StartResizeEvent event, Emitter<ResizerState> emit) async {
    if (state is! ResizerConfiguredState) return;
    final current = state as ResizerConfiguredState;

    emit(ResizerProcessingState(
      currentIndex: 0,
      totalCount: current.files.length,
      progress: 0.0,
    ));

    final results = <ResizeResult>[];

    try {
      for (int i = 0; i < current.files.length; i++) {
        emit(ResizerProcessingState(
          currentIndex: i + 1,
          totalCount: current.files.length,
          progress: (i + 1) / current.files.length,
        ));

        final res = await resizerService.resizeImage(
          imageFile: current.files[i],
          targetWidth: current.targetWidth,
          targetHeight: current.targetHeight,
          maintainAspectRatio: current.maintainAspectRatio,
        );

        results.add(res);

        await historyService.addHistoryItem(HistoryItem(
          id: '${DateTime.now().millisecondsSinceEpoch}_$i',
          toolName: 'Resize',
          originalPath: res.originalFile.path,
          processedPath: res.resizedFile.path,
          originalSizeBytes: res.originalSizeBytes,
          processedSizeBytes: res.resizedSizeBytes,
          timestamp: DateTime.now(),
        ));
      }

      emit(ResizerSuccessState(results));
    } catch (e) {
      emit(ResizerErrorState("Resize failed: ${e.toString()}"));
    }
  }

  void _onReset(ResetResizerEvent event, Emitter<ResizerState> emit) {
    emit(ResizerInitialState());
  }
}
