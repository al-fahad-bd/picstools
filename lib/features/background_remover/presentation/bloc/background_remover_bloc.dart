import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/history_service.dart';
import '../../domain/entities/ai_model_info.dart';
import '../../domain/usecases/cancel_model_download_usecase.dart';
import '../../domain/usecases/check_model_status_usecase.dart';
import '../../domain/usecases/delete_model_usecase.dart';
import '../../domain/usecases/download_model_usecase.dart';
import '../../domain/usecases/remove_background_usecase.dart';
import 'background_remover_event.dart';
import 'background_remover_state.dart';

class BackgroundRemoverBloc
    extends Bloc<BackgroundRemoverEvent, BackgroundRemoverState> {
  final CheckModelStatusUseCase checkModelStatusUseCase;
  final DownloadModelUseCase downloadModelUseCase;
  final CancelModelDownloadUseCase cancelModelDownloadUseCase;
  final DeleteModelUseCase deleteModelUseCase;
  final RemoveBackgroundUseCase removeBackgroundUseCase;
  final HistoryService historyService;

  AiModelInfo? _cachedModelInfo;

  BackgroundRemoverBloc({
    required this.checkModelStatusUseCase,
    required this.downloadModelUseCase,
    required this.cancelModelDownloadUseCase,
    required this.deleteModelUseCase,
    required this.removeBackgroundUseCase,
    required this.historyService,
  }) : super(BackgroundRemoverInitial()) {
    on<CheckModelStatusEvent>(_onCheckModelStatus);
    on<DownloadModelEvent>(_onDownloadModel);
    on<CancelDownloadEvent>(_onCancelDownload);
    on<DeleteModelEvent>(_onDeleteModel);
    on<SelectImageEvent>(_onSelectImage);
    on<ProcessBackgroundRemovalEvent>(_onProcessBackgroundRemoval);
    on<ResetBackgroundRemoverEvent>(_onReset);
  }

  Future<void> _onCheckModelStatus(
    CheckModelStatusEvent event,
    Emitter<BackgroundRemoverState> emit,
  ) async {
    debugPrint('[BackgroundRemoverBloc] Checking AI model status...');
    emit(const BackgroundRemoverLoadingState('Checking AI model status...'));
    try {
      final info = await checkModelStatusUseCase();
      _cachedModelInfo = info;
      debugPrint('[BackgroundRemoverBloc] Model status checked: isDownloaded=${info.isDownloaded}, path=${info.localFilePath}, size=${info.actualSizeBytes}');
      if (info.isDownloaded) {
        emit(ModelReadyState(modelInfo: info));
      } else {
        emit(ModelNotDownloadedState(info));
      }
    } catch (e, stackTrace) {
      debugPrint('════════════════════════════════════════════════════════════');
      debugPrint('[BackgroundRemoverBloc] ❌ Could not check model status: $e');
      debugPrint('[BackgroundRemoverBloc] StackTrace:\n$stackTrace');
      debugPrint('════════════════════════════════════════════════════════════');
      emit(BackgroundRemoverErrorState(
        message: 'Could not check model status: $e',
        modelInfo: _cachedModelInfo,
      ));
    }
  }

  Future<void> _onDownloadModel(
    DownloadModelEvent event,
    Emitter<BackgroundRemoverState> emit,
  ) async {
    debugPrint('[BackgroundRemoverBloc] Initiating model download...');
    final info = _cachedModelInfo ?? await checkModelStatusUseCase();
    _cachedModelInfo = info;

    emit(ModelDownloadingState(
      progress: 0.0,
      receivedBytes: 0,
      totalBytes: info.expectedSizeBytes,
      modelInfo: info,
    ));

    try {
      await downloadModelUseCase(
        onProgress: (received, total, percentage) {
          if (!isClosed) {
            emit(ModelDownloadingState(
              progress: percentage,
              receivedBytes: received,
              totalBytes: total,
              modelInfo: info,
            ));
          }
        },
      );

      final updatedInfo = await checkModelStatusUseCase();
      _cachedModelInfo = updatedInfo;
      debugPrint('[BackgroundRemoverBloc] Model download completed successfully. ModelReady.');
      emit(ModelReadyState(modelInfo: updatedInfo));
    } catch (e, stackTrace) {
      debugPrint('════════════════════════════════════════════════════════════');
      debugPrint('[BackgroundRemoverBloc] ❌ Download error: $e');
      debugPrint('[BackgroundRemoverBloc] StackTrace:\n$stackTrace');
      debugPrint('════════════════════════════════════════════════════════════');
      if (e.toString().contains('cancelled') || e.toString().contains('canceled')) {
        emit(ModelNotDownloadedState(info));
      } else {
        emit(BackgroundRemoverErrorState(
          message: 'Download failed: $e',
          canRetry: true,
          modelInfo: info,
        ));
      }
    }
  }

  void _onCancelDownload(
    CancelDownloadEvent event,
    Emitter<BackgroundRemoverState> emit,
  ) {
    debugPrint('[BackgroundRemoverBloc] Cancelling model download...');
    cancelModelDownloadUseCase();
    if (_cachedModelInfo != null) {
      emit(ModelNotDownloadedState(_cachedModelInfo!));
    } else {
      add(CheckModelStatusEvent());
    }
  }

  Future<void> _onDeleteModel(
    DeleteModelEvent event,
    Emitter<BackgroundRemoverState> emit,
  ) async {
    debugPrint('[BackgroundRemoverBloc] Deleting model from disk...');
    emit(const BackgroundRemoverLoadingState('Removing AI model from disk...'));
    try {
      await deleteModelUseCase();
      final info = await checkModelStatusUseCase();
      _cachedModelInfo = info;
      debugPrint('[BackgroundRemoverBloc] Model deleted.');
      emit(ModelNotDownloadedState(info));
    } catch (e, stackTrace) {
      debugPrint('════════════════════════════════════════════════════════════');
      debugPrint('[BackgroundRemoverBloc] ❌ Failed to delete model: $e');
      debugPrint('[BackgroundRemoverBloc] StackTrace:\n$stackTrace');
      debugPrint('════════════════════════════════════════════════════════════');
      emit(BackgroundRemoverErrorState(
        message: 'Failed to delete model: $e',
        modelInfo: _cachedModelInfo,
      ));
    }
  }

  Future<void> _onSelectImage(
    SelectImageEvent event,
    Emitter<BackgroundRemoverState> emit,
  ) async {
    debugPrint('[BackgroundRemoverBloc] Image selected: ${event.file.path}');
    add(ProcessBackgroundRemovalEvent(event.file));
  }

  Future<void> _onProcessBackgroundRemoval(
    ProcessBackgroundRemovalEvent event,
    Emitter<BackgroundRemoverState> emit,
  ) async {
    debugPrint('[BackgroundRemoverBloc] Processing background removal for: ${event.file.path}');
    emit(BackgroundRemovingState(originalImage: event.file));
    try {
      final result = await removeBackgroundUseCase(imageFile: event.file);

      // Add to global HistoryService
      try {
        await historyService.addHistoryItem(
          HistoryItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            toolName: 'Remove BG',
            originalPath: result.originalFile.path,
            processedPath: result.transparentPngFile.path,
            originalSizeBytes: result.originalSizeBytes,
            processedSizeBytes: result.processedSizeBytes,
            timestamp: DateTime.now(),
          ),
        );
      } catch (histErr) {
        debugPrint('[BackgroundRemoverBloc] HistoryService error (non-fatal): $histErr');
      }

      debugPrint('[BackgroundRemoverBloc] Background removal succeeded in ${result.duration.inMilliseconds}ms');
      emit(BackgroundRemovalSuccessState(result));
    } catch (e, stackTrace) {
      debugPrint('════════════════════════════════════════════════════════════');
      debugPrint('[BackgroundRemoverBloc] ❌ BACKGROUND REMOVAL PROCESS ERROR: $e');
      debugPrint('[BackgroundRemoverBloc] StackTrace:\n$stackTrace');
      debugPrint('════════════════════════════════════════════════════════════');
      emit(BackgroundRemoverErrorState(
        message: 'Background removal error: $e',
        canRetry: true,
        modelInfo: _cachedModelInfo,
      ));
    }
  }

  Future<void> _onReset(
    ResetBackgroundRemoverEvent event,
    Emitter<BackgroundRemoverState> emit,
  ) async {
    debugPrint('[BackgroundRemoverBloc] Resetting background remover state...');
    if (_cachedModelInfo != null && _cachedModelInfo!.isDownloaded) {
      emit(ModelReadyState(modelInfo: _cachedModelInfo!));
    } else {
      add(CheckModelStatusEvent());
    }
  }
}
