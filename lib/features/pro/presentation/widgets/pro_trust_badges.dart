import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';

class ProTrustBadges extends StatelessWidget {
  final bool isDark;

  const ProTrustBadges({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBadge(
              icon: Icons.security_rounded,
              label: 'Google Play\nEncrypted',
              isDark: isDark,
            ),
            _buildBadge(
              icon: Icons.cancel_outlined,
              label: 'Cancel\nAnytime',
              isDark: isDark,
            ),
            _buildBadge(
              icon: Icons.bolt_rounded,
              label: 'Instant\nActivation',
              isDark: isDark,
            ),
            _buildBadge(
              icon: Icons.verified_user_rounded,
              label: '7-Day Money\nBack',
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? NeoColors.darkSurface : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? NeoColors.borderDark : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isDark ? NeoColors.cyan : NeoColors.purple,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark
                ? NeoColors.textSecondaryDark
                : NeoColors.textSecondaryLight,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
