import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/sound_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.12, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
    );

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    final sound = getIt<SoundService>();
    sound.playPopSound();
    _controller.forward();

    await Future.delayed(const Duration(milliseconds: 2300));
    if (!mounted) return;

    final prefs = getIt<SharedPreferences>();
    final completed = prefs.getBool('onboarding_completed') ?? false;

    if (completed) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.yellow,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Animated Logo Card
                    Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 32,
                          ),
                          decoration: NeoStyles.neoDecoration(
                            backgroundColor: NeoColors.lightSurface,
                            radius: 20,
                            shadow: 8,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: NeoStyles.neoDecoration(
                                      backgroundColor: NeoColors.yellow,
                                      radius: 14,
                                      shadow: 3,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        'assets/icon/app_icon.png',
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const NeoBadge(
                                            label: 'PICS',
                                            backgroundColor: NeoColors.pink,
                                            fontSize: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          const NeoBadge(
                                            label: 'TOOLS',
                                            backgroundColor: NeoColors.cyan,
                                            fontSize: 16,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'IMAGE UTILITY SUITE',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: NeoColors.textSecondaryLight,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Tagline Ticker
                    Text(
                      'COMPRESS • RESIZE • CROP • CONVERT • PDF • SIGN • ID PHOTO',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.borderLight,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const Spacer(),

                    // Neo-Brutalist Striped Block Progress Bar
                    Container(
                      width: 220,
                      height: 16,
                      padding: const EdgeInsets.all(2),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.lightSurface,
                        radius: 8,
                        shadow: 3,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _progressAnimation.value.clamp(
                              0.05,
                              1.0,
                            ),
                            child: Container(color: NeoColors.pink),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'POWERING UTILITIES...',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
