import 'dart:async';
import 'package:flutter/scheduler.dart';
import '../../../../core/widgets/neo_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_crop_canvas.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/file_save_service.dart';
import '../../models/id_photo_preset.dart';
import '../../services/id_photo_service.dart';
import '../../bloc/id_photo_bloc.dart';
import '../widgets/face_guide_overlay.dart';
import '../../../background_remover/domain/usecases/check_model_status_usecase.dart';
import '../../../background_remover/domain/usecases/download_model_usecase.dart';

class IdPhotoView extends StatelessWidget {
  const IdPhotoView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          IdPhotoBloc(idPhotoService: getIt(), historyService: getIt()),
      child: const _IdPhotoViewContent(),
    );
  }
}

class _IdPhotoViewContent extends StatelessWidget {
  const _IdPhotoViewContent();

  Future<void> _pickImage(
    BuildContext context,
    ImageSource source, {
    IdPhotoPreset? preset,
  }) async {
    final picker = getIt<ImagePickerService>();
    final bloc = context.read<IdPhotoBloc>();
    final file = await picker.pickSingleImage(source: source);
    if (file != null) {
      bloc.add(SelectPhotoEvent(file, preset: preset));
    }
  }

  void _showPresetDetailsSheet(
    BuildContext context,
    IdPhotoPreset preset,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
              width: 2.5,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NeoBadge(
                        label: preset.country,
                        backgroundColor: NeoColors.orange,
                        fontSize: 12,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: NeoStyles.neoDecoration(
                          backgroundColor: NeoColors.yellow,
                          radius: 6,
                          shadow: 1,
                        ),
                        child: Text(
                          '${preset.widthMm.round()} x ${preset.heightMm.round()} mm',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: NeoColors.borderLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    preset.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    preset.description,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: isDark
                          ? NeoColors.textSecondaryDark
                          : NeoColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'High-Res @ 300 DPI: ${preset.targetWidthPx} × ${preset.targetHeightPx} px',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.orange,
                    ),
                  ),
                  const SizedBox(height: 20),
                  NeoButton(
                    label: 'Pick from Gallery',
                    icon: const Icon(
                      Icons.photo_library_rounded,
                      color: NeoColors.borderLight,
                      size: 20,
                    ),
                    backgroundColor: NeoColors.softOrange,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    onPressed: () {
                      Navigator.pop(modalContext);
                      _pickImage(context, ImageSource.gallery, preset: preset);
                    },
                  ),
                  const SizedBox(height: 10),
                  NeoButton(
                    label: 'Take with Camera',
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: NeoColors.borderLight,
                      size: 20,
                    ),
                    backgroundColor: NeoColors.softYellow,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    onPressed: () {
                      Navigator.pop(modalContext);
                      _pickImage(context, ImageSource.camera, preset: preset);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const NeoBackButton(),
        title: Text(
          'Passport & ID Photo Maker',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<IdPhotoBloc, IdPhotoState>(
          listener: (context, state) {
            if (state is IdPhotoErrorState) {
              NeoToast.showError(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is IdPhotoInitialState) {
              return _buildEmptyState(context, isDark);
            } else if (state is IdPhotoConfiguredState) {
              return _buildConfigurationState(context, state, isDark);
            } else if (state is IdPhotoProcessingState) {
              return _buildProcessingState(context, isDark);
            } else if (state is IdPhotoSuccessState) {
              return _buildSuccessState(context, state, isDark);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: NeoStyles.neoDecoration(
              backgroundColor: NeoColors.orange,
              radius: 50,
              shadow: 5,
            ),
            child: const Icon(
              Icons.badge_rounded,
              size: 50,
              color: NeoColors.borderLight,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Passport & ID Photo Creator',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate official biometric ID photos with face alignment guides, custom backgrounds & printable 4x6" photo sheets.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: isDark
                  ? NeoColors.textSecondaryDark
                  : NeoColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 28),

          // Preset Standards Showcase Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Supported Passport Standards',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.sync_rounded,
                    size: 14,
                    color: NeoColors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Auto-scrolling',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SeamlessPresetCarousel(
            presets: IdPhotoPreset.defaultPresets,
            isDark: isDark,
            onPresetTap: (preset) =>
                _showPresetDetailsSheet(context, preset, isDark),
          ),
          const SizedBox(height: 32),

          // Pickers
          NeoCard(
            backgroundColor: NeoColors.softOrange,
            shadowOffset: 4,
            onTap: () => _pickImage(context, ImageSource.gallery),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.orange,
                    radius: 12,
                    shadow: 2,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: NeoColors.borderLight,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Photo from Gallery',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                      Text(
                        'Select an existing portrait photo',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: NeoColors.borderLight.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: NeoColors.borderLight,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          NeoCard(
            backgroundColor: NeoColors.softYellow,
            shadowOffset: 4,
            onTap: () => _pickImage(context, ImageSource.camera),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.yellow,
                    radius: 12,
                    shadow: 2,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: NeoColors.borderLight,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Take Portrait with Camera',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                      Text(
                        'Snap a fresh passport photo',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: NeoColors.borderLight.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: NeoColors.borderLight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationState(
    BuildContext context,
    IdPhotoConfiguredState state,
    bool isDark,
  ) {
    final bloc = context.read<IdPhotoBloc>();
    final bgColors = [
      {'name': 'White', 'color': Colors.white},
      {'name': 'Light Blue', 'color': const Color(0xFFE6F0FA)},
      {'name': 'Blue', 'color': const Color(0xFF0055FF)},
      {'name': 'Off-White', 'color': const Color(0xFFF0F0F0)},
    ];

    return Column(
      children: [
        // Interactive Face Alignment Canvas with Guide Overlay
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: NeoCard(
              backgroundColor: isDark
                  ? NeoColors.darkSurface
                  : NeoColors.lightSurface,
              padding: const EdgeInsets.all(4),
              shadowOffset: 4,
              child: Stack(
                children: [
                  NeoCropCanvas(
                    imageFile: state.file,
                    aspectRatio: state.preset.aspectRatio,
                    rotationAngle: state.rotationAngle,
                    onCropChanged: (rect) {
                      bloc.add(UpdateNormCropRectIdEvent(rect));
                    },
                  ),
                  const FaceGuideOverlay(),
                ],
              ),
            ),
          ),
        ),

        // Controls Sheet
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
              width: 2.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preset Standard Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Preset Standard:',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<IdPhotoPreset>(
                    value: state.preset,
                    dropdownColor: isDark
                        ? NeoColors.darkSurface
                        : NeoColors.lightSurface,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? NeoColors.textPrimaryDark
                          : NeoColors.textPrimaryLight,
                    ),
                    items: IdPhotoPreset.defaultPresets.map((p) {
                      return DropdownMenuItem<IdPhotoPreset>(
                        value: p,
                        child: Text(
                          '${p.country} (${p.widthMm.round()}x${p.heightMm.round()}mm)',
                        ),
                      );
                    }).toList(),
                    onChanged: (p) {
                      if (p != null) bloc.add(SelectPresetEvent(p));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Background Color Options
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Background Color:',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: state.bgColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? NeoColors.borderDark
                                : NeoColors.borderLight,
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          bgColors.firstWhere(
                                (b) => b['color'] == state.bgColor,
                                orElse: () => bgColors.first,
                              )['name']
                              as String,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: NeoColors.getContrastColor(state.bgColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: bgColors.map((bg) {
                        final c = bg['color'] as Color;
                        final isSelected = state.bgColor == c;
                        final textColor = NeoColors.getContrastColor(c);
                        return GestureDetector(
                          onTap: () => bloc.add(SetBackgroundColorEvent(c)),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: NeoStyles.neoDecoration(
                              backgroundColor: c,
                              radius: 8,
                              shadow: isSelected ? 4 : 1,
                              borderColor: isSelected
                                  ? (isDark
                                        ? Colors.white
                                        : NeoColors.borderLight)
                                  : (isDark
                                        ? NeoColors.borderDark.withValues(
                                            alpha: 0.5,
                                          )
                                        : Colors.grey[400]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: textColor,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  bg['name'] as String,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Print Sheet Format Selector
              Row(
                children: [
                  Expanded(
                    child: _buildSheetChip(
                      label: 'Single Photo',
                      isSelected: state.sheetType == PrintSheetType.single,
                      onTap: () => bloc.add(
                        const SetPrintSheetTypeEvent(PrintSheetType.single),
                      ),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSheetChip(
                      label: '4x6" (6 Photos)',
                      isSelected: state.sheetType == PrintSheetType.sheet4x6,
                      onTap: () => bloc.add(
                        const SetPrintSheetTypeEvent(PrintSheetType.sheet4x6),
                      ),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSheetChip(
                      label: 'A4 (24 Photos)',
                      isSelected: state.sheetType == PrintSheetType.sheetA4,
                      onTap: () => bloc.add(
                        const SetPrintSheetTypeEvent(PrintSheetType.sheetA4),
                      ),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              NeoButton(
                label: 'GENERATE PASSPORT PHOTO & SHEET',
                icon: const Icon(
                  Icons.badge_rounded,
                  color: NeoColors.borderLight,
                ),
                backgroundColor: NeoColors.orange,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: () async {
                  final hasModel = await _ensureAiModelDownloaded(
                    context,
                    isDark,
                  );
                  if (!hasModel) return;
                  if (context.mounted) {
                    bloc.add(StartProcessingIdPhotoEvent());
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> _ensureAiModelDownloaded(
    BuildContext context,
    bool isDark,
  ) async {
    final checkModelUseCase = getIt<CheckModelStatusUseCase>();
    final downloadModelUseCase = getIt<DownloadModelUseCase>();

    final modelInfo = await checkModelUseCase();
    if (modelInfo.isDownloaded) {
      return true;
    }

    if (!context.mounted) return false;
    final bool? downloaded = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        double progress = 0.0;
        int receivedBytes = 0;
        int totalBytes = modelInfo.expectedSizeBytes;
        String? errorMessage;
        bool isDownloading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            void startDownload() async {
              setDialogState(() {
                isDownloading = true;
                errorMessage = null;
              });

              try {
                await downloadModelUseCase(
                  onProgress: (received, total, percentage) {
                    setDialogState(() {
                      receivedBytes = received;
                      totalBytes = total;
                      progress = percentage;
                    });
                  },
                );
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              } catch (e) {
                setDialogState(() {
                  isDownloading = false;
                  errorMessage = 'Download failed: $e';
                });
              }
            }

            return AlertDialog(
              backgroundColor: isDark
                  ? NeoColors.darkSurface
                  : NeoColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
                  width: 2.5,
                ),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: NeoStyles.neoDecoration(
                      backgroundColor: NeoColors.purple,
                      radius: 8,
                      shadow: 2,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI Model Required',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To cleanly isolate your portrait and replace complex or outdoor backgrounds with studio precision, the compact on-device AI model (~${(modelInfo.expectedSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB) must be downloaded once.',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: isDark
                          ? NeoColors.textSecondaryDark
                          : NeoColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isDownloading) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: isDark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          NeoColors.purple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(receivedBytes / (1024 * 1024)).toStringAsFixed(1)} / ${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: isDark
                                ? NeoColors.textSecondaryDark
                                : NeoColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: NeoColors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                if (!isDownloading) ...[
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
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
                  NeoButton(
                    label:
                        'Download (~${(modelInfo.expectedSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB)',
                    backgroundColor: NeoColors.yellow,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    onPressed: startDownload,
                  ),
                ],
              ],
            );
          },
        );
      },
    );

    return downloaded == true;
  }

  Widget _buildSheetChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: NeoStyles.neoDecoration(
          backgroundColor: isSelected
              ? NeoColors.orange
              : (isDark ? NeoColors.darkBg : NeoColors.lightBg),
          radius: 8,
          shadow: isSelected ? 3 : 1,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isSelected ? NeoColors.borderLight : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: NeoStyles.neoDecoration(
              backgroundColor: NeoColors.orange,
              radius: 40,
              shadow: 4,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  NeoColors.borderLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Generating ID Photo & Print Sheet...',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    IdPhotoSuccessState state,
    bool isDark,
  ) {
    final bloc = context.read<IdPhotoBloc>();
    final res = state.result;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          NeoCard(
            backgroundColor: NeoColors.softOrange,
            shadowOffset: 5,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                NeoBadge(
                  label: res.preset.country,
                  backgroundColor: NeoColors.orange,
                  fontSize: 12,
                ),
                const SizedBox(height: 10),
                Text(
                  res.preset.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.borderLight,
                  ),
                ),
                Text(
                  '${res.preset.widthMm} x ${res.preset.heightMm} mm (${res.singleWidthPx} x ${res.singleHeightPx} px @ 300 DPI)',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: NeoColors.borderLight.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Single & Print Sheet Previews
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Single Photo',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    NeoCard(
                      backgroundColor: isDark
                          ? NeoColors.darkSurface
                          : NeoColors.lightSurface,
                      padding: const EdgeInsets.all(6),
                      shadowOffset: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          res.singlePhotoFile,
                          height: 160,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (res.printSheetJpgFile != null) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Print Sheet',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      NeoCard(
                        backgroundColor: isDark
                            ? NeoColors.darkSurface
                            : NeoColors.lightSurface,
                        padding: const EdgeInsets.all(6),
                        shadowOffset: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            res.printSheetJpgFile!,
                            height: 160,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
            onPressed: () async {
              final saver = getIt<FileSaveService>();
              await saver.saveFileToPublicStorage(
                sourceFile: res.singlePhotoFile,
                subFolder: 'ID_Photos',
              );
              if (res.printSheetPdfFile != null) {
                await saver.saveFileToPublicStorage(
                  sourceFile: res.printSheetPdfFile!,
                  subFolder: 'ID_Photos',
                );
              }
              if (context.mounted) {
                NeoToast.showSuccess(
                  context,
                  '🎉 Saved Passport Photo & Sheet to Device!',
                  icon: Icons.badge_rounded,
                );
              }
            },
          ),
          const SizedBox(height: 12),
          NeoButton(
            label: 'SHARE PASSPORT PHOTO',
            icon: const Icon(Icons.share_rounded, color: NeoColors.borderLight),
            backgroundColor: NeoColors.orange,
            fullWidth: true,
            onPressed: () {
              final files = [
                XFile(res.singlePhotoFile.path),
                if (res.printSheetPdfFile != null)
                  XFile(res.printSheetPdfFile!.path),
              ];
              final box = context.findRenderObject() as RenderBox?;
              final origin = box != null
                  ? box.localToGlobal(Offset.zero) & box.size
                  : null;
              Share.shareXFiles(
                files,
                text: 'Created with PicsTools!',
                sharePositionOrigin: origin,
              );
            },
          ),
          const SizedBox(height: 12),
          NeoButton(
            label: 'CREATE ANOTHER ID PHOTO',
            icon: const Icon(
              Icons.refresh_rounded,
              color: NeoColors.borderLight,
            ),
            backgroundColor: NeoColors.yellow,
            fullWidth: true,
            onPressed: () => bloc.add(ResetIdPhotoEvent()),
          ),
        ],
      ),
    );
  }
}

class _SeamlessPresetCarousel extends StatefulWidget {
  final List<IdPhotoPreset> presets;
  final bool isDark;
  final ValueChanged<IdPhotoPreset> onPresetTap;

  const _SeamlessPresetCarousel({
    required this.presets,
    required this.isDark,
    required this.onPresetTap,
  });

  @override
  State<_SeamlessPresetCarousel> createState() =>
      _SeamlessPresetCarouselState();
}

class _SeamlessPresetCarouselState extends State<_SeamlessPresetCarousel>
    with SingleTickerProviderStateMixin {
  static const double _itemWidth = 225.0;
  static const double _itemSpacing = 12.0;
  static const double _speed =
      38.0; // pixels per second for smooth readable motion

  late final ScrollController _scrollController;
  late final Ticker _ticker;
  Duration? _lastElapsed;
  bool _isUserInteracting = false;
  Timer? _resumeTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    if (_lastElapsed == null) {
      _lastElapsed = elapsed;
      return;
    }
    final double dt = (elapsed - _lastElapsed!).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    if (_isUserInteracting) return;
    if (!_scrollController.hasClients) return;
    if (widget.presets.isEmpty) return;

    final double totalStride = _itemWidth + _itemSpacing;
    final double totalLoopLength = totalStride * widget.presets.length;

    double newOffset = _scrollController.offset + (_speed * dt);
    if (newOffset >= totalLoopLength) {
      newOffset -= totalLoopLength;
    } else if (newOffset < 0) {
      newOffset += totalLoopLength;
    }
    _scrollController.jumpTo(newOffset);
  }

  void _onUserTouchStart() {
    _isUserInteracting = true;
    _resumeTimer?.cancel();
  }

  void _onUserTouchEnd() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _lastElapsed = null;
        _isUserInteracting = false;
      }
    });
  }

  @override
  void dispose() {
    _resumeTimer?.cancel();
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: Listener(
        onPointerDown: (_) => _onUserTouchStart(),
        onPointerUp: (_) => _onUserTouchEnd(),
        onPointerCancel: (_) => _onUserTouchEnd(),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(vertical: 2),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final safeIndex =
                (index % widget.presets.length + widget.presets.length) %
                widget.presets.length;
            final preset = widget.presets[safeIndex];
            return Container(
              width: _itemWidth,
              margin: const EdgeInsets.only(right: _itemSpacing),
              child: NeoCard(
                backgroundColor: widget.isDark
                    ? NeoColors.darkSurface
                    : NeoColors.lightSurface,
                padding: const EdgeInsets.all(12),
                shadowOffset: 3,
                onTap: () => widget.onPresetTap(preset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: NeoBadge(
                            label: preset.country,
                            backgroundColor: NeoColors.orange,
                            fontSize: 9.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: NeoColors.yellow.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: widget.isDark
                                  ? NeoColors.borderDark
                                  : NeoColors.borderLight,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${preset.widthMm.round()}×${preset.heightMm.round()}mm',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preset.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preset.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        height: 1.25,
                        color: widget.isDark
                            ? NeoColors.textSecondaryDark
                            : NeoColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
