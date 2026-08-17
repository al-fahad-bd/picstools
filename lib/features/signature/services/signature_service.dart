import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/signature_stroke.dart';

class SignatureExportResult {
  final File transparentPngFile;
  final File solidBackgroundFile;
  final int widthPx;
  final int heightPx;
  final int fileSizeBytes;

  SignatureExportResult({
    required this.transparentPngFile,
    required this.solidBackgroundFile,
    required this.widthPx,
    required this.heightPx,
    required this.fileSizeBytes,
  });
}

class SignatureService {
  Future<SignatureExportResult> exportDrawnSignature({
    required List<SignatureStroke> strokes,
    required Size canvasSize,
    required Color solidBgColor,
  }) async {
    if (strokes.isEmpty) {
      throw Exception(
        'Signature canvas is empty. Please draw a signature first.',
      );
    }

    final tempDir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;

    // Convert strokes to primitive serializable data for isolate execution
    final strokeDataList = strokes.map((s) {
      return {
        'points': s.points.map((pt) => [pt.dx, pt.dy]).toList(),
        'color': [
          (s.color.r * 255).round(),
          (s.color.g * 255).round(),
          (s.color.b * 255).round(),
        ],
        'strokeWidth': s.strokeWidth,
      };
    }).toList();

    final result = await compute(_exportDrawnSignatureIsolate, {
      'strokes': strokeDataList,
      'canvasWidth': canvasSize.width,
      'canvasHeight': canvasSize.height,
      'tempDirPath': tempDir.path,
      'timestamp': ts,
    });

    return SignatureExportResult(
      transparentPngFile: File(result['transPath'] as String),
      solidBackgroundFile: File(result['solidPath'] as String),
      widthPx: result['width'] as int,
      heightPx: result['height'] as int,
      fileSizeBytes: result['size'] as int,
    );
  }

  Future<SignatureExportResult> scanPaperSignature({
    required File photoFile,
    double cropXRatio = 0.0,
    double cropYRatio = 0.0,
    double cropWidthRatio = 1.0,
    double cropHeightRatio = 1.0,
    num rotationAngle = 0,
  }) async {
    final bytes = await photoFile.readAsBytes();
    final tempDir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;

    final result = await compute(_scanPaperSignatureIsolate, {
      'imageBytes': bytes,
      'cropXRatio': cropXRatio,
      'cropYRatio': cropYRatio,
      'cropWidthRatio': cropWidthRatio,
      'cropHeightRatio': cropHeightRatio,
      'rotationAngle': rotationAngle,
      'tempDirPath': tempDir.path,
      'timestamp': ts,
    });

    return SignatureExportResult(
      transparentPngFile: File(result['transPath'] as String),
      solidBackgroundFile: File(result['solidPath'] as String),
      widthPx: result['width'] as int,
      heightPx: result['height'] as int,
      fileSizeBytes: result['size'] as int,
    );
  }

  Future<SignatureExportResult> adjustSignature({
    required File transparentPngFile,
    required double cropXRatio,
    required double cropYRatio,
    required double cropWidthRatio,
    required double cropHeightRatio,
    num rotationAngle = 0,
  }) async {
    final bytes = await transparentPngFile.readAsBytes();
    final tempDir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;

    final result = await compute(_adjustSignatureIsolate, {
      'imageBytes': bytes,
      'cropXRatio': cropXRatio,
      'cropYRatio': cropYRatio,
      'cropWidthRatio': cropWidthRatio,
      'cropHeightRatio': cropHeightRatio,
      'rotationAngle': rotationAngle,
      'tempDirPath': tempDir.path,
      'timestamp': ts,
    });

    return SignatureExportResult(
      transparentPngFile: File(result['transPath'] as String),
      solidBackgroundFile: File(result['solidPath'] as String),
      widthPx: result['width'] as int,
      heightPx: result['height'] as int,
      fileSizeBytes: result['size'] as int,
    );
  }
}

