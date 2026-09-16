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
    VoidCallback? onTap,
    String? actionLabel,
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
          content: InkWell(
            onTap: () {
              messenger.hideCurrentSnackBar();
              onTap?.call();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
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
                  if (actionLabel != null || onTap != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: resolvedTextColor.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            actionLabel ?? 'OPEN',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: resolvedTextColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: resolvedTextColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
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
        actionLabel: actionLabel,
        onTap: onTap != null
            ? () {
                if (_currentEntry == entry) {
                  _currentEntry?.remove();
                  _currentEntry = null;
                }
                onTap();
              }
            : null,
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
    Duration duration = const Duration(milliseconds: 3200),
    VoidCallback? onTap,
    String? actionLabel,
  }) {
    show(
      context,
      message,
      color: NeoColors.green,
      icon: icon,
      duration: duration,
      onTap: onTap,
      actionLabel: actionLabel,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    IconData icon = Icons.error_outline_rounded,
    Duration duration = const Duration(milliseconds: 3500),
    VoidCallback? onTap,
    String? actionLabel,
  }) {
    show(
      context,
      message,
      color: NeoColors.pink,
      icon: icon,
      duration: duration,
      onTap: onTap,
      actionLabel: actionLabel,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Color color = NeoColors.blue,
    IconData icon = Icons.info_outline_rounded,
    Duration duration = const Duration(milliseconds: 3000),
    VoidCallback? onTap,
    String? actionLabel,
  }) {
    show(
      context,
      message,
      color: color,
      icon: icon,
      duration: duration,
      onTap: onTap,
      actionLabel: actionLabel,
    );
  }
}

class _TopToastOverlayWidget extends StatefulWidget {
  final String message;
  final Color color;
  final Color textColor;
  final IconData icon;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;
  final String? actionLabel;

  const _TopToastOverlayWidget({
    required this.message,
    required this.color,
    required this.textColor,
    required this.icon,
    required this.onDismiss,
    this.onTap,
    this.actionLabel,
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
              onTap: () {
                if (widget.onTap != null) {
                  widget.onTap!();
                } else {
                  widget.onDismiss();
                }
              },
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
                    if (widget.onTap != null || widget.actionLabel != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.textColor.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.actionLabel ?? 'OPEN',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: widget.textColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 13,
                              color: widget.textColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onDismiss,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: widget.textColor.withValues(alpha: 0.6),
                        ),
                      ),
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
