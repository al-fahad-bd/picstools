import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import 'pro_manage_subscription_modal.dart';

class ProActiveDashboard extends StatefulWidget {
  final bool isDark;
  final VoidCallback? onNavigateToHome;
  final VoidCallback onManageSubscription;

  const ProActiveDashboard({
    super.key,
    required this.isDark,
    this.onNavigateToHome,
    required this.onManageSubscription,
  });

  @override
  State<ProActiveDashboard> createState() => _ProActiveDashboardState();
}

class _ProActiveDashboardState extends State<ProActiveDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. VIP Pro Membership Card
        NeoCard(
          backgroundColor: isDark
              ? const Color(0xFF0F1E17) // Deep Emerald Slate
              : const Color(0xFFE8F5E9),
          borderColor: NeoColors.green,
          shadowOffset: 4,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: NeoColors.yellow,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: NeoColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          size: 22,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PicsTools PRO',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            'VIP CREATOR MEMBERSHIP',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: NeoColors.green,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: NeoColors.green,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: NeoColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ACTIVE',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Text(
                'You have full unlocked access to all 8 photo tools with zero ads, high-speed processing, and unlimited multi-image batch capabilities.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? NeoColors.textSecondaryDark
                      : NeoColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 10),

              // Quick Status Pills
              Wrap(
                spacing: 6,
                runSpacing: 5,
                children: [
                  _buildStatPill('🚫 100% Zero Ads', NeoColors.cyan, isDark),
                  _buildStatPill('⚡ Unlimited Batch', NeoColors.yellow, isDark),
                  _buildStatPill('🚀 Fast Processing', NeoColors.purple, isDark),
                  _buildStatPill('🔒 100% On-Device', NeoColors.green, isDark),
                ],
              ),
              const SizedBox(height: 12),

              NeoButton(
                label: 'MANAGE SUBSCRIPTION',
                icon: Icon(
                  Icons.settings_outlined,
                  size: 15,
                  color: isDark ? Colors.white : Colors.black,
                ),
                backgroundColor: isDark ? NeoColors.darkSurface : Colors.white,
                textColor: isDark ? Colors.white : Colors.black,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: () {
                  ProManageSubscriptionModal.show(
                    context,
                    isDark: isDark,
                    onManageOnStore: widget.onManageSubscription,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // 2. Unlocked Pro Privileges Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'YOUR PRO PRIVILEGES',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isDark
                    ? NeoColors.textSecondaryDark
                    : NeoColors.textSecondaryLight,
                letterSpacing: 0.5,
              ),
            ),
            const NeoBadge(
              label: '⚡ ALL UNLOCKED',
              backgroundColor: NeoColors.green,
              textColor: Colors.black,
              fontSize: 9.5,
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildSuperpowerTile(
          icon: Icons.block_rounded,
          title: '100% Ad-Free Experience',
          subtitle: 'Zero banner ads, interstitial popups, or video ads anywhere in the app',
          badgeText: 'ZERO ADS',
          accent: NeoColors.cyan,
          isDark: isDark,
        ),
        _buildSuperpowerTile(
          icon: Icons.burst_mode_rounded,
          title: 'Unlimited Batch Processing',
          subtitle: 'Process, resize, convert, and compress multiple photos at once with batch export',
          badgeText: 'MULTI-PHOTO',
          accent: NeoColors.yellow,
          isDark: isDark,
        ),
        _buildSuperpowerTile(
          icon: Icons.tune_rounded,
          title: 'Advanced Compression & Controls',
          subtitle: 'Target exact file sizes in KB/MB and custom fine-tune quality slider controls',
          badgeText: 'PRECISION',
          accent: NeoColors.green,
          isDark: isDark,
        ),
        _buildSuperpowerTile(
          icon: Icons.all_inclusive_rounded,
          title: 'Unlimited High-Quality Exports',
          subtitle: 'No daily file limits, watermark-free output, and full resolution across all 8 tools',
          badgeText: 'UNLIMITED',
          accent: NeoColors.purple,
          isDark: isDark,
        ),

        const SizedBox(height: 16),
        NeoButton(
          label: 'START CREATING ON HOME',
          icon: const Icon(
            Icons.grid_view_rounded,
            size: 18,
            color: Colors.black,
          ),
          backgroundColor: NeoColors.yellow,
          textColor: Colors.black,
          fullWidth: true,
          padding: const EdgeInsets.symmetric(vertical: 15),
          onPressed: () {
            if (widget.onNavigateToHome != null) {
              widget.onNavigateToHome!();
            } else {
              context.go('/home');
            }
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatPill(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? NeoColors.borderDark : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSuperpowerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required bool isDark,
    String? badgeText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeoCard(
        backgroundColor: isDark ? NeoColors.darkSurface : Colors.white,
        padding: const EdgeInsets.all(12),
        shadowOffset: 2,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: NeoStyles.neoDecoration(
                backgroundColor: accent,
                radius: 10,
                shadow: 1,
              ),
              child: Icon(icon, size: 18, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: accent, width: 1),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: isDark
                          ? NeoColors.textSecondaryDark
                          : NeoColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: NeoColors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 12, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
