import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/image_converter_service.dart';
import '../../../core/services/history_service.dart';

// Events
abstract class ConverterEvent extends Equatable {
  const ConverterEvent();
  @override
  List<Object?> get props => [];
}

class SelectConvertImagesEvent extends ConverterEvent {
  final List<File> files;
  const SelectConvertImagesEvent(this.files);
  @override
  List<Object?> get props => [files];
}

class SetTargetFormatEvent extends ConverterEvent {
  final String format; // JPG, PNG, WEBP
  const SetTargetFormatEvent(this.format);
  @override
  List<Object?> get props => [format];
}

class SetConvertQualityEvent extends ConverterEvent {
  final int quality;
  const SetConvertQualityEvent(this.quality);
  @override
  List<Object?> get props => [quality];
}

class StartConversionEvent extends ConverterEvent {}

class ResetConverterEvent extends ConverterEvent {}

// States
abstract class ConverterState extends Equatable {
  const ConverterState();
  @override
  List<Object?> get props => [];
}

class ConverterInitialState extends ConverterState {}

class ConverterConfiguredState extends ConverterState {
  final List<File> files;
  final String targetFormat;
  final int quality;

  const ConverterConfiguredState({
    required this.files,
    this.targetFormat = 'JPG',
    this.quality = 90,
  });

  ConverterConfiguredState copyWith({
    List<File>? files,
    String? targetFormat,
    int? quality,
  }) {
    return ConverterConfiguredState(
      files: files ?? this.files,
      targetFormat: targetFormat ?? this.targetFormat,
      quality: quality ?? this.quality,
    );
  }

  @override
  List<Object?> get props => [files, targetFormat, quality];
}

class ConverterProcessingState extends ConverterState {
  final int currentIndex;
  final int totalCount;
  final double progress;

  const ConverterProcessingState({
    required this.currentIndex,
    required this.totalCount,
    required this.progress,
  });

  @override
  List<Object?> get props => [currentIndex, totalCount, progress];
}

class ConverterSuccessState extends ConverterState {
  final List<ConvertResult> results;
  const ConverterSuccessState(this.results);
  @override
  List<Object?> get props => [results];
}

class ConverterErrorState extends ConverterState {
  final String message;
  const ConverterErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

class ConverterBloc extends Bloc<ConverterEvent, ConverterState> {
  final ImageConverterService converterService;
  final HistoryService historyService;

  ConverterBloc({
    required this.converterService,
    required this.historyService,
  }) : super(ConverterInitialState()) {
    on<SelectConvertImagesEvent>((event, emit) => emit(ConverterConfiguredState(files: event.files)));
    on<SetTargetFormatEvent>(_onSetFormat);
    on<SetConvertQualityEvent>(_onSetQuality);
    on<StartConversionEvent>(_onStartConversion);
    on<ResetConverterEvent>((event, emit) => emit(ConverterInitialState()));
  }

  void _onSetFormat(SetTargetFormatEvent event, Emitter<ConverterState> emit) {
    if (state is ConverterConfiguredState) {
      final current = state as ConverterConfiguredState;
      emit(current.copyWith(targetFormat: event.format));
    }
  }

  void _onSetQuality(SetConvertQualityEvent event, Emitter<ConverterState> emit) {
    if (state is ConverterConfiguredState) {
      final current = state as ConverterConfiguredState;
      emit(current.copyWith(quality: event.quality));
    }
  }

  Future<void> _onStartConversion(StartConversionEvent event, Emitter<ConverterState> emit) async {
    if (state is! ConverterConfiguredState) return;
    final current = state as ConverterConfiguredState;

    emit(ConverterProcessingState(
      currentIndex: 0,
      totalCount: current.files.length,
      progress: 0.0,
    ));

    final results = <ConvertResult>[];

    try {
      for (int i = 0; i < current.files.length; i++) {
        emit(ConverterProcessingState(
          currentIndex: i + 1,
          totalCount: current.files.length,
          progress: (i + 1) / current.files.length,
        ));

        final res = await converterService.convertImage(
          imageFile: current.files[i],
          targetFormat: current.targetFormat,
          quality: current.quality,
        );

        results.add(res);

        await historyService.addHistoryItem(HistoryItem(
          id: '${DateTime.now().millisecondsSinceEpoch}_$i',
          toolName: 'Convert (${res.targetFormat})',
          originalPath: res.originalFile.path,
          processedPath: res.convertedFile.path,
          originalSizeBytes: res.originalSizeBytes,
          processedSizeBytes: res.convertedSizeBytes,
          timestamp: DateTime.now(),
        ));
      }

      emit(ConverterSuccessState(results));
    } catch (e) {
      emit(ConverterErrorState("Conversion failed: ${e.toString()}"));
    }
  }
}
