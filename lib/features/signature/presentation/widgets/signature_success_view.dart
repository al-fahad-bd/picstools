import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/widgets/neo_crop_canvas.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/file_save_service.dart';
import '../../bloc/signature_bloc.dart';
import '../../services/signature_service.dart';
import 'checkered_pattern_painter.dart';
import 'neo_rotation_control.dart';

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

  void _showSaveOptionsModal(BuildContext context, SignatureExportResult res) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
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
                    _buildModalFormatTile(
                      leadingIcon: Container(
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
                      title: 'Transparent PNG',
                      subtitle: 'Ideal for overlaying on documents & dark backgrounds',
                      onTap: () {
                        Navigator.pop(ctx);
                        _saveSignatureMultiple(context, [
                          res.transparentPngFile,
                        ], 'Transparent PNG');
                      },
                    ),
                    const Divider(),
                    _buildModalFormatTile(
                      leadingIcon: Container(
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
                      title: 'White Background Only (JPG)',
                      subtitle: 'Ideal for forms, printing & official records',
                      onTap: () {
                        Navigator.pop(ctx);
                        _saveSignatureMultiple(context, [
                          res.solidBackgroundFile,
                        ], 'White Background Signature');
                      },
                    ),
                    const Divider(),
                    _buildModalFormatTile(
                      leadingIcon: Container(
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
                      title: 'Save Both Versions (Transparent & White)',
                      subtitle: 'Downloads Transparent PNG & White JPG',
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
          ),
        );
      },
    );
  }

  void _showShareOptionsModal(BuildContext context, SignatureExportResult res) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
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
                    _buildModalFormatTile(
                      leadingIcon: Container(
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
                      title: 'Share Transparent PNG Only',
                      subtitle: 'Transparent background signature',
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
                    _buildModalFormatTile(
                      leadingIcon: Container(
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
                      title: 'Share White Background Only (JPG)',
                      subtitle: 'Guaranteed visibility on all apps & documents',
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
                    _buildModalFormatTile(
                      leadingIcon: Container(
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
                      title: 'Share Both Formats',
                      subtitle: 'Shares Transparent PNG & White JPG',
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
                          text: 'Digital Signature Files (Transparent & White)',
                          sharePositionOrigin: origin,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalFormatTile({
    required Widget leadingIcon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            leadingIcon,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark
                          ? NeoColors.textPrimaryDark
                          : NeoColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
              size: 20,
            ),
          ],
        ),
      ),
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

  void _showCropRotateModal(BuildContext context, SignatureExportResult res) {
    double baseRotation90 = 0.0;
    double fineAngle = 0.0;
    Rect normCropRect = const Rect.fromLTWH(0.02, 0.02, 0.96, 0.96);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final totalAngle = baseRotation90 + fineAngle;
            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crop & Rotate Signature',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Trim unwanted parts and align orientation',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: isDark
                                  ? NeoColors.textSecondaryDark
                                  : NeoColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Crop canvas on transparent PNG
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? NeoColors.borderDark
                              : NeoColors.borderLight,
                          width: 2,
                        ),
                        color: isDark
                            ? Colors.black38
                            : const Color(0xFFE2E8F0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: CheckeredPatternPainter(
                                  squareSize: 10,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: NeoCropCanvas(
                                imageFile: res.transparentPngFile,
                                rotationAngle: totalAngle,
                                initialNormCropRect: normCropRect,
                                onCropChanged: (rect) {
                                  normCropRect = rect;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Continuous Rotation & Straightening Panel
                  NeoRotationControl(
                    baseRotation90: baseRotation90,
                    fineAngle: fineAngle,
                    isDark: isDark,
                    onFineAngleChanged: (val) {
                      setModalState(() => fineAngle = val);
                    },
                    onRotate90: () {
                      setModalState(() {
                        baseRotation90 = (baseRotation90 + 90.0) % 360.0;
                      });
                    },
                    onReset: () {
                      setModalState(() {
                        baseRotation90 = 0.0;
                        fineAngle = 0.0;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Apply changes button
                  NeoButton(
                    label: 'APPLY CHANGES',
                    icon: const Icon(
                      Icons.check_rounded,
                      color: NeoColors.borderLight,
                    ),
                    backgroundColor: NeoColors.green,
                    fullWidth: true,
                    onPressed: () {
                      Navigator.pop(modalCtx);
                      context.read<SignatureBloc>().add(
                        AdjustSignatureEvent(
                          cropXRatio: normCropRect.left,
                          cropYRatio: normCropRect.top,
                          cropWidthRatio: normCropRect.width,
                          cropHeightRatio: normCropRect.height,
                          rotationAngle: totalAngle,
                        ),
                      );
                    },
                  ),
                ],
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
          const SizedBox(height: 24),

          // Crop & Rotate Action Button
          NeoButton(
            label: 'CROP & ROTATE SIGNATURE',
            icon: const Icon(
              Icons.crop_rotate_rounded,
              color: NeoColors.borderLight,
            ),
            backgroundColor: NeoColors.pink,
            fullWidth: true,
            onPressed: () => _showCropRotateModal(context, res),
          ),
          const SizedBox(height: 12),

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
