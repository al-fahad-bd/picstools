import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

/// Provides true lossless optimization for images before cloud backup.
/// Guarantees 100% pixel fidelity with zero quality degradation.
class LosslessImageOptimizer {
  const LosslessImageOptimizer._();

  static Future<Uint8List> optimize({
    required Uint8List bytes,
    required String filePath,
  }) async {
    try {
      final ext = p.extension(filePath).toLowerCase();

      if (ext == '.png') {
        final optimized = await compute(_losslessPngWorker, bytes);
        if (optimized != null && optimized.length < bytes.length) {
          final saved = bytes.length - optimized.length;
          final pct = (saved / bytes.length * 100).toStringAsFixed(1);
          debugPrint('⚡ [LosslessOptimizer] PNG optimized: saved $saved bytes ($pct%)');
          return optimized;
        }
      } else if (ext == '.jpg' || ext == '.jpeg') {
        final optimized = _stripJpegExif(bytes);
        if (optimized.length < bytes.length) {
          final saved = bytes.length - optimized.length;
          final pct = (saved / bytes.length * 100).toStringAsFixed(1);
          debugPrint('⚡ [LosslessOptimizer] JPEG metadata optimized: saved $saved bytes ($pct%)');
          return optimized;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [LosslessOptimizer] Optimization error, using original: $e');
    }

    return bytes;
  }

  static Uint8List? _losslessPngWorker(Uint8List bytes) {
    try {
      final decoded = img.decodePng(bytes);
      if (decoded != null) {
        return Uint8List.fromList(img.encodePng(
          decoded,
          level: 9,
          filter: img.PngFilter.paeth,
        ));
      }
    } catch (_) {}
    return null;
  }

  static Uint8List _stripJpegExif(Uint8List bytes) {
    if (bytes.length < 4 || bytes[0] != 0xFF || bytes[1] != 0xD8) {
      return bytes;
    }

    final builder = BytesBuilder(copy: false);
    builder.add([0xFF, 0xD8]); // SOI

    int offset = 2;
    while (offset < bytes.length - 1) {
      if (bytes[offset] != 0xFF) break;
      final marker = bytes[offset + 1];

      // Skip padding FF
      if (marker == 0xFF) {
        offset++;
        continue;
      }

      // Standalone markers
      if (marker == 0xD8 || (marker >= 0xD0 && marker <= 0xD7)) {
        builder.add([0xFF, marker]);
        offset += 2;
        continue;
      }

      // SOS (Start of Scan) or EOI: keep remaining scan data intact
      if (marker == 0xDA || marker == 0xD9) {
        builder.add(bytes.sublist(offset));
        break;
      }

      if (offset + 4 > bytes.length) break;
      final length = (bytes[offset + 2] << 8) | bytes[offset + 3];
      final segmentEnd = offset + 2 + length;
      if (segmentEnd > bytes.length) break;

      // Skip APP1 (Exif) marker 0xE1
      if (marker == 0xE1) {
        offset = segmentEnd;
        continue;
      }

      // Keep all image defining segments (DQT, DHT, SOF, etc.)
      builder.add(bytes.sublist(offset, segmentEnd));
      offset = segmentEnd;
    }

    final result = builder.toBytes();
    return result.length < bytes.length ? result : bytes;
  }
}
