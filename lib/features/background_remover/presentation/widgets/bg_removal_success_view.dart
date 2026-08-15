import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../domain/entities/background_removal_result.dart';
import 'preview_mode_tabs.dart';
import 'comparison_slider.dart';
import 'checkerboard_container.dart';

class BgRemovalSuccessView extends StatelessWidget {
  final BackgroundRemovalResult result;
  final int previewMode;
  final bool isDark;
  final bool isSaving;
  final ValueChanged<int> onSelectMode;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onReset;

  const BgRemovalSuccessView({
    super.key,
    required this.result,
    required this.previewMode,
    required this.isDark,
    required this.isSaving,
    required this.onSelectMode,
    required this.onSave,
    required this.onShare,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? NeoColors.borderDark : NeoColors.borderLight;
    final origKb = (result.originalSizeBytes / 1024).toStringAsFixed(1);
    final pngKb = (result.processedSizeBytes / 1024).toStringAsFixed(1);
    final durMs = result.duration.inMilliseconds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview Mode Toggle Tabs
        PreviewModeTabs(
          selectedIndex: previewMode,
          isDark: isDark,
          onSelectMode: onSelectMode,
        ),
        const SizedBox(height: 14),

        // Main Image Canvas Area
        if (previewMode == 0) ...[
          ComparisonSlider(
            originalImage: result.originalFile,
            transparentImage: result.transparentPngFile,
            height: 360,
          ),
        ] else if (previewMode == 1) ...[
          CheckerboardContainer(
            borderRadius: 16,
            borderColor: borderColor,
            child: SizedBox(
              height: 360,
              width: double.infinity,
              child: Image.file(result.transparentPngFile, fit: BoxFit.contain),
            ),
          ),
        ] else ...[
          Container(
            height: 360,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: NeoStyles.neoShadow(
                shadowColor: isDark ? NeoColors.borderDark : borderColor,
                offset: NeoStyles.shadowOffset,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(result.originalFile, fit: BoxFit.contain),
            ),
          ),
        ],
        const SizedBox(height: 14),

        // Metrics Info Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF24242A) : NeoColors.softCyan,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 15,
                    color: NeoColors.blue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${durMs}ms inference',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: isDark ? NeoColors.cyan : NeoColors.borderLight,
                    ),
                  ),
                ],
              ),
              Text(
                '${result.width} × ${result.height} px',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? NeoColors.textSecondaryDark
                      : NeoColors.textSecondaryLight,
                ),
              ),
              Text(
                '$origKb KB → $pngKb KB',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? NeoColors.green : NeoColors.borderLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Primary Action: Save PNG
        NeoButton(
          label: isSaving ? 'Saving PNG...' : 'Save Transparent PNG',
          icon: const Icon(
            Icons.file_download_rounded,
            size: 18,
            color: NeoColors.borderLight,
          ),
          backgroundColor: NeoColors.yellow,
          textColor: NeoColors.borderLight,
          isLoading: isSaving,
          fullWidth: true,
          onPressed: onSave,
        ),
        const SizedBox(height: 10),

        // Secondary Action: Share & Remove Another
        Row(
          children: [
            Expanded(
              child: NeoButton(
                label: 'Share PNG',
                icon: const Icon(
                  Icons.share_rounded,
                  size: 18,
                  color: NeoColors.borderLight,
                ),
                backgroundColor: NeoColors.cyan,
                textColor: NeoColors.borderLight,
                onPressed: onShare,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: NeoButton(
                label: 'New Photo',
                icon: Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 18,
                  color: isDark
                      ? NeoColors.textPrimaryDark
                      : NeoColors.textPrimaryLight,
                ),
                backgroundColor: isDark
                    ? const Color(0xFF26262B)
                    : NeoColors.lightSurface,
                textColor: isDark
                    ? NeoColors.textPrimaryDark
                    : NeoColors.textPrimaryLight,
                onPressed: onReset,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
