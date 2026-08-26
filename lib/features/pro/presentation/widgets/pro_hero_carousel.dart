import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';

class ProHeroCarousel extends StatefulWidget {
  final bool isDark;

  const ProHeroCarousel({super.key, required this.isDark});

  @override
  State<ProHeroCarousel> createState() => _ProHeroCarouselState();
}

class _ProHeroCarouselState extends State<ProHeroCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  final List<({String image, String title, String subtitle, Color tagColor})>
      _slides = [
    (
      image: 'assets/images/pro_hero_showcase.jpg',
      title: 'ULTRA-HD 8K ENGINE',
      subtitle: 'Unlimited batch processing & zero compression quality loss',
      tagColor: NeoColors.yellow,
    ),
    (
      image: 'assets/images/pro_ai_cutout.jpg',
      title: 'NEURAL AI MAGIC CUTOUT',
      subtitle: 'Instant crystal-clear background removal & subject isolation',
      tagColor: NeoColors.cyan,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Column(
      children: [
        Container(
          height: 195,
          decoration: NeoStyles.neoDecoration(
            backgroundColor: isDark ? NeoColors.darkSurface : Colors.white,
            radius: 16,
            shadow: 4,
            borderColor: isDark ? NeoColors.borderDark : NeoColors.borderLight,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) {
                  setState(() => _currentPage = idx);
                },
                itemCount: _slides.length,
                itemBuilder: (ctx, idx) {
                  final slide = _slides[idx];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        slide.image,
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay for text readability
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.1),
                              Colors.black.withValues(alpha: 0.85),
                            ],
                            stops: const [0.3, 0.6, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: slide.tagColor,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: NeoColors.borderLight,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                slide.title,
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
                              slide.subtitle,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                shadows: [
                                  const Shadow(
                                    color: Colors.black87,
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (idx) {
            final isActive = _currentPage == idx;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? NeoColors.yellow
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
                  width: 1,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
