import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';

class ProBenefitsList extends StatelessWidget {
  final bool isDark;

  const ProBenefitsList({super.key, required this.isDark});

  static const List<_BenefitItem> _benefits = [
    _BenefitItem(
      icon: Icons.block_rounded,
      iconColor: NeoColors.green,
      iconBg: Colors.black,
      title: '100% Ad-Free Experience',
      description:
          'Zero interruptions, no popups or banners while using any of the tools.',
    ),
    _BenefitItem(
      icon: Icons.bolt_rounded,
      iconColor: NeoColors.cyan,
      iconBg: Colors.black,
      title: 'Batch Processing Mode',
      description:
          'Compress, convert formats, and resize multiple photos simultaneously.',
    ),
    _BenefitItem(
      icon: Icons.speed_rounded,
      iconColor: NeoColors.yellow,
      iconBg: Colors.black,
      title: 'High-Speed Processing',
      description:
          'Accelerated on-device neural background removal and fast image export.',
    ),
    _BenefitItem(
      icon: Icons.all_inclusive_rounded,
      iconColor: NeoColors.pink,
      iconBg: Colors.black,
      title: 'Unlimited Daily Operations',
      description:
          'Process as many photos and documents as you want with no daily limits.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: NeoColors.yellow,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                'PRO BENEFITS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Everything unlocked with Pro',
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
        const SizedBox(height: 14),
        ..._benefits.map((b) => _buildBenefitRow(b)),
      ],
    );
  }

  Widget _buildBenefitRow(_BenefitItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? NeoColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(NeoStyles.borderRadius),
          border: Border.all(
            color: isDark ? NeoColors.borderDark : Colors.black,
            width: isDark ? 1.5 : 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? NeoColors.borderDark : Colors.black,
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.iconColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Icon(item.icon, size: 20, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? NeoColors.textPrimaryDark
                          : NeoColors.textPrimaryLight,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.description,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? NeoColors.textSecondaryDark
                          : NeoColors.textSecondaryLight,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;

  const _BenefitItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
  });
}
