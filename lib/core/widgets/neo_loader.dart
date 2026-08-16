import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/neo_colors.dart';
import '../constants/neo_styles.dart';

enum NeoLoaderStyle {
  /// Staggered pulsing neo-bars / dots (great for buttons and chips)
  dots,

  /// Rotating geometric neo-square with border and hard shadow
  spinner,

  /// Staggered pulsing geometric cubes with neo borders
  cubes,
}

class NeoLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Color? secondaryColor;
  final Color? tertiaryColor;
  final Color? borderColor;
  final NeoLoaderStyle style;
  final double strokeWidth;

  const NeoLoader({
    super.key,
    this.size = 24.0,
    this.color,
    this.secondaryColor,
    this.tertiaryColor,
    this.borderColor,
    this.style = NeoLoaderStyle.dots,
    this.strokeWidth = 2.0,
  });

  /// Factory for button loading states
  const NeoLoader.button({
    super.key,
    this.size = 18.0,
    this.color,
    this.secondaryColor,
    this.tertiaryColor,
    this.borderColor,
    this.strokeWidth = 1.5,
  }) : style = NeoLoaderStyle.dots;

  /// Factory for card / screen loading states
  const NeoLoader.large({
    super.key,
    this.size = 48.0,
    this.color = NeoColors.yellow,
    this.secondaryColor = NeoColors.cyan,
    this.tertiaryColor,
    this.borderColor,
    this.strokeWidth = 2.5,
  }) : style = NeoLoaderStyle.cubes;

  /// Factory for spinner style
  const NeoLoader.spinner({
    super.key,
    this.size = 28.0,
    this.color = NeoColors.yellow,
    this.secondaryColor,
    this.tertiaryColor,
    this.borderColor,
    this.strokeWidth = 2.5,
  }) : style = NeoLoaderStyle.spinner;

  @override
  State<NeoLoader> createState() => _NeoLoaderState();
}

class _NeoLoaderState extends State<NeoLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        widget.color ?? (isDark ? NeoColors.yellow : NeoColors.borderLight);
    final secColor =
        widget.secondaryColor ?? (isDark ? NeoColors.cyan : NeoColors.pink);
    final tertColor =
        widget.tertiaryColor ??
        ((primaryColor == NeoColors.green || secColor == NeoColors.green)
            ? NeoColors.pink
            : (primaryColor == NeoColors.cyan || secColor == NeoColors.cyan
                  ? NeoColors.green
                  : NeoColors.cyan));
    final border =
        widget.borderColor ??
        (isDark ? NeoColors.borderDark : NeoColors.borderLight);

    switch (widget.style) {
      case NeoLoaderStyle.dots:
        return _buildPulsingDots(primaryColor, secColor, tertColor, border);
      case NeoLoaderStyle.spinner:
        return _buildRotatingSpinner(primaryColor, border);
      case NeoLoaderStyle.cubes:
        return _buildBouncingCubes(primaryColor, secColor, tertColor, border);
    }
  }

  Widget _buildPulsingDots(
    Color color,
    Color secColor,
    Color tertColor,
    Color border,
  ) {
    final dotSize = widget.size * 0.32;
    final spacing = widget.size * 0.12;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size * 1.4,
          height: widget.size,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final delay = index * 0.22;
              final progress = (_controller.value - delay) % 1.0;
              final sinVal = math.sin(progress * math.pi);
              final scale = 0.6 + (0.55 * (sinVal < 0 ? 0 : sinVal));
              final translateY = -4.0 * (sinVal < 0 ? 0 : sinVal);

              final dotColor = index == 0
                  ? color
                  : (index == 1 ? secColor : tertColor);

              return Transform.translate(
                offset: Offset(0, translateY),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    margin: EdgeInsets.symmetric(horizontal: spacing / 2),
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: border,
                        width: widget.strokeWidth,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: border,
                          offset: const Offset(1, 1),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildRotatingSpinner(Color color, Color border) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: NeoStyles.neoDecoration(
              backgroundColor: color,
              borderColor: border,
              radius: widget.size * 0.25,
              shadow: widget.size * 0.08,
            ),
            child: Center(
              child: Container(
                width: widget.size * 0.35,
                height: widget.size * 0.35,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(widget.size * 0.08),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBouncingCubes(
    Color color,
    Color secColor,
    Color tertColor,
    Color border,
  ) {
    final cubeSize = widget.size * 0.36;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size * 1.5,
          height: widget.size,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSingleCube(
                size: cubeSize,
                color: color,
                border: border,
                t: _controller.value,
              ),
              SizedBox(width: widget.size * 0.14),
              _buildSingleCube(
                size: cubeSize,
                color: secColor,
                border: border,
                t: (_controller.value + 0.33) % 1.0,
              ),
              SizedBox(width: widget.size * 0.14),
              _buildSingleCube(
                size: cubeSize,
                color: tertColor,
                border: border,
                t: (_controller.value + 0.66) % 1.0,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSingleCube({
    required double size,
    required Color color,
    required Color border,
    required double t,
  }) {
    final sinVal = math.sin(t * math.pi);
    final scale = 0.75 + (0.35 * (sinVal < 0 ? 0 : sinVal));
    final angle = (t * math.pi * 0.5);

    return Transform.scale(
      scale: scale,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size * 0.2),
            border: Border.all(color: border, width: widget.strokeWidth),
            boxShadow: [
              BoxShadow(
                color: border,
                offset: const Offset(1.5, 1.5),
                blurRadius: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
