import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_badge.dart';

class SignatureModeSelection extends StatelessWidget {
  final bool isDark;
  final VoidCallback onSelectDraw;
  final VoidCallback onSelectScan;

  const SignatureModeSelection({
    super.key,
    required this.isDark,
    required this.onSelectDraw,
    required this.onSelectScan,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: NeoStyles.neoDecoration(
              backgroundColor: isDark
                  ? NeoColors.darkSurface
                  : NeoColors.lightSurface,
              radius: 16,
              shadow: 3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.yellow,
                        radius: 12,
                        shadow: 2,
                      ),
                      child: const Icon(
                        Icons.gesture_rounded,
                        color: NeoColors.borderLight,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Digital Signature',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Choose how you want to create your signature',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: isDark
                                  ? NeoColors.textSecondaryDark
                                  : NeoColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Option 1: Draw Signature Container Card
          NeoCard(
            backgroundColor: NeoColors.softYellow,
            shadowOffset: 5,
            padding: const EdgeInsets.all(20),
            onTap: onSelectDraw,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.yellow,
                        radius: 14,
                        shadow: 3,
                      ),
                      child: const Icon(
                        Icons.draw_rounded,
                        size: 36,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    const NeoBadge(
                      label: 'TOUCH CANVAS',
                      backgroundColor: NeoColors.yellow,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Draw Signature',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.borderLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Draw directly on touchscreen canvas using custom ink colors (Black, Blue, Red, Navy) & adjustable pen thicknesses.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    height: 1.35,
                    color: NeoColors.borderLight.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.borderLight,
                        radius: 10,
                        shadow: 2,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'START DRAWING',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: NeoColors.yellow,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: NeoColors.yellow,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Option 2: Scan Paper Signature Container Card
          NeoCard(
            backgroundColor: NeoColors.softCyan,
            shadowOffset: 5,
            padding: const EdgeInsets.all(20),
            onTap: onSelectScan,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.cyan,
                        radius: 14,
                        shadow: 3,
                      ),
                      child: const Icon(
                        Icons.scanner_rounded,
                        size: 36,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    const NeoBadge(
                      label: 'AI AUTO-REMOVE',
                      backgroundColor: NeoColors.cyan,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Scan Paper Signature',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.borderLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Snap a photo of your signature on paper. PicsTools automatically removes paper background & converts it to transparent PNG.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    height: 1.35,
                    color: NeoColors.borderLight.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.borderLight,
                        radius: 10,
                        shadow: 2,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'SCAN PAPER',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: NeoColors.cyan,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: NeoColors.cyan,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
