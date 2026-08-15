import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_button.dart';

class BgRemovalErrorCard extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onRetry;

  const BgRemovalErrorCard({
    super.key,
    required this.message,
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? NeoColors.borderDark : NeoColors.borderLight;

    return NeoCard(
      backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.softPink,
      borderColor: borderColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NeoColors.pink,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 28,
              color: NeoColors.lightSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark
                  ? NeoColors.textPrimaryDark
                  : NeoColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black26
                  : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: SelectableText(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? NeoColors.textSecondaryDark
                    : NeoColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(height: 20),
          NeoButton(
            label: 'Try Again',
            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
              color: NeoColors.borderLight,
            ),
            backgroundColor: NeoColors.yellow,
            textColor: NeoColors.borderLight,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
