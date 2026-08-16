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
      throw Exception('Signature canvas is empty. Please draw a signature first.');
    }

    final tempDir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;

    // Convert strokes to primitive serializable data for isolate execution
    final strokeDataList = strokes.map((s) {
      return {
        'points': s.points.map((pt) => [pt.dx, pt.dy]).toList(),
        'color': [(s.color.r * 255).round(), (s.color.g * 255).round(), (s.color.b * 255).round()],
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

  Future<SignatureExportResult> scanPaperSignature(File photoFile) async {
    final bytes = await photoFile.readAsBytes();
    final tempDir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;

    final result = await compute(_scanPaperSignatureIsolate, {
      'imageBytes': bytes,
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

  const padding = 16.0;
  minX = (minX - padding).clamp(0.0, canvasWidth);
  minY = (minY - padding).clamp(0.0, canvasHeight);
  maxX = (maxX + padding).clamp(0.0, canvasWidth);
  maxY = (maxY + padding).clamp(0.0, canvasHeight);

  final int width = (maxX - minX).round().clamp(60, canvasWidth.round());
  final int height = (maxY - minY).round().clamp(40, canvasHeight.round());

  final transparentImg = img.Image(width: width, height: height, numChannels: 4);
  img.fill(transparentImg, color: img.ColorRgba8(0, 0, 0, 0));

  final solidImg = img.Image(width: width, height: height);
  img.fill(solidImg, color: img.ColorRgb8(255, 255, 255));

  // First pass: white contour halo for dark strokes
  for (final s in strokesData) {
    final c = (s['color'] as List<dynamic>).cast<int>();
    final r = c[0];
    final g = c[1];
    final b = c[2];
    final strokeWidth = (s['strokeWidth'] as num).toDouble();
    final isDark = (0.299 * r + 0.587 * g + 0.114 * b) < 60;

    if (isDark) {
      final whiteContourColor = img.ColorRgba8(255, 255, 255, 230);
      final contourThickness = (strokeWidth + 2.5).round();
      final points = (s['points'] as List<dynamic>).cast<List<dynamic>>();

      for (int i = 0; i < points.length - 1; i++) {
        final x1 = ((points[i][0] as num).toDouble() - minX).round();
        final y1 = ((points[i][1] as num).toDouble() - minY).round();
        final x2 = ((points[i + 1][0] as num).toDouble() - minX).round();
        final y2 = ((points[i + 1][1] as num).toDouble() - minY).round();

        img.drawLine(
          transparentImg,
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
          color: whiteContourColor,
          thickness: contourThickness,
        );
      }
    }
  }

  // Second pass: actual ink strokes
  for (final s in strokesData) {
    final c = (s['color'] as List<dynamic>).cast<int>();
    final r = c[0];
    final g = c[1];
    final b = c[2];
    final strokeWidth = (s['strokeWidth'] as num).toDouble();
    final points = (s['points'] as List<dynamic>).cast<List<dynamic>>();

    final colorRgba = img.ColorRgba8(r, g, b, 255);
    final isNearWhite = r > 230 && g > 230 && b > 230;
    final colorSolidRgb = isNearWhite ? img.ColorRgb8(15, 23, 42) : img.ColorRgb8(r, g, b);

    for (int i = 0; i < points.length - 1; i++) {
      final x1 = ((points[i][0] as num).toDouble() - minX).round();
      final y1 = ((points[i][1] as num).toDouble() - minY).round();
      final x2 = ((points[i + 1][0] as num).toDouble() - minX).round();
      final y2 = ((points[i + 1][1] as num).toDouble() - minY).round();

      img.drawLine(
        transparentImg,
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        color: colorRgba,
        thickness: strokeWidth.round(),
      );

      img.drawLine(
        solidImg,
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        color: colorSolidRgb,
        thickness: strokeWidth.round(),
      );
    }
  }

  final transBytes = img.encodePng(transparentImg);
  final transFile = File(p.join(tempDirPath, 'signature_transparent_$ts.png'))..writeAsBytesSync(transBytes);

  final solidBytes = img.encodeJpg(solidImg, quality: 95);
  final solidFile = File(p.join(tempDirPath, 'signature_white_$ts.jpg'))..writeAsBytesSync(solidBytes);

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
  final tempDirPath = params['tempDirPath'] as String;
  final ts = params['timestamp'] as int;

  img.Image? decoded = img.decodeImage(imageBytes);
  if (decoded == null) {
    throw Exception('Failed to decode paper photo.');
  }

  // Downscale large camera photos to a reasonable dimension (max 1400px)
  // This prevents memory spikes and speeds up extraction by ~15x
  if (decoded.width > 1400 || decoded.height > 1400) {
    final scale = 1400 / (decoded.width > decoded.height ? decoded.width : decoded.height);
    decoded = img.copyResize(
      decoded,
      width: (decoded.width * scale).round(),
      height: (decoded.height * scale).round(),
      interpolation: img.Interpolation.linear,
    );
  }

  final grayscale = img.grayscale(decoded);
  final int w = grayscale.width;
  final int h = grayscale.height;

  // 1. Compute Otsu/Adaptive Luminance Threshold & Bounding Box
  int minX = w;
  int minY = h;
  int maxX = 0;
  int maxY = 0;

  // Compute average luminance to adapt to bright/dim paper lighting
  double sumLuminance = 0;
  final sampleStep = (w * h / 10000).clamp(1, 20).round();
  int sampleCount = 0;
  for (int y = 0; y < h; y += sampleStep) {
    for (int x = 0; x < w; x += sampleStep) {
      final p = grayscale.getPixel(x, y);
      sumLuminance += (p.r + p.g + p.b) / 3.0;
      sampleCount++;
    }
  }
  final avgLuminance = sumLuminance / sampleCount;
  final threshold = (avgLuminance * 0.75).clamp(80.0, 160.0);

  final inkMask = Uint8List(w * h);

  for (int y = 0; y < h; y++) {
    final rowOffset = y * w;
    for (int x = 0; x < w; x++) {
      final pixel = grayscale.getPixel(x, y);
      final lum = (pixel.r + pixel.g + pixel.b) / 3.0;

      if (lum < threshold) {
        final alpha = (((threshold - lum) / threshold) * 255 * 1.6).clamp(0, 255).round();
        if (alpha > 25) {
          inkMask[rowOffset + x] = alpha;
          if (x < minX) minX = x;
          if (y < minY) minY = y;
          if (x > maxX) maxX = x;
          if (y > maxY) maxY = y;
        }
      }
    }
  }

  // If no ink was found, fallback to center bounds
  if (maxX <= minX || maxY <= minY) {
    minX = (w * 0.1).round();
    maxX = (w * 0.9).round();
    minY = (h * 0.1).round();
    maxY = (h * 0.9).round();
  }

  // Add 16px padding around detected ink bounds
  const pad = 16;
  minX = (minX - pad).clamp(0, w - 1);
  minY = (minY - pad).clamp(0, h - 1);
  maxX = (maxX + pad).clamp(0, w);
  maxY = (maxY + pad).clamp(0, h);

  final cropW = (maxX - minX).clamp(40, w);
  final cropH = (maxY - minY).clamp(30, h);

  // 2. Render cropped transparent and solid images
  final transparentImg = img.Image(width: cropW, height: cropH, numChannels: 4);
  img.fill(transparentImg, color: img.ColorRgba8(0, 0, 0, 0));

  final solidImg = img.Image(width: cropW, height: cropH);
  img.fill(solidImg, color: img.ColorRgb8(255, 255, 255));

  // Pass 1: Render subtle white halo for dark mode support
  const radius = 2;
  for (int cy = 0; cy < cropH; cy++) {
    final gy = minY + cy;
    final rowOffset = gy * w;
    for (int cx = 0; cx < cropW; cx++) {
      final gx = minX + cx;
      if (inkMask[rowOffset + gx] > 40) {
        for (int dy = -radius; dy <= radius; dy++) {
          final ny = cy + dy;
          if (ny < 0 || ny >= cropH) continue;
          for (int dx = -radius; dx <= radius; dx++) {
            final nx = cx + dx;
            if (nx < 0 || nx >= cropW) continue;
            final existingAlpha = transparentImg.getPixel(nx, ny).a;
            if (existingAlpha < 200) {
              transparentImg.setPixel(nx, ny, img.ColorRgba8(255, 255, 255, 210));
            }
          }
        }
      }
    }
  }

  // Pass 2: Render smooth dark blue/black ink onto transparent & solid white
  for (int cy = 0; cy < cropH; cy++) {
    final gy = minY + cy;
    final rowOffset = gy * w;
    for (int cx = 0; cx < cropW; cx++) {
      final gx = minX + cx;
      final alpha = inkMask[rowOffset + gx];
      if (alpha > 15) {
        // Crisp dark-blue ink color
        transparentImg.setPixel(cx, cy, img.ColorRgba8(10, 15, 45, alpha));
        solidImg.setPixel(cx, cy, img.ColorRgb8(10, 15, 45));
      }
    }
  }

  final transBytes = img.encodePng(transparentImg);
  final transFile = File(p.join(tempDirPath, 'scanned_signature_transparent_$ts.png'))..writeAsBytesSync(transBytes);

  final solidBytes = img.encodeJpg(solidImg, quality: 95);
  final solidFile = File(p.join(tempDirPath, 'scanned_signature_white_$ts.jpg'))..writeAsBytesSync(solidBytes);

  return {
    'transPath': transFile.path,
    'solidPath': solidFile.path,
    'width': cropW,
    'height': cropH,
    'size': transBytes.length,
  };
}
