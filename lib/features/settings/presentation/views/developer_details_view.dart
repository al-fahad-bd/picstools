import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_button.dart';

class DeveloperDetailsView extends StatelessWidget {
  const DeveloperDetailsView({super.key});

  Future<void> _launchPortfolioUrl(BuildContext context) async {
    final Uri url = Uri.parse('http://abdullahalfahad.vercel.app/');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        await launchUrl(url);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open http://abdullahalfahad.vercel.app/'),
            backgroundColor: NeoColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: NeoStyles.neoDecoration(
              backgroundColor:
                  isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
              radius: 10,
              shadow: 2,
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 18),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Developer Details',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Illustration Card
              NeoCard(
                backgroundColor: NeoColors.purple,
                shadowOffset: 5,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: NeoStyles.neoDecoration(
                            backgroundColor: NeoColors.yellow,
                            radius: 50,
                            shadow: 4,
                          ),
                        ),
                        Container(
                          width: 84,
                          height: 84,
                          decoration: NeoStyles.neoDecoration(
                            backgroundColor: NeoColors.cyan,
                            radius: 42,
                            shadow: 2,
                          ),
                          child: const Icon(
                            Icons.terminal_rounded,
                            size: 44,
                            color: NeoColors.borderLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const NeoBadge(
                      label: 'DEVELOPER UNLOCKED',
                      backgroundColor: NeoColors.yellow,
                      textColor: NeoColors.borderLight,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Abdullah Al Fahad',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.lightSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lead Mobile Software Engineer',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: NeoColors.lightSurface.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Passionate mobile developer focused on crafting privacy-first, ultra-fast offline image utility tools with bold Neo-Brutalist UI designs.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          height: 1.4,
                          color: NeoColors.lightSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Portfolio Website Button
                    NeoButton(
                      label: 'VISIT PORTFOLIO SITE',
                      icon: const Icon(
                        Icons.language_rounded,
                        color: NeoColors.borderLight,
                      ),
                      backgroundColor: NeoColors.cyan,
                      textColor: NeoColors.borderLight,
                      fullWidth: true,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: () => _launchPortfolioUrl(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Engineering Specs Section
              Text(
                'Engineering & Tech Stack',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              NeoCard(
                backgroundColor:
                    isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
                shadowOffset: 3,
                child: Column(
                  children: [
                    _buildSpecRow(
                      icon: Icons.code_rounded,
                      iconBg: NeoColors.cyan,
                      title: 'Framework & Engine',
                      subtitle: 'Flutter 3.x (Dart 3.x)',
                      isDark: isDark,
                    ),
                    const Divider(height: 1),
                    _buildSpecRow(
                      icon: Icons.architecture_rounded,
                      iconBg: NeoColors.yellow,
                      title: 'Architecture Pattern',
                      subtitle: 'BLoC Pattern + Clean Architecture',
                      isDark: isDark,
                    ),
                    const Divider(height: 1),
                    _buildSpecRow(
                      icon: Icons.palette_rounded,
                      iconBg: NeoColors.purple,
                      title: 'Design System',
                      subtitle: 'Neo-Brutalist UI & Dynamic Theme',
                      isDark: isDark,
                    ),
                    const Divider(height: 1),
                    _buildSpecRow(
                      icon: Icons.shield_rounded,
                      iconBg: NeoColors.green,
                      title: 'Privacy & Security',
                      subtitle: '100% On-Device Offline Processing',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Connect & Socials Section
              Text(
                'Connect & Information',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: NeoCard(
                      backgroundColor: NeoColors.softCyan,
                      shadowOffset: 3,
                      padding: const EdgeInsets.all(16),
                      onTap: () => _launchPortfolioUrl(context),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            size: 28,
                            color: NeoColors.borderLight,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Portfolio',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: NeoColors.borderLight,
                            ),
                          ),
                          Text(
                            'abdullahalfahad.vercel.app',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              color: NeoColors.borderLight.withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoCard(
                      backgroundColor: NeoColors.softYellow,
                      shadowOffset: 3,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 28,
                            color: NeoColors.borderLight,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'PicsTools v1.0.0',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: NeoColors.borderLight,
                            ),
                          ),
                          Text(
                            'Developer Edition',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              color: NeoColors.borderLight.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Back to Home Action Button
              NeoButton(
                label: 'BACK TO APP',
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: NeoColors.borderLight,
                ),
                backgroundColor: NeoColors.cyan,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 16),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: NeoStyles.neoDecoration(
              backgroundColor: iconBg,
              radius: 10,
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
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: isDark
                        ? NeoColors.textSecondaryDark
                        : NeoColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
