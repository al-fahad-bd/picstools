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

  final isPng = ext == '.png';
  img.Image currentImage = decoded;
  List<int> bestBytes;

  if (targetSizeBytes != null) {
    // Mode A: Target File Size Specified (e.g. Max 200 KB, 500 KB, 1 MB)
    final int effectiveTarget = targetSizeBytes < originalSizeBytes ? targetSizeBytes : originalSizeBytes;
    int q = quality >= 95 ? 85 : quality.clamp(10, 90);

    List<int> candidate = _encodeImage(currentImage, isPng, q);

    if (candidate.length > effectiveTarget) {
      double scale = 0.9;
      while (scale >= 0.25) {
        // Drop quality first at current resolution
        while (q >= 30 && candidate.length > effectiveTarget) {
          q -= 10;
          candidate = _encodeImage(currentImage, isPng, q);
        }

        if (candidate.length <= effectiveTarget) break;

        // If quality drop alone isn't enough, downscale dimensions
        final newWidth = (decoded.width * scale).round().clamp(50, decoded.width);
        final newHeight = (decoded.height * scale).round().clamp(50, decoded.height);
        currentImage = img.copyResize(
          decoded,
          width: newWidth,
          height: newHeight,
          interpolation: img.Interpolation.linear,
        );
        q = 75; // reset quality slightly for resized image
        candidate = _encodeImage(currentImage, isPng, q);
        scale -= 0.15;
      }
    }

    bestBytes = candidate;

    // Strict guarantee: never exceed original size
    if (bestBytes.length >= originalSizeBytes) {
      bestBytes = bytes;
      currentImage = decoded;
    }
  } else {
    // Mode B: Quality-based compression (No target file size)
    if (isPng) {
      // PNG format (lossless compression level 6 -> 9)
      List<int> pngCandidate = img.encodePng(currentImage, level: 6, filter: img.PngFilter.paeth);

      // If level 6 is not smaller than original or quality preset is lower, try max level 9
      if (pngCandidate.length >= originalSizeBytes || quality < 80) {
        pngCandidate = img.encodePng(currentImage, level: 9, filter: img.PngFilter.paeth);
      }

      // If PNG is still larger and user chose lower quality (< 80), attempt palette quantization
      if ((pngCandidate.length >= originalSizeBytes || quality < 80) && currentImage.numChannels >= 3) {
        try {
          final quantized = img.quantize(
            currentImage,
            numberOfColors: (quality * 2.5).round().clamp(32, 256),
          );
          final quantizedBytes = img.encodePng(quantized, level: 9);
          if (quantizedBytes.length < originalSizeBytes) {
            pngCandidate = quantizedBytes;
            currentImage = quantized;
          }
        } catch (_) {}
      }

      // If output is still >= originalSizeBytes, preserve original bytes
      if (pngCandidate.length >= originalSizeBytes) {
        bestBytes = bytes;
        currentImage = decoded;
      } else {
        bestBytes = pngCandidate;
      }
    } else {
      // JPEG / Other formats
      // Start with optimal perceptual quality (max 88 to avoid JPEG 100 bloat)
      int q = quality >= 95 ? 88 : quality.clamp(10, 95);
      List<int> jpgCandidate = img.encodeJpg(currentImage, quality: q);

      // If output is >= original size, step down quality to achieve genuine compression
      while (jpgCandidate.length >= originalSizeBytes && q > 25) {
        q -= (q > 70 ? 7 : 5);
        jpgCandidate = img.encodeJpg(currentImage, quality: q);
      }

      // If still >= original size (e.g. image already has high entropy/small dimensions),
      // test a subtle downscale (0.9x)
      if (jpgCandidate.length >= originalSizeBytes) {
        final newWidth = (decoded.width * 0.9).round();
        final newHeight = (decoded.height * 0.9).round();
        if (newWidth > 50 && newHeight > 50) {
          final resized = img.copyResize(
            decoded,
            width: newWidth,
            height: newHeight,
            interpolation: img.Interpolation.linear,
          );
          final resizedCandidate = img.encodeJpg(resized, quality: 75);
          if (resizedCandidate.length < originalSizeBytes) {
            jpgCandidate = resizedCandidate;
            currentImage = resized;
          }
        }
      }

      // Absolute guarantee: never produce a file larger than the original
      if (jpgCandidate.length >= originalSizeBytes) {
        bestBytes = bytes;
        currentImage = decoded;
      } else {
        bestBytes = jpgCandidate;
      }
    }
  }

  final outPath = p.join(
    tempDirPath,
    'compressed_${DateTime.now().millisecondsSinceEpoch}_$fileName',
  );
  final outFile = File(outPath)..writeAsBytesSync(bestBytes);

  return {
    'outPath': outFile.path,
    'width': currentImage.width,
    'height': currentImage.height,
    'size': bestBytes.length,
  };
}

List<int> _encodeImage(img.Image image, bool isPng, int quality) {
  if (isPng) {
    if (quality < 70) {
      try {
        final quantized = img.quantize(
          image,
          numberOfColors: (quality * 2.5).round().clamp(32, 256),
        );
        return img.encodePng(quantized, level: 6);
      } catch (_) {}
    }
    return img.encodePng(image, level: 6, filter: img.PngFilter.paeth);
  } else {
    return img.encodeJpg(image, quality: quality.clamp(10, 100));
  }
}
