import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/neo_colors.dart';

class ProVideoHero extends StatefulWidget {
  final bool isDark;

  const ProVideoHero({super.key, required this.isDark});

  @override
  State<ProVideoHero> createState() => _ProVideoHeroState();
}

class _ProVideoHeroState extends State<ProVideoHero>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _controller = VideoPlayerController.asset(
        'assets/videos/pro_background.mp4',
      );
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setVolume(0.0);
      await _controller!.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (_) {
      // Graceful fallback for environments where video decoder is unavailable
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final screenBg = isDark ? NeoColors.darkBg : NeoColors.lightBg;
    final heroHeight = MediaQuery.of(context).size.height * 0.40;

    return SizedBox(
      height: heroHeight.clamp(280.0, 360.0),
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-Width 0-Padding Background Video (or Image Fallback)
          if (_isInitialized && _controller != null)
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _controller!.value.size.width > 0
                    ? _controller!.value.size.width
                    : 1280,
                height: _controller!.value.size.height > 0
                    ? _controller!.value.size.height
                    : 720,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            Image.asset(
              'assets/images/pro_cyber_magic.jpg',
              fit: BoxFit.cover,
            ),

          // 2. Dark/Vibrant Tint for High-Contrast Text
          Container(
            color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.30),
          ),

          // 3. Seamless Bottom Gradient Fade into Screen Background
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 140,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    screenBg.withValues(alpha: 0.0),
                    screenBg.withValues(alpha: 0.60),
                    screenBg.withValues(alpha: 0.95),
                    screenBg,
                  ],
                  stops: const [0.0, 0.45, 0.85, 1.0],
                ),
              ),
            ),
          ),

          // 4. Content Layered On Top (Centered & Crystal Clear)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Glowing Animated Top Badge
                ScaleTransition(
                  scale: _glowAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
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
                          size: 16,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '⚡ 50% LAUNCH DISCOUNT • LIMITED TIME',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Center Headline & Subtitle
                Column(
                  children: [
                    Text(
                      'PicsTools PRO',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        shadows: [
                          const Shadow(
                            color: Colors.black,
                            offset: Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Unlimited Batch • 8K Lossless • Neural AI Magic',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF8FAFC),
                        shadows: [
                          const Shadow(
                            color: Colors.black87,
                            offset: Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Feature Highlights Layered on Video Bottom
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildPill('🚫 ZERO ADS', NeoColors.cyan),
                    _buildPill('🚀 MASS BATCH', NeoColors.yellow),
                    _buildPill('🧠 NEURAL AI', NeoColors.pink),
                    _buildPill('💎 8K LOSSLESS', NeoColors.green),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String text, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accent,
          width: 1.5,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
