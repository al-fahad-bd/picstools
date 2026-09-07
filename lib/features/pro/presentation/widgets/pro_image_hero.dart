import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';

class ProImageHero extends StatelessWidget {
  final bool isDark;

  const ProImageHero({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = screenHeight * 0.44;
    final topPadding = MediaQuery.of(context).padding.top;
    final bgColor = isDark ? NeoColors.darkBg : NeoColors.lightBg;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background AI Image - Perfectly cropped near notch, phone completely visible
          Image.asset(
            'assets/images/pro_hero_user_editing.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
                child: const Center(
                  child: Icon(
                    Icons.image_rounded,
                    size: 48,
                    color: NeoColors.yellow,
                  ),
                ),
              );
            },
          ),

          // 2. Fading Gradient Overlay - Ultra-smooth gradual transition into background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [
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

          // 3. Top Badge
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding > 0 ? topPadding + 4 : 24,
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
                        color: NeoColors.yellow,
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
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PICSTOOLS PRO',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: 0.8,
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
}
