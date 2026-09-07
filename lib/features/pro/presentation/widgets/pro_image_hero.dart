import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';

class ProImageHero extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = screenHeight * heightFactor;
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
                  stops: heightFactor > 0.50
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

          // 3. Top Header Bar (Badge + Neo Close / Home Button)
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
                        color: badgeColor,
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
                            badgeIcon,
                            size: 15,
                            color: badgeTextColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            badgeLabel,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: badgeTextColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showCloseButton)
                      GestureDetector(
                        onTap: onClose,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: isDark ? NeoColors.darkSurface : Colors.white,
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
                            closeIcon,
                            size: 18,
                            color: isDark ? Colors.white : Colors.black,
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
}
