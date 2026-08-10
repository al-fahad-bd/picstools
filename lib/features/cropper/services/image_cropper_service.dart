import 'dart:io';
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
    required double cropXRatio, // 0.0 to 1.0 offset
    required double cropYRatio, // 0.0 to 1.0 offset
    required double cropWidthRatio, // 0.0 to 1.0 width
    required double cropHeightRatio, // 0.0 to 1.0 height
    int rotationAngle = 0, // 0, 90, 180, 270
    bool flipHorizontal = false,
    bool flipVertical = false,
  }) async {
    final originalBytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(originalBytes);
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

    final ext = p.extension(imageFile.path).toLowerCase();
    List<int> encodedBytes;
    if (ext == '.png') {
      encodedBytes = img.encodePng(processed);
    } else if (ext == '.webp') {
      encodedBytes = img.encodeWebP(processed);
    } else {
      encodedBytes = img.encodeJpg(processed, quality: 90);
    }

    final tempDir = await getTemporaryDirectory();
    final outPath = p.join(
      tempDir.path,
      'cropped_${DateTime.now().millisecondsSinceEpoch}_${p.basename(imageFile.path)}',
    );
    final outFile = File(outPath);
    await outFile.writeAsBytes(encodedBytes);

    return CropResult(
      originalFile: imageFile,
      croppedFile: outFile,
      croppedWidth: processed.width,
      croppedHeight: processed.height,
      originalSizeBytes: originalBytes.length,
      croppedSizeBytes: encodedBytes.length,
    );
  }
}
