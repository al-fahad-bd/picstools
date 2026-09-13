import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';

class ProImageHero extends StatefulWidget {
  final bool isDark;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final double heightFactor;
  final String badgeLabel;
  final IconData badgeIcon;
  final Color badgeColor;
  final Color badgeTextColor;
  final IconData closeIcon;

  const ProImageHero({
    super.key,
    required this.isDark,
    this.showCloseButton = false,
    this.onClose,
    this.heightFactor = 0.44,
    this.badgeLabel = 'PicsTools PRO',
    this.badgeIcon = Icons.star_rounded,
    this.badgeColor = NeoColors.yellow,
    this.badgeTextColor = Colors.black,
    this.closeIcon = Icons.close_rounded,
  });

  @override
  State<ProImageHero> createState() => _ProImageHeroState();
}

class _ProImageHeroState extends State<ProImageHero>
    with SingleTickerProviderStateMixin {
  static const List<String> _images = [
    'assets/images/pro_hero_male_editing.jpeg',
    'assets/images/pro_hero_female_editing.jpeg',
  ];

  int _currentIndex = 0;
  int _targetIndex = 1;
  late AnimationController _zapController;
  Timer? _loopTimer;
  final Random _random = Random();
  int _seed = 42;

  // Cached sparks generated for each zap
  List<_ElectricSpark> _sparks = [];

  @override
  void initState() {
    super.initState();
    _zapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _zapController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex = _targetIndex;
          _targetIndex = (_currentIndex + 1) % _images.length;
        });
        _zapController.reset();
        _scheduleNextZap();
      }
    });

    _scheduleNextZap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache both images for instant, seamless transitions
    for (final img in _images) {
      precacheImage(AssetImage(img), context);
    }
  }

  void _scheduleNextZap() {
    _loopTimer?.cancel();
    _loopTimer = Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      _triggerZap();
    });
  }

  void _triggerZap() {
    setState(() {
      _seed = _random.nextInt(100000);
      _targetIndex = (_currentIndex + 1) % _images.length;
      _sparks = List.generate(
        18,
        (_) => _ElectricSpark(
          angle: _random.nextDouble() * 2 * pi,
          speed: 80.0 + _random.nextDouble() * 160.0,
          radius: 1.5 + _random.nextDouble() * 2.5,
          color: _random.nextBool()
              ? const Color(0xFF00F0FF) // Neon Cyan
              : (_random.nextBool()
                    ? const Color(0xFFFFE600) // Electric Yellow
                    : const Color(0xFFFFFFFF)), // Bright Core White
        ),
      );
    });
    _zapController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    _zapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = screenHeight * widget.heightFactor;
    final topPadding = MediaQuery.of(context).padding.top;
    final bgColor = widget.isDark ? NeoColors.darkBg : NeoColors.lightBg;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Dual-Layer Image Switcher with Electrifying Glitch/Shake
          AnimatedBuilder(
            animation: _zapController,
            builder: (context, child) {
              final t = _zapController.value;

              // Horizontal glitch jitter during peak strike (between 0.18 and 0.42)
              double glitchOffsetX = 0.0;
              if (t >= 0.18 && t <= 0.42) {
                final jitterPhase = (t - 0.18) / 0.24;
                glitchOffsetX =
                    sin(jitterPhase * 18 * pi) * (4.0 * (1.0 - jitterPhase));
              }

              // Image cross-switch timing: switches right under peak electric flash (0.28)
              final double targetOpacity = t < 0.22
                  ? 0.0
                  : (t > 0.38 ? 1.0 : (t - 0.22) / 0.16);

              return Transform.translate(
                offset: Offset(glitchOffsetX, 0),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Base current image
                    Image.asset(
                      _images[_currentIndex],
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildErrorPlaceholder(),
                    ),

                    // Target image fading in during electric flash
                    if (_zapController.isAnimating)
                      Opacity(
                        opacity: targetOpacity.clamp(0.0, 1.0),
                        child: Image.asset(
                          _images[_targetIndex],
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildErrorPlaceholder(),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          // 2. Electrifying VFX Layer (Bolts, Shockwave Glow, Sparks)
          AnimatedBuilder(
            animation: _zapController,
            builder: (context, child) {
              if (!_zapController.isAnimating && _zapController.value == 0.0) {
                return const SizedBox.shrink();
              }
              return CustomPaint(
                painter: _ElectricZapPainter(
                  progress: _zapController.value,
                  seed: _seed,
                  sparks: _sparks,
                ),
              );
            },
          ),

          // 3. Fading Gradient Overlay - Ultra-smooth gradual transition into background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: widget.heightFactor > 0.50
                      ? const [
                          0.0,
                          0.10,
                          0.58,
                          0.72,
                          0.82,
                          0.89,
                          0.95,
                          0.98,
                          1.0,
                        ]
                      : const [
                          0.0,
                          0.10,
                          0.50,
                          0.65,
                          0.76,
                          0.85,
                          0.92,
                          0.97,
                          1.0,
                        ],
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                    Colors.transparent,
                    bgColor.withValues(alpha: 0.08),
                    bgColor.withValues(alpha: 0.22),
                    bgColor.withValues(alpha: 0.45),
                    bgColor.withValues(alpha: 0.72),
                    bgColor.withValues(alpha: 0.92),
                    bgColor,
                  ],
                ),
              ),
            ),
          ),

          // 4. Top Header Bar (Badge + Neo Close / Home Button)
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding > 0 ? topPadding + 6 : 24,
                left: 20,
                right: 20,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: widget.badgeColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.badgeIcon,
                            size: 15,
                            color: widget.badgeTextColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.badgeLabel,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: widget.badgeTextColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.showCloseButton)
                      GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? NeoColors.darkSurface
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.closeIcon,
                            size: 18,
                            color: widget.isDark ? Colors.white : Colors.black,
                          ),
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

  Widget _buildErrorPlaceholder() {
    return Container(
      color: widget.isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
      child: const Center(
        child: Icon(Icons.image_rounded, size: 48, color: NeoColors.yellow),
      ),
    );
  }
}

