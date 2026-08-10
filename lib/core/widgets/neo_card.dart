import 'package:flutter/material.dart';
import '../constants/neo_colors.dart';
import '../constants/neo_styles.dart';

class NeoCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double shadowOffset;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final bool showShadow;

  const NeoCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = NeoStyles.borderRadius,
    this.shadowOffset = NeoStyles.shadowOffset,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? NeoColors.darkSurface : NeoColors.lightSurface;
    final defaultBorder = isDark ? NeoColors.borderDark : NeoColors.borderLight;

    final card = Container(
      margin: margin,
      padding: padding,
      decoration: NeoStyles.neoDecoration(
        backgroundColor: backgroundColor ?? defaultBg,
        borderColor: borderColor ?? defaultBorder,
        radius: borderRadius,
        shadow: shadowOffset,
        showShadow: showShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
