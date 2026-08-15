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
                      label: '100% LOCAL ON-DEVICE PROCESSING',
                      backgroundColor: NeoColors.green,
                      fontSize: 11,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your Photos Never Leave Your Phone',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PicsTools processes all images, compressions, resizes, crops, format conversions, PDF compilations, digital signatures, and passport photos strictly offline on your device. We do NOT collect, transmit, or store any of your photos on external cloud servers.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: NeoColors.borderLight.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Policy Section 1: Zero Personal Data Collection
              _buildPolicySection(
                title: '1. Zero Data Collection',
                icon: Icons.shield_sharp,
                color: NeoColors.cyan,
                isDark: isDark,
                content:
                    'We do not require user account creation, logins, names, email addresses, or phone numbers. PicsTools operates completely anonymously without collecting or profiling user identities.',
              ),
              const SizedBox(height: 16),

              // Policy Section 2: Permissions Usage
              _buildPolicySection(
                title: '2. Device Permissions Usage',
                icon: Icons.lock_outline_rounded,
                color: NeoColors.yellow,
                isDark: isDark,
                content:
                    '• Camera Permission: Used exclusively to capture document photos, passport portraits, or handwritten paper signatures when initiated by you.\n'
                    '• Photos & Storage Permission: Used exclusively to load images selected by you for editing and to save exported files to your device\'s public Downloads/PicsTools folder.',
              ),
              const SizedBox(height: 16),

              // Policy Section 3: Third-Party Advertising
              _buildPolicySection(
                title: '3. Third-Party Ad Services',
                icon: Icons.ad_units_rounded,
                color: NeoColors.pink,
                isDark: isDark,
                content:
                    'PicsTools uses standard non-intrusive mobile advertising networks (such as Google AdMob) to support free app maintenance. These networks may collect anonymized device identifiers in accordance with standard privacy laws.',
              ),
              const SizedBox(height: 16),

              // Policy Section 4: Data Control & Clearance
              _buildPolicySection(
                title: '4. Local Storage & Data Control',
                icon: Icons.folder_special_rounded,
                color: NeoColors.purple,
                isDark: isDark,
                content:
                    'All history logs and app preferences are stored locally in your phone\'s private app directory. You can clear your processing history at any time using the button below.',
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
                  'PicsTools v1.0.0 • Updated August 2026',
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
                child: Icon(icon, size: 18, color: NeoColors.borderLight),
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
