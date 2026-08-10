import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PdfResult {
  final File pdfFile;
  final int pageCount;
  final int fileSizeBytes;

  PdfResult({
    required this.pdfFile,
    required this.pageCount,
    required this.fileSizeBytes,
  });
}

enum PdfPageFormatType { a4, letter, original }
enum PdfOrientation { portrait, landscape }
enum PdfMarginType { none, small, medium }

class ImagePdfService {
  Future<PdfResult> generatePdf({
    required List<File> imageFiles,
    PdfPageFormatType pageFormat = PdfPageFormatType.a4,
    PdfOrientation orientation = PdfOrientation.portrait,
    PdfMarginType margin = PdfMarginType.small,
  }) async {
    final pdf = pw.Document();

    double marginVal = 10.0;
    if (margin == PdfMarginType.none) marginVal = 0.0;
    if (margin == PdfMarginType.medium) marginVal = 20.0;

    PdfPageFormat baseFormat = PdfPageFormat.a4;
    if (pageFormat == PdfPageFormatType.letter) {
      baseFormat = PdfPageFormat.letter;
    }

    final targetFormat = orientation == PdfOrientation.landscape
        ? baseFormat.landscape
        : baseFormat.portrait;

    for (final file in imageFiles) {
      final bytes = await file.readAsBytes();
      final image = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat == PdfPageFormatType.original
              ? PdfPageFormat(image.width?.toDouble() ?? 595, image.height?.toDouble() ?? 842)
              : targetFormat,
          margin: pw.EdgeInsets.all(marginVal),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    final tempDir = await getTemporaryDirectory();
    final outPath = p.join(
      tempDir.path,
      'doc_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    final outFile = File(outPath);
    await outFile.writeAsBytes(await pdf.save());

    return PdfResult(
      pdfFile: outFile,
      pageCount: imageFiles.length,
      fileSizeBytes: await outFile.length(),
    );
  }
}
