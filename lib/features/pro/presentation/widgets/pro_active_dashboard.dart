import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';

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
        // 0. Top VIP Visual Banner
        Container(
          height: 140,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: NeoStyles.neoDecoration(
            backgroundColor: isDark ? NeoColors.darkSurface : Colors.white,
            radius: 16,
            shadow: 3,
            borderColor: NeoColors.green,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/pro_hero_showcase.jpg',
                fit: BoxFit.cover,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: NeoColors.green,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: NeoColors.borderLight,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '👑 VIP PRO CREATOR',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Full AI & 8K Lossless Studio Unlocked',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.verified_rounded,
                      color: NeoColors.green,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 1. VIP Pro Membership Card
        NeoCard(
          backgroundColor: isDark
              ? const Color(0xFF0F1E17) // Deep Emerald Slate
              : const Color(0xFFE8F5E9),
          borderColor: NeoColors.green,
          shadowOffset: 4,
          padding: const EdgeInsets.all(18),
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
                          size: 24,
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
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            'VIP CREATOR MEMBERSHIP',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10.5,
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
                        horizontal: 10,
                        vertical: 4,
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
                          const SizedBox(width: 5),
                          Text(
                            'ACTIVE',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
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
              const SizedBox(height: 14),

              Text(
                'You have unlimited access to all AI engines, 8K ultra-HD lossless exports, zero ads & cloud sync.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? NeoColors.textSecondaryDark
                      : NeoColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 14),

              // Quick Status Pills
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildStatPill('🚫 100% Zero Ads', NeoColors.cyan, isDark),
                  _buildStatPill(
                    '🚀 Unlimited Batch',
                    NeoColors.yellow,
                    isDark,
                  ),
                  _buildStatPill('🧠 Neural AI 8K', NeoColors.purple, isDark),
                  _buildStatPill('☁️ Cloud Synced', NeoColors.green, isDark),
                ],
              ),
              const SizedBox(height: 16),

              NeoButton(
                label: 'MANAGE SUBSCRIPTION',
                icon: Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
                backgroundColor: isDark ? NeoColors.darkSurface : Colors.white,
                textColor: isDark ? Colors.white : Colors.black,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 11),
                onPressed: widget.onManageSubscription,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // 2. VIP Quick Tools Launcher
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PRO STUDIO LAUNCHER',
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
              backgroundColor: NeoColors.yellow,
              textColor: Colors.black,
              fontSize: 9.5,
            ),
          ],
        ),
        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            _buildLauncherCard(
              context: context,
              icon: Icons.layers_rounded,
              title: 'Batch Studio',
              subtitle: 'Compress & Convert',
              accentColor: NeoColors.yellow,
              route: '/compress',
              isDark: isDark,
            ),
            _buildLauncherCard(
              context: context,
              icon: Icons.auto_awesome_rounded,
              title: 'AI Cutout',
              subtitle: 'Neural Backgrounds',
              accentColor: NeoColors.cyan,
              route: '/bg-remover',
              isDark: isDark,
            ),
            _buildLauncherCard(
              context: context,
              icon: Icons.photo_size_select_actual_rounded,
              title: '8K Resizer',
              subtitle: 'Lossless Scaling',
              accentColor: NeoColors.purple,
              route: '/resize',
              isDark: isDark,
            ),
            _buildLauncherCard(
              context: context,
              icon: Icons.picture_as_pdf_rounded,
              title: 'PDF Vault',
              subtitle: 'Encrypted Export',
              accentColor: NeoColors.pink,
              route: '/image-to-pdf',
              isDark: isDark,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 3. Unlocked Superpowers List
        Text(
          'YOUR ACTIVE SUPERPOWERS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isDark
                ? NeoColors.textSecondaryDark
                : NeoColors.textSecondaryLight,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),

        _buildSuperpowerTile(
          icon: Icons.block_rounded,
          title: 'Ad-Free High Speed Engine',
          subtitle: 'Instant file generation with zero waiting or video ads',
          accent: NeoColors.cyan,
          isDark: isDark,
        ),
        _buildSuperpowerTile(
          icon: Icons.high_quality_rounded,
          title: 'Ultra-HD Lossless 8K Output',
          subtitle: 'Zero compression artifacts and studio level clarity',
          accent: NeoColors.yellow,
          isDark: isDark,
        ),
        _buildSuperpowerTile(
          icon: Icons.psychology_rounded,
          title: 'Deep AI Neural Saliency (BiRefNet)',
          subtitle: 'High precision on-device subject segmentation',
          accent: NeoColors.green,
          isDark: isDark,
        ),
        _buildSuperpowerTile(
          icon: Icons.cloud_done_rounded,
          title: 'Multi-Device Cloud Backup',
          subtitle: 'Sync your history, presets, and Pro status anywhere',
          accent: NeoColors.purple,
          isDark: isDark,
        ),

        const SizedBox(height: 16),
        NeoButton(
          label: 'GO TO MAIN STUDIO',
          icon: const Icon(
            Icons.rocket_launch_rounded,
            size: 18,
            color: Colors.black,
          ),
          backgroundColor: NeoColors.green,
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

  Widget _buildLauncherCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required String route,
    required bool isDark,
  }) {
    return NeoCard(
      backgroundColor: isDark ? NeoColors.darkSurface : Colors.white,
      padding: const EdgeInsets.all(10),
      shadowOffset: 2,
      onTap: () => context.push(route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: NeoColors.borderLight, width: 1.5),
                ),
                child: Icon(icon, size: 16, color: Colors.black),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              color: isDark
                  ? NeoColors.textSecondaryDark
                  : NeoColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSuperpowerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required bool isDark,
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
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
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
