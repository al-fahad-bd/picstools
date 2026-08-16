import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/file_save_service.dart';
import '../../bloc/signature_bloc.dart';
import '../../services/signature_service.dart';
import 'checkered_pattern_painter.dart';

class SignatureSuccessView extends StatelessWidget {
  final SignatureSuccessState state;
  final bool isDark;
  final VoidCallback onCreateNew;

  const SignatureSuccessView({
    super.key,
    required this.state,
    required this.isDark,
    required this.onCreateNew,
  });

  Future<void> _saveSignatureMultiple(
    BuildContext context,
    List<File> files,
    String label,
  ) async {
    final saver = getIt<FileSaveService>();
    for (final f in files) {
      await saver.saveFileToPublicStorage(
        sourceFile: f,
        subFolder: 'Signatures',
      );
    }
    if (context.mounted) {
      NeoToast.showSuccess(
        context,
        '🎉 Saved $label to Gallery & Files!',
        icon: Icons.draw_rounded,
      );
    }
  }

  void _showSaveOptionsModal(
    BuildContext context,
    SignatureExportResult res,
  ) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(
                color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
                width: 2.5,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Save Signature Options',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select format option to download to your device',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: isDark
                          ? NeoColors.textSecondaryDark
                          : NeoColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.cyan,
                        radius: 10,
                        shadow: 1.5,
                      ),
                      child: const Icon(
                        Icons.texture_rounded,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    title: Text(
                      'Transparent PNG',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Ideal for overlaying on documents & dark backgrounds',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _saveSignatureMultiple(context, [
                        res.transparentPngFile,
                      ], 'Transparent PNG');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.yellow,
                        radius: 10,
                        shadow: 1.5,
                      ),
                      child: const Icon(
                        Icons.crop_square_rounded,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    title: Text(
                      'White Background Only (JPG)',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Ideal for forms, printing & official records',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _saveSignatureMultiple(context, [
                        res.solidBackgroundFile,
                      ], 'White Background Signature');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.green,
                        radius: 10,
                        shadow: 1.5,
                      ),
                      child: const Icon(
                        Icons.style_rounded,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    title: Text(
                      'Save Both Versions (Transparent & White)',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Downloads Transparent PNG & White JPG',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _saveSignatureMultiple(context, [
                        res.transparentPngFile,
                        res.solidBackgroundFile,
                      ], 'Both Signature Formats');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showShareOptionsModal(
    BuildContext context,
    SignatureExportResult res,
  ) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(
                color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
                width: 2.5,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share Signature Options',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select which signature format you want to share',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: isDark
                          ? NeoColors.textSecondaryDark
                          : NeoColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.cyan,
                        radius: 10,
                        shadow: 1.5,
                      ),
                      child: const Icon(
                        Icons.texture_rounded,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    title: Text(
                      'Share Transparent PNG Only',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Transparent background signature',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      final box = context.findRenderObject() as RenderBox?;
                      final origin = box != null
                          ? box.localToGlobal(Offset.zero) & box.size
                          : null;
                      Share.shareXFiles(
                        [XFile(res.transparentPngFile.path)],
                        text: 'Transparent Digital Signature',
                        sharePositionOrigin: origin,
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.yellow,
                        radius: 10,
                        shadow: 1.5,
                      ),
                      child: const Icon(
                        Icons.crop_square_rounded,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    title: Text(
                      'Share White Background Only (JPG)',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Guaranteed visibility on all apps & documents',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      final box = context.findRenderObject() as RenderBox?;
                      final origin = box != null
                          ? box.localToGlobal(Offset.zero) & box.size
                          : null;
                      Share.shareXFiles(
                        [XFile(res.solidBackgroundFile.path)],
                        text: 'White Background Signature',
                        sharePositionOrigin: origin,
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.green,
                        radius: 10,
                        shadow: 1.5,
                      ),
                      child: const Icon(
                        Icons.style_rounded,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    title: Text(
                      'Share Both Formats',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Shares Transparent PNG & White JPG',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      final box = context.findRenderObject() as RenderBox?;
                      final origin = box != null
                          ? box.localToGlobal(Offset.zero) & box.size
                          : null;
                      Share.shareXFiles(
                        [
                          XFile(res.transparentPngFile.path),
                          XFile(res.solidBackgroundFile.path),
                        ],
                        text: 'Digital Signatures (Transparent & White BG)',
                        sharePositionOrigin: origin,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImagePreviewDialog(
    BuildContext context,
    File imageFile,
    String title,
  ) {
    String bgMode = title.contains('Transparent') ? 'checkered' : 'white';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            Widget bgWidget;
            if (bgMode == 'dark') {
              bgWidget = Container(color: const Color(0xFF0F172A));
            } else if (bgMode == 'white') {
              bgWidget = Container(color: Colors.white);
            } else {
              bgWidget = CustomPaint(
                painter: CheckeredPatternPainter(squareSize: 12),
              );
            }

            return Dialog(
              backgroundColor: isDark
                  ? NeoColors.darkSurface
                  : NeoColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
                  width: 2.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(dialogCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (title.contains('Transparent'))
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Preview Background: ',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            ChoiceChip(
                              label: const Text(
                                'Checkered',
                                style: TextStyle(fontSize: 10),
                              ),
                              selected: bgMode == 'checkered',
                              onSelected: (val) {
                                if (val) {
                                  setModalState(() => bgMode = 'checkered');
                                }
                              },
                            ),
                            const SizedBox(width: 4),
                            ChoiceChip(
                              label: const Text(
                                'Dark Mode',
                                style: TextStyle(fontSize: 10),
                              ),
                              selected: bgMode == 'dark',
                              selectedColor: NeoColors.yellow,
                              onSelected: (val) {
                                if (val) setModalState(() => bgMode = 'dark');
                              },
                            ),
                            const SizedBox(width: 4),
                            ChoiceChip(
                              label: const Text(
                                'White',
                                style: TextStyle(fontSize: 10),
                              ),
                              selected: bgMode == 'white',
                              onSelected: (val) {
                                if (val) setModalState(() => bgMode = 'white');
                              },
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),

                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: NeoColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            Positioned.fill(child: bgWidget),
                            Positioned.fill(
                              child: InteractiveViewer(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Image.file(
                                    imageFile,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final res = state.result;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          NeoCard(
            backgroundColor: NeoColors.softYellow,
            shadowOffset: 5,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const NeoBadge(
                  label: 'SIGNATURE READY',
                  backgroundColor: NeoColors.yellow,
                  fontSize: 12,
                ),
                const SizedBox(height: 12),
                Text(
                  '${res.widthPx} x ${res.heightPx} px (Auto-Cropped)',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.borderLight,
                  ),
                ),
                Text(
                  'File Size: ${FileUtils.formatBytes(res.fileSizeBytes)}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: NeoColors.borderLight.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Dual Previews: Transparent & White Background
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Transparent PNG',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    NeoCard(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      shadowOffset: 3,
                      onTap: () => _showImagePreviewDialog(
                        context,
                        res.transparentPngFile,
                        'Transparent PNG Signature',
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: CheckeredPatternPainter(
                                    squareSize: 8,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.file(
                                    res.transparentPngFile,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'White Background',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    NeoCard(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      shadowOffset: 3,
                      onTap: () => _showImagePreviewDialog(
                        context,
                        res.solidBackgroundFile,
                        'White Background Signature',
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.file(
                              res.solidBackgroundFile,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          NeoButton(
            label: 'SAVE TO DEVICE',
            icon: const Icon(
              Icons.download_rounded,
              color: NeoColors.borderLight,
            ),
            backgroundColor: NeoColors.green,
            fullWidth: true,
            onPressed: () => _showSaveOptionsModal(context, res),
          ),
          const SizedBox(height: 12),
          NeoButton(
            label: 'SHARE SIGNATURE',
            icon: const Icon(Icons.share_rounded, color: NeoColors.borderLight),
            backgroundColor: NeoColors.yellow,
            fullWidth: true,
            onPressed: () => _showShareOptionsModal(context, res),
          ),
          const SizedBox(height: 12),
          NeoButton(
            label: 'CREATE NEW SIGNATURE',
            icon: const Icon(
              Icons.refresh_rounded,
              color: NeoColors.borderLight,
            ),
            backgroundColor: NeoColors.cyan,
            fullWidth: true,
            onPressed: onCreateNew,
          ),
        ],
      ),
    );
  }
}
