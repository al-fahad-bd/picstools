import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/neo_colors.dart';
import '../constants/neo_styles.dart';

class NeoButton extends StatefulWidget {
  final String? label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double borderRadius;
  final double shadowOffset;
  final EdgeInsetsGeometry padding;
  final bool fullWidth;
  final bool isLoading;

  const NeoButton({
    super.key,
    this.label,
    this.icon,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius = NeoStyles.borderRadius,
    this.shadowOffset = NeoStyles.shadowOffset,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.fullWidth = false,
    this.isLoading = false,
  }) : assert(label != null || icon != null, 'Button must have either label or icon');

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
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
    final defaultBg = widget.backgroundColor ?? NeoColors.yellow;
    final defaultText =
        widget.textColor ?? NeoColors.getContrastColor(defaultBg);
    final defaultBorder = widget.borderColor ??
        (isDark ? NeoColors.borderDark : NeoColors.borderLight);

    final currentOffset = _isPressed ? 1.0 : widget.shadowOffset;
    final transformTranslation = _isPressed ? widget.shadowOffset - 1.0 : 0.0;

    Widget content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(defaultText),
            ),
          ),
          if (widget.label != null) const SizedBox(width: 10),
        ] else if (widget.icon != null) ...[
          widget.icon!,
          if (widget.label != null) const SizedBox(width: 8),
        ],
        if (widget.label != null && !widget.isLoading)
          Flexible(
            child: Text(
              widget.label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: defaultText,
              ),
            ),
          ),
      ],
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(transformTranslation, transformTranslation, 0),
        padding: widget.padding,
        decoration: NeoStyles.neoDecoration(
          backgroundColor: widget.onPressed == null ? Colors.grey.shade400 : defaultBg,
          borderColor: defaultBorder,
          radius: widget.borderRadius,
          shadow: currentOffset,
        ),
        child: content,
      ),
    );
  }
}
