import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_card.dart';

class ProFeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const ProFeatureCard({
    super.key,
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoCard(
        backgroundColor: isDark
            ? NeoColors.darkSurface
            : NeoColors.lightSurface,
        padding: const EdgeInsets.all(14),
        shadowOffset: 2,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: NeoStyles.neoDecoration(
                backgroundColor: NeoColors.cyan,
                radius: 8,
                shadow: 1,
              ),
              child: Icon(icon, size: 20, color: NeoColors.borderLight),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
