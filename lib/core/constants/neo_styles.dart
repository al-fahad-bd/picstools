import 'package:flutter/material.dart';
import 'neo_colors.dart';

abstract class NeoStyles {
  static const double borderWidth = 2.5;
  static const double borderRadius = 14.0;
  static const double shadowOffset = 4.0;

  static List<BoxShadow> neoShadow({
    Color shadowColor = NeoColors.borderLight,
    double offset = shadowOffset,
  }) {
    return [
      BoxShadow(
        color: shadowColor,
        offset: Offset(offset, offset),
        blurRadius: 0,
        spreadRadius: 0,
      ),
    ];
  }

  static BoxDecoration neoDecoration({
    required Color backgroundColor,
    Color borderColor = NeoColors.borderLight,
    double radius = borderRadius,
    double shadow = shadowOffset,
    bool showShadow = true,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
      boxShadow: showShadow
          ? neoShadow(shadowColor: borderColor, offset: shadow)
          : null,
    );
  }
}
