import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/image_pdf_service.dart';
import '../../../core/services/history_service.dart';

// Events
abstract class PdfEvent extends Equatable {
  const PdfEvent();
  @override
  List<Object?> get props => [];
}

class SelectPdfImagesEvent extends PdfEvent {
  final List<File> files;
  const SelectPdfImagesEvent(this.files);
  @override
  List<Object?> get props => [files];
}

class AddPdfImagesEvent extends PdfEvent {
  final List<File> files;
  const AddPdfImagesEvent(this.files);
  @override
  List<Object?> get props => [files];
}

class UpdatePdfPageImageEvent extends PdfEvent {
  final int index;
  final File updatedFile;
  const UpdatePdfPageImageEvent(this.index, this.updatedFile);
  @override
  List<Object?> get props => [index, updatedFile];
}

class RemovePdfPageEvent extends PdfEvent {
  final int index;
  const RemovePdfPageEvent(this.index);
  @override
  List<Object?> get props => [index];
}

class ReorderPdfImagesEvent extends PdfEvent {
  final int oldIndex;
  final int newIndex;
  const ReorderPdfImagesEvent(this.oldIndex, this.newIndex);
  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class SetPdfPageFormatEvent extends PdfEvent {
  final PdfPageFormatType format;
  const SetPdfPageFormatEvent(this.format);
  @override
  List<Object?> get props => [format];
}

class SetPdfOrientationEvent extends PdfEvent {
  final PdfOrientation orientation;
  const SetPdfOrientationEvent(this.orientation);
  @override
  List<Object?> get props => [orientation];
}

class SetPdfMarginEvent extends PdfEvent {
  final PdfMarginType margin;
  const SetPdfMarginEvent(this.margin);
  @override
  List<Object?> get props => [margin];
}

class StartPdfGenerationEvent extends PdfEvent {}

class ResetPdfEvent extends PdfEvent {}

// States
abstract class PdfState extends Equatable {
  const PdfState();
  @override
  List<Object?> get props => [];
}

class PdfInitialState extends PdfState {}

class PdfConfiguredState extends PdfState {
  final List<File> files;
  final PdfPageFormatType pageFormat;
  final PdfOrientation orientation;
  final PdfMarginType margin;

  const PdfConfiguredState({
    required this.files,
    this.pageFormat = PdfPageFormatType.a4,
    this.orientation = PdfOrientation.portrait,
    this.margin = PdfMarginType.small,
  });

  PdfConfiguredState copyWith({
    List<File>? files,
    PdfPageFormatType? pageFormat,
    PdfOrientation? orientation,
    PdfMarginType? margin,
  }) {
    return PdfConfiguredState(
      files: files ?? this.files,
      pageFormat: pageFormat ?? this.pageFormat,
      orientation: orientation ?? this.orientation,
      margin: margin ?? this.margin,
    );
  }

  @override
  List<Object?> get props => [files, pageFormat, orientation, margin];
}

class PdfProcessingState extends PdfState {}

class PdfSuccessState extends PdfState {
  final PdfResult result;
  const PdfSuccessState(this.result);
  @override
  List<Object?> get props => [result];
}

class PdfErrorState extends PdfState {
  final String message;
  const PdfErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

class PdfBloc extends Bloc<PdfEvent, PdfState> {
  final ImagePdfService pdfService;
  final HistoryService historyService;

  PdfBloc({
    required this.pdfService,
    required this.historyService,
  }) : super(PdfInitialState()) {
    on<SelectPdfImagesEvent>((event, emit) => emit(PdfConfiguredState(files: event.files)));
    on<AddPdfImagesEvent>(_onAddImages);
    on<UpdatePdfPageImageEvent>(_onUpdatePageImage);
    on<RemovePdfPageEvent>(_onRemovePage);
    on<ReorderPdfImagesEvent>(_onReorder);
    on<SetPdfPageFormatEvent>(_onSetFormat);
    on<SetPdfOrientationEvent>(_onSetOrientation);
    on<SetPdfMarginEvent>(_onSetMargin);
    on<StartPdfGenerationEvent>(_onStartPdf);
    on<ResetPdfEvent>((event, emit) => emit(PdfInitialState()));
  }

  void _onAddImages(AddPdfImagesEvent event, Emitter<PdfState> emit) {
    if (state is PdfConfiguredState) {
      final current = state as PdfConfiguredState;
      final updatedList = List<File>.from(current.files)..addAll(event.files);
      emit(current.copyWith(files: updatedList));
    }
  }

  void _onUpdatePageImage(UpdatePdfPageImageEvent event, Emitter<PdfState> emit) {
    if (state is PdfConfiguredState) {
      final current = state as PdfConfiguredState;
      if (event.index >= 0 && event.index < current.files.length) {
        final updatedList = List<File>.from(current.files);
        updatedList[event.index] = event.updatedFile;
        emit(current.copyWith(files: updatedList));
      }
    }
  }

  void _onRemovePage(RemovePdfPageEvent event, Emitter<PdfState> emit) {
    if (state is PdfConfiguredState) {
      final current = state as PdfConfiguredState;
      final updatedList = List<File>.from(current.files);
      if (event.index >= 0 && event.index < updatedList.length) {
        updatedList.removeAt(event.index);
      }
      if (updatedList.isEmpty) {
        emit(PdfInitialState());
      } else {
        emit(current.copyWith(files: updatedList));
      }
    }
  }

  void _onReorder(ReorderPdfImagesEvent event, Emitter<PdfState> emit) {
    if (state is PdfConfiguredState) {
      final current = state as PdfConfiguredState;
      final list = List<File>.from(current.files);
      int newIdx = event.newIndex;
      if (newIdx > event.oldIndex) newIdx -= 1;
      final item = list.removeAt(event.oldIndex);
      list.insert(newIdx, item);
      emit(current.copyWith(files: list));
    }
  }

  void _onSetFormat(SetPdfPageFormatEvent event, Emitter<PdfState> emit) {
    if (state is PdfConfiguredState) {
      final current = state as PdfConfiguredState;
      emit(current.copyWith(pageFormat: event.format));
    }
  }

  void _onSetOrientation(SetPdfOrientationEvent event, Emitter<PdfState> emit) {
    if (state is PdfConfiguredState) {
      final current = state as PdfConfiguredState;
      emit(current.copyWith(orientation: event.orientation));
    }
  }

  void _onSetMargin(SetPdfMarginEvent event, Emitter<PdfState> emit) {
    if (state is PdfConfiguredState) {
      final current = state as PdfConfiguredState;
      emit(current.copyWith(margin: event.margin));
    }
  }

  Future<void> _onStartPdf(StartPdfGenerationEvent event, Emitter<PdfState> emit) async {
    if (state is! PdfConfiguredState) return;
    final current = state as PdfConfiguredState;
    emit(PdfProcessingState());

    try {
      final res = await pdfService.generatePdf(
        imageFiles: current.files,
        pageFormat: current.pageFormat,
        orientation: current.orientation,
        margin: current.margin,
      );

      await historyService.addHistoryItem(HistoryItem(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        toolName: 'Image → PDF (${res.pageCount} Pages)',
        originalPath: current.files.first.path,
        processedPath: res.pdfFile.path,
        originalSizeBytes: 0,
        processedSizeBytes: res.fileSizeBytes,
        timestamp: DateTime.now(),
      ));

      emit(PdfSuccessState(res));
    } catch (e) {
      emit(PdfErrorState("PDF generation failed: ${e.toString()}"));
    }
  }
}