class _ElectricSpark {
  final double angle;
  final double speed;
  final double radius;
  final Color color;

  const _ElectricSpark({
    required this.angle,
    required this.speed,
    required this.radius,
    required this.color,
  });
}

class _ElectricZapPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final int seed;
  final List<_ElectricSpark> sparks;

  _ElectricZapPainter({
    required this.progress,
    required this.seed,
    required this.sparks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final center = Offset(size.width * 0.5, size.height * 0.35);

    // 1. Plasma Glow Shockwave (peak around 0.28)
    double glowIntensity = 0.0;
    if (progress < 0.28) {
      glowIntensity = progress / 0.28;
    } else {
      glowIntensity = (1.0 - (progress - 0.28) / 0.52).clamp(0.0, 1.0);
    }

    if (glowIntensity > 0.02) {
      // Ambient radial electric flash
      final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
      final flashPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment(0.0, -0.3),
          radius: 0.9,
          colors: [
            Colors.white.withValues(alpha: 0.85 * glowIntensity),
            const Color(0xFF00F0FF).withValues(alpha: 0.65 * glowIntensity),
            const Color(0xFF7000FF).withValues(alpha: 0.25 * glowIntensity),
            Colors.transparent,
          ],
          stops: const [0.0, 0.28, 0.65, 1.0],
        ).createShader(rect);
      canvas.drawRect(rect, flashPaint);
    }

    // 2. Procedural Lightning Arcs (active between 0.10 and 0.55)
    if (progress >= 0.10 && progress <= 0.55) {
      final boltPhase = (progress - 0.10) / 0.45;
      final boltAlpha =
          (boltPhase < 0.35
                  ? boltPhase / 0.35
                  : (1.0 - (boltPhase - 0.35) / 0.65))
              .clamp(0.0, 1.0);

      if (boltAlpha > 0.05) {
        final rng = Random(seed);

        // Generate 3 main lightning branches radiating across the hero
        final boltTargets = [
          Offset(size.width * 0.15, size.height * 0.70),
          Offset(size.width * 0.85, size.height * 0.65),
          Offset(size.width * 0.50, size.height * 0.80),
          Offset(size.width * 0.20, size.height * 0.15),
          Offset(size.width * 0.80, size.height * 0.18),
        ];

        final startPoints = [
          Offset(size.width * 0.50, size.height * 0.0),
          Offset(size.width * 0.35, size.height * 0.30),
          Offset(size.width * 0.65, size.height * 0.32),
        ];

        for (int b = 0; b < 3; b++) {
          final start = startPoints[b % startPoints.length];
          final end = boltTargets[(b + (rng.nextInt(3))) % boltTargets.length];
          _drawLightningBolt(canvas, start, end, rng, boltAlpha);
        }
      }
    }

    // 3. Electric Sparks Burst (active between 0.20 and 0.85)
    if (progress >= 0.20 && progress <= 0.85) {
      final sparkProgress = (progress - 0.20) / 0.65;
      final sparkFade = (1.0 - sparkProgress).clamp(0.0, 1.0);

      for (final s in sparks) {
        final distance = s.speed * sparkProgress;
        final pos = Offset(
          center.dx + cos(s.angle) * distance,
          center.dy + sin(s.angle) * distance,
        );

        // Spark trail
        final trailStart = Offset(
          center.dx + cos(s.angle) * (distance - 8.0 * sparkFade),
          center.dy + sin(s.angle) * (distance - 8.0 * sparkFade),
        );

        final sparkPaint = Paint()
          ..color = s.color.withValues(alpha: sparkFade)
          ..strokeWidth = s.radius
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(trailStart, pos, sparkPaint);

        // Spark head glow
        final glowPaint = Paint()
          ..color = s.color.withValues(alpha: 0.4 * sparkFade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(pos, s.radius * 2, glowPaint);
      }
    }
  }

  void _drawLightningBolt(
    Canvas canvas,
    Offset start,
    Offset end,
    Random rng,
    double alpha,
  ) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    const int segments = 7;

    for (int i = 1; i <= segments; i++) {
      final double fraction = i / segments;
      final Offset ideal = Offset.lerp(start, end, fraction)!;

      // Jitter perpendicular to line
      final double jitter = (rng.nextDouble() - 0.5) * 32.0;
      final Offset next = i == segments
          ? end
          : Offset(
              ideal.dx + jitter,
              ideal.dy + (rng.nextDouble() - 0.5) * 16.0,
            );

      path.lineTo(next.dx, next.dy);

      // Chance of mini sub-branch
      if (i == 3 || i == 5) {
        final subEnd = Offset(
          next.dx + (rng.nextDouble() - 0.5) * 45.0,
          next.dy + rng.nextDouble() * 35.0,
        );
        _drawSubBranch(canvas, next, subEnd, rng, alpha * 0.7);
      }
    }

    // 1. Outer Neon Bloom
    final bloomPaint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.5 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, bloomPaint);

    // 2. Cyan Body
    final cyanPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.9 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, cyanPaint);

    // 3. Core White Light
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, corePaint);
  }

  void _drawSubBranch(
    Canvas canvas,
    Offset start,
    Offset end,
    Random rng,
    double alpha,
  ) {
    final subPath = Path();
    subPath.moveTo(start.dx, start.dy);
    final mid = Offset(
      (start.dx + end.dx) * 0.5 + (rng.nextDouble() - 0.5) * 16.0,
      (start.dy + end.dy) * 0.5,
    );
    subPath.lineTo(mid.dx, mid.dy);
    subPath.lineTo(end.dx, end.dy);

    final subPaint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(subPath, subPaint);

    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(subPath, corePaint);
  }

  @override
  bool shouldRepaint(covariant _ElectricZapPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.seed != seed;
  }
}
