import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_card.dart';

class ProFeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isDark;
  final bool isUnlocked;
  final Color? accentColor;

  const ProFeatureCard({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.isDark,
    this.isUnlocked = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgIconColor = accentColor ?? (isUnlocked ? NeoColors.green : NeoColors.cyan);

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
              padding: const EdgeInsets.all(10),
              decoration: NeoStyles.neoDecoration(
                backgroundColor: bgIconColor,
                radius: 8,
                shadow: 1,
              ),
              child: Icon(icon, size: 20, color: NeoColors.borderLight),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? NeoColors.textPrimaryDark
                          : NeoColors.textPrimaryLight,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: isDark
                            ? NeoColors.textSecondaryDark
                            : NeoColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isUnlocked) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: NeoColors.green,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: NeoColors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ACTIVE',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.green,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

