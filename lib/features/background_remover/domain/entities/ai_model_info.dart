import 'package:equatable/equatable.dart';

class AiModelInfo extends Equatable {
  final String modelId;
  final String displayName;
  final String version;
  final String fileName;
  final String downloadUrl;
  final String? fallbackDownloadUrl;
  final int expectedSizeBytes;
  final String? sha256;
  final bool isDownloaded;
  final String? localFilePath;
  final int actualSizeBytes;

  const AiModelInfo({
    required this.modelId,
    required this.displayName,
    required this.version,
    required this.fileName,
    required this.downloadUrl,
    this.fallbackDownloadUrl,
    required this.expectedSizeBytes,
    this.sha256,
    required this.isDownloaded,
    this.localFilePath,
    this.actualSizeBytes = 0,
  });

  String get formattedExpectedSize {
    final mb = expectedSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  String get formattedActualSize {
    if (actualSizeBytes <= 0) return formattedExpectedSize;
    final mb = actualSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  AiModelInfo copyWith({
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
    return AiModelInfo(
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

  @override
  List<Object?> get props => [
        modelId,
        displayName,
        version,
        fileName,
        downloadUrl,
        fallbackDownloadUrl,
        expectedSizeBytes,
        sha256,
        isDownloaded,
        localFilePath,
        actualSizeBytes,
      ];
}
