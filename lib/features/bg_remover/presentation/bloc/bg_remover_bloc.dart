import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/history_service.dart';
import '../../domain/entities/bg_remover_params.dart';
import '../../domain/repositories/bg_remover_repository.dart';
import 'bg_remover_event.dart';
import 'bg_remover_state.dart';

class BgRemoverBloc extends Bloc<BgRemoverEvent, BgRemoverState> {
  final BgRemoverRepository _repository;
  File? _currentOriginalImage;

  BgRemoverBloc(this._repository) : super(BgRemoverInitial()) {
    on<SelectImageEvent>(_onSelectImage);
    on<ProcessSegmentationEvent>(_onProcessSegmentation);
    on<ResetBgRemoverEvent>(_onReset);
  }

  Future<void> _onSelectImage(
    SelectImageEvent event,
    Emitter<BgRemoverState> emit,
  ) async {
    _currentOriginalImage = event.imageFile;
    const defaultParams = BgRemoverParams();

    emit(BgRemoverProcessing(event.imageFile));
    await _executeSegmentation(event.imageFile, defaultParams, emit);
  }

  Future<void> _onProcessSegmentation(
    ProcessSegmentationEvent event,
    Emitter<BgRemoverState> emit,
  ) async {
    if (_currentOriginalImage == null) return;
    emit(BgRemoverProcessing(_currentOriginalImage!));
    await _executeSegmentation(_currentOriginalImage!, event.params, emit);
  }

  Future<void> _executeSegmentation(
    File originalFile,
    BgRemoverParams params,
    Emitter<BgRemoverState> emit,
  ) async {
    try {
      final processedFile = await _repository.removeBackground(
        imageFile: originalFile,
        params: params,
      );

      // Record to history
      final historyService = getIt<HistoryService>();
      final origSize = await originalFile.length();
      final procSize = await processedFile.length();

      await historyService.addHistoryItem(
        HistoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          toolName: 'Background Remover',
          originalPath: originalFile.path,
          processedPath: processedFile.path,
          originalSizeBytes: origSize,
          processedSizeBytes: procSize,
          timestamp: DateTime.now(),
        ),
      );

      emit(BgRemoverSuccess(
        originalImage: originalFile,
        processedImage: processedFile,
        params: params,
      ));
    } catch (e) {
      emit(BgRemoverFailure('Background removal failed: $e'));
    }
  }

  void _onReset(
    ResetBgRemoverEvent event,
    Emitter<BgRemoverState> emit,
  ) {
    _currentOriginalImage = null;
    emit(BgRemoverInitial());
  }
}
