import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/neo_colors.dart';

class NeoBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const NeoBadge({
    super.key,
    required this.label,
    this.backgroundColor = NeoColors.cyan,
    this.textColor,
    this.borderColor,
    this.icon,
    this.fontSize = 12.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorder =
        borderColor ?? (isDark ? NeoColors.borderDark : NeoColors.borderLight);
    final effectiveTextColor =
        textColor ?? NeoColors.getContrastColor(backgroundColor);

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: effectiveBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: effectiveBorder,
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text.rich(
        TextSpan(
          children: [
            if (icon != null) ...[
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Icon(
                    icon,
                    size: fontSize + 2,
                    color: effectiveTextColor,
                  ),
                ),
              ),
            ],
            TextSpan(
              text: label.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: effectiveTextColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false,
        textAlign: TextAlign.center,
      ),
    );
  }
}
