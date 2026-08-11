import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/image_cropper_service.dart';
import '../../../core/services/history_service.dart';

// Events
abstract class CropperEvent extends Equatable {
  const CropperEvent();
  @override
  List<Object?> get props => [];
}

class SelectCropImageEvent extends CropperEvent {
  final File file;
  const SelectCropImageEvent(this.file);
  @override
  List<Object?> get props => [file];
}

class SetCropAspectRatioEvent extends CropperEvent {
  final String ratioName; // Free, 1:1, 4:3, 3:4, 16:9, 9:16
  final double? ratioValue;
  const SetCropAspectRatioEvent(this.ratioName, this.ratioValue);
  @override
  List<Object?> get props => [ratioName, ratioValue];
}

class UpdateNormCropRectEvent extends CropperEvent {
  final Rect normCropRect;
  const UpdateNormCropRectEvent(this.normCropRect);
  @override
  List<Object?> get props => [normCropRect];
}

class Rotate90ClockwiseEvent extends CropperEvent {}

class ToggleFlipHorizontalEvent extends CropperEvent {}

class ToggleFlipVerticalEvent extends CropperEvent {}

class StartCropEvent extends CropperEvent {}

class ResetCropperEvent extends CropperEvent {}

// States
abstract class CropperState extends Equatable {
  const CropperState();
  @override
  List<Object?> get props => [];
}

class CropperInitialState extends CropperState {}

class CropperConfiguredState extends CropperState {
  final File file;
  final String selectedRatioName;
  final double? selectedRatioValue;
  final Rect normCropRect;
  final int rotationAngle; // 0, 90, 180, 270
  final bool flipHorizontal;
  final bool flipVertical;

  const CropperConfiguredState({
    required this.file,
    this.selectedRatioName = 'Free',
    this.selectedRatioValue,
    this.normCropRect = const Rect.fromLTWH(0.05, 0.05, 0.9, 0.9),
    this.rotationAngle = 0,
    this.flipHorizontal = false,
    this.flipVertical = false,
  });

  CropperConfiguredState copyWith({
    File? file,
    String? selectedRatioName,
    double? selectedRatioValue,
    bool clearRatioValue = false,
    Rect? normCropRect,
    int? rotationAngle,
    bool? flipHorizontal,
    bool? flipVertical,
  }) {
    return CropperConfiguredState(
      file: file ?? this.file,
      selectedRatioName: selectedRatioName ?? this.selectedRatioName,
      selectedRatioValue: clearRatioValue
          ? null
          : (selectedRatioValue ?? this.selectedRatioValue),
      normCropRect: normCropRect ?? this.normCropRect,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
    );
  }

  @override
  List<Object?> get props => [
        file,
        selectedRatioName,
        selectedRatioValue,
        normCropRect,
        rotationAngle,
        flipHorizontal,
        flipVertical,
      ];
}

class CropperProcessingState extends CropperState {}

class CropperSuccessState extends CropperState {
  final CropResult result;
  const CropperSuccessState(this.result);
  @override
  List<Object?> get props => [result];
}

class CropperErrorState extends CropperState {
  final String message;
  const CropperErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

class CropperBloc extends Bloc<CropperEvent, CropperState> {
  final ImageCropperService cropperService;
  final HistoryService historyService;

  CropperBloc({
    required this.cropperService,
    required this.historyService,
  }) : super(CropperInitialState()) {
    on<SelectCropImageEvent>((event, emit) => emit(CropperConfiguredState(file: event.file)));
    on<SetCropAspectRatioEvent>(_onSetRatio);
    on<UpdateNormCropRectEvent>(_onUpdateRect);
    on<Rotate90ClockwiseEvent>(_onRotate);
    on<ToggleFlipHorizontalEvent>(_onFlipH);
    on<ToggleFlipVerticalEvent>(_onFlipV);
    on<StartCropEvent>(_onStartCrop);
    on<ResetCropperEvent>((event, emit) => emit(CropperInitialState()));
  }

  void _onSetRatio(SetCropAspectRatioEvent event, Emitter<CropperState> emit) {
    if (state is CropperConfiguredState) {
      final current = state as CropperConfiguredState;
      emit(current.copyWith(
        selectedRatioName: event.ratioName,
        selectedRatioValue: event.ratioValue,
        clearRatioValue: event.ratioValue == null,
      ));
    }
  }

  void _onUpdateRect(UpdateNormCropRectEvent event, Emitter<CropperState> emit) {
    if (state is CropperConfiguredState) {
      final current = state as CropperConfiguredState;
      emit(current.copyWith(normCropRect: event.normCropRect));
    }
  }

  void _onRotate(Rotate90ClockwiseEvent event, Emitter<CropperState> emit) {
    if (state is CropperConfiguredState) {
      final current = state as CropperConfiguredState;
      final nextAngle = (current.rotationAngle + 90) % 360;
      emit(current.copyWith(rotationAngle: nextAngle));
    }
  }

  void _onFlipH(ToggleFlipHorizontalEvent event, Emitter<CropperState> emit) {
    if (state is CropperConfiguredState) {
      final current = state as CropperConfiguredState;
      emit(current.copyWith(flipHorizontal: !current.flipHorizontal));
    }
  }

  void _onFlipV(ToggleFlipVerticalEvent event, Emitter<CropperState> emit) {
    if (state is CropperConfiguredState) {
      final current = state as CropperConfiguredState;
      emit(current.copyWith(flipVertical: !current.flipVertical));
    }
  }

  Future<void> _onStartCrop(StartCropEvent event, Emitter<CropperState> emit) async {
    if (state is! CropperConfiguredState) return;
    final current = state as CropperConfiguredState;
    emit(CropperProcessingState());

    try {
      final res = await cropperService.processCrop(
        imageFile: current.file,
        cropXRatio: current.normCropRect.left,
        cropYRatio: current.normCropRect.top,
        cropWidthRatio: current.normCropRect.width,
        cropHeightRatio: current.normCropRect.height,
        rotationAngle: current.rotationAngle,
        flipHorizontal: current.flipHorizontal,
        flipVertical: current.flipVertical,
      );

      await historyService.addHistoryItem(HistoryItem(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        toolName: 'Crop',
        originalPath: res.originalFile.path,
        processedPath: res.croppedFile.path,
        originalSizeBytes: res.originalSizeBytes,
        processedSizeBytes: res.croppedSizeBytes,
        timestamp: DateTime.now(),
      ));

      emit(CropperSuccessState(res));
    } catch (e) {
      emit(CropperErrorState("Crop failed: ${e.toString()}"));
    }
  }
}
