import '../../../../core/widgets/neo_back_button.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;

import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_text_field.dart';
import '../../../../core/widgets/neo_slider.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/widgets/neo_loader.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/file_save_service.dart';
import '../../bloc/resizer_bloc.dart';

class ResizeView extends StatelessWidget {
  const ResizeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ResizerBloc(resizerService: getIt(), historyService: getIt()),
      child: const _ResizeViewContent(),
    );
  }
}

class _ResizeViewContent extends StatefulWidget {
  const _ResizeViewContent();

  @override
  State<_ResizeViewContent> createState() => _ResizeViewContentState();
}

class _ResizeViewContentState extends State<_ResizeViewContent> {
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  int _selectedPreviewIndex = 0;

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = getIt<ImagePickerService>();
    final bloc = context.read<ResizerBloc>();

    if (source == ImageSource.gallery) {
      final files = await picker.pickMultipleImages();
      if (files.isNotEmpty) {
        bloc.add(SelectResizeImagesEvent(files));
      }
    } else {
      final file = await picker.pickSingleImage(source: ImageSource.camera);
      if (file != null) {
        bloc.add(SelectResizeImagesEvent([file]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const NeoBackButton(),
        title: Text(
          'Resize Image',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<ResizerBloc, ResizerState>(
          listener: (context, state) {
            if (state is ResizerConfiguredState) {
              if (_widthController.text.isEmpty ||
                  _heightController.text.isEmpty) {
                _widthController.text = state.targetWidth.toString();
                _heightController.text = state.targetHeight.toString();
              }
            }
            if (state is ResizerErrorState) {
              NeoToast.showError(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is ResizerInitialState) {
              return _buildEmptyState(context, isDark);
            } else if (state is ResizerConfiguredState) {
              return _buildConfigurationState(context, state, isDark);
            } else if (state is ResizerProcessingState) {
              return _buildProcessingState(context, state, isDark);
            } else if (state is ResizerSuccessState) {
              return _buildSuccessState(context, state, isDark);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: NeoStyles.neoDecoration(
              backgroundColor: NeoColors.cyan,
              radius: 50,
              shadow: 5,
            ),
            child: const Icon(
              Icons.aspect_ratio_rounded,
              size: 50,
              color: NeoColors.borderLight,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Resize Image Dimensions',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Change image pixels, percentage scale, or resolution presets with aspect ratio lock.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: isDark
                  ? NeoColors.textSecondaryDark
                  : NeoColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 36),
          NeoCard(
            backgroundColor: NeoColors.softCyan,
            shadowOffset: 4,
            onTap: () => _pickImage(context, ImageSource.gallery),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.cyan,
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
                        'Select from Gallery',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                      Text(
                        'Select single or multiple photos',
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
            backgroundColor:
                isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
            shadowOffset: 3,
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
                        'Take Photo with Camera',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Capture instant photo to resize',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: isDark
                              ? NeoColors.textSecondaryDark
                              : NeoColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openImageViewerModal(
    BuildContext context,
    File imageFile, {
    required int width,
    required int height,
    required int sizeBytes,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? NeoColors.darkBg : NeoColors.lightBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
              width: 3,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: NeoStyles.neoDecoration(
                                backgroundColor: NeoColors.cyan,
                                radius: 8,
                                shadow: 2,
                              ),
                              child: const Icon(
                                Icons.image_rounded,
                                size: 18,
                                color: NeoColors.borderLight,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                path.basename(imageFile.path),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1.5),

                // Image Canvas
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            imageFile,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: NeoBadge(
                            label:
                                '$width x $height px • ${FileUtils.formatBytes(sizeBytes)}',
                            backgroundColor: NeoColors.cyan,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: NeoButton(
                          label: 'SHARE',
                          icon: const Icon(
                            Icons.share_rounded,
                            size: 16,
                            color: NeoColors.borderLight,
                          ),
                          backgroundColor: NeoColors.yellow,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                          onPressed: () {
                            final box = context.findRenderObject() as RenderBox?;
                            final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;
                            Share.shareXFiles([
                              XFile(imageFile.path),
                            ], text: 'Resized with PicsTools!', sharePositionOrigin: origin);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeoButton(
                          label: 'SAVE IMAGE',
                          icon: const Icon(
                            Icons.download_rounded,
                            size: 16,
                            color: NeoColors.borderLight,
                          ),
                          backgroundColor: NeoColors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                          onPressed: () async {
                            final saver = getIt<FileSaveService>();
                            final saved = await saver.saveFileToPublicStorage(
                              sourceFile: imageFile,
                              subFolder: 'Resized',
                            );
                            if (modalContext.mounted) {
                              NeoToast.showSuccess(
                                modalContext,
                                '🎉 Saved to Gallery!\n${saved.path.split(Platform.pathSeparator).last}',
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfigurationState(
    BuildContext context,
    ResizerConfiguredState state,
    bool isDark,
  ) {
    final bloc = context.read<ResizerBloc>();
    final isBatch = state.files.length > 1;

    final safeIndex = _selectedPreviewIndex.clamp(
      0,
      state.files.isEmpty ? 0 : state.files.length - 1,
    );
    final previewFile = state.files.isNotEmpty ? state.files[safeIndex] : null;
    final origSize = (safeIndex < state.originalSizes.length)
        ? state.originalSizes[safeIndex]
        : Size(state.originalWidth.toDouble(), state.originalHeight.toDouble());

    final currentScaledW = (origSize.width * (state.percentage / 100.0))
        .round();
    final currentScaledH = (origSize.height * (state.percentage / 100.0))
        .round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Image Preview Frame
          if (previewFile != null) ...[
            NeoCard(
              backgroundColor: isDark
                  ? NeoColors.darkSurface
                  : NeoColors.lightSurface,
              shadowOffset: 4,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          previewFile,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: NeoBadge(
                          label: isBatch
                              ? '$currentScaledW x $currentScaledH px (${state.percentage.round()}%)'
                              : '${state.targetWidth} x ${state.targetHeight} px',
                          backgroundColor: NeoColors.cyan,
                          fontSize: 11,
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            path.basename(previewFile.path),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              color: NeoColors.lightSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isBatch) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 64,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.files.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final file = state.files[index];
                          final isSelected = index == safeIndex;
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedPreviewIndex = index),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? NeoColors.cyan
                                          : (isDark
                                                ? NeoColors.borderDark
                                                : NeoColors.borderLight),
                                      width: 2.0,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(
                                      file,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (_selectedPreviewIndex >=
                                            state.files.length - 1 &&
                                        _selectedPreviewIndex > 0) {
                                      setState(() {
                                        _selectedPreviewIndex =
                                            _selectedPreviewIndex - 1;
                                      });
                                    }
                                    bloc.add(RemoveResizeImageEvent(index));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: NeoColors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Header summary card
          NeoCard(
            backgroundColor: NeoColors.softYellow,
            shadowOffset: 3,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.yellow,
                    radius: 10,
                    shadow: 2,
                  ),
                  child: Center(
                    child: Text(
                      '${state.files.length}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.borderLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBatch
                            ? 'Batch Mode: ${state.files.length} Photos Selected'
                            : 'Original: ${origSize.width.round()} x ${origSize.height.round()} px',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                      Text(
                        isBatch
                            ? 'Photo ${safeIndex + 1}: ${origSize.width.round()} x ${origSize.height.round()} px'
                            : 'Single image resize mode',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: NeoColors.borderLight.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                NeoButton(
                  label: 'CHANGE',
                  backgroundColor: NeoColors.cyan,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  onPressed: () {
                    setState(() => _selectedPreviewIndex = 0);
                    bloc.add(ResetResizerEvent());
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Custom Dimension Inputs (Only for Single Image Mode)
          if (!isBatch) ...[
            Text(
              'Target Dimensions (Pixels)',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NeoTextField(
                    labelText: 'Width (px)',
                    controller: _widthController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final w = int.tryParse(val) ?? state.targetWidth;
                      int h = state.targetHeight;
                      if (state.maintainAspectRatio &&
                          state.originalWidth > 0) {
                        h = ((w / state.originalWidth) * state.originalHeight)
                            .round();
                        _heightController.text = h.toString();
                      }
                      bloc.add(UpdateDimensionsEvent(w, h));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeoTextField(
                    labelText: 'Height (px)',
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final h = int.tryParse(val) ?? state.targetHeight;
                      int w = state.targetWidth;
                      if (state.maintainAspectRatio &&
                          state.originalHeight > 0) {
                        w = ((h / state.originalHeight) * state.originalWidth)
                            .round();
                        _widthController.text = w.toString();
                      }
                      bloc.add(UpdateDimensionsEvent(w, h));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Aspect Ratio Lock Toggle
            NeoCard(
              backgroundColor: isDark
                  ? NeoColors.darkSurface
                  : NeoColors.lightSurface,
              shadowOffset: 2,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        state.maintainAspectRatio
                            ? Icons.lock_rounded
                            : Icons.lock_open_rounded,
                        color: state.maintainAspectRatio
                            ? NeoColors.yellow
                            : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Maintain Aspect Ratio',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: state.maintainAspectRatio,
                    activeTrackColor: NeoColors.yellow,
                    onChanged: (_) =>
                        bloc.add(ToggleMaintainAspectRatioEvent()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            // Batch Mode Info Banner
            NeoCard(
              backgroundColor: NeoColors.softCyan,
              shadowOffset: 2,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: NeoStyles.neoDecoration(
                      backgroundColor: NeoColors.cyan,
                      radius: 8,
                      shadow: 1,
                    ),
                    child: const Icon(
                      Icons.aspect_ratio_rounded,
                      size: 20,
                      color: NeoColors.borderLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Batch Mode: Photos have different aspect ratios. Scaling by percentage preserves each photo\'s proportions perfectly without stretching.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: NeoColors.borderLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Percentage Resize Slider & Quick Presets
          Text(
            'Percentage Scale',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          NeoCard(
            backgroundColor: isDark
                ? NeoColors.darkSurface
                : NeoColors.lightSurface,
            child: NeoSlider(
              label: 'Scale (${state.percentage.round()}%)',
              value: state.percentage,
              min: 10,
              max: 100,
              divisions: 90,
              activeColor: NeoColors.cyan,
              onChanged: (val) {
                bloc.add(SetPercentageResizeEvent(val));
                if (!isBatch) {
                  final newW = (state.originalWidth * (val / 100.0)).round();
                  final newH = (state.originalHeight * (val / 100.0)).round();
                  _widthController.text = newW.toString();
                  _heightController.text = newH.toString();
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: NeoButton(
                  label: '25%',
                  backgroundColor: state.percentage == 25
                      ? NeoColors.cyan
                      : (isDark
                            ? NeoColors.darkSurface
                            : NeoColors.lightSurface),
                  textColor: state.percentage == 25
                      ? NeoColors.borderLight
                      : (isDark
                            ? NeoColors.textPrimaryDark
                            : NeoColors.textPrimaryLight),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onPressed: () {
                    bloc.add(const SetPercentageResizeEvent(25));
                    if (!isBatch) {
                      final newW = (state.originalWidth * 0.25).round();
                      final newH = (state.originalHeight * 0.25).round();
                      _widthController.text = newW.toString();
                      _heightController.text = newH.toString();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NeoButton(
                  label: '50%',
                  backgroundColor: state.percentage == 50
                      ? NeoColors.cyan
                      : (isDark
                            ? NeoColors.darkSurface
                            : NeoColors.lightSurface),
                  textColor: state.percentage == 50
                      ? NeoColors.borderLight
                      : (isDark
                            ? NeoColors.textPrimaryDark
                            : NeoColors.textPrimaryLight),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onPressed: () {
                    bloc.add(const SetPercentageResizeEvent(50));
                    if (!isBatch) {
                      final newW = (state.originalWidth * 0.50).round();
                      final newH = (state.originalHeight * 0.50).round();
                      _widthController.text = newW.toString();
                      _heightController.text = newH.toString();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NeoButton(
                  label: '75%',
                  backgroundColor: state.percentage == 75
                      ? NeoColors.cyan
                      : (isDark
                            ? NeoColors.darkSurface
                            : NeoColors.lightSurface),
                  textColor: state.percentage == 75
                      ? NeoColors.borderLight
                      : (isDark
                            ? NeoColors.textPrimaryDark
                            : NeoColors.textPrimaryLight),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onPressed: () {
                    bloc.add(const SetPercentageResizeEvent(75));
                    if (!isBatch) {
                      final newW = (state.originalWidth * 0.75).round();
                      final newH = (state.originalHeight * 0.75).round();
                      _widthController.text = newW.toString();
                      _heightController.text = newH.toString();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NeoButton(
                  label: '100%',
                  backgroundColor: state.percentage == 100
                      ? NeoColors.cyan
                      : (isDark
                            ? NeoColors.darkSurface
                            : NeoColors.lightSurface),
                  textColor: state.percentage == 100
                      ? NeoColors.borderLight
                      : (isDark
                            ? NeoColors.textPrimaryDark
                            : NeoColors.textPrimaryLight),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onPressed: () {
                    bloc.add(const SetPercentageResizeEvent(100));
                    if (!isBatch) {
                      _widthController.text = state.originalWidth.toString();
                      _heightController.text = state.originalHeight.toString();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Resolution Presets (Only in Single Image Mode)
          if (!isBatch) ...[
            Text(
              'Common Presets',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildPresetChip(
                  label: '1080p (Full HD)',
                  w: 1920,
                  h: 1080,
                  bloc: bloc,
                  isDark: isDark,
                ),
                _buildPresetChip(
                  label: '720p (HD)',
                  w: 1280,
                  h: 720,
                  bloc: bloc,
                  isDark: isDark,
                ),
                _buildPresetChip(
                  label: '4K Ultra HD',
                  w: 3840,
                  h: 2160,
                  bloc: bloc,
                  isDark: isDark,
                ),
                _buildPresetChip(
                  label: 'Web (800x600)',
                  w: 800,
                  h: 600,
                  bloc: bloc,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 36),
          ] else
            const SizedBox(height: 24),

          NeoButton(
            label: isBatch
                ? 'RESIZE ${state.files.length} IMAGES'
                : 'RESIZE IMAGE',
            icon: const Icon(
              Icons.aspect_ratio_rounded,
              color: NeoColors.borderLight,
            ),
            backgroundColor: NeoColors.cyan,
            fullWidth: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
            onPressed: () => bloc.add(StartResizeEvent()),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required int w,
    required int h,
    required ResizerBloc bloc,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        _widthController.text = w.toString();
        _heightController.text = h.toString();
        bloc.add(UpdateDimensionsEvent(w, h));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: NeoStyles.neoDecoration(
          backgroundColor: isDark
              ? NeoColors.darkSurface
              : NeoColors.lightSurface,
          radius: 10,
          shadow: 2,
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingState(
    BuildContext context,
    ResizerProcessingState state,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: NeoStyles.neoDecoration(
              backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.softCyan,
              borderColor: isDark ? NeoColors.borderDark : NeoColors.borderLight,
              radius: 20,
              shadow: 4,
            ),
            child: const Center(
              child: NeoLoader.large(
                size: 46,
                color: NeoColors.cyan,
                secondaryColor: NeoColors.yellow,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Resizing Images...',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Processing file ${state.currentIndex} of ${state.totalCount}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: isDark
                  ? NeoColors.textSecondaryDark
                  : NeoColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 12,
              backgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(NeoColors.cyan),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    ResizerSuccessState state,
    bool isDark,
  ) {
    final bloc = context.read<ResizerBloc>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          NeoCard(
            backgroundColor: NeoColors.softCyan,
            shadowOffset: 5,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const NeoBadge(
                  label: 'RESIZE COMPLETE',
                  backgroundColor: NeoColors.cyan,
                  fontSize: 12,
                ),
                const SizedBox(height: 12),
                Text(
                  '${state.results.length} Image(s) Resized',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.borderLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.results.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = state.results[index];
              return NeoCard(
                backgroundColor: isDark
                    ? NeoColors.darkSurface
                    : NeoColors.lightSurface,
                onTap: () => _openImageViewerModal(
                  context,
                  item.resizedFile,
                  width: item.resizedWidth,
                  height: item.resizedHeight,
                  sizeBytes: item.resizedSizeBytes,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        item.resizedFile,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.originalWidth}x${item.originalHeight} ➔ ${item.resizedWidth}x${item.resizedHeight} px',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${FileUtils.formatBytes(item.originalSizeBytes)} ➔ ${FileUtils.formatBytes(item.resizedSizeBytes)}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: isDark
                                  ? NeoColors.textSecondaryDark
                                  : NeoColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.visibility_rounded,
                      size: 20,
                      color: NeoColors.cyan,
                    ),
                  ],
                ),
              );
            },
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
              for (final res in state.results) {
                await saver.saveFileToPublicStorage(
                  sourceFile: res.resizedFile,
                  subFolder: 'Resized',
                );
              }
              if (context.mounted) {
                NeoToast.showSuccess(
                  context,
                  '🎉 Saved ${state.results.length} resized photo(s) to Gallery!',
                );
              }
            },
          ),
          const SizedBox(height: 12),
          NeoButton(
            label: 'SHARE RESIZED FILE(S)',
            icon: const Icon(Icons.share_rounded, color: NeoColors.borderLight),
            backgroundColor: NeoColors.cyan,
            fullWidth: true,
            onPressed: () {
              final xFiles = state.results
                  .map((r) => XFile(r.resizedFile.path))
                  .toList();
              final box = context.findRenderObject() as RenderBox?;
              final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;
              Share.shareXFiles(xFiles, text: 'Resized with PicsTools!', sharePositionOrigin: origin);
            },
          ),
          const SizedBox(height: 12),
          NeoButton(
            label: 'RESIZE ANOTHER IMAGE',
            icon: const Icon(
              Icons.refresh_rounded,
              color: NeoColors.borderLight,
            ),
            backgroundColor: NeoColors.yellow,
            fullWidth: true,
            onPressed: () => bloc.add(ResetResizerEvent()),
          ),
        ],
      ),
    );
  }
}
