import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_card.dart';

class ProSocialProof extends StatelessWidget {
  final bool isDark;

  const ProSocialProof({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      backgroundColor: isDark
          ? const Color(0xFF1E293B)
          : const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(16),
      shadowOffset: 2,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                5,
                (i) => const Icon(
                  Icons.star_rounded,
                  color: NeoColors.yellow,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '4.9 / 5.0 Rating',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Trusted by 50,000+ photographers, designers & creators worldwide',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? NeoColors.textSecondaryDark
                  : NeoColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? NeoColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? NeoColors.borderDark : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  color: NeoColors.cyan,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"PicsTools Pro saved me hours of manual editing with lightning batch export & perfect AI cutouts!"',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
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
