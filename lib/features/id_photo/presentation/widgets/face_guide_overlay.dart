import 'package:flutter/material.dart';
import '../../../../core/constants/neo_colors.dart';

class FaceGuideOverlay extends StatelessWidget {
  final String title;

  const FaceGuideOverlay({
    super.key,
    this.title = 'Align Face Inside Oval Guide',
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _FaceGuidePainter(title: title),
      ),
    );
  }
}

class _FaceGuidePainter extends CustomPainter {
  final String title;

  _FaceGuidePainter({required this.title});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ovalWidth = size.width * 0.55;
    final ovalHeight = size.height * 0.65;
    final ovalRect = Rect.fromCenter(center: center, width: ovalWidth, height: ovalHeight);

    // 1. Oval stroke paint
    final ovalPaint = Paint()
      ..color = NeoColors.yellow
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final shadowPaint = Paint()
      ..color = NeoColors.borderLight
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    canvas.drawOval(ovalRect, shadowPaint);
    canvas.drawOval(ovalRect, ovalPaint);

    // 2. Eye Level Guide Line (Dashed horizontal)
    final eyeLevelY = center.dy - (ovalHeight * 0.1);
    final dashedPaint = Paint()
      ..color = NeoColors.cyan
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(ovalRect.left + 10, eyeLevelY),
      Offset(ovalRect.right - 10, eyeLevelY),
      dashedPaint,
    );

    // 3. Head Top & Chin guides
    final topY = ovalRect.top + (ovalHeight * 0.05);
    final chinY = ovalRect.bottom - (ovalHeight * 0.05);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 1.5;

    canvas.drawLine(Offset(center.dx - 25, topY), Offset(center.dx + 25, topY), linePaint);
    canvas.drawLine(Offset(center.dx - 25, chinY), Offset(center.dx + 25, chinY), linePaint);
  }

  @override
  bool shouldRepaint(covariant _FaceGuidePainter oldDelegate) {
    return oldDelegate.title != title;
  }
}
