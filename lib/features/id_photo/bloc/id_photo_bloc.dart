import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/id_photo_preset.dart';
import '../services/id_photo_service.dart';
import '../../../core/services/history_service.dart';

// Events
abstract class IdPhotoEvent extends Equatable {
  const IdPhotoEvent();
  @override
  List<Object?> get props => [];
}

class SelectPresetEvent extends IdPhotoEvent {
  final IdPhotoPreset preset;
  const SelectPresetEvent(this.preset);
  @override
  List<Object?> get props => [preset];
}

class SelectPhotoEvent extends IdPhotoEvent {
  final File file;
  const SelectPhotoEvent(this.file);
  @override
  List<Object?> get props => [file];
}

class UpdateNormCropRectIdEvent extends IdPhotoEvent {
  final Rect normCropRect;
  const UpdateNormCropRectIdEvent(this.normCropRect);
  @override
  List<Object?> get props => [normCropRect];
}

class SetBackgroundColorEvent extends IdPhotoEvent {
  final Color color;
  const SetBackgroundColorEvent(this.color);
  @override
  List<Object?> get props => [color];
}

class SetPrintSheetTypeEvent extends IdPhotoEvent {
  final PrintSheetType sheetType;
  const SetPrintSheetTypeEvent(this.sheetType);
  @override
  List<Object?> get props => [sheetType];
}

class RotatePhotoEvent extends IdPhotoEvent {}

class StartProcessingIdPhotoEvent extends IdPhotoEvent {}

class ResetIdPhotoEvent extends IdPhotoEvent {}

// States
abstract class IdPhotoState extends Equatable {
  const IdPhotoState();
  @override
  List<Object?> get props => [];
}

class IdPhotoInitialState extends IdPhotoState {}

class IdPhotoConfiguredState extends IdPhotoState {
  final File file;
  final IdPhotoPreset preset;
  final Rect normCropRect;
  final Color bgColor;
  final PrintSheetType sheetType;
  final int rotationAngle;

  const IdPhotoConfiguredState({
    required this.file,
    required this.preset,
    this.normCropRect = const Rect.fromLTWH(0.1, 0.1, 0.8, 0.8),
    this.bgColor = Colors.white,
    this.sheetType = PrintSheetType.sheet4x6,
    this.rotationAngle = 0,
  });

  IdPhotoConfiguredState copyWith({
    File? file,
    IdPhotoPreset? preset,
    Rect? normCropRect,
    Color? bgColor,
    PrintSheetType? sheetType,
    int? rotationAngle,
  }) {
    return IdPhotoConfiguredState(
      file: file ?? this.file,
      preset: preset ?? this.preset,
      normCropRect: normCropRect ?? this.normCropRect,
      bgColor: bgColor ?? this.bgColor,
      sheetType: sheetType ?? this.sheetType,
      rotationAngle: rotationAngle ?? this.rotationAngle,
    );
  }

  @override
  List<Object?> get props => [
        file,
        preset,
        normCropRect,
        bgColor,
        sheetType,
        rotationAngle,
      ];
}

class IdPhotoProcessingState extends IdPhotoState {}

class IdPhotoSuccessState extends IdPhotoState {
  final IdPhotoResult result;
  const IdPhotoSuccessState(this.result);
  @override
  List<Object?> get props => [result];
}

class IdPhotoErrorState extends IdPhotoState {
  final String message;
  const IdPhotoErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

class IdPhotoBloc extends Bloc<IdPhotoEvent, IdPhotoState> {
  final IdPhotoService idPhotoService;
  final HistoryService historyService;

  IdPhotoBloc({
    required this.idPhotoService,
    required this.historyService,
  }) : super(IdPhotoInitialState()) {
    on<SelectPresetEvent>(_onSelectPreset);
    on<SelectPhotoEvent>(_onSelectPhoto);
    on<UpdateNormCropRectIdEvent>(_onUpdateRect);
    on<SetBackgroundColorEvent>(_onSetBgColor);
    on<SetPrintSheetTypeEvent>(_onSetSheetType);
    on<RotatePhotoEvent>(_onRotate);
    on<StartProcessingIdPhotoEvent>(_onStartProcessing);
    on<ResetIdPhotoEvent>((event, emit) => emit(IdPhotoInitialState()));
  }

  void _onSelectPreset(SelectPresetEvent event, Emitter<IdPhotoState> emit) {
    if (state is IdPhotoConfiguredState) {
      final current = state as IdPhotoConfiguredState;
      emit(current.copyWith(preset: event.preset));
    }
  }

  void _onSelectPhoto(SelectPhotoEvent event, Emitter<IdPhotoState> emit) {
    final defaultPreset = IdPhotoPreset.defaultPresets.first;
    if (state is IdPhotoConfiguredState) {
      final current = state as IdPhotoConfiguredState;
      emit(current.copyWith(file: event.file));
    } else {
      emit(IdPhotoConfiguredState(
        file: event.file,
        preset: defaultPreset,
      ));
    }
  }

  void _onUpdateRect(UpdateNormCropRectIdEvent event, Emitter<IdPhotoState> emit) {
    if (state is IdPhotoConfiguredState) {
      final current = state as IdPhotoConfiguredState;
      emit(current.copyWith(normCropRect: event.normCropRect));
    }
  }

  void _onSetBgColor(SetBackgroundColorEvent event, Emitter<IdPhotoState> emit) {
    if (state is IdPhotoConfiguredState) {
      final current = state as IdPhotoConfiguredState;
      emit(current.copyWith(bgColor: event.color));
    }
  }

  void _onSetSheetType(SetPrintSheetTypeEvent event, Emitter<IdPhotoState> emit) {
    if (state is IdPhotoConfiguredState) {
      final current = state as IdPhotoConfiguredState;
      emit(current.copyWith(sheetType: event.sheetType));
    }
  }

  void _onRotate(RotatePhotoEvent event, Emitter<IdPhotoState> emit) {
    if (state is IdPhotoConfiguredState) {
      final current = state as IdPhotoConfiguredState;
      final nextAngle = (current.rotationAngle + 90) % 360;
      emit(current.copyWith(rotationAngle: nextAngle));
    }
  }

  Future<void> _onStartProcessing(StartProcessingIdPhotoEvent event, Emitter<IdPhotoState> emit) async {
    if (state is! IdPhotoConfiguredState) return;
    final current = state as IdPhotoConfiguredState;
    emit(IdPhotoProcessingState());

    try {
      final res = await idPhotoService.createPassportPhoto(
        imageFile: current.file,
        preset: current.preset,
        normCropRect: current.normCropRect,
        bgColor: current.bgColor,
        sheetType: current.sheetType,
        rotationAngle: current.rotationAngle,
      );

      await historyService.addHistoryItem(HistoryItem(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        toolName: 'ID Photo (${res.preset.title})',
        originalPath: current.file.path,
        processedPath: res.singlePhotoFile.path,
        originalSizeBytes: 0,
        processedSizeBytes: res.singleFileSizeBytes,
        timestamp: DateTime.now(),
      ));

      emit(IdPhotoSuccessState(res));
    } catch (e) {
      emit(IdPhotoErrorState("ID Photo generation failed: ${e.toString()}"));
    }
  }
}
