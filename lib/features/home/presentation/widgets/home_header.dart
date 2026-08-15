import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';

class HomeHeader extends StatelessWidget {
  final bool isDark;
  final bool isPro;
  final VoidCallback onProTap;

  const HomeHeader({
    super.key,
    required this.isDark,
    this.isPro = false,
    required this.onProTap,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = isPro ? NeoColors.green : NeoColors.pink;
    final badgeTextColor = NeoColors.getContrastColor(badgeColor);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo Pill
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: NeoStyles.neoDecoration(
            backgroundColor: isDark
                ? NeoColors.darkSurface
                : NeoColors.lightSurface,
            radius: 14,
            shadow: 3,
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/icon/app_icon.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 10),
              Text(
                'PicsTools',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: isDark
                      ? NeoColors.textPrimaryDark
                      : NeoColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),

        // PRO Badge
        GestureDetector(
          onTap: onProTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: NeoStyles.neoDecoration(
              backgroundColor: badgeColor,
              radius: 12,
              shadow: 3,
            ),
            child: Row(
              children: [
                Icon(
                  isPro ? Icons.verified_rounded : Icons.bolt_rounded,
                  size: 18,
                  color: badgeTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  isPro ? 'PRO MEMBER' : 'PRO',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: badgeTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

