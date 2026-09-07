import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/monetization/in_app_purchase_service.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_doodles.dart';

class OnboardingGiftView extends StatefulWidget {
  const OnboardingGiftView({super.key});

  @override
  State<OnboardingGiftView> createState() => _OnboardingGiftViewState();
}

class _OnboardingGiftViewState extends State<OnboardingGiftView>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _floatController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // If user is already Pro, never show the temporary 24-hour trial gift screen
    if (getIt.isRegistered<InAppPurchaseService>() &&
        getIt<InAppPurchaseService>().isProUser()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/home');
        }
      });
      return;
    }

    // Entrance pop & slide animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // Continuous floating/hovering animation for the gift
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? NeoColors.borderDark : NeoColors.borderLight;
    final cardBg = isDark ? NeoColors.darkSurface : NeoColors.lightSurface;
    final textColor = isDark
        ? NeoColors.textPrimaryDark
        : NeoColors.textPrimaryLight;
    final subtextColor = isDark
        ? NeoColors.textSecondaryDark
        : NeoColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: isDark ? NeoColors.darkBg : NeoColors.lightBg,
      body: Stack(
        children: [
          // Background Neo-Brutalist Grid Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: NeoGridBackgroundPainter(isDark: isDark),
            ),
          ),

          // Celebratory Confetti Burst
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/animations/confetti.json',
                repeat: false,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),

          // Main Interactive Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Floating Celebration Hero Container
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _entranceController,
                        _floatController,
                      ]),
                      builder: (context, child) {
                        final floatOffset =
                            math.sin(_floatController.value * 2 * math.pi) * 6;
                        return Transform.translate(
                          offset: Offset(0, floatOffset),
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Opacity(
                              opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Center(
                        child: SizedBox(
                          width: 240,
                          height: 210,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              // Decorative background neo circle badge
                              Container(
                                width: 156,
                                height: 156,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? NeoColors.darkSurface
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 3.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(6, 6),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                              ),

                              // Custom Neo-Brutalist Gift Box Lottie Animation
                              Positioned.fill(
                                child: Lottie.asset(
                                  'assets/animations/gift.json',
                                  repeat: true,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                        child: Icon(
                                          Icons.card_giftcard_rounded,
                                          size: 72,
                                          color: Colors.black,
                                        ),
                                      ),
                                ),
                              ),

                              // Floating Top-Left Badge
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Transform.rotate(
                                  angle: -0.15,
                                  child: const NeoBadge(
                                    label: '🎁 3-DAY VIP',
                                    backgroundColor: NeoColors.pink,
                                    textColor: Colors.white,
                                    fontSize: 11,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                ),
                              ),

                              // Floating Bottom-Right Badge
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Transform.rotate(
                                  angle: 0.12,
                                  child: const NeoBadge(
                                    label: '⚡ 100% FREE',
                                    backgroundColor: NeoColors.green,
                                    textColor: Colors.black,
                                    fontSize: 11,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                ),
                              ),

                              // Sparkle accent top-right
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: NeoSparkleDoodle(
                                  size: 26,
                                  color: NeoColors.cyan,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Staggered Entrance for Ticket & Content
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Opacity(
                            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Headline
                          Text(
                            'Here\'s 24 Hours Ad-Free\nOn Us!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'We appreciate you! Enjoy unrestricted creation completely uninterrupted.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: subtextColor,
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Neo-Brutalist VIP Voucher Ticket Card
                          Container(
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: borderColor,
                                  offset: const Offset(5, 5),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Voucher Header
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: NeoColors.yellow,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(13),
                                    ),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: borderColor,
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.stars_rounded,
                                            size: 18,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'VIP ACCESS PASS',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                              letterSpacing: 0.8,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          '24 HOURS',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Voucher Body / Perks
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      _buildPerkRow(
                                        icon: Icons.block_flipped,
                                        iconBg: NeoColors.pink,
                                        title: '100% Ad-Free Experience',
                                        subtitle:
                                            'Zero ads, zero banners, zero waiting',
                                        textColor: textColor,
                                        subtextColor: subtextColor,
                                        borderColor: borderColor,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildPerkRow(
                                        icon: Icons.bolt_rounded,
                                        iconBg: NeoColors.cyan,
                                        title: 'All 8 Tools Unlocked',
                                        subtitle:
                                            'Full batch processing & max quality exports',
                                        textColor: textColor,
                                        subtextColor: subtextColor,
                                        borderColor: borderColor,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildPerkRow(
                                        icon: Icons.check_circle_rounded,
                                        iconBg: NeoColors.green,
                                        title: 'No Credit Card Needed',
                                        subtitle:
                                            'Expires automatically. Never billed',
                                        textColor: textColor,
                                        subtextColor: subtextColor,
                                        borderColor: borderColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Neo CTA Button
                          NeoButton(
                            label: 'CLAIM GIFT & START CREATING 🚀',
                            backgroundColor: NeoColors.green,
                            textColor: Colors.black,
                            fullWidth: true,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            onPressed: () async {
                              final prefs = getIt<SharedPreferences>();
                              await prefs.setInt(
                                'vip_gift_start_time',
                                DateTime.now().millisecondsSinceEpoch,
                              );
                              if (context.mounted) {
                                context.go('/home');
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your pass activates immediately • Enjoy creating!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerkRow({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: borderColor,
                offset: const Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: Colors.black),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: subtextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
