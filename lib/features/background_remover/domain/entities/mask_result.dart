import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class MaskResult extends Equatable {
  final Float32List alphaValues; // Values from 0.0 (transparent) to 1.0 (opaque)
  final int width;
  final int height;

  const MaskResult({
    required this.alphaValues,
    required this.width,
    required this.height,
  });

  @override
  List<Object?> get props => [width, height, alphaValues.length];
}
