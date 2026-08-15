import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/ai_model_info_model.dart';

abstract class ModelStorageDataSource {
  Future<String> getModelDirectoryPath({
    String modelId = 'u2netp',
    String version = '1.0.0',
  });

  Future<File> getFinalModelFile({
    String modelId = 'u2netp',
    String version = '1.0.0',
    String fileName = 'u2netp.onnx',
  });

  Future<File> getTempDownloadFile({
    String modelId = 'u2netp',
    String version = '1.0.0',
    String fileName = 'u2netp.onnx',
  });

  Future<AiModelInfoModel> getStoredModelInfo({
    String modelId = 'u2netp',
    String version = '1.0.0',
  });

  Future<void> saveMetadata(AiModelInfoModel modelInfo);

  Future<bool> deleteModel({
    String modelId = 'u2netp',
    String version = '1.0.0',
  });

  Future<bool> isModelInstalled({
    String modelId = 'u2netp',
    String version = '1.0.0',
  });
}

class ModelStorageDataSourceImpl implements ModelStorageDataSource {
  @override
  Future<String> getModelDirectoryPath({
    String modelId = 'u2netp',
    String version = '1.0.0',
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dirPath = p.join(
      docsDir.path,
      'ai_models',
      'background_remover',
      modelId,
      version,
    );
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dirPath;
  }

  @override
  Future<File> getFinalModelFile({
    String modelId = 'u2netp',
    String version = '1.0.0',
    String fileName = 'u2netp.onnx',
  }) async {
    final dir = await getModelDirectoryPath(modelId: modelId, version: version);
    return File(p.join(dir, fileName));
  }

  @override
  Future<File> getTempDownloadFile({
    String modelId = 'u2netp',
    String version = '1.0.0',
    String fileName = 'u2netp.onnx',
  }) async {
    final dir = await getModelDirectoryPath(modelId: modelId, version: version);
    return File(p.join(dir, '$fileName.downloading'));
  }

  @override
  Future<AiModelInfoModel> getStoredModelInfo({
    String modelId = 'u2netp',
    String version = '1.0.0',
  }) async {
    final dir = await getModelDirectoryPath(modelId: modelId, version: version);
    final metaFile = File(p.join(dir, 'metadata.json'));
    final modelFile = await getFinalModelFile(modelId: modelId, version: version);

    final exists = await modelFile.exists();
    final fileSize = exists ? await modelFile.length() : 0;
    final isComplete = exists && fileSize > (2 * 1024 * 1024); // at least 2MB

    if (await metaFile.exists()) {
      try {
        final content = await metaFile.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        final model = AiModelInfoModel.fromJson(json);
        return model.copyWith(
          isDownloaded: isComplete,
          localFilePath: isComplete ? modelFile.path : null,
          actualSizeBytes: fileSize,
        );
      } catch (_) {}
    }

    return AiModelInfoModel.defaultModel.copyWith(
      isDownloaded: isComplete,
      localFilePath: isComplete ? modelFile.path : null,
      actualSizeBytes: fileSize,
    );
  }

  @override
  Future<void> saveMetadata(AiModelInfoModel modelInfo) async {
    final dir = await getModelDirectoryPath(
      modelId: modelInfo.modelId,
      version: modelInfo.version,
    );
    final metaFile = File(p.join(dir, 'metadata.json'));
    await metaFile.writeAsString(jsonEncode(modelInfo.toJson()));
  }

  @override
  Future<bool> deleteModel({
    String modelId = 'u2netp',
    String version = '1.0.0',
  }) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final modelBaseDir = Directory(
        p.join(docsDir.path, 'ai_models', 'background_remover', modelId),
      );
      if (await modelBaseDir.exists()) {
        await modelBaseDir.delete(recursive: true);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isModelInstalled({
    String modelId = 'u2netp',
    String version = '1.0.0',
  }) async {
    final file = await getFinalModelFile(modelId: modelId, version: version);
    if (!await file.exists()) return false;
    final size = await file.length();
    return size > (2 * 1024 * 1024);
  }
}
