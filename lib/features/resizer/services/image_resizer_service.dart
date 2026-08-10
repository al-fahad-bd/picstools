import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ResizeResult {
  final File originalFile;
  final File resizedFile;
  final int originalWidth;
  final int originalHeight;
  final int resizedWidth;
  final int resizedHeight;
  final int originalSizeBytes;
  final int resizedSizeBytes;

  ResizeResult({
    required this.originalFile,
    required this.resizedFile,
    required this.originalWidth,
    required this.originalHeight,
    required this.resizedWidth,
    required this.resizedHeight,
    required this.originalSizeBytes,
    required this.resizedSizeBytes,
  });
}

class ImageResizerService {
  Future<ResizeResult> resizeImage({
    required File imageFile,
    required int targetWidth,
    required int targetHeight,
    bool maintainAspectRatio = true,
  }) async {
    final originalBytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(originalBytes);
    if (decoded == null) {
      throw Exception('Failed to decode image file.');
    }

    final int origW = decoded.width;
    final int origH = decoded.height;

    int finalW = targetWidth;
    int finalH = targetHeight;

    if (maintainAspectRatio && origW > 0 && origH > 0) {
      final double ratio = origW / origH;
      if (finalW / finalH > ratio) {
        finalW = (finalH * ratio).round();
      } else {
        finalH = (finalW / ratio).round();
      }
    }

    final resized = img.copyResize(
      decoded,
      width: finalW.clamp(10, 10000),
      height: finalH.clamp(10, 10000),
      interpolation: img.Interpolation.average,
    );

    final ext = p.extension(imageFile.path).toLowerCase();
    List<int> encodedBytes;
    if (ext == '.png') {
      encodedBytes = img.encodePng(resized);
    } else if (ext == '.webp') {
      encodedBytes = img.encodeWebP(resized);
    } else {
      encodedBytes = img.encodeJpg(resized, quality: 90);
    }

    final tempDir = await getTemporaryDirectory();
    final outPath = p.join(
      tempDir.path,
      'resized_${DateTime.now().millisecondsSinceEpoch}_${p.basename(imageFile.path)}',
    );
    final outFile = File(outPath);
    await outFile.writeAsBytes(encodedBytes);

    return ResizeResult(
      originalFile: imageFile,
      resizedFile: outFile,
      originalWidth: origW,
      originalHeight: origH,
      resizedWidth: resized.width,
      resizedHeight: resized.height,
      originalSizeBytes: originalBytes.length,
      resizedSizeBytes: encodedBytes.length,
    );
  }
}
