import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/services/service_locator.dart';

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String tag;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.tag,
  });
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Compress Images\nWithout Losing Quality',
      description: 'Reduce image file size by up to 90% instantly with smart batch processing.',
      icon: Icons.compress_rounded,
      accentColor: NeoColors.yellow,
      tag: 'FAST & EFFICIENT',
    ),
    OnboardingSlide(
      title: '8 Essential\nImage Tools in One',
      description: 'Resize, crop, convert JPG/PNG/WebP, build PDFs, make passport photos & digital signatures.',
      icon: Icons.grid_view_rounded,
      accentColor: NeoColors.cyan,
      tag: 'ALL-IN-ONE UTILITY',
    ),
    OnboardingSlide(
      title: '100% On-Device\nPrivate & Secure',
      description: 'All processing happens locally on your mobile device. Your photos never leave your phone.',
      icon: Icons.shield_rounded,
      accentColor: NeoColors.pink,
      tag: 'PRIVACY FIRST',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = getIt<SharedPreferences>();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentSlide = _slides[_currentPage];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header Skip row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: NeoStyles.neoDecoration(
                          backgroundColor: NeoColors.yellow,
                          shadow: 2,
                        ),
                        child: const Icon(
                          Icons.photo_library_rounded,
                          size: 20,
                          color: NeoColors.borderLight,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'PicsTools',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < _slides.length - 1)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'SKIP',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Main PageView Card
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: NeoCard(
                        backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
                        shadowOffset: 6,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NeoBadge(
                              label: slide.tag,
                              backgroundColor: slide.accentColor,
                              fontSize: 11,
                            ),
                            const Spacer(),
                            Container(
                              width: 120,
                              height: 120,
                              decoration: NeoStyles.neoDecoration(
                                backgroundColor: slide.accentColor,
                                radius: 60,
                                shadow: 5,
                              ),
                              child: Icon(
                                slide.icon,
                                size: 60,
                                color: NeoColors.borderLight,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              slide.description,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
                                height: 1.4,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Indicators & Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page dots
                  Row(
                    children: List.generate(_slides.length, (index) {
                      final isSelected = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        width: isSelected ? 32 : 12,
                        height: 12,
                        decoration: NeoStyles.neoDecoration(
                          backgroundColor: isSelected
                              ? currentSlide.accentColor
                              : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                          radius: 6,
                          shadow: isSelected ? 2 : 0,
                          showShadow: isSelected,
                        ),
                      );
                    }),
                  ),

                  // Next / Get Started button
                  NeoButton(
                    label: _currentPage == _slides.length - 1 ? 'GET STARTED' : 'NEXT',
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: NeoColors.borderLight),
                    backgroundColor: currentSlide.accentColor,
                    onPressed: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
