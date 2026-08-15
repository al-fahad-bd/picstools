import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/ai_model_info_model.dart';
import 'model_storage_datasource.dart';

abstract class ModelDownloaderDataSource {
  Future<File> downloadModel({
    required AiModelInfoModel modelInfo,
    required void Function(int receivedBytes, int totalBytes, double percentage) onProgress,
  });

  void cancelDownload();

  Future<String> calculateSha256(File file);
}

class ModelDownloaderDataSourceImpl implements ModelDownloaderDataSource {
  final Dio _dio;
  final ModelStorageDataSource storageDataSource;
  CancelToken? _cancelToken;

  ModelDownloaderDataSourceImpl({
    Dio? dio,
    required this.storageDataSource,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(minutes: 15),
                followRedirects: true,
                maxRedirects: 5,
              ),
            );

  @override
  void cancelDownload() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('User cancelled download');
      _cancelToken = null;
      debugPrint('[ModelDownloader] Download cancelled by user');
    }
  }

  @override
  Future<String> calculateSha256(File file) async {
    debugPrint('[ModelDownloader] Calculating SHA-256 checksum for: ${file.path}');
    final stream = file.openRead();
    final hash = await sha256.bind(stream).first;
    final hashStr = hash.toString();
    debugPrint('[ModelDownloader] SHA-256: $hashStr');
    return hashStr;
  }

  @override
  Future<File> downloadModel({
    required AiModelInfoModel modelInfo,
    required void Function(int receivedBytes, int totalBytes, double percentage) onProgress,
  }) async {
    _cancelToken = CancelToken();

    final tempFile = await storageDataSource.getTempDownloadFile(
      modelId: modelInfo.modelId,
      version: modelInfo.version,
      fileName: modelInfo.fileName,
    );

    final finalFile = await storageDataSource.getFinalModelFile(
      modelId: modelInfo.modelId,
      version: modelInfo.version,
      fileName: modelInfo.fileName,
    );

    debugPrint('[ModelDownloader] Starting model download for ${modelInfo.displayName} (${modelInfo.modelId})');
    debugPrint('[ModelDownloader] Destination: ${finalFile.path}');
    debugPrint('[ModelDownloader] Temp file: ${tempFile.path}');

    // If temp file already exists from an aborted run, delete it to ensure a clean stream
    if (await tempFile.exists()) {
      try {
        await tempFile.delete();
      } catch (_) {}
    }

    String activeUrl = modelInfo.downloadUrl;
    bool downloadSuccess = false;
    dynamic lastError;

    // 1. Try primary URL
    try {
      debugPrint('[ModelDownloader] Downloading from primary URL: $activeUrl');
      await _downloadToFile(
        url: activeUrl,
        savePath: tempFile.path,
        cancelToken: _cancelToken!,
        expectedTotalBytes: modelInfo.expectedSizeBytes,
        onProgress: onProgress,
      );
      downloadSuccess = true;
      debugPrint('[ModelDownloader] Primary download finished successfully.');
    } catch (e) {
      lastError = e;
      debugPrint('[ModelDownloader] Primary download failed: $e');
      if (_cancelToken?.isCancelled ?? false) {
        rethrow;
      }
      // If primary failed and fallback exists, try fallback URL
      if (modelInfo.fallbackDownloadUrl != null &&
          modelInfo.fallbackDownloadUrl!.isNotEmpty) {
        try {
          activeUrl = modelInfo.fallbackDownloadUrl!;
          debugPrint('[ModelDownloader] Attempting fallback URL: $activeUrl');
          await _downloadToFile(
            url: activeUrl,
            savePath: tempFile.path,
            cancelToken: _cancelToken!,
            expectedTotalBytes: modelInfo.expectedSizeBytes,
            onProgress: onProgress,
          );
          downloadSuccess = true;
          debugPrint('[ModelDownloader] Fallback download finished successfully.');
        } catch (fallbackErr) {
          lastError = fallbackErr;
          debugPrint('[ModelDownloader] Fallback download also failed: $fallbackErr');
        }
      }
    }

    if (!downloadSuccess) {
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      throw Exception('Failed to download AI model from $activeUrl: $lastError');
    }

    // 2. Validate downloaded file integrity
    if (!await tempFile.exists()) {
      throw Exception('Downloaded file not found on disk');
    }

    final fileSize = await tempFile.length();
    debugPrint('[ModelDownloader] Downloaded file size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB');
    if (fileSize < (2 * 1024 * 1024)) {
      await tempFile.delete();
      throw Exception('Downloaded file is incomplete ($fileSize bytes). Expected ~${modelInfo.expectedSizeBytes} bytes.');
    }

    // 3. Calculate SHA256 checksum
    final computedSha256 = await calculateSha256(tempFile);

    // 4. Move temp file to final model destination
    if (await finalFile.exists()) {
      await finalFile.delete();
    }
    await tempFile.rename(finalFile.path);

    // 5. Update and save metadata.json
    final updatedMeta = modelInfo.copyWith(
      isDownloaded: true,
      localFilePath: finalFile.path,
      actualSizeBytes: fileSize,
      sha256: computedSha256,
    );

    await storageDataSource.saveMetadata(updatedMeta);
    debugPrint('[ModelDownloader] Model saved and metadata updated. Ready.');

    return finalFile;
  }

  Future<void> _downloadToFile({
    required String url,
    required String savePath,
    required CancelToken cancelToken,
    required int expectedTotalBytes,
    required void Function(int receivedBytes, int totalBytes, double percentage) onProgress,
  }) async {
    await _dio.download(
      url,
      savePath,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        final effectiveTotal = total > 0 ? total : expectedTotalBytes;
        final percentage = effectiveTotal > 0
            ? (received / effectiveTotal).clamp(0.0, 1.0)
            : 0.0;
        onProgress(received, effectiveTotal, percentage);
      },
    );
  }
}
