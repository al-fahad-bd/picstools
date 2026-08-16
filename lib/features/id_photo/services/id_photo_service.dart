import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
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
  sheetA4, // 24 photos on A4 paper sheet
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
  final RemoveBackgroundUseCase removeBackgroundUseCase;

  IdPhotoService({required this.removeBackgroundUseCase});

  Future<IdPhotoResult> createPassportPhoto({
    required File imageFile,
    required IdPhotoPreset preset,
    required Rect normCropRect,
    required Color bgColor,
    required PrintSheetType sheetType,
    int rotationAngle = 0,
  }) async {
    // Enforce AI portrait isolation so the subject is cleanly placed on the chosen background color
    final bgResult = await removeBackgroundUseCase(imageFile: imageFile);
    final sourceImageFile = bgResult.transparentPngFile;

    final rawBytes = await sourceImageFile.readAsBytes();
    final tempDir = await getTemporaryDirectory();

    final workerParams = _IdPhotoWorkerParams(
      imageBytes: rawBytes,
      targetWidthPx: preset.targetWidthPx,
      targetHeightPx: preset.targetHeightPx,
      cropLeft: normCropRect.left,
      cropTop: normCropRect.top,
      cropWidth: normCropRect.width,
      cropHeight: normCropRect.height,
      bgColorR: (bgColor.r * 255).round().clamp(0, 255),
      bgColorG: (bgColor.g * 255).round().clamp(0, 255),
      bgColorB: (bgColor.b * 255).round().clamp(0, 255),
      sheetType: sheetType,
      rotationAngle: rotationAngle,
      tempDirPath: tempDir.path,
      presetId: preset.id,
    );

    final workerOutput = await compute(_idPhotoWorkerIsolate, workerParams);

    File? pdfFile;
    if (workerOutput.printSheetPdfBytes != null) {
      pdfFile = File(
        p.join(
          tempDir.path,
          'print_sheet_${DateTime.now().millisecondsSinceEpoch}.pdf',
        ),
      );
      await pdfFile.writeAsBytes(workerOutput.printSheetPdfBytes!);
    }

    return IdPhotoResult(
      singlePhotoFile: File(workerOutput.singlePhotoPath),
      printSheetJpgFile: workerOutput.printSheetJpgPath != null
          ? File(workerOutput.printSheetJpgPath!)
          : null,
      printSheetPdfFile: pdfFile,
      preset: preset,
      sheetType: sheetType,
      singleWidthPx: workerOutput.singleWidthPx,
      singleHeightPx: workerOutput.singleHeightPx,
      singleFileSizeBytes: workerOutput.singleFileSizeBytes,
    );
  }
}

class _IdPhotoWorkerParams {
  final Uint8List imageBytes;
  final int targetWidthPx;
  final int targetHeightPx;
  final double cropLeft;
  final double cropTop;
  final double cropWidth;
  final double cropHeight;
  final int bgColorR;
  final int bgColorG;
  final int bgColorB;
  final PrintSheetType sheetType;
  final int rotationAngle;
  final String tempDirPath;
  final String presetId;

  const _IdPhotoWorkerParams({
    required this.imageBytes,
    required this.targetWidthPx,
    required this.targetHeightPx,
    required this.cropLeft,
    required this.cropTop,
    required this.cropWidth,
    required this.cropHeight,
    required this.bgColorR,
    required this.bgColorG,
    required this.bgColorB,
    required this.sheetType,
    required this.rotationAngle,
    required this.tempDirPath,
    required this.presetId,
  });
}

class _IdPhotoWorkerOutput {
  final String singlePhotoPath;
  final String? printSheetJpgPath;
  final Uint8List? printSheetPdfBytes;
  final int singleWidthPx;
  final int singleHeightPx;
  final int singleFileSizeBytes;

  const _IdPhotoWorkerOutput({
    required this.singlePhotoPath,
    this.printSheetJpgPath,
    this.printSheetPdfBytes,
    required this.singleWidthPx,
    required this.singleHeightPx,
    required this.singleFileSizeBytes,
  });
}

