import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';

class ProElectrifyingHero extends StatefulWidget {
  final bool isDark;

  const ProElectrifyingHero({super.key, required this.isDark});

  @override
  State<ProElectrifyingHero> createState() => _ProElectrifyingHeroState();
}

class _ProElectrifyingHeroState extends State<ProElectrifyingHero>
    with TickerProviderStateMixin {
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  Timer? _imageCycleTimer;
  int _currentImageIndex = 0;

  final List<String> _electrifyingImages = [
    'assets/images/pro_cyber_magic.jpg',
    'assets/images/pro_batch_speed.jpg',
    'assets/images/pro_ai_cutout.jpg',
    'assets/images/pro_hero_showcase.jpg',
  ];

  @override
  void initState() {
    super.initState();

    // Slow cinematic zoom (Ken Burns video effect)
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
    );

    // Electric glow pulsation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Automatic smooth image switching every 2.5 seconds (video effect)
    _imageCycleTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (!mounted) return;
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _electrifyingImages.length;
      });
    });
  }

  @override
  void dispose() {
    _imageCycleTimer?.cancel();
    _zoomController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Container(
      height: 275,
      decoration: NeoStyles.neoDecoration(
        backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFF0F172A),
        radius: 20,
        shadow: 4,
        borderColor: isDark ? NeoColors.borderDark : NeoColors.borderLight,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Video-like Electrifying Image Cross-fader with Ken Burns Zoom
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 750),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: ScaleTransition(
              key: ValueKey<int>(_currentImageIndex),
              scale: _zoomAnimation,
              child: Opacity(
                opacity: isDark ? 0.42 : 0.35, // Slightly reduced opacity for maximum text clarity
                child: Image.asset(
                  _electrifyingImages[_currentImageIndex],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),

          // 2. Cinematic Gradient & Electric Vignette Overlay
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.black.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // 3. Electric Particle & Border Highlight Accents
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    NeoColors.cyan,
                    NeoColors.yellow,
                    NeoColors.pink,
                    NeoColors.green,
                  ],
                ),
              ),
            ),
          ),

          // 4. Content Layered On Top (Crystal Clear, High Contrast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Animated Electric Badge
                ScaleTransition(
                  scale: _glowAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: NeoColors.yellow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: NeoColors.borderLight,
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: NeoColors.borderLight,
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          size: 15,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '⚡ 50% LAUNCH DISCOUNT • LIMITED TIME',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Center Text
                Column(
                  children: [
                    Text(
                      'PicsTools PRO',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        shadows: [
                          const Shadow(
                            color: Colors.black,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unlimited Batch • 8K Lossless • Neural AI Precision',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF1F5F9),
                        shadows: [
                          const Shadow(
                            color: Colors.black87,
                            offset: Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Glowing Feature Chips at Bottom of Hero
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildChip('🚫 ZERO ADS', NeoColors.cyan),
                    _buildChip('🚀 MASS BATCH', NeoColors.yellow),
                    _buildChip('🧠 NEURAL AI', NeoColors.pink),
                    _buildChip('💎 8K ULTRA-HD', NeoColors.green),
                  ],
                ),
              ],
            ),
          ),

          // 5. Video Loop Indicator Pills
          Positioned(
            bottom: 6,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_electrifyingImages.length, (idx) {
                final isActive = _currentImageIndex == idx;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  width: isActive ? 16 : 5,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? NeoColors.yellow : Colors.white38,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accent,
          width: 1.2,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
