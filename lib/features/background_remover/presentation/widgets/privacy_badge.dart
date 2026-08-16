import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';

class PrivacyBadge extends StatelessWidget {
  final bool isDark;

  const PrivacyBadge({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: NeoStyles.neoDecoration(
        backgroundColor: isDark ? const Color(0xFF1E2620) : NeoColors.softGreen,
        borderColor: isDark ? NeoColors.borderDark : NeoColors.borderLight,
        radius: 12,
        shadow: 2.5,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: NeoColors.green,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: NeoColors.borderLight, width: 1.5),
            ),
            child: const Icon(
              Icons.privacy_tip_outlined,
              size: 16,
              color: NeoColors.borderLight,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '100% PRIVATE & OFFLINE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isDark ? NeoColors.green : NeoColors.borderLight,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Photos are processed purely on-device and never leave your phone.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? NeoColors.textSecondaryDark
                        : NeoColors.textSecondaryLight,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
