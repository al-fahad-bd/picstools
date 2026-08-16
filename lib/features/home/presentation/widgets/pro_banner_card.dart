import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_badge.dart';

class ProBannerCard extends StatelessWidget {
  final VoidCallback onTap;
  final bool isPro;

  const ProBannerCard({super.key, required this.onTap, this.isPro = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isPro) {
      return NeoCard(
        backgroundColor: isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFE8F5E9),
        shadowOffset: 4,
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: NeoStyles.neoDecoration(
                backgroundColor: NeoColors.green,
                radius: 12,
                shadow: 2,
              ),
              child: const Icon(
                Icons.verified_rounded,
                size: 28,
                color: NeoColors.borderLight,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'PicsTools PRO',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? NeoColors.textPrimaryDark
                                : NeoColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const NeoBadge(
                        label: 'VIP ACTIVE',
                        backgroundColor: NeoColors.green,
                        fontSize: 9,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'All 8 tools unlocked with Ultra HD & 0 ads.',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? NeoColors.textSecondaryDark
                          : NeoColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark
                  ? NeoColors.textSecondaryDark
                  : NeoColors.borderLight,
              size: 16,
            ),
          ],
        ),
      );
    }

    return NeoCard(
      backgroundColor: NeoColors.softYellow,
      shadowOffset: 5,
      padding: const EdgeInsets.all(18),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: NeoStyles.neoDecoration(
              backgroundColor: NeoColors.yellow,
              radius: 14,
              shadow: 3,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 32,
              color: NeoColors.borderLight,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'PicsTools PRO',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const NeoBadge(
                      label: 'UNLIMITED',
                      backgroundColor: NeoColors.pink,
                      fontSize: 9,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Batch processing without limits & 0 ads.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: NeoColors.borderLight.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_rounded,
            color: NeoColors.borderLight,
            size: 22,
          ),
        ],
      ),
    );
  }
}
