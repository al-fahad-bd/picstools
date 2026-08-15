import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';

class ProHeader extends StatelessWidget {
  final bool isDark;

  const ProHeader({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: NeoStyles.neoDecoration(
            backgroundColor: NeoColors.pink,
            radius: 40,
            shadow: 4,
          ),
          child: Icon(
            Icons.workspace_premium_rounded,
            size: 50,
            color: NeoColors.getContrastColor(NeoColors.pink),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'PicsTools Pro',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Unlock maximum image productivity',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: isDark
                ? NeoColors.textSecondaryDark
                : NeoColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
