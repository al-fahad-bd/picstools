import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/image_compressor_service.dart';
import '../../../core/services/history_service.dart';

// Events
abstract class CompressorEvent extends Equatable {
  const CompressorEvent();
  @override
  List<Object?> get props => [];
}

class SelectImagesEvent extends CompressorEvent {
  final List<File> files;
  const SelectImagesEvent(this.files);
  @override
  List<Object?> get props => [files];
}

class SetQualityPresetEvent extends CompressorEvent {
  final int quality;
  const SetQualityPresetEvent(this.quality);
  @override
  List<Object?> get props => [quality];
}

class SetCustomQualityEvent extends CompressorEvent {
  final double quality;
  const SetCustomQualityEvent(this.quality);
  @override
  List<Object?> get props => [quality];
}

class SetTargetFileSizeEvent extends CompressorEvent {
  final int? targetSizeBytes;
  const SetTargetFileSizeEvent(this.targetSizeBytes);
  @override
  List<Object?> get props => [targetSizeBytes];
}

class RemoveImageEvent extends CompressorEvent {
  final int index;
  const RemoveImageEvent(this.index);
  @override
  List<Object?> get props => [index];
}

class StartCompressionEvent extends CompressorEvent {}

class ResetCompressorEvent extends CompressorEvent {}

// States
abstract class CompressorState extends Equatable {
  const CompressorState();
  @override
  List<Object?> get props => [];
}

class CompressorInitialState extends CompressorState {}

class CompressorImagesSelectedState extends CompressorState {
  final List<File> files;
  final int quality;
  final int? targetSizeBytes;
  final int totalOriginalSizeBytes;

  const CompressorImagesSelectedState({
    required this.files,
    this.quality = 75,
    this.targetSizeBytes,
    required this.totalOriginalSizeBytes,
  });

  CompressorImagesSelectedState copyWith({
    List<File>? files,
    int? quality,
    int? targetSizeBytes,
    bool clearTargetSizeBytes = false,
    int? totalOriginalSizeBytes,
  }) {
    return CompressorImagesSelectedState(
      files: files ?? this.files,
      quality: quality ?? this.quality,
      targetSizeBytes: clearTargetSizeBytes ? null : (targetSizeBytes ?? this.targetSizeBytes),
      totalOriginalSizeBytes: totalOriginalSizeBytes ?? this.totalOriginalSizeBytes,
    );
  }

  @override
  List<Object?> get props => [files, quality, targetSizeBytes, totalOriginalSizeBytes];
}

class CompressorProcessingState extends CompressorState {
  final int currentIndex;
  final int totalCount;
  final double progress;

  const CompressorProcessingState({
    required this.currentIndex,
    required this.totalCount,
    required this.progress,
  });

  @override
  List<Object?> get props => [currentIndex, totalCount, progress];
}

class CompressorSuccessState extends CompressorState {
  final List<CompressionResult> results;
  final int totalOriginalSizeBytes;
  final int totalCompressedSizeBytes;

  const CompressorSuccessState({
    required this.results,
    required this.totalOriginalSizeBytes,
    required this.totalCompressedSizeBytes,
  });

  @override
  List<Object?> get props => [results, totalOriginalSizeBytes, totalCompressedSizeBytes];
}

class CompressorErrorState extends CompressorState {
  final String message;
  const CompressorErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc Implementation
class CompressorBloc extends Bloc<CompressorEvent, CompressorState> {
  final ImageCompressorService compressorService;
  final HistoryService historyService;

  CompressorBloc({
    required this.compressorService,
    required this.historyService,
  })  : super(CompressorInitialState()) {
    on<SelectImagesEvent>(_onSelectImages);
    on<SetQualityPresetEvent>(_onSetQualityPreset);
    on<SetCustomQualityEvent>(_onSetCustomQuality);
    on<SetTargetFileSizeEvent>(_onSetTargetFileSize);
    on<RemoveImageEvent>(_onRemoveImage);
    on<StartCompressionEvent>(_onStartCompression);
    on<ResetCompressorEvent>(_onReset);
  }

