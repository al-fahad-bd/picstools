import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/id_photo_preset.dart';
import '../../background_remover/domain/usecases/remove_background_usecase.dart';

enum PrintSheetType {
  single,
  sheet4x6, // 6 photos on 4x6" photo paper
  sheetA4,  // 24 photos on A4 paper sheet
}

class IdPhotoResult {
  final File singlePhotoFile;
  final File? printSheetJpgFile;
  final File? printSheetPdfFile;
  final IdPhotoPreset preset;
  final PrintSheetType sheetType;
  final int singleWidthPx;
  final int singleHeightPx;
  final int singleFileSizeBytes;

  IdPhotoResult({
    required this.singlePhotoFile,
    this.printSheetJpgFile,
    this.printSheetPdfFile,
    required this.preset,
    required this.sheetType,
    required this.singleWidthPx,
    required this.singleHeightPx,
    required this.singleFileSizeBytes,
  });
}

class IdPhotoService {
  final RemoveBackgroundUseCase? removeBackgroundUseCase;

  IdPhotoService({this.removeBackgroundUseCase});

  Future<IdPhotoResult> createPassportPhoto({
    required File imageFile,
    required IdPhotoPreset preset,
    required Rect normCropRect,
    required Color bgColor,
    required PrintSheetType sheetType,
    int rotationAngle = 0,
  }) async {
    File sourceImageFile = imageFile;
    if (removeBackgroundUseCase != null) {
      try {
        final bgResult = await removeBackgroundUseCase!(imageFile: imageFile);
        sourceImageFile = bgResult.transparentPngFile;
      } catch (e) {
        debugPrint('Auto background removal fallback (model not downloaded or error): $e');
      }
    }

    final originalBytes = await sourceImageFile.readAsBytes();
    final decoded = img.decodeImage(originalBytes);
    if (decoded == null) {
      throw Exception('Failed to decode photo file.');
    }

    img.Image processed = decoded;
    if (rotationAngle != 0) {
      processed = img.copyRotate(processed, angle: rotationAngle);
    }

    // 1. Crop to selected area
    final int origW = processed.width;
    final int origH = processed.height;

    final int cropX = (origW * normCropRect.left).round().clamp(0, origW - 1);
    final int cropY = (origH * normCropRect.top).round().clamp(0, origH - 1);
    final int cropW = (origW * normCropRect.width).round().clamp(10, origW - cropX);
    final int cropH = (origH * normCropRect.height).round().clamp(10, origH - cropY);

    final cropped = img.copyCrop(processed, x: cropX, y: cropY, width: cropW, height: cropH);

    // 2. High-DPI Resize to target pixel dimensions
    final resized = img.copyResize(
      cropped,
      width: preset.targetWidthPx,
      height: preset.targetHeightPx,
      interpolation: img.Interpolation.average,
    );

    // 3. Apply Background Color Fill
    final canvasPhoto = img.Image(
      width: preset.targetWidthPx,
      height: preset.targetHeightPx,
      numChannels: 4,
    );
    final bgRgb = img.ColorRgb8(
      (bgColor.r * 255).round().clamp(0, 255),
      (bgColor.g * 255).round().clamp(0, 255),
      (bgColor.b * 255).round().clamp(0, 255),
    );
    img.fill(canvasPhoto, color: bgRgb);
    img.compositeImage(canvasPhoto, resized);

    // Save Single Photo File
    final singleBytes = img.encodeJpg(canvasPhoto, quality: 95);
    final tempDir = await getTemporaryDirectory();
    final singleOut = File(p.join(
      tempDir.path,
      'id_${preset.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    ));
    await singleOut.writeAsBytes(singleBytes);

    File? printSheetJpg;
    File? printSheetPdf;

    if (sheetType != PrintSheetType.single) {
      final sheetData = await _generatePrintSheet(
        singleImage: canvasPhoto,
        preset: preset,
        sheetType: sheetType,
        tempDir: tempDir,
      );
      printSheetJpg = sheetData['jpg'] as File?;
      printSheetPdf = sheetData['pdf'] as File?;
    }

    return IdPhotoResult(
      singlePhotoFile: singleOut,
      printSheetJpgFile: printSheetJpg,
      printSheetPdfFile: printSheetPdf,
      preset: preset,
      sheetType: sheetType,
      singleWidthPx: preset.targetWidthPx,
      singleHeightPx: preset.targetHeightPx,
      singleFileSizeBytes: singleBytes.length,
    );
  }

  Future<Map<String, dynamic>> _generatePrintSheet({
    required img.Image singleImage,
    required IdPhotoPreset preset,
    required PrintSheetType sheetType,
    required Directory tempDir,
  }) async {
    final isA4 = sheetType == PrintSheetType.sheetA4;
    // 4x6 sheet @ 300 DPI = 1200 x 1800 px
    // A4 sheet @ 300 DPI = 2480 x 3508 px
    final sheetW = isA4 ? 2480 : 1200;
    final sheetH = isA4 ? 3508 : 1800;

    final sheet = img.Image(width: sheetW, height: sheetH);
    img.fill(sheet, color: img.ColorRgb8(255, 255, 255));

    final cols = isA4 ? 4 : 2;
    final rows = isA4 ? 6 : 3;

    final photoW = singleImage.width;
    final photoH = singleImage.height;

    // Scale photo to fit grid if needed
    final double maxTileW = (sheetW * 0.85) / cols;
    final double maxTileH = (sheetH * 0.85) / rows;
    final double scale = (maxTileW / photoW < maxTileH / photoH) ? maxTileW / photoW : maxTileH / photoH;

    final tileW = (photoW * scale).round();
    final tileH = (photoH * scale).round();

    final tileImage = img.copyResize(singleImage, width: tileW, height: tileH);

    final totalMarginX = sheetW - (cols * tileW);
    final totalMarginY = sheetH - (rows * tileH);
    final startX = (totalMarginX / 2.0).round();
    final startY = (totalMarginY / 2.0).round();

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final posX = startX + (c * tileW);
        final posY = startY + (r * tileH);
        img.compositeImage(sheet, tileImage, dstX: posX, dstY: posY);

        // Thin cutting border rectangle
        img.drawRect(
          sheet,
          x1: posX,
          y1: posY,
          x2: posX + tileW,
          y2: posY + tileH,
          color: img.ColorRgb8(200, 200, 200),
          thickness: 2,
        );
      }
    }

    final jpgBytes = img.encodeJpg(sheet, quality: 92);
    final jpgFile = File(p.join(tempDir.path, 'print_sheet_${DateTime.now().millisecondsSinceEpoch}.jpg'));
    await jpgFile.writeAsBytes(jpgBytes);

    // Create PDF Print Document
    final pdfDoc = pw.Document();
    final pdfImage = pw.MemoryImage(jpgBytes);
    pdfDoc.addPage(
      pw.Page(
        pageFormat: isA4 ? PdfPageFormat.a4 : const PdfPageFormat(4 * PdfPageFormat.inch, 6 * PdfPageFormat.inch),
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
        ),
      ),
    );

    final pdfFile = File(p.join(tempDir.path, 'print_sheet_${DateTime.now().millisecondsSinceEpoch}.pdf'));
    await pdfFile.writeAsBytes(await pdfDoc.save());

    return {'jpg': jpgFile, 'pdf': pdfFile};
  }
}
