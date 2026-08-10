import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/neo_colors.dart';
import '../constants/neo_styles.dart';

class NeoSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String label;
  final ValueChanged<double> onChanged;
  final Color activeColor;

  const NeoSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.label,
    this.divisions,
    this.activeColor = NeoColors.yellow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? NeoColors.borderDark : NeoColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: NeoStyles.neoDecoration(
                backgroundColor: activeColor,
                borderColor: borderColor,
                radius: 8,
                shadow: 2,
              ),
              child: Text(
                '${value.round()}%',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: NeoColors.borderLight,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: activeColor,
            inactiveTrackColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            thumbColor: activeColor,
            overlayColor: activeColor.withValues(alpha: 0.2),
            trackHeight: 10,
            thumbShape: _NeoThumbShape(borderColor: borderColor),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _NeoThumbShape extends SliderComponentShape {
  final Color borderColor;

  const _NeoThumbShape({required this.borderColor});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(24, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final fillPaint = Paint()
      ..color = sliderTheme.thumbColor ?? NeoColors.yellow
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final shadowPaint = Paint()
      ..color = NeoColors.borderLight
      ..style = PaintingStyle.fill;

    // Draw shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center + const Offset(2, 2), width: 22, height: 22),
        const Radius.circular(6),
      ),
      shadowPaint,
    );

    // Draw thumb fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 22, height: 22),
        const Radius.circular(6),
      ),
      fillPaint,
    );

    // Draw thumb border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 22, height: 22),
        const Radius.circular(6),
      ),
      borderPaint,
    );
  }
}
