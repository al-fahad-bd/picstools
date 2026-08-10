import 'dart:io';
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
    required int quality, // 1 to 100
    int? targetSizeBytes, // Optional max target file size in bytes
  }) async {
    final originalBytes = await imageFile.readAsBytes();
    final originalSizeBytes = originalBytes.length;

    final decoded = img.decodeImage(originalBytes);
    if (decoded == null) {
      throw Exception("Could not decode image file.");
    }

    int currentQuality = quality.clamp(5, 100);
    img.Image imageToProcess = decoded;

    // If a target size is requested, scale down width/height if needed
    if (targetSizeBytes != null && originalSizeBytes > targetSizeBytes) {
      final double scaleFactor = (targetSizeBytes / originalSizeBytes).clamp(0.4, 0.9);
      final newWidth = (decoded.width * scaleFactor).round().clamp(100, decoded.width);
      final newHeight = (decoded.height * scaleFactor).round().clamp(100, decoded.height);
      imageToProcess = img.copyResize(decoded, width: newWidth, height: newHeight);
      currentQuality = (currentQuality * 0.85).round().clamp(10, 85);
    }

    final ext = p.extension(imageFile.path).toLowerCase();
    List<int> compressedBytes;

    if (ext == '.png') {
      compressedBytes = img.encodePng(imageToProcess, level: (9 - (currentQuality / 10).round()).clamp(0, 9));
    } else {
      compressedBytes = img.encodeJpg(imageToProcess, quality: currentQuality);
    }

    final tempDir = await getTemporaryDirectory();
    final fileName = 'compressed_${DateTime.now().millisecondsSinceEpoch}_${p.basename(imageFile.path)}';
    final outFile = File(p.join(tempDir.path, fileName));
    await outFile.writeAsBytes(compressedBytes);

    return CompressionResult(
      originalFile: imageFile,
      compressedFile: outFile,
      originalSizeBytes: originalSizeBytes,
      compressedSizeBytes: compressedBytes.length,
      width: imageToProcess.width,
      height: imageToProcess.height,
    );
  }
}
