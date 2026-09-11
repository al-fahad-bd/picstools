import '../../../../core/widgets/neo_back_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/history_service.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const NeoBackButton(),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Guarantee Card
              NeoCard(
                backgroundColor: NeoColors.softGreen,
                shadowOffset: 5,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NeoBadge(
                      label: '100% ON-DEVICE PROCESSING GUARANTEE',
                      backgroundColor: NeoColors.green,
                      fontSize: 11,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your Photos Never Leave Your Phone for Processing',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlike other photo apps that transmit your private images to remote servers to run AI models, PicsTools processes all image tools—AI background removal, compression, resizing, cropping, format conversion, PDF compilation, and ID photos—strictly offline on your device processor. Your photos are NEVER uploaded or sent to external servers for processing.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: NeoColors.borderLight.withValues(alpha: 0.85),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Policy Section 1: Anonymous & Account-Free Access
              _buildPolicySection(
                title: '1. Fully Usable Without an Account',
                icon: Icons.no_accounts_rounded,
                color: NeoColors.cyan,
                isDark: isDark,
                content:
                    'PicsTools does not require you to create an account or sign in. You can use all editing and image processing tools completely anonymously. An anonymous local identifier is maintained only to store your theme and preferences locally on your device.',
              ),
              const SizedBox(height: 16),

              // Policy Section 2: Optional Multi-Device Cloud Sync
              _buildPolicySection(
                title: '2. Optional Cloud Sync for Multi-Device Access',
                icon: Icons.cloud_sync_rounded,
                color: NeoColors.purple,
                iconColor: Colors.white,
                isDark: isDark,
                content:
                    'If you explicitly choose to sign in (via Google or Email), PicsTools provides optional cloud backup so you can access your saved history across multiple devices. Only your exported result images and history timestamps are stored in private, encrypted cloud storage (Cloudflare R2 & Firebase). This sync feature exists solely for your multi-device convenience—your photos are never sold, never shared, and never used to train public AI models.',
              ),
              const SizedBox(height: 16),

              // Policy Section 3: Permissions Usage
              _buildPolicySection(
                title: '3. Device Permissions Usage',
                icon: Icons.lock_outline_rounded,
                color: NeoColors.yellow,
                isDark: isDark,
                content:
                    '• Camera Permission: Used exclusively to capture document photos, passport portraits, or handwritten paper signatures when initiated by you.\n'
                    '• Photos & Storage Permission: Used exclusively to load images selected by you for editing and to save exported files to your device\'s public Downloads/PicsTools folder.',
              ),
              const SizedBox(height: 16),

              // Policy Section 4: Third-Party Services
              _buildPolicySection(
                title: '4. Third-Party Services',
                icon: Icons.ad_units_rounded,
                color: NeoColors.pink,
                iconColor: Colors.white,
                isDark: isDark,
                content:
                    '• Google AdMob: Displays standard non-intrusive mobile ads for free users.\n'
                    '• Firebase & Cloudflare R2: Used solely to authenticate your account and securely back up your history across devices if you choose to sign in.',
              ),
              const SizedBox(height: 16),

              // Policy Section 5: Data Control & Account Deletion
              _buildPolicySection(
                title: '5. Data Control & Account Deletion',
                icon: Icons.folder_special_rounded,
                color: NeoColors.orange,
                iconColor: Colors.white,
                isDark: isDark,
                content:
                    'You maintain 100% control over your data. You can clear your local processing history anytime using the button below. If you created an account, you can also delete your account and its cloud data at any time directly in the app Settings.',
              ),
              const SizedBox(height: 28),

              // Clear History Action
              NeoButton(
                label: 'CLEAR ALL LOCAL HISTORY LOGS',
                icon: const Icon(
                  Icons.delete_sweep_rounded,
                  color: NeoColors.borderLight,
                ),
                backgroundColor: NeoColors.red,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 16),
                onPressed: () async {
                  final history = getIt<HistoryService>();
                  await history.clearHistory();
                  if (context.mounted) {
                    NeoToast.showSuccess(
                      context,
                      'All local processing history cleared successfully!',
                      icon: Icons.delete_outline_rounded,
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  'PicsTools v1.0.0 • Updated September 2026',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: isDark
                        ? NeoColors.textSecondaryDark
                        : NeoColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection({
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    required String content,
    Color? iconColor,
  }) {
    return NeoCard(
      backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
      padding: const EdgeInsets.all(16),
      shadowOffset: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: NeoStyles.neoDecoration(
                  backgroundColor: color,
                  radius: 8,
                  shadow: 2,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: iconColor ?? NeoColors.borderLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              height: 1.45,
              color: isDark
                  ? NeoColors.textSecondaryDark
                  : NeoColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