/// Top-level worker isolate for drawn signatures
Map<String, dynamic> _exportDrawnSignatureIsolate(Map<String, dynamic> params) {
  final strokesData = params['strokes'] as List<dynamic>;
  final canvasWidth = (params['canvasWidth'] as num).toDouble();
  final canvasHeight = (params['canvasHeight'] as num).toDouble();
  final tempDirPath = params['tempDirPath'] as String;
  final ts = params['timestamp'] as int;

  double minX = canvasWidth;
  double minY = canvasHeight;
  double maxX = 0;
  double maxY = 0;

  for (final s in strokesData) {
    final points = (s['points'] as List<dynamic>).cast<List<dynamic>>();
    for (final pt in points) {
      final x = (pt[0] as num).toDouble();
      final y = (pt[1] as num).toDouble();
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }
  }

  // Add 16px logical padding around ink bounds
  const padding = 16.0;
  minX = (minX - padding).clamp(0.0, canvasWidth);
  minY = (minY - padding).clamp(0.0, canvasHeight);
  maxX = (maxX + padding).clamp(0.0, canvasWidth);
  maxY = (maxY + padding).clamp(0.0, canvasHeight);

  final rawW = (maxX - minX).clamp(60.0, canvasWidth);
  final rawH = (maxY - minY).clamp(40.0, canvasHeight);

  // High-DPI supersampling scale factor (aims for ~1800-2400px ultra-crisp resolution)
  final double scale = (2000.0 / rawW).clamp(4.0, 6.0);

  final int width = (rawW * scale).round();
  final int height = (rawH * scale).round();

  final transparentImg = img.Image(
    width: width,
    height: height,
    numChannels: 4,
  );
  img.fill(transparentImg, color: img.ColorRgba8(0, 0, 0, 0));

  final solidImg = img.Image(width: width, height: height);
  img.fill(solidImg, color: img.ColorRgb8(255, 255, 255));

  // Render high-definition strokes with round caps & joints
  for (final s in strokesData) {
    final c = (s['color'] as List<dynamic>).cast<int>();
    int r = c[0];
    int g = c[1];
    int b = c[2];

    // If ink is black or near-black, map to the signature midnight slate ink (15, 23, 42)
    // identical to the scan paper signature flow for perfect contrast & consistency
    final lum = 0.299 * r + 0.587 * g + 0.114 * b;
    if (lum < 40) {
      r = 15;
      g = 23;
      b = 42;
    }

    final strokeWidth = (s['strokeWidth'] as num).toDouble();
    final scaledThickness = (strokeWidth * scale).clamp(2.0, 60.0);
    final radius = (scaledThickness / 2.0).round().clamp(1, 30);
    final points = (s['points'] as List<dynamic>).cast<List<dynamic>>();

    final colorRgba = img.ColorRgba8(r, g, b, 255);
    final isNearWhite = r > 230 && g > 230 && b > 230;
    final colorSolidRgb = isNearWhite
        ? img.ColorRgb8(15, 23, 42)
        : img.ColorRgb8(r, g, b);

    if (points.isEmpty) continue;

    // If single dot
    if (points.length == 1) {
      final x = (((points[0][0] as num).toDouble() - minX) * scale).round();
      final y = (((points[0][1] as num).toDouble() - minY) * scale).round();
      img.fillCircle(
        transparentImg,
        x: x,
        y: y,
        radius: radius,
        color: colorRgba,
      );
      img.fillCircle(
        solidImg,
        x: x,
        y: y,
        radius: radius,
        color: colorSolidRgb,
      );
      continue;
    }

    for (int i = 0; i < points.length - 1; i++) {
      final x1 = (((points[i][0] as num).toDouble() - minX) * scale).round();
      final y1 = (((points[i][1] as num).toDouble() - minY) * scale).round();
      final x2 = (((points[i + 1][0] as num).toDouble() - minX) * scale)
          .round();
      final y2 = (((points[i + 1][1] as num).toDouble() - minY) * scale)
          .round();

      // Draw round joint at start
      img.fillCircle(
        transparentImg,
        x: x1,
        y: y1,
        radius: radius,
        color: colorRgba,
      );
      img.fillCircle(
        solidImg,
        x: x1,
        y: y1,
        radius: radius,
        color: colorSolidRgb,
      );

      // Draw connecting line segment
      img.drawLine(
        transparentImg,
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        color: colorRgba,
        thickness: scaledThickness.round(),
      );

      img.drawLine(
        solidImg,
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        color: colorSolidRgb,
        thickness: scaledThickness.round(),
      );

      // Draw round joint at end
      img.fillCircle(
        transparentImg,
        x: x2,
        y: y2,
        radius: radius,
        color: colorRgba,
      );
      img.fillCircle(
        solidImg,
        x: x2,
        y: y2,
        radius: radius,
        color: colorSolidRgb,
      );
    }
  }

  final transBytes = img.encodePng(transparentImg);
  final transFile = File(p.join(tempDirPath, 'signature_transparent_$ts.png'))
    ..writeAsBytesSync(transBytes);

  final solidBytes = img.encodeJpg(solidImg, quality: 98);
  final solidFile = File(p.join(tempDirPath, 'signature_white_$ts.jpg'))
    ..writeAsBytesSync(solidBytes);

  return {
    'transPath': transFile.path,
    'solidPath': solidFile.path,
    'width': width,
    'height': height,
    'size': transBytes.length,
  };
}

