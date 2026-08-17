import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/signature_stroke.dart';
import '../services/signature_service.dart';
import '../../../core/services/history_service.dart';

// Events
abstract class SignatureEvent extends Equatable {
  const SignatureEvent();
  @override
  List<Object?> get props => [];
}

class AddStrokePointEvent extends SignatureEvent {
  final Offset point;
  const AddStrokePointEvent(this.point);
  @override
  List<Object?> get props => [point];
}

class EndStrokeEvent extends SignatureEvent {}

class UndoStrokeEvent extends SignatureEvent {}

class ClearCanvasEvent extends SignatureEvent {}

class SetStrokeWidthEvent extends SignatureEvent {
  final double width;
  const SetStrokeWidthEvent(this.width);
  @override
  List<Object?> get props => [width];
}

class SetInkColorEvent extends SignatureEvent {
  final Color color;
  const SetInkColorEvent(this.color);
  @override
  List<Object?> get props => [color];
}

class SetSolidBgColorEvent extends SignatureEvent {
  final Color color;
  const SetSolidBgColorEvent(this.color);
  @override
  List<Object?> get props => [color];
}

class ScanPaperSignatureEvent extends SignatureEvent {
  final File photoFile;
  final double cropXRatio;
  final double cropYRatio;
  final double cropWidthRatio;
  final double cropHeightRatio;
  final num rotationAngle;

  const ScanPaperSignatureEvent({
    required this.photoFile,
    this.cropXRatio = 0.0,
    this.cropYRatio = 0.0,
    this.cropWidthRatio = 1.0,
    this.cropHeightRatio = 1.0,
    this.rotationAngle = 0,
  });

  @override
  List<Object?> get props => [
        photoFile,
        cropXRatio,
        cropYRatio,
        cropWidthRatio,
        cropHeightRatio,
        rotationAngle,
      ];
}

class AdjustSignatureEvent extends SignatureEvent {
  final double cropXRatio;
  final double cropYRatio;
  final double cropWidthRatio;
  final double cropHeightRatio;
  final num rotationAngle;

  const AdjustSignatureEvent({
    required this.cropXRatio,
    required this.cropYRatio,
    required this.cropWidthRatio,
    required this.cropHeightRatio,
    this.rotationAngle = 0,
  });

  @override
  List<Object?> get props => [
        cropXRatio,
        cropYRatio,
        cropWidthRatio,
        cropHeightRatio,
        rotationAngle,
      ];
}

class UpdateSignatureResultEvent extends SignatureEvent {
  final SignatureExportResult result;
  const UpdateSignatureResultEvent(this.result);
  @override
  List<Object?> get props => [result];
}

class StartExportSignatureEvent extends SignatureEvent {
  final Size canvasSize;
  const StartExportSignatureEvent(this.canvasSize);
  @override
  List<Object?> get props => [canvasSize];
}

class ResetSignatureEvent extends SignatureEvent {}

// States
abstract class SignatureState extends Equatable {
  const SignatureState();
  @override
  List<Object?> get props => [];
}

class SignatureInitialState extends SignatureState {
  final List<SignatureStroke> strokes;
  final SignatureStroke? currentStroke;
  final double strokeWidth;
  final Color inkColor;
  final Color solidBgColor;

  const SignatureInitialState({
    this.strokes = const [],
    this.currentStroke,
    this.strokeWidth = 4.0,
    this.inkColor = Colors.black,
    this.solidBgColor = Colors.white,
  });

  SignatureInitialState copyWith({
    List<SignatureStroke>? strokes,
    SignatureStroke? currentStroke,
    bool clearCurrent = false,
    double? strokeWidth,
    Color? inkColor,
    Color? solidBgColor,
  }) {
    return SignatureInitialState(
      strokes: strokes ?? this.strokes,
      currentStroke: clearCurrent ? null : (currentStroke ?? this.currentStroke),
      strokeWidth: strokeWidth ?? this.strokeWidth,
      inkColor: inkColor ?? this.inkColor,
      solidBgColor: solidBgColor ?? this.solidBgColor,
    );
  }

  @override
  List<Object?> get props => [
        strokes,
        currentStroke,
        strokeWidth,
        inkColor,
        solidBgColor,
      ];
}

class SignatureProcessingState extends SignatureState {}

class SignatureSuccessState extends SignatureState {
  final SignatureExportResult result;
  const SignatureSuccessState(this.result);
  @override
  List<Object?> get props => [result];
}

class SignatureErrorState extends SignatureState {
  final String message;
  const SignatureErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

class SignatureBloc extends Bloc<SignatureEvent, SignatureState> {
  final SignatureService signatureService;
  final HistoryService historyService;

  SignatureBloc({
    required this.signatureService,
    required this.historyService,
  }) : super(const SignatureInitialState()) {
    on<AddStrokePointEvent>(_onAddPoint);
    on<EndStrokeEvent>(_onEndStroke);
    on<UndoStrokeEvent>(_onUndo);
    on<ClearCanvasEvent>(_onClear);
    on<SetStrokeWidthEvent>(_onSetWidth);
    on<SetInkColorEvent>(_onSetInkColor);
    on<SetSolidBgColorEvent>(_onSetBgColor);
    on<ScanPaperSignatureEvent>(_onScanPaper);
    on<AdjustSignatureEvent>(_onAdjustSignature);
    on<UpdateSignatureResultEvent>(_onUpdateResult);
    on<StartExportSignatureEvent>(_onStartExport);
    on<ResetSignatureEvent>((event, emit) => emit(const SignatureInitialState()));
  }

