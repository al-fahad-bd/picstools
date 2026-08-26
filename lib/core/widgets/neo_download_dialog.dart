import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../constants/neo_colors.dart';
import '../constants/neo_styles.dart';
import '../services/service_locator.dart';
import '../services/monetization/in_app_purchase_service.dart';
import 'neo_badge.dart';
import 'neo_button.dart';
import 'neo_card.dart';

class NeoDownloadDialog {
  /// Prompts the user with commercial download options if they are on the Free tier.
  /// If the user is already a PRO member, returns `true` immediately with no dialog or ads.
  /// Returns `true` if the user selected the "Watch Ad & Download Free" option.
  /// Returns `false` if dismissed or cancelled.
  static Future<bool> show(
    BuildContext context, {
    String? title,
    String? subtitle,
  }) async {
    final iapService = getIt<InAppPurchaseService>();
    if (iapService.isProUser()) {
      return true; // Pro users download instantly with 0 ads & 0 popups
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DownloadOptionsBottomSheet(
        title: title ?? 'Commercial Export Center',
        subtitle: subtitle ?? 'Select your preferred export & download option',
      ),
    );

    return result ?? false;
  }
}

class _DownloadOptionsBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;

  const _DownloadOptionsBottomSheet({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
          width: 3,
        ),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar & Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const NeoBadge(
                  label: '🚀 EXPORT READY',
                  backgroundColor: NeoColors.yellow,
                  fontSize: 11,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? NeoColors.borderDark
                            : NeoColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Header Title & Subtitle
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: isDark
                    ? NeoColors.textSecondaryDark
                    : NeoColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),

            // Option 1: PicsTools PRO (Recommended High-Converting Commercial Card)
            NeoCard(
              backgroundColor: NeoColors.softYellow,
              shadowOffset: 4,
              padding: const EdgeInsets.all(18),
              onTap: () {
                Navigator.of(context).pop(false);
                context.push('/pro');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: NeoStyles.neoDecoration(
                              backgroundColor: NeoColors.yellow,
                              radius: 10,
                              shadow: 2,
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 22,
                              color: NeoColors.borderLight,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'PicsTools PRO',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: NeoColors.borderLight,
                            ),
                          ),
                        ],
                      ),
                      const NeoBadge(
                        label: 'RECOMMENDED',
                        backgroundColor: NeoColors.yellow,
                        fontSize: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureBullet(
                    '🚀 100% Ad-Free Instant 1-Click Downloads',
                  ),
                  _buildFeatureBullet('💎 Maximum Ultra-HD Resolution Output'),
                  _buildFeatureBullet(
                    '⚡ Unlimited Batch Multi-Photo Processing',
                  ),
                  _buildFeatureBullet('☁️ Cloud Backup & Device Sync Included'),
                  const SizedBox(height: 16),
                  NeoButton(
                    label: 'UPGRADE TO PRO — GET ZERO ADS',
                    icon: const Icon(
                      Icons.star_rounded,
                      color: NeoColors.borderLight,
                      size: 18,
                    ),
                    backgroundColor: NeoColors.yellow,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      context.push('/pro');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Option 2: Free Download with Sponsor Ad
            NeoCard(
              backgroundColor: isDark
                  ? NeoColors.darkSurface
                  : NeoColors.lightSurface,
              shadowOffset: 3,
              padding: const EdgeInsets.all(18),
              onTap: () => Navigator.of(context).pop(true),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: NeoStyles.neoDecoration(
                              backgroundColor: NeoColors.cyan,
                              radius: 10,
                              shadow: 2,
                            ),
                            child: const Icon(
                              Icons.play_circle_outline_rounded,
                              size: 22,
                              color: NeoColors.borderLight,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Free Sponsored Save',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const NeoBadge(
                        label: 'FREE',
                        backgroundColor: NeoColors.cyan,
                        fontSize: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Watch a quick sponsor video to unlock free file download and save directly to your gallery.',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: isDark
                          ? NeoColors.textSecondaryDark
                          : NeoColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  NeoButton(
                    label: 'WATCH AD & DOWNLOAD FREE',
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      color: NeoColors.borderLight,
                      size: 18,
                    ),
                    backgroundColor: NeoColors.cyan,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: NeoColors.borderLight.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
