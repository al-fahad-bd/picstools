import 'dart:io';
import 'package:equatable/equatable.dart';

class BackgroundRemovalResult extends Equatable {
  final File originalFile;
  final File transparentPngFile;
  final int width;
  final int height;
  final Duration duration;
  final int originalSizeBytes;
  final int processedSizeBytes;

  const BackgroundRemovalResult({
    required this.originalFile,
    required this.transparentPngFile,
    required this.width,
    required this.height,
    required this.duration,
    required this.originalSizeBytes,
    required this.processedSizeBytes,
  });

  @override
  List<Object?> get props => [
        originalFile.path,
        transparentPngFile.path,
        width,
        height,
        duration,
        originalSizeBytes,
        processedSizeBytes,
      ];
}