  void _onAddPoint(AddStrokePointEvent event, Emitter<SignatureState> emit) {
    if (state is SignatureInitialState) {
      final current = state as SignatureInitialState;
      if (current.currentStroke == null) {
        emit(current.copyWith(
          currentStroke: SignatureStroke(
            points: [event.point],
            strokeWidth: current.strokeWidth,
            color: current.inkColor,
          ),
        ));
      } else {
        final pts = List<Offset>.from(current.currentStroke!.points)..add(event.point);
        emit(current.copyWith(
          currentStroke: current.currentStroke!.copyWith(points: pts),
        ));
      }
    }
  }

  void _onEndStroke(EndStrokeEvent event, Emitter<SignatureState> emit) {
    if (state is SignatureInitialState) {
      final current = state as SignatureInitialState;
      if (current.currentStroke != null && current.currentStroke!.points.isNotEmpty) {
        final list = List<SignatureStroke>.from(current.strokes)..add(current.currentStroke!);
        emit(current.copyWith(
          strokes: list,
          clearCurrent: true,
        ));
      }
    }
  }

  void _onUndo(UndoStrokeEvent event, Emitter<SignatureState> emit) {
    if (state is SignatureInitialState) {
      final current = state as SignatureInitialState;
      if (current.strokes.isNotEmpty) {
        final list = List<SignatureStroke>.from(current.strokes)..removeLast();
        emit(current.copyWith(strokes: list));
      }
    }
  }

  void _onClear(ClearCanvasEvent event, Emitter<SignatureState> emit) {
    if (state is SignatureInitialState) {
      final current = state as SignatureInitialState;
      emit(current.copyWith(strokes: [], clearCurrent: true));
    }
  }

  void _onSetWidth(SetStrokeWidthEvent event, Emitter<SignatureState> emit) {
    if (state is SignatureInitialState) {
      final current = state as SignatureInitialState;
      emit(current.copyWith(strokeWidth: event.width));
    }
  }

  void _onSetInkColor(SetInkColorEvent event, Emitter<SignatureState> emit) {
    if (state is SignatureInitialState) {
      final current = state as SignatureInitialState;
      emit(current.copyWith(inkColor: event.color));
    }
  }

  void _onSetBgColor(SetSolidBgColorEvent event, Emitter<SignatureState> emit) {
    if (state is SignatureInitialState) {
      final current = state as SignatureInitialState;
      emit(current.copyWith(solidBgColor: event.color));
    }
  }

  Future<void> _onScanPaper(ScanPaperSignatureEvent event, Emitter<SignatureState> emit) async {
    emit(SignatureProcessingState());
    try {
      final res = await signatureService.scanPaperSignature(
        photoFile: event.photoFile,
        cropXRatio: event.cropXRatio,
        cropYRatio: event.cropYRatio,
        cropWidthRatio: event.cropWidthRatio,
        cropHeightRatio: event.cropHeightRatio,
        rotationAngle: event.rotationAngle,
      );
      await historyService.addHistoryItem(HistoryItem(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        toolName: 'Scanned Digital Signature',
        originalPath: event.photoFile.path,
        processedPath: res.transparentPngFile.path,
        originalSizeBytes: 0,
        processedSizeBytes: res.fileSizeBytes,
        timestamp: DateTime.now(),
      ));
      emit(SignatureSuccessState(res));
    } catch (e) {
      emit(SignatureErrorState("Paper signature extraction failed: ${e.toString()}"));
    }
  }

  Future<void> _onAdjustSignature(AdjustSignatureEvent event, Emitter<SignatureState> emit) async {
    if (state is! SignatureSuccessState) return;
    final current = state as SignatureSuccessState;

    emit(SignatureProcessingState());
    try {
      final res = await signatureService.adjustSignature(
        transparentPngFile: current.result.transparentPngFile,
        cropXRatio: event.cropXRatio,
        cropYRatio: event.cropYRatio,
        cropWidthRatio: event.cropWidthRatio,
        cropHeightRatio: event.cropHeightRatio,
        rotationAngle: event.rotationAngle,
      );

      await historyService.addHistoryItem(HistoryItem(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        toolName: 'Adjusted Signature',
        originalPath: current.result.transparentPngFile.path,
        processedPath: res.transparentPngFile.path,
        originalSizeBytes: current.result.fileSizeBytes,
        processedSizeBytes: res.fileSizeBytes,
        timestamp: DateTime.now(),
      ));

      emit(SignatureSuccessState(res));
    } catch (e) {
      emit(SignatureErrorState("Signature adjustment failed: ${e.toString()}"));
    }
  }

  void _onUpdateResult(UpdateSignatureResultEvent event, Emitter<SignatureState> emit) {
    emit(SignatureSuccessState(event.result));
  }

  Future<void> _onStartExport(StartExportSignatureEvent event, Emitter<SignatureState> emit) async {
    if (state is! SignatureInitialState) return;
    final current = state as SignatureInitialState;

    if (current.strokes.isEmpty) {
      emit(const SignatureErrorState("Canvas is empty. Draw a signature first!"));
      return;
    }

    emit(SignatureProcessingState());
    try {
      final res = await signatureService.exportDrawnSignature(
        strokes: current.strokes,
        canvasSize: event.canvasSize,
        solidBgColor: current.solidBgColor,
      );

      await historyService.addHistoryItem(HistoryItem(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        toolName: 'Digital Signature',
        originalPath: res.transparentPngFile.path,
        processedPath: res.transparentPngFile.path,
        originalSizeBytes: res.fileSizeBytes,
        processedSizeBytes: res.fileSizeBytes,
        timestamp: DateTime.now(),
      ));

      emit(SignatureSuccessState(res));
    } catch (e) {
      emit(SignatureErrorState("Export failed: ${e.toString()}"));
    }
  }
}
