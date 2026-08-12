import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/signature_stroke.dart';

class SignatureExportResult {
  final File transparentPngFile; // Transparent PNG (with white contour if black ink)
  final File solidBackgroundFile; // White background
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

    // 1. Compute tight bounding box around strokes
    double minX = canvasSize.width;
    double minY = canvasSize.height;
    double maxX = 0;
    double maxY = 0;

    for (final stroke in strokes) {
      for (final pt in stroke.points) {
        if (pt.dx < minX) minX = pt.dx;
        if (pt.dy < minY) minY = pt.dy;
        if (pt.dx > maxX) maxX = pt.dx;
        if (pt.dy > maxY) maxY = pt.dy;
      }
    }

    // Add padding around signature (15px)
    const padding = 15.0;
    minX = (minX - padding).clamp(0.0, canvasSize.width);
    minY = (minY - padding).clamp(0.0, canvasSize.height);
    maxX = (maxX + padding).clamp(0.0, canvasSize.width);
    maxY = (maxY + padding).clamp(0.0, canvasSize.height);

    final int width = (maxX - minX).round().clamp(50, canvasSize.width.round());
    final int height = (maxY - minY).round().clamp(30, canvasSize.height.round());

    // 2. Render Transparent PNG Image
    final transparentImg = img.Image(width: width, height: height, numChannels: 4);
    img.fill(transparentImg, color: img.ColorRgba8(0, 0, 0, 0));

    // 3. Render Solid White Background Image
    final solidImg = img.Image(width: width, height: height);
    img.fill(solidImg, color: img.ColorRgb8(255, 255, 255));

    // First pass on transparentImg: Draw subtle white contour ONLY for black/dark strokes
    for (final stroke in strokes) {
      final c = stroke.color;
      final r = (c.r * 255).round().clamp(0, 255);
      final g = (c.g * 255).round().clamp(0, 255);
      final b = (c.b * 255).round().clamp(0, 255);
      final isBlackOrDark = (r < 40 && g < 40 && b < 40) || (0.299 * r + 0.587 * g + 0.114 * b < 30);

      if (isBlackOrDark) {
        // Black stroke: add white contour halo for dark mode & WhatsApp visibility
        final whiteContourColor = img.ColorRgba8(255, 255, 255, 230);
        final contourThickness = (stroke.strokeWidth + 2.5).round();

        for (int i = 0; i < stroke.points.length - 1; i++) {
          final p1 = stroke.points[i];
          final p2 = stroke.points[i + 1];

          final x1 = (p1.dx - minX).round();
          final y1 = (p1.dy - minY).round();
          final x2 = (p2.dx - minX).round();
          final y2 = (p2.dy - minY).round();

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

    // Second pass: Draw actual strokes on transparentImg and solidImg
    for (final stroke in strokes) {
      final c = stroke.color;
      final r = (c.r * 255).round().clamp(0, 255);
      final g = (c.g * 255).round().clamp(0, 255);
      final b = (c.b * 255).round().clamp(0, 255);

      final colorRgba = img.ColorRgba8(r, g, b, 255);
      final isNearWhite = r > 230 && g > 230 && b > 230;
      final colorSolidRgb = isNearWhite ? img.ColorRgb8(15, 23, 42) : img.ColorRgb8(r, g, b);

      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];

        final x1 = (p1.dx - minX).round();
        final y1 = (p1.dy - minY).round();
        final x2 = (p2.dx - minX).round();
        final y2 = (p2.dy - minY).round();

        img.drawLine(
          transparentImg,
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
          color: colorRgba,
          thickness: stroke.strokeWidth.round(),
        );

        img.drawLine(
          solidImg,
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
          color: colorSolidRgb,
          thickness: stroke.strokeWidth.round(),
        );
      }
    }

    // Save files
    final tempDir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;

    final transPngBytes = img.encodePng(transparentImg);
    final transFile = File(p.join(tempDir.path, 'signature_transparent_$ts.png'));
    await transFile.writeAsBytes(transPngBytes);

    final solidBytes = img.encodeJpg(solidImg, quality: 95);
    final solidFile = File(p.join(tempDir.path, 'signature_white_$ts.jpg'));
    await solidFile.writeAsBytes(solidBytes);

    return SignatureExportResult(
      transparentPngFile: transFile,
      solidBackgroundFile: solidFile,
      widthPx: width,
      heightPx: height,
      fileSizeBytes: transPngBytes.length,
    );
  }

