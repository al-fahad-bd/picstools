import 'package:flutter/material.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';

class CheckerboardPainter extends CustomPainter {
  final double cellSize;
  final Color color1;
  final Color color2;

  const CheckerboardPainter({
    this.cellSize = 12.0,
    this.color1 = const Color(0xFFEEEEEE),
    this.color2 = const Color(0xFFFFFFFF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = color1;
    final paint2 = Paint()..color = color2;

    final numX = (size.width / cellSize).ceil();
    final numY = (size.height / cellSize).ceil();

    for (int y = 0; y < numY; y++) {
      for (int x = 0; x < numX; x++) {
        final rect = Rect.fromLTWH(
          x * cellSize,
          y * cellSize,
          cellSize,
          cellSize,
        );
        canvas.drawRect(rect, (x + y) % 2 == 0 ? paint1 : paint2);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CheckerboardContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final double shadowOffset;

  const CheckerboardContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.borderWidth = NeoStyles.borderWidth,
    this.borderColor = NeoColors.borderLight,
    this.shadowOffset = NeoStyles.shadowOffset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c1 = isDark ? const Color(0xFF2A2A2E) : const Color(0xFFE2E2E6);
    final c2 = isDark ? const Color(0xFF1E1E22) : const Color(0xFFFFFFFF);
    final effectiveBorder = isDark ? NeoColors.borderDark : borderColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: NeoStyles.neoShadow(
          shadowColor: effectiveBorder,
          offset: shadowOffset,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: effectiveBorder,
              width: borderWidth,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: CheckerboardPainter(
                    cellSize: 10.0,
                    color1: c1,
                    color2: c2,
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
