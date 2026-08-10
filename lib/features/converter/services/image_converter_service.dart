import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ConvertResult {
  final File originalFile;
  final File convertedFile;
  final String targetFormat; // JPG, PNG, WebP
  final int originalSizeBytes;
  final int convertedSizeBytes;

  ConvertResult({
    required this.originalFile,
    required this.convertedFile,
    required this.targetFormat,
    required this.originalSizeBytes,
    required this.convertedSizeBytes,
  });
}

class ImageConverterService {
  Future<ConvertResult> convertImage({
    required File imageFile,
    required String targetFormat, // 'JPG', 'PNG', 'WebP'
    int quality = 90,
  }) async {
    final originalBytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(originalBytes);
    if (decoded == null) {
      throw Exception('Failed to decode image file.');
    }

    final String fmt = targetFormat.toUpperCase();
    List<int> encodedBytes;
    String ext = '.jpg';

    if (fmt == 'PNG') {
      encodedBytes = img.encodePng(decoded);
      ext = '.png';
    } else if (fmt == 'WEBP') {
      encodedBytes = img.encodeWebP(decoded);
      ext = '.webp';
    } else {
      encodedBytes = img.encodeJpg(decoded, quality: quality);
      ext = '.jpg';
    }

    final tempDir = await getTemporaryDirectory();
    final outName = 'converted_${DateTime.now().millisecondsSinceEpoch}_${p.basenameWithoutExtension(imageFile.path)}$ext';
    final outFile = File(p.join(tempDir.path, outName));
    await outFile.writeAsBytes(encodedBytes);

    return ConvertResult(
      originalFile: imageFile,
      convertedFile: outFile,
      targetFormat: fmt,
      originalSizeBytes: originalBytes.length,
      convertedSizeBytes: encodedBytes.length,
    );
  }
}
