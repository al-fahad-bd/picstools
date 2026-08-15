import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/neo_colors.dart';
import '../constants/neo_styles.dart';
import '../services/service_locator.dart';
import '../services/sound_service.dart';

class NeoBackButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const NeoBackButton({
    super.key,
    this.onPressed,
  });

  @override
  State<NeoBackButton> createState() => _NeoBackButtonState();
}

class _NeoBackButtonState extends State<NeoBackButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
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

  void _handlePress() {
    try {
      getIt<SoundService>().playClickSound();
    } catch (_) {}
    
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final currentOffset = _isPressed ? 1.0 : 2.0;
    final transformTranslation = _isPressed ? 1.0 : 0.0;

    return Center(
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _handlePress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          transform: Matrix4.translationValues(transformTranslation, transformTranslation, 0),
          padding: const EdgeInsets.all(6),
          decoration: NeoStyles.neoDecoration(
            backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
            borderColor: isDark ? NeoColors.borderDark : NeoColors.borderLight,
            radius: 10,
            shadow: currentOffset,
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 18,
            color: isDark ? NeoColors.textPrimaryDark : NeoColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }
}
