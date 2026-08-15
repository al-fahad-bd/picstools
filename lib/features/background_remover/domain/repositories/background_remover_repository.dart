import 'dart:io';
import '../entities/ai_model_info.dart';
import '../entities/background_removal_result.dart';

abstract class BackgroundRemoverRepository {
  /// Retrieves the current AI model status (downloaded/not, size, metadata)
  Future<AiModelInfo> getModelInfo();

  /// Starts downloading the AI model with progress callbacks
  Future<File> downloadModel({
    required void Function(int receivedBytes, int totalBytes, double percentage) onProgress,
  });

  /// Cancels any active model download
  void cancelDownload();

  /// Deletes the local AI model from disk
  Future<bool> deleteModel();

  /// Performs complete on-device background removal pipeline
  Future<BackgroundRemovalResult> removeBackground({
    required File imageFile,
  });
}
