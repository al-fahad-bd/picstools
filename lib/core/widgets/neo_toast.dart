import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/neo_colors.dart';
import '../constants/neo_styles.dart';

class NeoToast {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show(
    BuildContext context,
    String message, {
    Color color = NeoColors.green,
    Color? textColor,
    IconData icon = Icons.check_circle_rounded,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    _dismissTimer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;

    final resolvedTextColor = textColor ?? NeoColors.getContrastColor(color);

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
          duration: duration,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: NeoStyles.neoDecoration(
              backgroundColor: color,
              radius: 16,
              shadow: 4,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: resolvedTextColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: resolvedTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _TopToastOverlayWidget(
        message: message,
        color: color,
        textColor: resolvedTextColor,
        icon: icon,
        onDismiss: () {
          if (_currentEntry == entry) {
            _currentEntry?.remove();
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(duration, () {
      if (_currentEntry == entry) {
        _currentEntry?.remove();
        _currentEntry = null;
      }
    });
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    IconData icon = Icons.download_done_rounded,
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    show(
      context,
      message,
      color: NeoColors.green,
      icon: icon,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    IconData icon = Icons.error_outline_rounded,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    show(
      context,
      message,
      color: NeoColors.pink,
      icon: icon,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Color color = NeoColors.blue,
    IconData icon = Icons.info_outline_rounded,
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    show(context, message, color: color, icon: icon, duration: duration);
  }
}

class _TopToastOverlayWidget extends StatefulWidget {
  final String message;
  final Color color;
  final Color textColor;
  final IconData icon;
  final VoidCallback onDismiss;

  const _TopToastOverlayWidget({
    required this.message,
    required this.color,
    required this.textColor,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<_TopToastOverlayWidget> createState() => _TopToastOverlayWidgetState();
}

class _TopToastOverlayWidgetState extends State<_TopToastOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 10,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: NeoStyles.neoDecoration(
                  backgroundColor: widget.color,
                  radius: 16,
                  shadow: 4,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(widget.icon, size: 20, color: widget.textColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: widget.textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: widget.textColor.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
