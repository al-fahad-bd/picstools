import 'dart:io';
import 'dart:ui';
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
  final List<Size> originalSizes;
  final int originalWidth;
  final int originalHeight;
  final int targetWidth;
  final int targetHeight;
  final bool maintainAspectRatio;
  final double percentage;

  const ResizerConfiguredState({
    required this.files,
    required this.originalSizes,
    required this.originalWidth,
    required this.originalHeight,
    required this.targetWidth,
    required this.targetHeight,
    this.maintainAspectRatio = true,
    this.percentage = 100.0,
  });

  ResizerConfiguredState copyWith({
    List<File>? files,
    List<Size>? originalSizes,
    int? originalWidth,
    int? originalHeight,
    int? targetWidth,
    int? targetHeight,
    bool? maintainAspectRatio,
    double? percentage,
  }) {
    return ResizerConfiguredState(
      files: files ?? this.files,
      originalSizes: originalSizes ?? this.originalSizes,
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
        originalSizes,
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
    final sizes = <Size>[];

    for (final f in event.files) {
      try {
        final bytes = await f.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          sizes.add(Size(decoded.width.toDouble(), decoded.height.toDouble()));
        } else {
          sizes.add(const Size(1080, 1080));
        }
      } catch (_) {
        sizes.add(const Size(1080, 1080));
      }
    }

    final firstW = sizes.isNotEmpty ? sizes.first.width.round() : 1080;
    final firstH = sizes.isNotEmpty ? sizes.first.height.round() : 1080;

    emit(ResizerConfiguredState(
      files: event.files,
      originalSizes: sizes,
      originalWidth: firstW,
      originalHeight: firstH,
      targetWidth: firstW,
      targetHeight: firstH,
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
    final isBatch = current.files.length > 1;

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
          maintainAspectRatio: true,
          percentage: isBatch ? current.percentage : null,
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
