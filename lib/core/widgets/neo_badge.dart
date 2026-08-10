import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/neo_colors.dart';

class NeoBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData? icon;
  final double fontSize;

  const NeoBadge({
    super.key,
    required this.label,
    this.backgroundColor = NeoColors.cyan,
    this.textColor = NeoColors.borderLight,
    this.borderColor = NeoColors.borderLight,
    this.icon,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: NeoColors.borderLight,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
