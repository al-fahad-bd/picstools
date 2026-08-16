import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class CropResult {
  final File originalFile;
  final File croppedFile;
  final int croppedWidth;
  final int croppedHeight;
  final int originalSizeBytes;
  final int croppedSizeBytes;

  CropResult({
    required this.originalFile,
    required this.croppedFile,
    required this.croppedWidth,
    required this.croppedHeight,
    required this.originalSizeBytes,
    required this.croppedSizeBytes,
  });
}

class ImageCropperService {
  Future<CropResult> processCrop({
    required File imageFile,
    required double cropXRatio,
    required double cropYRatio,
    required double cropWidthRatio,
    required double cropHeightRatio,
    int rotationAngle = 0,
    bool flipHorizontal = false,
    bool flipVertical = false,
  }) async {
    final originalBytes = await imageFile.readAsBytes();
    final tempDir = await getTemporaryDirectory();
    final fileName = p.basename(imageFile.path);
    final ext = p.extension(imageFile.path).toLowerCase();

    final result = await compute(_cropWorkerIsolate, {
      'bytes': originalBytes,
      'cropXRatio': cropXRatio,
      'cropYRatio': cropYRatio,
      'cropWidthRatio': cropWidthRatio,
      'cropHeightRatio': cropHeightRatio,
      'rotationAngle': rotationAngle,
      'flipHorizontal': flipHorizontal,
      'flipVertical': flipVertical,
      'ext': ext,
      'tempDirPath': tempDir.path,
      'fileName': fileName,
    });

    final outFile = File(result['outPath'] as String);

    return CropResult(
      originalFile: imageFile,
      croppedFile: outFile,
      croppedWidth: result['width'] as int,
      croppedHeight: result['height'] as int,
      originalSizeBytes: originalBytes.length,
      croppedSizeBytes: result['size'] as int,
    );
  }
}

Map<String, dynamic> _cropWorkerIsolate(Map<String, dynamic> params) {
  final bytes = params['bytes'] as Uint8List;
  final cropXRatio = (params['cropXRatio'] as num).toDouble();
  final cropYRatio = (params['cropYRatio'] as num).toDouble();
  final cropWidthRatio = (params['cropWidthRatio'] as num).toDouble();
  final cropHeightRatio = (params['cropHeightRatio'] as num).toDouble();
  final rotationAngle = params['rotationAngle'] as int;
  final flipHorizontal = params['flipHorizontal'] as bool;
  final flipVertical = params['flipVertical'] as bool;
  final ext = params['ext'] as String;
  final tempDirPath = params['tempDirPath'] as String;
  final fileName = params['fileName'] as String;

  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw Exception('Failed to decode image file.');
  }

  img.Image processed = decoded;

  // 1. Rotation
  if (rotationAngle != 0) {
    processed = img.copyRotate(processed, angle: rotationAngle);
  }

  // 2. Flip
  if (flipHorizontal) {
    processed = img.copyFlip(processed, direction: img.FlipDirection.horizontal);
  }
  if (flipVertical) {
    processed = img.copyFlip(processed, direction: img.FlipDirection.vertical);
  }

  // 3. Crop coordinates
  final int origW = processed.width;
  final int origH = processed.height;

  final int cropX = (origW * cropXRatio).round().clamp(0, origW - 1);
  final int cropY = (origH * cropYRatio).round().clamp(0, origH - 1);
  final int cropW = (origW * cropWidthRatio).round().clamp(10, origW - cropX);
  final int cropH = (origH * cropHeightRatio).round().clamp(10, origH - cropY);

  processed = img.copyCrop(
    processed,
    x: cropX,
    y: cropY,
    width: cropW,
    height: cropH,
  );

  List<int> encodedBytes;
  if (ext == '.png') {
    encodedBytes = img.encodePng(processed);
  } else if (ext == '.webp') {
    encodedBytes = img.encodeWebP(processed);
  } else {
    encodedBytes = img.encodeJpg(processed, quality: 90);
  }

  final outPath = p.join(
    tempDirPath,
    'cropped_${DateTime.now().millisecondsSinceEpoch}_$fileName',
  );
  final outFile = File(outPath)..writeAsBytesSync(encodedBytes);

  return {
    'outPath': outFile.path,
    'width': processed.width,
    'height': processed.height,
    'size': encodedBytes.length,
  };
}
