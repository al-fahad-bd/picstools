import 'package:flutter/material.dart';

abstract class NeoColors {
  // Base Colors
  static const Color lightBg = Color(0xFFFFFDF6);
  static const Color darkBg = Color(0xFF141416);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF1F1F23);

  static const Color borderLight = Color(0xFF121212);
  static const Color borderDark = Color(0xFFD8D8DB);

  static const Color textPrimaryLight = Color(0xFF121212);
  static const Color textSecondaryLight = Color(0xFF52525B);
  static const Color textPrimaryDark = Color(0xFFFAFAFA);
  static const Color textSecondaryDark = Color(0xFFA1A1AA);

  // High-Contrast Neo Accents
  static const Color yellow = Color(0xFFFFE600);
  static const Color cyan = Color(0xFF00E5FF);
  static const Color pink = Color(0xFFFF3366);
  static const Color green = Color(0xFF00E676);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color orange = Color(0xFFFF6B00);
  static const Color blue = Color(0xFF3B82F6);
  static const Color red = Color(0xFFEF4444);

  // Soft accents for card background variations
  static const Color softYellow = Color(0xFFFFF7AD);
  static const Color softCyan = Color(0xFFB5F6FF);
  static const Color softPink = Color(0xFFFFB8C6);
  static const Color softGreen = Color(0xFFB2FAD4);
  static const Color softPurple = Color(0xFFDDD0FF);
  static const Color softOrange = Color(0xFFFFD4B2);

  // Helpers
  static Color getCardColor(int index, bool isDark) {
    if (isDark) {
      return darkSurface;
    }
    const colors = [
      softYellow,
      softCyan,
      softPink,
      softGreen,
      softPurple,
      softOrange,
    ];
    return colors[index % colors.length];
  }

  static Color getAccentColor(int index) {
    const colors = [yellow, cyan, pink, green, purple, orange];
    return colors[index % colors.length];
  }
}
