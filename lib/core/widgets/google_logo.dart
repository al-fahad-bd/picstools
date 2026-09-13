import 'package:flutter/material.dart';

/// Pixel-perfect vector render of the official Google 4-color "G" mark
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 48.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Blue: horizontal center bar and right side
    final bluePath = Path()
      ..moveTo(46.98, 24.55)
      ..cubicTo(46.98, 22.92, 46.83, 21.34, 46.56, 19.82)
      ..lineTo(24, 19.82)
      ..lineTo(24, 28.98)
      ..lineTo(36.93, 28.98)
      ..cubicTo(36.37, 31.99, 34.68, 34.54, 32.12, 36.26)
      ..lineTo(32.12, 42.34)
      ..lineTo(39.91, 42.34)
      ..cubicTo(44.47, 38.14, 46.98, 31.94, 46.98, 24.55)
      ..close();
    paint.color = const Color(0xFF4285F4);
    canvas.drawPath(bluePath, paint);

    // 2. Green: bottom arc
    final greenPath = Path()
      ..moveTo(24, 48)
      ..cubicTo(30.48, 48, 35.91, 45.85, 39.91, 42.34)
      ..lineTo(32.12, 36.26)
      ..cubicTo(29.96, 37.71, 27.18, 38.57, 24, 38.57)
      ..cubicTo(17.76, 38.57, 12.49, 34.37, 10.6, 28.71)
      ..lineTo(2.57, 28.71)
      ..lineTo(2.57, 35)
      ..cubicTo(6.52, 42.84, 14.62, 48, 24, 48)
      ..close();
    paint.color = const Color(0xFF34A853);
    canvas.drawPath(greenPath, paint);

    // 3. Yellow: left lower arc
    final yellowPath = Path()
      ..moveTo(10.6, 28.71)
      ..cubicTo(10.12, 27.27, 9.85, 25.73, 9.85, 24.14)
      ..cubicTo(9.85, 22.56, 10.12, 21.01, 10.6, 19.57)
      ..lineTo(10.6, 13.28)
      ..lineTo(2.57, 13.28)
      ..cubicTo(0.93, 16.54, 0, 20.24, 0, 24.14)
      ..cubicTo(0, 28.05, 0.93, 31.74, 2.57, 35)
      ..lineTo(10.6, 28.71)
      ..close();
    paint.color = const Color(0xFFFBBC05);
    canvas.drawPath(yellowPath, paint);

    // 4. Red: top arc
    final redPath = Path()
      ..moveTo(24, 9.71)
      ..cubicTo(27.52, 9.71, 30.68, 10.92, 33.17, 13.3)
      ..lineTo(40.09, 6.38)
      ..cubicTo(35.89, 2.47, 30.46, 0, 24, 0)
      ..cubicTo(14.62, 0, 6.52, 5.16, 2.57, 13)
      ..lineTo(10.6, 19.29)
      ..cubicTo(12.49, 13.63, 17.76, 9.71, 24, 9.71)
      ..close();
    paint.color = const Color(0xFFEA4335);
    canvas.drawPath(redPath, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
