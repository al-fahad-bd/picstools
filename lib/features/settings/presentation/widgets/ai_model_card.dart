import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_loader.dart';
import '../../../background_remover/domain/entities/ai_model_info.dart';

class AiModelCard extends StatelessWidget {
  final AiModelInfo? modelInfo;
  final bool isDark;
  final bool isDeleting;
  final VoidCallback onDeleteModel;

  const AiModelCard({
    super.key,
    required this.modelInfo,
    required this.isDark,
    this.isDeleting = false,
    required this.onDeleteModel,
  });

  @override
  Widget build(BuildContext context) {
    final isInstalled = modelInfo?.isDownloaded ?? false;
    final sizeText = modelInfo?.formattedActualSize ?? '~213 MB';

    return NeoCard(
      backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: NeoColors.purple,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: NeoColors.borderLight,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_fix_high_rounded,
                    size: 22,
                    color: NeoColors.lightSurface,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Background Remover',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'BiRefNet General Lite (v1.0.0)',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: isDark
                              ? NeoColors.textSecondaryDark
                              : NeoColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isInstalled
                              ? NeoColors.softGreen
                              : (isDark
                                    ? const Color(0xFF2E2E34)
                                    : const Color(0xFFEEEEF0)),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isInstalled
                                ? NeoColors.green
                                : NeoColors.borderLight,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isInstalled
                                  ? Icons.check_circle_rounded
                                  : Icons.cloud_download_outlined,
                              size: 13,
                              color: isInstalled
                                  ? NeoColors.borderLight
                                  : (isDark
                                        ? NeoColors.textSecondaryDark
                                        : NeoColors.textSecondaryLight),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isInstalled
                                  ? 'Downloaded ($sizeText)'
                                  : 'Not Installed',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isInstalled
                                    ? NeoColors.borderLight
                                    : (isDark
                                          ? NeoColors.textSecondaryDark
                                          : NeoColors.textSecondaryLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isInstalled) ...[
            const Divider(),
            InkWell(
              onTap: isDeleting
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: isDark
                              ? NeoColors.darkSurface
                              : NeoColors.lightSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDark
                                  ? NeoColors.borderDark
                                  : NeoColors.borderLight,
                              width: 2,
                            ),
                          ),
                          title: Text(
                            'Delete AI Model?',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? NeoColors.textPrimaryDark
                                  : NeoColors.textPrimaryLight,
                            ),
                          ),
                          content: Text(
                            'The BiRefNet Lite model file will be removed from your device. You can download it again whenever you use the Background Remover.',
                            style: GoogleFonts.spaceGrotesk(
                              color: isDark
                                  ? NeoColors.textSecondaryDark
                                  : NeoColors.textSecondaryLight,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? NeoColors.textSecondaryDark
                                      : NeoColors.textSecondaryLight,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NeoColors.red,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(
                                'Delete',
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        onDeleteModel();
                      }
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline_rounded,
                      color: NeoColors.red,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delete AI Model',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w900,
                              color: NeoColors.red,
                            ),
                          ),
                          Text(
                            'Free up disk space. You can download it again anytime.',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              color: isDark
                                  ? NeoColors.textSecondaryDark
                                  : NeoColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    isDeleting
                        ? const NeoLoader.button(
                            size: 16,
                            color: NeoColors.red,
                            secondaryColor: NeoColors.pink,
                            borderColor: NeoColors.red,
                          )
                        : const Icon(
                            Icons.chevron_right_rounded,
                            color: NeoColors.red,
                          ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
