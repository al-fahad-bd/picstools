import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/neo_colors.dart';
import '../constants/neo_styles.dart';
import '../services/remote_config_service.dart';

class AppUpdateDialog extends StatelessWidget {
  final AppUpdateInfo updateInfo;

  const AppUpdateDialog({
    super.key,
    required this.updateInfo,
  });

  static Future<void> show(
    BuildContext context,
    AppUpdateInfo updateInfo,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: !updateInfo.isForceUpdate,
      builder: (context) => AppUpdateDialog(updateInfo: updateInfo),
    );
  }

  Future<void> _openStore(BuildContext context) async {
    if (updateInfo.storeUrl.isEmpty) return;
    try {
      final uri = Uri.parse(updateInfo.storeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch store URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? NeoColors.borderDark : NeoColors.borderLight;
    final surfaceColor = isDark ? NeoColors.darkSurface : NeoColors.lightSurface;
    final textPrimary =
        isDark ? NeoColors.textPrimaryDark : NeoColors.textPrimaryLight;
    final textSecondary =
        isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight;

    return PopScope(
      canPop: !updateInfo.isForceUpdate,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: NeoStyles.neoDecoration(
            backgroundColor: surfaceColor,
            borderColor: borderColor,
            radius: 20,
            shadow: 6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Icon Badge
              Container(
                width: 64,
                height: 64,
                decoration: NeoStyles.neoDecoration(
                  backgroundColor: updateInfo.isForceUpdate
                      ? NeoColors.pink
                      : NeoColors.yellow,
                  borderColor: borderColor,
                  radius: 16,
                  shadow: 3,
                ),
                child: Icon(
                  updateInfo.isForceUpdate
                      ? Icons.system_update_rounded
                      : Icons.rocket_launch_rounded,
                  color: NeoColors.borderLight,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                updateInfo.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),

              // Version Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isDark ? NeoColors.cyan : NeoColors.softCyan)
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? NeoColors.cyan : NeoColors.borderLight,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'v${updateInfo.targetVersion}',
                  style: GoogleFonts.firaCode(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? NeoColors.cyan : NeoColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Message
              Text(
                updateInfo.message,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Primary Update Now Button
                  GestureDetector(
                    onTap: () => _openStore(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.green,
                        borderColor: borderColor,
                        radius: 14,
                        shadow: 4,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.download_rounded,
                            color: NeoColors.borderLight,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Update Now',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: NeoColors.borderLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Optional "Later" Button
                  if (!updateInfo.isForceUpdate) ...[
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'Later',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