  Future<void> _onRemoveImage(RemoveImageEvent event, Emitter<CompressorState> emit) async {
    if (state is! CompressorImagesSelectedState) return;
    final current = state as CompressorImagesSelectedState;
    if (event.index < 0 || event.index >= current.files.length) return;

    final updatedFiles = List<File>.from(current.files)..removeAt(event.index);
    if (updatedFiles.isEmpty) {
      emit(CompressorInitialState());
      return;
    }

    int totalBytes = 0;
    for (final f in updatedFiles) {
      if (await f.exists()) {
        totalBytes += await f.length();
      }
    }

    emit(current.copyWith(
      files: updatedFiles,
      totalOriginalSizeBytes: totalBytes,
    ));
  }

  Future<void> _onSelectImages(SelectImagesEvent event, Emitter<CompressorState> emit) async {
    if (event.files.isEmpty) return;
    int totalBytes = 0;
    for (final f in event.files) {
      if (await f.exists()) {
        totalBytes += await f.length();
      }
    }
    emit(CompressorImagesSelectedState(
      files: event.files,
      quality: 75,
      totalOriginalSizeBytes: totalBytes,
    ));
  }

  void _onSetQualityPreset(SetQualityPresetEvent event, Emitter<CompressorState> emit) {
    if (state is CompressorImagesSelectedState) {
      final current = state as CompressorImagesSelectedState;
      emit(current.copyWith(quality: event.quality));
    }
  }

  void _onSetCustomQuality(SetCustomQualityEvent event, Emitter<CompressorState> emit) {
    if (state is CompressorImagesSelectedState) {
      final current = state as CompressorImagesSelectedState;
      emit(current.copyWith(quality: event.quality.round()));
    }
  }

  void _onSetTargetFileSize(SetTargetFileSizeEvent event, Emitter<CompressorState> emit) {
    if (state is CompressorImagesSelectedState) {
      final current = state as CompressorImagesSelectedState;
      if (event.targetSizeBytes == null) {
        emit(current.copyWith(clearTargetSizeBytes: true));
      } else {
        emit(current.copyWith(targetSizeBytes: event.targetSizeBytes));
      }
    }
  }

  Future<void> _onStartCompression(StartCompressionEvent event, Emitter<CompressorState> emit) async {
    if (state is! CompressorImagesSelectedState) return;
    final current = state as CompressorImagesSelectedState;

    emit(CompressorProcessingState(
      currentIndex: 0,
      totalCount: current.files.length,
      progress: 0.0,
    ));

    final results = <CompressionResult>[];
    int totalCompBytes = 0;

    try {
      for (int i = 0; i < current.files.length; i++) {
        emit(CompressorProcessingState(
          currentIndex: i + 1,
          totalCount: current.files.length,
          progress: (i + 1) / current.files.length,
        ));

        final res = await compressorService.compressImage(
          imageFile: current.files[i],
          quality: current.quality,
          targetSizeBytes: current.targetSizeBytes,
        );

        results.add(res);
        totalCompBytes += res.compressedSizeBytes;

        // Record history entry
        await historyService.addHistoryItem(HistoryItem(
          id: '${DateTime.now().millisecondsSinceEpoch}_$i',
          toolName: 'Compress',
          originalPath: res.originalFile.path,
          processedPath: res.compressedFile.path,
          originalSizeBytes: res.originalSizeBytes,
          processedSizeBytes: res.compressedSizeBytes,
          timestamp: DateTime.now(),
        ));
      }

      emit(CompressorSuccessState(
        results: results,
        totalOriginalSizeBytes: current.totalOriginalSizeBytes,
        totalCompressedSizeBytes: totalCompBytes,
      ));
    } catch (e) {
      emit(CompressorErrorState("Compression failed: ${e.toString()}"));
    }
  }

  void _onReset(ResetCompressorEvent event, Emitter<CompressorState> emit) {
    emit(CompressorInitialState());
  }
}
