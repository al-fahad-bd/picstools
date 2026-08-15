import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_badge.dart';

class ProBannerCard extends StatelessWidget {
  final VoidCallback onTap;

  const ProBannerCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      'PicsTools PRO',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.borderLight,
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