/// Top-level worker isolate for paper extraction
Map<String, dynamic> _scanPaperSignatureIsolate(Map<String, dynamic> params) {
  final imageBytes = params['imageBytes'] as Uint8List;
  final cropXRatio = (params['cropXRatio'] as num?)?.toDouble() ?? 0.0;
  final cropYRatio = (params['cropYRatio'] as num?)?.toDouble() ?? 0.0;
  final cropWidthRatio = (params['cropWidthRatio'] as num?)?.toDouble() ?? 1.0;
  final cropHeightRatio =
      (params['cropHeightRatio'] as num?)?.toDouble() ?? 1.0;
  final rotationAngle = (params['rotationAngle'] as num?) ?? 0;
  final tempDirPath = params['tempDirPath'] as String;
  final ts = params['timestamp'] as int;

  img.Image? decoded = img.decodeImage(imageBytes);
  if (decoded == null) {
    throw Exception('Failed to decode paper photo.');
  }

  // 1. Maintain high 2800px resolution for ultra-sharp signature details
  if (decoded.width > 2800 || decoded.height > 2800) {
    final scale =
        2800.0 /
        (decoded.width > decoded.height ? decoded.width : decoded.height);
    decoded = img.copyResize(
      decoded,
      width: (decoded.width * scale).round(),
      height: (decoded.height * scale).round(),
      interpolation: img.Interpolation.linear,
    );
  }

  // 2. Rotate if requested
  if (rotationAngle != 0) {
    decoded = img.copyRotate(decoded, angle: rotationAngle);
  }

  // 3. Crop coordinates if requested
  if (cropWidthRatio < 0.999 ||
      cropHeightRatio < 0.999 ||
      cropXRatio > 0.001 ||
      cropYRatio > 0.001) {
    final int origW = decoded.width;
    final int origH = decoded.height;

    final int cropX = (origW * cropXRatio).round().clamp(0, origW - 1);
    final int cropY = (origH * cropYRatio).round().clamp(0, origH - 1);
    final int cropW = (origW * cropWidthRatio).round().clamp(10, origW - cropX);
    final int cropH = (origH * cropHeightRatio).round().clamp(
      10,
      origH - cropY,
    );

    decoded = img.copyCrop(
      decoded,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );
  }

  final grayscale = img.grayscale(decoded);
  final int w = grayscale.width;
  final int h = grayscale.height;

  // 4. Adaptive Paper Luminance Detection
  // Sample paper brightness from brightest regions
  final sampleStep = (w * h / 8000).clamp(1, 25).round();
  final luminanceList = <double>[];

  for (int y = 0; y < h; y += sampleStep) {
    for (int x = 0; x < w; x += sampleStep) {
      final p = grayscale.getPixel(x, y);
      final lum = (p.r + p.g + p.b) / 3.0;
      luminanceList.add(lum);
    }
  }

  luminanceList.sort();
  // Average of upper 40% brightest pixels represents the actual paper surface color
  final topIndex = (luminanceList.length * 0.6).round();
  double paperLumSum = 0;
  int paperLumCount = 0;
  for (int i = topIndex; i < luminanceList.length; i++) {
    paperLumSum += luminanceList[i];
    paperLumCount++;
  }
  final paperLum = paperLumCount > 0 ? (paperLumSum / paperLumCount) : 230.0;
  final baseThreshold = (paperLum * 0.82).clamp(70.0, 220.0);

  // 5. Ink Extraction & Auto-Crop Bounding Box
  int minX = w;
  int minY = h;
  int maxX = 0;
  int maxY = 0;

  final inkMask = Uint8List(w * h);

  for (int y = 0; y < h; y++) {
    final rowOffset = y * w;
    for (int x = 0; x < w; x++) {
      final pixel = grayscale.getPixel(x, y);
      final lum = (pixel.r + pixel.g + pixel.b) / 3.0;

      if (lum < baseThreshold) {
        // High-precision smooth contrast curve for razor-sharp edges
        final contrastRatio = ((paperLum - lum) / paperLum).clamp(0.0, 1.0);
        final normalizedAlpha = (((contrastRatio - 0.08) / 0.32) * 255.0)
            .clamp(0.0, 255.0)
            .round();

        if (normalizedAlpha > 15) {
          inkMask[rowOffset + x] = normalizedAlpha;
          if (x < minX) minX = x;
          if (y < minY) minY = y;
          if (x > maxX) maxX = x;
          if (y > maxY) maxY = y;
        }
      }
    }
  }

  // Fallback if no ink detected
  if (maxX <= minX || maxY <= minY) {
    minX = (w * 0.05).round();
    maxX = (w * 0.95).round();
    minY = (h * 0.05).round();
    maxY = (h * 0.95).round();
  }

  // Add comfortable padding around ink
  const pad = 24;
  minX = (minX - pad).clamp(0, w - 1);
  minY = (minY - pad).clamp(0, h - 1);
  maxX = (maxX + pad).clamp(0, w);
  maxY = (maxY + pad).clamp(0, h);

  final cropW = (maxX - minX).clamp(40, w);
  final cropH = (maxY - minY).clamp(30, h);

  // 6. High-Definition Anti-Aliased Image Synthesis
  final transparentImg = img.Image(width: cropW, height: cropH, numChannels: 4);
  img.fill(transparentImg, color: img.ColorRgba8(0, 0, 0, 0));

  final solidImg = img.Image(width: cropW, height: cropH);
  img.fill(solidImg, color: img.ColorRgb8(255, 255, 255));

  for (int cy = 0; cy < cropH; cy++) {
    final gy = minY + cy;
    final rowOffset = gy * w;
    for (int cx = 0; cx < cropW; cx++) {
      final gx = minX + cx;
      final alpha = inkMask[rowOffset + gx];
      if (alpha > 10) {
        // Razor-sharp deep dark midnight ink (RGB: 15, 23, 42)
        transparentImg.setPixel(cx, cy, img.ColorRgba8(15, 23, 42, alpha));

        // Anti-aliased blend on pure white background
        final blendR = (255 - (255 - 15) * (alpha / 255.0)).round().clamp(
          0,
          255,
        );
        final blendG = (255 - (255 - 23) * (alpha / 255.0)).round().clamp(
          0,
          255,
        );
        final blendB = (255 - (255 - 42) * (alpha / 255.0)).round().clamp(
          0,
          255,
        );
        solidImg.setPixel(cx, cy, img.ColorRgb8(blendR, blendG, blendB));
      }
    }
  }

  final transBytes = img.encodePng(transparentImg);
  final transFile = File(
    p.join(tempDirPath, 'scanned_signature_transparent_$ts.png'),
  )..writeAsBytesSync(transBytes);

  final solidBytes = img.encodeJpg(solidImg, quality: 98);
  final solidFile = File(p.join(tempDirPath, 'scanned_signature_white_$ts.jpg'))
    ..writeAsBytesSync(solidBytes);

  return {
    'transPath': transFile.path,
    'solidPath': solidFile.path,
    'width': cropW,
    'height': cropH,
    'size': transBytes.length,
  };
}