  Future<SignatureExportResult> scanPaperSignature(File photoFile) async {
    final bytes = await photoFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Failed to decode paper photo.');
    }

    // Convert to grayscale & auto-contrast threshold
    final grayscale = img.grayscale(decoded);

    // Create transparent background image
    final transparentImg = img.Image(width: grayscale.width, height: grayscale.height, numChannels: 4);
    img.fill(transparentImg, color: img.ColorRgba8(0, 0, 0, 0));

    // First pass: Extract paper ink
    final tempInkImg = img.Image(width: grayscale.width, height: grayscale.height, numChannels: 4);
    img.fill(tempInkImg, color: img.ColorRgba8(0, 0, 0, 0));

    for (int y = 0; y < grayscale.height; y++) {
      for (int x = 0; x < grayscale.width; x++) {
        final pixel = grayscale.getPixel(x, y);
        final luminance = (pixel.r + pixel.g + pixel.b) / 3.0;

        if (luminance < 140) {
          final alpha = ((255 - luminance) * 1.5).clamp(0, 255).round();
          tempInkImg.setPixel(x, y, img.ColorRgba8(0, 0, 50, alpha));
        }
      }
    }

    // Add white halo around scanned dark paper ink for dark mode visibility
    const outlineRadius = 2;
    for (int y = 0; y < tempInkImg.height; y++) {
      for (int x = 0; x < tempInkImg.width; x++) {
        final p = tempInkImg.getPixel(x, y);
        if (p.a > 30) {
          for (int dy = -outlineRadius; dy <= outlineRadius; dy++) {
            for (int dx = -outlineRadius; dx <= outlineRadius; dx++) {
              final nx = x + dx;
              final ny = y + dy;
              if (nx >= 0 && nx < transparentImg.width && ny >= 0 && ny < transparentImg.height) {
                final currentAlpha = transparentImg.getPixel(nx, ny).a;
                if (currentAlpha < 220) {
                  transparentImg.setPixel(nx, ny, img.ColorRgba8(255, 255, 255, 220));
                }
              }
            }
          }
        }
      }
    }

    // Overlay paper ink on top of white contour
    for (int y = 0; y < tempInkImg.height; y++) {
      for (int x = 0; x < tempInkImg.width; x++) {
        final p = tempInkImg.getPixel(x, y);
        if (p.a > 10) {
          transparentImg.setPixel(x, y, img.ColorRgba8(p.r.round(), p.g.round(), p.b.round(), p.a.round()));
        }
      }
    }

    final solidImg = img.Image(width: transparentImg.width, height: transparentImg.height);
    img.fill(solidImg, color: img.ColorRgb8(255, 255, 255));

    for (int y = 0; y < tempInkImg.height; y++) {
      for (int x = 0; x < tempInkImg.width; x++) {
        final p = tempInkImg.getPixel(x, y);
        if (p.a > 10) {
          solidImg.setPixel(x, y, img.ColorRgb8(p.r.round(), p.g.round(), p.b.round()));
        }
      }
    }

    final tempDir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;

    final transBytes = img.encodePng(transparentImg);
    final transFile = File(p.join(tempDir.path, 'scanned_signature_transparent_$ts.png'));
    await transFile.writeAsBytes(transBytes);

    final solidBytes = img.encodeJpg(solidImg, quality: 95);
    final solidFile = File(p.join(tempDir.path, 'scanned_signature_white_$ts.jpg'));
    await solidFile.writeAsBytes(solidBytes);

    return SignatureExportResult(
      transparentPngFile: transFile,
      solidBackgroundFile: solidFile,
      widthPx: transparentImg.width,
      heightPx: transparentImg.height,
      fileSizeBytes: transBytes.length,
    );
  }
}
