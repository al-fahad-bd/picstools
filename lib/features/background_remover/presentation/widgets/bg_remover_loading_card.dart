import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_loader.dart';

class BgRemoverLoadingCard extends StatelessWidget {
  final String message;
  final bool isDark;

  const BgRemoverLoadingCard({
    super.key,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? NeoColors.borderDark : NeoColors.borderLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: NeoCard(
          backgroundColor: isDark
              ? NeoColors.darkSurface
              : NeoColors.lightSurface,
          borderColor: borderColor,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const NeoLoader.large(
                size: 38,
                color: NeoColors.purple,
                secondaryColor: NeoColors.yellow,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? NeoColors.textPrimaryDark
                      : NeoColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
