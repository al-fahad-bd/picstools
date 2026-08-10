import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/neo_colors.dart';

class NeoTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: NeoColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: NeoColors.yellow,
        secondary: NeoColors.cyan,
        surface: NeoColors.lightSurface,
        onSurface: NeoColors.textPrimaryLight,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: NeoColors.textPrimaryLight,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: NeoColors.textPrimaryLight,
        ),
        bodyLarge: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: NeoColors.textPrimaryLight,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: NeoColors.lightBg,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: NeoColors.borderLight),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: NeoColors.textPrimaryLight,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NeoColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: NeoColors.yellow,
        secondary: NeoColors.cyan,
        surface: NeoColors.darkSurface,
        onSurface: NeoColors.textPrimaryDark,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: NeoColors.textPrimaryDark,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: NeoColors.textPrimaryDark,
        ),
        bodyLarge: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: NeoColors.textPrimaryDark,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: NeoColors.darkBg,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: NeoColors.borderDark),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: NeoColors.textPrimaryDark,
        ),
      ),
    );
  }
}
