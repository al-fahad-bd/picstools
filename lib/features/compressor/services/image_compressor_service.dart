import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class CompressionResult {
  final File originalFile;
  final File compressedFile;
  final int originalSizeBytes;
  final int compressedSizeBytes;
  final int width;
  final int height;

  CompressionResult({
    required this.originalFile,
    required this.compressedFile,
    required this.originalSizeBytes,
    required this.compressedSizeBytes,
    required this.width,
    required this.height,
  });
}

class ImageCompressorService {
  Future<CompressionResult> compressImage({
    required File imageFile,
    required int quality,
    int? targetSizeBytes,
  }) async {
    final originalBytes = await imageFile.readAsBytes();
    final tempDir = await getTemporaryDirectory();
    final fileName = p.basename(imageFile.path);
    final ext = p.extension(imageFile.path).toLowerCase();

    final result = await compute(_compressWorkerIsolate, {
      'bytes': originalBytes,
      'quality': quality,
      'targetSizeBytes': targetSizeBytes,
      'ext': ext,
      'tempDirPath': tempDir.path,
      'fileName': fileName,
    });

    final outFile = File(result['outPath'] as String);

    return CompressionResult(
      originalFile: imageFile,
      compressedFile: outFile,
      originalSizeBytes: originalBytes.length,
      compressedSizeBytes: result['size'] as int,
      width: result['width'] as int,
      height: result['height'] as int,
    );
  }
}

Map<String, dynamic> _compressWorkerIsolate(Map<String, dynamic> params) {
  final bytes = params['bytes'] as Uint8List;
  final quality = params['quality'] as int;
  final targetSizeBytes = params['targetSizeBytes'] as int?;
  final ext = params['ext'] as String;
  final tempDirPath = params['tempDirPath'] as String;
  final fileName = params['fileName'] as String;

  final originalSizeBytes = bytes.length;
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw Exception("Could not decode image file.");
  }

  int currentQuality = quality.clamp(5, 100);
  img.Image imageToProcess = decoded;

  if (targetSizeBytes != null && originalSizeBytes > targetSizeBytes) {
    final double scaleFactor = (targetSizeBytes / originalSizeBytes).clamp(0.4, 0.9);
    final newWidth = (decoded.width * scaleFactor).round().clamp(100, decoded.width);
    final newHeight = (decoded.height * scaleFactor).round().clamp(100, decoded.height);
    imageToProcess = img.copyResize(decoded, width: newWidth, height: newHeight);
    currentQuality = (currentQuality * 0.85).round().clamp(10, 85);
  }

  List<int> compressedBytes;
  if (ext == '.png') {
    compressedBytes = img.encodePng(imageToProcess, level: (9 - (currentQuality / 10).round()).clamp(0, 9));
  } else {
    compressedBytes = img.encodeJpg(imageToProcess, quality: currentQuality);
  }

  final outPath = p.join(
    tempDirPath,
    'compressed_${DateTime.now().millisecondsSinceEpoch}_$fileName',
  );
  final outFile = File(outPath)..writeAsBytesSync(compressedBytes);

  return {
    'outPath': outFile.path,
    'width': imageToProcess.width,
    'height': imageToProcess.height,
    'size': compressedBytes.length,
  };
}
