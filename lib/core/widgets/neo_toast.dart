import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/neo_colors.dart';
import '../constants/neo_styles.dart';

class NeoToast {
  static void show(
    BuildContext context,
    String message, {
    Color color = NeoColors.green,
    Color? textColor,
    IconData icon = Icons.check_circle_rounded,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final resolvedTextColor = textColor ?? NeoColors.getContrastColor(color);

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
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    IconData icon = Icons.download_done_rounded,
    Duration duration = const Duration(milliseconds: 2500),
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
    Duration duration = const Duration(milliseconds: 3000),
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
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    show(context, message, color: color, icon: icon, duration: duration);
  }
}
