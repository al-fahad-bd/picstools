import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_button.dart';

class ProUpsellBottomSheet extends StatelessWidget {
  final String featureName;

  const ProUpsellBottomSheet({
    super.key,
    required this.featureName,
  });

  static Future<void> show(BuildContext context, {required String featureName}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProUpsellBottomSheet(featureName: featureName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isDark ? NeoColors.darkBg : NeoColors.lightBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
          width: 3,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: NeoStyles.neoDecoration(
                  backgroundColor: NeoColors.pink,
                  radius: 16,
                  shadow: 4,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Text content
            Text(
              '$featureName is a\nPro Feature',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upgrade to PicsTools Pro to unlock $featureName, remove ads, and access our creative studio.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // CTA Button
            NeoButton(
              label: 'VIEW PRO PLANS',
              icon: const Icon(Icons.star_rounded, size: 20, color: Colors.black),
              backgroundColor: NeoColors.yellow,
              textColor: Colors.black,
              fullWidth: true,
              padding: const EdgeInsets.symmetric(vertical: 16),
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/pro');
              },
            ),
            const SizedBox(height: 12),

            // Cancel
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Maybe Later',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
