import 'package:flutter/material.dart';

class SignatureStroke {
  final List<Offset> points;
  final double strokeWidth;
  final Color color;

  SignatureStroke({
    required this.points,
    required this.strokeWidth,
    required this.color,
  });

  SignatureStroke copyWith({
    List<Offset>? points,
    double? strokeWidth,
    Color? color,
  }) {
    return SignatureStroke(
      points: points ?? List.from(this.points),
      strokeWidth: strokeWidth ?? this.strokeWidth,
      color: color ?? this.color,
    );
  }
}
