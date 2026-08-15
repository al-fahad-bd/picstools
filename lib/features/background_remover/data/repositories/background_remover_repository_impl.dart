import 'dart:io';
import '../../domain/entities/ai_model_info.dart';
import '../../domain/entities/background_removal_result.dart';
import '../../domain/repositories/background_remover_repository.dart';
import '../datasources/model_downloader_datasource.dart';
import '../datasources/model_storage_datasource.dart';
import '../datasources/onnx_inference_datasource.dart';

class BackgroundRemoverRepositoryImpl implements BackgroundRemoverRepository {
  final ModelStorageDataSource storageDataSource;
  final ModelDownloaderDataSource downloaderDataSource;
  final OnnxInferenceDataSource inferenceDataSource;

  BackgroundRemoverRepositoryImpl({
    required this.storageDataSource,
    required this.downloaderDataSource,
    required this.inferenceDataSource,
  });

  @override
  Future<AiModelInfo> getModelInfo() async {
    return await storageDataSource.getStoredModelInfo();
  }

  @override
  Future<File> downloadModel({
    required void Function(int receivedBytes, int totalBytes, double percentage) onProgress,
  }) async {
    final currentInfo = await storageDataSource.getStoredModelInfo();
    return await downloaderDataSource.downloadModel(
      modelInfo: currentInfo,
      onProgress: onProgress,
    );
  }

  @override
  void cancelDownload() {
    downloaderDataSource.cancelDownload();
  }

  @override
  Future<bool> deleteModel() async {
    return await storageDataSource.deleteModel();
  }

  @override
  Future<BackgroundRemovalResult> removeBackground({
    required File imageFile,
  }) async {
    final modelInfo = await storageDataSource.getStoredModelInfo();
    final modelFile = await storageDataSource.getFinalModelFile(
      modelId: modelInfo.modelId,
      version: modelInfo.version,
      fileName: modelInfo.fileName,
    );

    if (!await modelFile.exists()) {
      throw Exception(
        'AI model file not found on device. Please download the model first.',
      );
    }

    return await inferenceDataSource.runInference(
      imageFile: imageFile,
      modelFilePath: modelFile.path,
    );
  }
}
