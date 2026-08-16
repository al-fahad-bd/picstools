import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/neo_colors.dart';

class NeoBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color? textColor;
  final Color borderColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const NeoBadge({
    super.key,
    required this.label,
    this.backgroundColor = NeoColors.cyan,
    this.textColor,
    this.borderColor = NeoColors.borderLight,
    this.icon,
    this.fontSize = 12.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor =
        textColor ?? NeoColors.getContrastColor(backgroundColor);

    final textWidget = Text(
      label.toUpperCase(),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      softWrap: false,
      style: GoogleFonts.spaceGrotesk(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: effectiveTextColor,
        letterSpacing: 0.3,
      ),
    );

    final content = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: fontSize + 2, color: effectiveTextColor),
              const SizedBox(width: 4),
              Flexible(child: textWidget),
            ],
          )
        : textWidget;

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: NeoColors.borderLight,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: content,
    );
  }
}
