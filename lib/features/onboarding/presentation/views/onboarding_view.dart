import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_doodles.dart';
import '../../../../core/services/service_locator.dart';

class OnboardingSlide {
  final String titlePrefix;
  final String highlightedTitle;
  final String? titleSuffix;
  final String description;
  final String imagePath;
  final Color accentColor;
  final Color softBgColor;
  final String tag;
  final IconData icon;

  OnboardingSlide({
    required this.titlePrefix,
    required this.highlightedTitle,
    this.titleSuffix,
    required this.description,
    required this.imagePath,
    required this.accentColor,
    required this.softBgColor,
    required this.tag,
    required this.icon,
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
      titlePrefix: 'Compress Images\n',
      highlightedTitle: 'WITHOUT LOSS',
      description:
          'Reduce image file size by up to 90% instantly with smart local batch processing.',
      imagePath: 'assets/images/onboarding_compress.png',
      accentColor: NeoColors.yellow,
      softBgColor: NeoColors.softYellow,
      tag: '⚡ FAST & EFFICIENT',
      icon: Icons.compress_rounded,
    ),
    OnboardingSlide(
      titlePrefix: '9 Essential\n',
      highlightedTitle: 'IMAGE TOOLS',
      titleSuffix: ' In One',
      description:
          'Resize, crop, convert formats, build PDFs, craft passport photos & signatures seamlessly.',
      imagePath: 'assets/images/onboarding_tools.png',
      accentColor: NeoColors.cyan,
      softBgColor: NeoColors.softCyan,
      tag: '🛠️ ALL-IN-ONE UTILITY',
      icon: Icons.grid_view_rounded,
    ),
    OnboardingSlide(
      titlePrefix: '100% On-Device\n',
      highlightedTitle: 'PRIVATE & SECURE',
      description:
          'All processing happens locally on your mobile device. Your photos never leave your phone.',
      imagePath: 'assets/images/onboarding_privacy.png',
      accentColor: NeoColors.pink,
      softBgColor: NeoColors.softPink,
      tag: '🔒 PRIVACY FIRST',
      icon: Icons.shield_rounded,
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
      backgroundColor: isDark ? NeoColors.darkBg : NeoColors.lightBg,
      body: CustomPaint(
        painter: NeoGridBackgroundPainter(isDark: isDark),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: isDark
                            ? NeoColors.darkSurface
                            : NeoColors.lightSurface,
                        borderColor: NeoColors.borderLight,
                        radius: 12,
                        shadow: 3,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: NeoColors.yellow,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: NeoColors.borderLight,
                                width: 2,
                              ),
                            ),
                            child: Image.asset(
                              'assets/icon/app_icon.png',
                              width: 22,
                              height: 22,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'PicsTools',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? NeoColors.textPrimaryDark
                                  : NeoColors.textPrimaryLight,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Skip button chip
                    if (_currentPage < _slides.length - 1)
                      GestureDetector(
                        onTap: _completeOnboarding,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: NeoStyles.neoDecoration(
                            backgroundColor: isDark
                                ? NeoColors.darkSurface
                                : NeoColors.lightSurface,
                            radius: 10,
                            shadow: 2.5,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'SKIP',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? NeoColors.textPrimaryDark
                                      : NeoColors.textPrimaryLight,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.fast_forward_rounded,
                                size: 14,
                                color: isDark
                                    ? NeoColors.textPrimaryDark
                                    : NeoColors.borderLight,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

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
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: NeoCard(
                          backgroundColor: isDark
                              ? NeoColors.darkSurface
                              : NeoColors.lightSurface,
                          shadowOffset: 6,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Tag & Sparkle doodle header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  NeoBadge(
                                    label: slide.tag,
                                    backgroundColor: slide.accentColor,
                                    fontSize: 11,
                                  ),
                                  NeoSparkleDoodle(
                                    size: 22,
                                    color: slide.accentColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Neo-Brutalist Frame Illustration Container
                              Expanded(
                                flex: 5,
                                child: Container(
                                  width: double.infinity,
                                  decoration: NeoStyles.neoDecoration(
                                    backgroundColor: isDark
                                        ? const Color(0xFF27272A)
                                        : slide.softBgColor,
                                    radius: 16,
                                    shadow: 4,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Background doodle grid
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: NeoGridBackgroundPainter(
                                            isDark: isDark,
                                          ),
                                        ),
                                      ),
                                      // Illustration Image
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.asset(
                                            slide.imagePath,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    color: slide.accentColor,
                                                    child: Center(
                                                      child: Icon(
                                                        slide.icon,
                                                        size: 80,
                                                        color: NeoColors
                                                            .borderLight,
                                                      ),
                                                    ),
                                                  );
                                                },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Highlight Typography Box (Image 1 & 3 style)
                              Expanded(
                                flex: 4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          height: 1.2,
                                          color: isDark
                                              ? NeoColors.textPrimaryDark
                                              : NeoColors.textPrimaryLight,
                                        ),
                                        children: [
                                          TextSpan(text: slide.titlePrefix),
                                          WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                    vertical: 2,
                                                  ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: slide.accentColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: NeoColors.borderLight,
                                                  width: 2.5,
                                                ),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color:
                                                        NeoColors.borderLight,
                                                    offset: Offset(2.5, 2.5),
                                                    blurRadius: 0,
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                slide.highlightedTitle,
                                                style: GoogleFonts.spaceGrotesk(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w900,
                                                  color: NeoColors.borderLight,
                                                  letterSpacing: -0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (slide.titleSuffix != null)
                                            TextSpan(text: slide.titleSuffix),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      slide.description,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? NeoColors.textSecondaryDark
                                            : NeoColors.textSecondaryLight,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Footer Row (Indicators & Action Button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Neo Dot Indicators
                    Row(
                      children: List.generate(_slides.length, (index) {
                        final isSelected = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutBack,
                          margin: const EdgeInsets.only(right: 8),
                          width: isSelected ? 36 : 12,
                          height: 12,
                          decoration: NeoStyles.neoDecoration(
                            backgroundColor: isSelected
                                ? currentSlide.accentColor
                                : (isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300),
                            radius: 6,
                            shadow: isSelected ? 2.5 : 0,
                            showShadow: isSelected,
                          ),
                        );
                      }),
                    ),

                    // Next / Get Started Button
                    NeoButton(
                      label: _currentPage == _slides.length - 1
                          ? 'GET STARTED 🚀'
                          : 'NEXT',
                      icon: Icon(
                        _currentPage == _slides.length - 1
                            ? Icons.rocket_launch_rounded
                            : Icons.arrow_forward_rounded,
                        size: 18,
                        color: NeoColors.borderLight,
                      ),
                      backgroundColor: currentSlide.accentColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      onPressed: () {
                        if (_currentPage < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
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
      ),
    );
  }
}
