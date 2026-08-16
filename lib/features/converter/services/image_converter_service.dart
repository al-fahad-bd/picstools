import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ConvertResult {
  final File originalFile;
  final File convertedFile;
  final String targetFormat;
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
    required String targetFormat,
    int quality = 90,
  }) async {
    final originalBytes = await imageFile.readAsBytes();
    final tempDir = await getTemporaryDirectory();
    final baseName = p.basenameWithoutExtension(imageFile.path);

    final result = await compute(_convertWorkerIsolate, {
      'bytes': originalBytes,
      'targetFormat': targetFormat,
      'quality': quality,
      'tempDirPath': tempDir.path,
      'baseName': baseName,
    });

    final outFile = File(result['outPath'] as String);

    return ConvertResult(
      originalFile: imageFile,
      convertedFile: outFile,
      targetFormat: targetFormat.toUpperCase(),
      originalSizeBytes: originalBytes.length,
      convertedSizeBytes: result['size'] as int,
    );
  }
}

Map<String, dynamic> _convertWorkerIsolate(Map<String, dynamic> params) {
  final bytes = params['bytes'] as Uint8List;
  final targetFormat = (params['targetFormat'] as String).toUpperCase();
  final quality = params['quality'] as int;
  final tempDirPath = params['tempDirPath'] as String;
  final baseName = params['baseName'] as String;

  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw Exception('Failed to decode image file.');
  }

  List<int> encodedBytes;
  String ext = '.jpg';

  if (targetFormat == 'PNG') {
    encodedBytes = img.encodePng(decoded);
    ext = '.png';
  } else if (targetFormat == 'WEBP') {
    encodedBytes = img.encodeWebP(decoded);
    ext = '.webp';
  } else {
    encodedBytes = img.encodeJpg(decoded, quality: quality);
    ext = '.jpg';
  }

  final outName = 'converted_${DateTime.now().millisecondsSinceEpoch}_$baseName$ext';
  final outFile = File(p.join(tempDirPath, outName))..writeAsBytesSync(encodedBytes);

  return {
    'outPath': outFile.path,
    'size': encodedBytes.length,
  };
}
