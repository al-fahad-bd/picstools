import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_button.dart';

class VipExpirationModal extends StatelessWidget {
  const VipExpirationModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const VipExpirationModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: isDark ? NeoColors.darkBg : NeoColors.lightBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
              offset: const Offset(6, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: NeoStyles.neoDecoration(
                backgroundColor: NeoColors.pink,
                radius: 16,
                shadow: 4,
              ),
              child: const Icon(
                Icons.timer_off_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'VIP Pass Expired',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.1,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your 24-hour ad-free VIP pass has expired. You can continue using PicsTools for free with ads, or upgrade to Pro for an ad-free experience and advanced features.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            NeoButton(
              label: 'UPGRADE TO PRO',
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Continue with Ads',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
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
