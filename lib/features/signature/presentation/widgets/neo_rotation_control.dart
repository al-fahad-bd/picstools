import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';

class NeoRotationControl extends StatelessWidget {
  final double baseRotation90; // 0, 90, 180, 270
  final double fineAngle; // -45.0 to +45.0
  final bool isDark;
  final ValueChanged<double> onFineAngleChanged;
  final VoidCallback onRotate90;
  final VoidCallback onReset;

  const NeoRotationControl({
    super.key,
    required this.baseRotation90,
    required this.fineAngle,
    required this.isDark,
    required this.onFineAngleChanged,
    required this.onRotate90,
    required this.onReset,
  });

  double get totalAngle => (baseRotation90 + fineAngle);

  @override
  Widget build(BuildContext context) {
    final formattedTotal = totalAngle == totalAngle.roundToDouble()
        ? '${totalAngle.toInt()}°'
        : '${totalAngle.toStringAsFixed(1)}°';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
          width: 2.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Angle Badge, Reset, and 90deg button
          Row(
            children: [
              const Icon(
                Icons.rotate_90_degrees_ccw_rounded,
                size: 18,
                color: NeoColors.borderLight,
              ),
              const SizedBox(width: 8),
              Text(
                'Straighten & Rotate',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? NeoColors.textPrimaryDark : NeoColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              // Angle Readout Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: NeoStyles.neoDecoration(
                  backgroundColor: NeoColors.cyan,
                  radius: 6,
                  shadow: 1.5,
                ),
                child: Text(
                  formattedTotal,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.borderLight,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Reset Button
              if (totalAngle != 0)
                GestureDetector(
                  onTap: onReset,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: NeoColors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: NeoColors.red, width: 1.2),
                    ),
                    child: Text(
                      'Reset',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: NeoColors.red,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Slider & Micro-steppers row
          Row(
            children: [
              // -1° Stepper
              _buildStepButton(
                icon: Icons.remove_rounded,
                onTap: () {
                  final next = (fineAngle - 1.0).clamp(-45.0, 45.0);
                  onFineAngleChanged(next);
                },
              ),
              const SizedBox(width: 6),

              // Slider
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    activeTrackColor: NeoColors.yellow,
                    inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
                    thumbColor: NeoColors.yellow,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    overlayColor: NeoColors.yellow.withValues(alpha: 0.2),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  ),
                  child: Slider(
                    value: fineAngle.clamp(-45.0, 45.0),
                    min: -45.0,
                    max: 45.0,
                    onChanged: (val) {
                      // Snap close to 0 if within 0.5 degrees
                      if (val.abs() < 0.5) {
                        onFineAngleChanged(0.0);
                      } else {
                        onFineAngleChanged(val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // +1° Stepper
              _buildStepButton(
                icon: Icons.add_rounded,
                onTap: () {
                  final next = (fineAngle + 1.0).clamp(-45.0, 45.0);
                  onFineAngleChanged(next);
                },
              ),
              const SizedBox(width: 8),

              // Quick Rotate 90° Button
              GestureDetector(
                onTap: onRotate90,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.softYellow,
                    radius: 8,
                    shadow: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.rotate_right_rounded,
                        size: 16,
                        color: NeoColors.borderLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+90°',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
            width: 1.2,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: isDark ? NeoColors.textPrimaryDark : NeoColors.textPrimaryLight,
        ),
      ),
    );
  }
}
