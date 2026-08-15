import '../../domain/entities/ai_model_info.dart';

class AiModelInfoModel extends AiModelInfo {
  const AiModelInfoModel({
    required super.modelId,
    required super.displayName,
    required super.version,
    required super.fileName,
    required super.downloadUrl,
    super.fallbackDownloadUrl,
    required super.expectedSizeBytes,
    super.sha256,
    required super.isDownloaded,
    super.localFilePath,
    super.actualSizeBytes = 0,
  });

  factory AiModelInfoModel.fromJson(Map<String, dynamic> json) {
    return AiModelInfoModel(
      modelId: json['modelId'] as String? ?? 'birefnet-general-lite',
      displayName: json['displayName'] as String? ?? 'BiRefNet General Lite',
      version: json['version'] as String? ?? '1.0.0',
      fileName: json['fileName'] as String? ?? 'birefnet-general-lite.onnx',
      downloadUrl: json['downloadUrl'] as String? ??
          'https://github.com/danielgatis/rembg/releases/download/v0.0.0/birefnet-general-lite.onnx',
      fallbackDownloadUrl: json['fallbackDownloadUrl'] as String? ??
          'https://huggingface.co/onnx-community/BiRefNet_lite-ONNX/resolve/main/onnx/model.onnx',
      expectedSizeBytes: json['expectedSizeBytes'] as int? ?? 224000000,
      sha256: json['sha256'] as String?,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      localFilePath: json['localFilePath'] as String?,
      actualSizeBytes: json['actualSizeBytes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modelId': modelId,
      'displayName': displayName,
      'version': version,
      'fileName': fileName,
      'downloadUrl': downloadUrl,
      'fallbackDownloadUrl': fallbackDownloadUrl,
      'expectedSizeBytes': expectedSizeBytes,
      'sha256': sha256,
      'isDownloaded': isDownloaded,
      'localFilePath': localFilePath,
      'actualSizeBytes': actualSizeBytes,
    };
  }

  @override
  AiModelInfoModel copyWith({
    String? modelId,
    String? displayName,
    String? version,
    String? fileName,
    String? downloadUrl,
    String? fallbackDownloadUrl,
    int? expectedSizeBytes,
    String? sha256,
    bool? isDownloaded,
    String? localFilePath,
    int? actualSizeBytes,
  }) {
    return AiModelInfoModel(
      modelId: modelId ?? this.modelId,
      displayName: displayName ?? this.displayName,
      version: version ?? this.version,
      fileName: fileName ?? this.fileName,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      fallbackDownloadUrl: fallbackDownloadUrl ?? this.fallbackDownloadUrl,
      expectedSizeBytes: expectedSizeBytes ?? this.expectedSizeBytes,
      sha256: sha256 ?? this.sha256,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localFilePath: localFilePath ?? this.localFilePath,
      actualSizeBytes: actualSizeBytes ?? this.actualSizeBytes,
    );
  }

  static const defaultModel = AiModelInfoModel(
    modelId: 'u2netp',
    displayName: 'U2NetP Mobile AI',
    version: '1.0.0',
    fileName: 'u2netp.onnx',
    downloadUrl:
        'https://github.com/danielgatis/rembg/releases/download/v0.0.0/u2netp.onnx',
    fallbackDownloadUrl:
        'https://huggingface.co/onnx-community/u2netp/resolve/main/onnx/model.onnx',
    expectedSizeBytes: 4700000, // ~4.5 MB
    isDownloaded: false,
  );
}
