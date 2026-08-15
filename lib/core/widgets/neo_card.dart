import 'package:flutter/material.dart';
import '../constants/neo_colors.dart';
import '../constants/neo_styles.dart';
import '../services/service_locator.dart';
import '../services/sound_service.dart';

class NeoCard extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double shadowOffset;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final bool showShadow;

  const NeoCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = NeoStyles.borderRadius,
    this.shadowOffset = NeoStyles.shadowOffset,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.showShadow = true,
  });

  @override
  State<NeoCard> createState() => _NeoCardState();
}

class _NeoCardState extends State<NeoCard> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? NeoColors.darkSurface : NeoColors.lightSurface;
    final defaultBorder = isDark ? NeoColors.borderDark : NeoColors.borderLight;

    final currentOffset = _isPressed ? 1.0 : widget.shadowOffset;
    final transformTranslation = _isPressed ? widget.shadowOffset - 1.0 : 0.0;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      transform: Matrix4.translationValues(transformTranslation, transformTranslation, 0),
      margin: widget.margin,
      padding: widget.padding,
      decoration: NeoStyles.neoDecoration(
        backgroundColor: widget.backgroundColor ?? defaultBg,
        borderColor: widget.borderColor ?? defaultBorder,
        radius: widget.borderRadius,
        shadow: currentOffset,
        showShadow: widget.showShadow,
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          try {
            getIt<SoundService>().playClickSound();
          } catch (_) {}
          widget.onTap!();
        },
        child: card,
      );
    }

    return card;
  }
}
