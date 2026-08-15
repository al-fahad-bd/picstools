import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import 'checkerboard_container.dart';

class ComparisonSlider extends StatefulWidget {
  final File originalImage;
  final File transparentImage;
  final double height;

  const ComparisonSlider({
    super.key,
    required this.originalImage,
    required this.transparentImage,
    this.height = 340,
  });

  @override
  State<ComparisonSlider> createState() => _ComparisonSliderState();
}

class _ComparisonSliderState extends State<ComparisonSlider> {
  double _splitPosition = 0.5; // 0.0 to 1.0
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? NeoColors.borderDark : NeoColors.borderLight;

    return CheckerboardContainer(
      borderRadius: 16,
      borderColor: borderColor,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final splitPixel = maxWidth * _splitPosition.clamp(0.0, 1.0);

              return Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: [
                  // 1. Full-size Transparent PNG on Checkerboard (Right side / base)
                  Image.file(widget.transparentImage, fit: BoxFit.contain),

                  // 2. Clipped Original Image (Left side)
                  ClipRect(
                    clipper: _SplitClipper(splitPixel),
                    child: Image.file(
                      widget.originalImage,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // 3. Vertical Divider Line
                  Positioned(
                    left: splitPixel - 1.5,
                    top: -16,
                    bottom: -16,
                    child: Container(width: 3.0, color: NeoColors.borderLight),
                  ),

                  // 4. Top Badges: 'ORIGINAL' & 'REMOVED'
                  Positioned(
                    top: 12,
                    left: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: NeoColors.yellow,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: NeoColors.borderLight,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        'ORIGINAL',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: NeoColors.green,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: NeoColors.borderLight,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        'AI REMOVED',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                    ),
                  ),

                  // 5. Central Slider Handle Button
                  Positioned(
                    left: splitPixel - 18,
                    top: (widget.height / 2) - 18,
                    child: GestureDetector(
                      onHorizontalDragStart: (_) =>
                          setState(() => _isDragging = true),
                      onHorizontalDragEnd: (_) =>
                          setState(() => _isDragging = false),
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _splitPosition =
                              (_splitPosition + details.delta.dx / maxWidth)
                                  .clamp(0.0, 1.0);
                        });
                      },
                      child: AnimatedScale(
                        scale: _isDragging ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: NeoColors.cyan,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: NeoColors.borderLight,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: NeoColors.borderLight,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.compare_arrows_rounded,
                              size: 20,
                              color: NeoColors.borderLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Full drag area
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _splitPosition =
                              (_splitPosition + details.delta.dx / maxWidth)
                                  .clamp(0.0, 1.0);
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SplitClipper extends CustomClipper<Rect> {
  final double splitX;
  const _SplitClipper(this.splitX);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, splitX, size.height);
  }

  @override
  bool shouldReclip(covariant _SplitClipper oldClipper) =>
      oldClipper.splitX != splitX;
}
