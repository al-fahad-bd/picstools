import 'package:flutter/material.dart';

class CheckeredPatternPainter extends CustomPainter {
  final double squareSize;

  CheckeredPatternPainter({this.squareSize = 8.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLight = Paint()..color = const Color(0xFFF1F5F9);
    final paintDark = Paint()..color = const Color(0xFFCBD5E1);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintLight);

    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        final isDark =
            ((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 1;
        if (isDark) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, squareSize, squareSize),
            paintDark,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