/// Top-level worker isolate for cropping & rotating extracted signature
Map<String, dynamic> _adjustSignatureIsolate(Map<String, dynamic> params) {
  final bytes = params['imageBytes'] as Uint8List;
  final cropXRatio = (params['cropXRatio'] as num).toDouble();
  final cropYRatio = (params['cropYRatio'] as num).toDouble();
  final cropWidthRatio = (params['cropWidthRatio'] as num).toDouble();
  final cropHeightRatio = (params['cropHeightRatio'] as num).toDouble();
  final rotationAngle = params['rotationAngle'] as num;
  final tempDirPath = params['tempDirPath'] as String;
  final ts = params['timestamp'] as int;

  img.Image? decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw Exception('Failed to decode signature image.');
  }

  img.Image processed = decoded;
  if (rotationAngle != 0) {
    processed = img.copyRotate(processed, angle: rotationAngle);
  }

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

  // Generate accompanying solid white background image
  final solidImg = img.Image(width: processed.width, height: processed.height);
  img.fill(solidImg, color: img.ColorRgb8(255, 255, 255));
  img.compositeImage(solidImg, processed);

  final transBytes = img.encodePng(processed);
  final transFile = File(
    p.join(tempDirPath, 'signature_adjusted_trans_$ts.png'),
  )..writeAsBytesSync(transBytes);

  final solidBytes = img.encodeJpg(solidImg, quality: 95);
  final solidFile = File(
    p.join(tempDirPath, 'signature_adjusted_white_$ts.jpg'),
  )..writeAsBytesSync(solidBytes);

  return {
    'transPath': transFile.path,
    'solidPath': solidFile.path,
    'width': processed.width,
    'height': processed.height,
    'size': transBytes.length,
  };
}
