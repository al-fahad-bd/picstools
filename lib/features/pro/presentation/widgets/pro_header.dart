import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';

class ProHeader extends StatelessWidget {
  final bool isDark;
  final bool isPro;

  const ProHeader({
    super.key,
    required this.isDark,
    this.isPro = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: NeoStyles.neoDecoration(
                backgroundColor: isPro ? NeoColors.green : NeoColors.pink,
                radius: 40,
                shadow: 4,
              ),
              child: Icon(
                isPro
                    ? Icons.workspace_premium_rounded
                    : Icons.workspace_premium_rounded,
                size: 52,
                color: NeoColors.getContrastColor(
                  isPro ? NeoColors.green : NeoColors.pink,
                ),
              ),
            ),
            if (isPro)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: NeoColors.yellow,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: NeoColors.borderLight,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          isPro ? 'PicsTools Pro Active' : 'PicsTools Pro',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: isDark
                ? NeoColors.textPrimaryDark
                : NeoColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isPro
              ? 'All premium tools and AI engines are fully unlocked'
              : 'Unlock maximum image productivity',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: isPro ? FontWeight.w600 : FontWeight.w500,
            color: isDark
                ? NeoColors.textSecondaryDark
                : NeoColors.textSecondaryLight,
          ),
        ),
        if (isPro) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: NeoStyles.neoDecoration(
              backgroundColor: NeoColors.green,
              radius: 20,
              shadow: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: NeoColors.borderLight,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'PRO MEMBER • UNLIMITED ACCESS',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.borderLight,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