Future<_IdPhotoWorkerOutput> _idPhotoWorkerIsolate(
  _IdPhotoWorkerParams params,
) async {
  final decoded = img.decodeImage(params.imageBytes);
  if (decoded == null) {
    throw Exception('Failed to decode photo file in background worker.');
  }

  // Downsample if image is excessively large (e.g. 48MP raw camera image > 2400px)
  img.Image processed = decoded;
  final maxDim = math.max(processed.width, processed.height);
  if (maxDim > 2400) {
    final scale = 2400 / maxDim;
    processed = img.copyResize(
      processed,
      width: (processed.width * scale).round(),
      height: (processed.height * scale).round(),
      interpolation: img.Interpolation.linear,
    );
  }

  if (params.rotationAngle != 0) {
    processed = img.copyRotate(processed, angle: params.rotationAngle);
  }

  // 1. Crop to normalized rect
  final int origW = processed.width;
  final int origH = processed.height;

  final int cropX = (origW * params.cropLeft).round().clamp(0, origW - 1);
  final int cropY = (origH * params.cropTop).round().clamp(0, origH - 1);
  final int cropW = (origW * params.cropWidth).round().clamp(
    10,
    origW - cropX,
  );
  final int cropH = (origH * params.cropHeight).round().clamp(
    10,
    origH - cropY,
  );

  final cropped = img.copyCrop(
    processed,
    x: cropX,
    y: cropY,
    width: cropW,
    height: cropH,
  );

  // 2. High-DPI Resize to target pixel dimensions
  final resized = img.copyResize(
    cropped,
    width: params.targetWidthPx,
    height: params.targetHeightPx,
    interpolation: img.Interpolation.average,
  );

  // 3. Apply Background Color Fill
  final canvasPhoto = img.Image(
    width: params.targetWidthPx,
    height: params.targetHeightPx,
    numChannels: 4,
  );
  final bgRgb = img.ColorRgb8(params.bgColorR, params.bgColorG, params.bgColorB);
  img.fill(canvasPhoto, color: bgRgb);
  img.compositeImage(canvasPhoto, resized);

  // Save Single Photo File
  final singleBytes = img.encodeJpg(canvasPhoto, quality: 95);
  final singleOutPath = p.join(
    params.tempDirPath,
    'id_${params.presetId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
  );
  File(singleOutPath).writeAsBytesSync(singleBytes);

  String? sheetJpgPath;
  Uint8List? sheetPdfBytes;

  if (params.sheetType != PrintSheetType.single) {
    final isA4 = params.sheetType == PrintSheetType.sheetA4;
    // 4x6 sheet @ 300 DPI = 1200 x 1800 px
    // A4 sheet @ 300 DPI = 2480 x 3508 px
    final sheetW = isA4 ? 2480 : 1200;
    final sheetH = isA4 ? 3508 : 1800;

    final sheet = img.Image(width: sheetW, height: sheetH);
    img.fill(sheet, color: img.ColorRgb8(255, 255, 255));

    final cols = isA4 ? 4 : 2;
    final rows = isA4 ? 6 : 3;

    final photoW = canvasPhoto.width;
    final photoH = canvasPhoto.height;

    // Scale photo to fit grid if needed
    final double maxTileW = (sheetW * 0.85) / cols;
    final double maxTileH = (sheetH * 0.85) / rows;
    final double scale =
        (maxTileW / photoW < maxTileH / photoH)
            ? maxTileW / photoW
            : maxTileH / photoH;

    final tileW = (photoW * scale).round();
    final tileH = (photoH * scale).round();

    final tileImage = img.copyResize(canvasPhoto, width: tileW, height: tileH);

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
    sheetJpgPath = p.join(
      params.tempDirPath,
      'print_sheet_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    File(sheetJpgPath).writeAsBytesSync(jpgBytes);

    // Create PDF Print Document
    final pdfDoc = pw.Document();
    final pdfImage = pw.MemoryImage(jpgBytes);
    pdfDoc.addPage(
      pw.Page(
        pageFormat:
            isA4
                ? PdfPageFormat.a4
                : const PdfPageFormat(
                  4 * PdfPageFormat.inch,
                  6 * PdfPageFormat.inch,
                ),
        margin: pw.EdgeInsets.zero,
        build:
            (pw.Context context) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
            ),
      ),
    );

    sheetPdfBytes = await pdfDoc.save();
  }

  return _IdPhotoWorkerOutput(
    singlePhotoPath: singleOutPath,
    printSheetJpgPath: sheetJpgPath,
    printSheetPdfBytes: sheetPdfBytes,
    singleWidthPx: params.targetWidthPx,
    singleHeightPx: params.targetHeightPx,
    singleFileSizeBytes: singleBytes.length,
  );
}
