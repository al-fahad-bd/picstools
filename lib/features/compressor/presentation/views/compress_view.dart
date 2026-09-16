import '../../../../core/widgets/neo_back_button.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_slider.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/widgets/neo_loader.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../../core/services/file_share_service.dart';
import '../../../../core/services/monetization/in_app_purchase_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/widgets/app_native_ad.dart';
import '../../../../core/widgets/neo_download_dialog.dart';
import '../../bloc/compressor_bloc.dart';

class CompressView extends StatelessWidget {
  const CompressView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CompressorBloc(compressorService: getIt(), historyService: getIt()),
      child: const _CompressViewContent(),
    );
  }
}

class _CompressViewContent extends StatefulWidget {
  const _CompressViewContent();

  @override
  State<_CompressViewContent> createState() => _CompressViewContentState();
}

class _CompressViewContentState extends State<_CompressViewContent> {
  int _selectedPreviewIndex = 0;

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = getIt<ImagePickerService>();
    final bloc = context.read<CompressorBloc>();

    if (source == ImageSource.gallery) {
      final files = await picker.pickMultipleImages();
      if (files.isNotEmpty) {
        bloc.add(SelectImagesEvent(files));
      }
    } else {
      final file = await picker.pickSingleImage(source: ImageSource.camera);
      if (file != null) {
        bloc.add(SelectImagesEvent([file]));
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
          'Compress Image',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<CompressorBloc, CompressorState>(
          listener: (context, state) {
            if (state is CompressorErrorState) {
              NeoToast.showError(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is CompressorInitialState) {
              return _buildEmptyState(context, isDark);
            } else if (state is CompressorImagesSelectedState) {
              return _buildConfigurationState(context, state, isDark);
            } else if (state is CompressorProcessingState) {
              return _buildProcessingState(context, state, isDark);
            } else if (state is CompressorSuccessState) {
              return _buildSuccessState(context, state, isDark);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // 1. Initial State: Picker Options
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final isPro = getIt<InAppPurchaseService>().isProUser();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: NeoStyles.neoDecoration(
              backgroundColor: NeoColors.yellow,
              radius: 50,
              shadow: 5,
            ),
            child: const Icon(
              Icons.compress_rounded,
              size: 50,
              color: NeoColors.borderLight,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Reduce Image File Size',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Select single or multiple photos to compress without losing visual quality.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: isDark
                  ? NeoColors.textSecondaryDark
                  : NeoColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 36),

          // Action cards
          NeoCard(
            backgroundColor: NeoColors.softYellow,
            shadowOffset: 4,
            onTap: () => _pickImage(context, ImageSource.gallery),
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
                        'Choose from Gallery',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                      Text(
                        'Supports multi-image batch selection',
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
          const SizedBox(height: 16),

          NeoCard(
            backgroundColor: isDark
                ? NeoColors.darkSurface
                : NeoColors.lightSurface,
            shadowOffset: 4,
            onTap: () => _pickImage(context, ImageSource.camera),
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
                        'Take a Photo',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Use camera to capture image instantly',
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
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
                ),
              ],
            ),
          ),

          // Native Ad below all content (Strictly for Free users)
          if (!isPro) ...[
            const SizedBox(height: 20),
            const AppNativeAd(
              templateType: TemplateType.medium,
              margin: EdgeInsets.only(top: 8, bottom: 20),
            ),
          ],
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
                                backgroundColor: NeoColors.green,
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
                            backgroundColor: NeoColors.green,
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
                            final origin =
                                FileShareService.getOrigin(modalContext);
                            getIt<FileShareService>().shareFiles(
                              files: [XFile(imageFile.path)],
                              text: 'Compressed with PicsTools!',
                              sharePositionOrigin: origin,
                            );
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
                            final proceed = await NeoDownloadDialog.show(
                              modalContext,
                              title: 'Download Compressed Photo',
                              subtitle:
                                  'Save high-resolution compressed image to your device gallery',
                            );
                            if (!proceed) return;

                            final saver = getIt<FileSaveService>();
                            final saved = await saver.saveFileToPublicStorage(
                              sourceFile: imageFile,
                              subFolder: 'Compressed',
                            );
                            if (modalContext.mounted) {
                              NeoToast.showSuccess(
                                modalContext,
                                '🎉 Saved to Gallery!\n${saved.path.split(Platform.pathSeparator).last}',
                                onTap: () => saver.openFileOrDirectory(
                                  file: saved,
                                  subFolder: 'Compressed',
                                ),
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

  // 2. Configuration State: Quality Slider & Presets
  Widget _buildConfigurationState(
    BuildContext context,
    CompressorImagesSelectedState state,
    bool isDark,
  ) {
    final bloc = context.read<CompressorBloc>();
    final safeIndex = _selectedPreviewIndex.clamp(
      0,
      state.files.isEmpty ? 0 : state.files.length - 1,
    );
    final previewFile = state.files.isNotEmpty ? state.files[safeIndex] : null;

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
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          previewFile,
                          height: 190,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: NeoBadge(
                          label: FileUtils.formatBytes(
                            previewFile.existsSync()
                                ? previewFile.lengthSync()
                                : 0,
                          ),
                          backgroundColor: NeoColors.yellow,
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
                  if (state.files.length > 1) ...[
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
                                onTap: () => setState(
                                  () => _selectedPreviewIndex = index,
                                ),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? NeoColors.yellow
                                          : (isDark
                                                ? NeoColors.borderDark
                                                : NeoColors.borderLight),
                                      width: 2.0,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(file, fit: BoxFit.cover),
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
                                    bloc.add(RemoveImageEvent(index));
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
            const SizedBox(height: 20),
          ],

          // Selected Files Summary Header
          NeoCard(
            backgroundColor: NeoColors.softCyan,
            shadowOffset: 4,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.cyan,
                    radius: 10,
                    shadow: 2,
                  ),
                  child: Center(
                    child: Text(
                      '${state.files.length}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
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
                        state.files.length == 1
                            ? '1 Image Selected'
                            : '${state.files.length} Images Selected',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                      Text(
                        'Total Size: ${FileUtils.formatBytes(state.totalOriginalSizeBytes)}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: NeoColors.borderLight.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                NeoButton(
                  label: 'CHANGE',
                  backgroundColor: NeoColors.yellow,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  onPressed: () {
                    setState(() => _selectedPreviewIndex = 0);
                    bloc.add(ResetCompressorEvent());
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quality Presets
          Text(
            'Quality Presets',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPresetCard(
                  label: 'HIGH',
                  sub: '80% Quality',
                  isSelected: state.quality == 80,
                  color: NeoColors.green,
                  onTap: () => bloc.add(const SetQualityPresetEvent(80)),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPresetCard(
                  label: 'MEDIUM',
                  sub: '60% Quality',
                  isSelected: state.quality == 60,
                  color: NeoColors.yellow,
                  onTap: () => bloc.add(const SetQualityPresetEvent(60)),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPresetCard(
                  label: 'LOW',
                  sub: '40% Quality',
                  isSelected: state.quality == 40,
                  color: NeoColors.pink,
                  onTap: () => bloc.add(const SetQualityPresetEvent(40)),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          NeoCard(
            backgroundColor: isDark
                ? NeoColors.darkSurface
                : NeoColors.lightSurface,
            child: NeoSlider(
              label: 'Custom Quality',
              value: state.quality.toDouble(),
              min: 10,
              max: 100,
              divisions: 90,
              activeColor: NeoColors.yellow,
              onChanged: (val) => bloc.add(SetCustomQualityEvent(val)),
            ),
          ),
          const SizedBox(height: 24),

          // Optional Target Size
          Text(
            'Target File Size (Optional)',
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
              _buildTargetChip(
                label: 'None',
                isSelected: state.targetSizeBytes == null,
                onTap: () => bloc.add(const SetTargetFileSizeEvent(null)),
                isDark: isDark,
              ),
              _buildTargetChip(
                label: 'Max 200 KB',
                isSelected: state.targetSizeBytes == 200 * 1024,
                onTap: () {
                  if (state.targetSizeBytes == 200 * 1024) {
                    bloc.add(const SetTargetFileSizeEvent(null));
                  } else {
                    bloc.add(const SetTargetFileSizeEvent(200 * 1024));
                  }
                },
                isDark: isDark,
              ),
              _buildTargetChip(
                label: 'Max 500 KB',
                isSelected: state.targetSizeBytes == 500 * 1024,
                onTap: () {
                  if (state.targetSizeBytes == 500 * 1024) {
                    bloc.add(const SetTargetFileSizeEvent(null));
                  } else {
                    bloc.add(const SetTargetFileSizeEvent(500 * 1024));
                  }
                },
                isDark: isDark,
              ),
              _buildTargetChip(
                label: 'Max 1 MB',
                isSelected: state.targetSizeBytes == 1024 * 1024,
                onTap: () {
                  if (state.targetSizeBytes == 1024 * 1024) {
                    bloc.add(const SetTargetFileSizeEvent(null));
                  } else {
                    bloc.add(const SetTargetFileSizeEvent(1024 * 1024));
                  }
                },
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 36),

          // Compress Action Button
          NeoButton(
            label: 'COMPRESS NOW',
            icon: const Icon(Icons.bolt_rounded, color: NeoColors.borderLight),
            backgroundColor: NeoColors.yellow,
            fullWidth: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
            onPressed: () {
              bloc.add(StartCompressionEvent());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPresetCard({
    required String label,
    required String sub,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return NeoCard(
      backgroundColor: isSelected
          ? color
          : (isDark ? NeoColors.darkSurface : NeoColors.lightSurface),
      padding: const EdgeInsets.all(12),
      shadowOffset: isSelected ? 4 : 2,
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isSelected ? NeoColors.borderLight : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? NeoColors.borderLight.withValues(alpha: 0.8)
                  : (isDark
                        ? NeoColors.textSecondaryDark
                        : NeoColors.textSecondaryLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: NeoStyles.neoDecoration(
          backgroundColor: isSelected
              ? NeoColors.cyan
              : (isDark ? NeoColors.darkSurface : NeoColors.lightSurface),
          radius: 10,
          shadow: isSelected ? 3 : 1,
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSelected ? NeoColors.borderLight : null,
          ),
        ),
      ),
    );
  }

  // 3. Processing State
  Widget _buildProcessingState(
    BuildContext context,
    CompressorProcessingState state,
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
              backgroundColor: isDark
                  ? NeoColors.darkSurface
                  : NeoColors.softYellow,
              borderColor: isDark
                  ? NeoColors.borderDark
                  : NeoColors.borderLight,
              radius: 20,
              shadow: 4,
            ),
            child: const Center(
              child: NeoLoader.large(
                size: 46,
                color: NeoColors.yellow,
                secondaryColor: NeoColors.pink,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Compressing Images...',
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
              valueColor: const AlwaysStoppedAnimation<Color>(NeoColors.yellow),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Success / Result State
  Widget _buildSuccessState(
    BuildContext context,
    CompressorSuccessState state,
    bool isDark,
  ) {
    final bloc = context.read<CompressorBloc>();
    final savedPct = FileUtils.calculateSavingsPercentage(
      state.totalOriginalSizeBytes,
      state.totalCompressedSizeBytes,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // High-Impact Savings Banner
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: NeoCard(
            backgroundColor: NeoColors.softGreen,
            shadowOffset: 4,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const NeoBadge(
                      label: 'SAVED',
                      backgroundColor: NeoColors.green,
                      fontSize: 12,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${savedPct.toStringAsFixed(1)}%',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.borderLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCol(
                      'Original',
                      FileUtils.formatBytes(state.totalOriginalSizeBytes),
                      NeoColors.borderLight,
                    ),
                    Container(
                      width: 2,
                      height: 28,
                      color: NeoColors.borderLight,
                    ),
                    _buildStatCol(
                      'Compressed',
                      FileUtils.formatBytes(state.totalCompressedSizeBytes),
                      NeoColors.borderLight,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COMPRESSED PHOTOS (${state.results.length})',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: isDark
                      ? NeoColors.textSecondaryDark
                      : NeoColors.textSecondaryLight,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: 13,
                    color: isDark ? NeoColors.softPurple : NeoColors.purple,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'TAP TO PREVIEW',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? NeoColors.softPurple : NeoColors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Scrollable File items preview list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            itemCount: state.results.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = state.results[index];
              final itemSavedPct = FileUtils.calculateSavingsPercentage(
                item.originalSizeBytes,
                item.compressedSizeBytes,
              );

              return NeoCard(
                backgroundColor: isDark
                    ? NeoColors.darkSurface
                    : NeoColors.lightSurface,
                onTap: () => _openImageViewerModal(
                  context,
                  item.compressedFile,
                  width: item.width,
                  height: item.height,
                  sizeBytes: item.compressedSizeBytes,
                ),
                child: Row(
                  children: [
                    // Thumbnail with zoom hint overlay badge
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? NeoColors.borderDark
                              : NeoColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.5),
                        child: Stack(
                          children: [
                            Image.file(
                              item.compressedFile,
                              width: 62,
                              height: 62,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.fullscreen_rounded,
                                  color: Colors.white,
                                  size: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.width} x ${item.height} px',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              NeoBadge(
                                label: '-${itemSavedPct.round()}%',
                                backgroundColor: NeoColors.yellow,
                                fontSize: 11,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${FileUtils.formatBytes(item.originalSizeBytes)} ➔ ${FileUtils.formatBytes(item.compressedSizeBytes)}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: isDark
                                  ? NeoColors.textSecondaryDark
                                  : NeoColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const _CompressTapPreviewBadge(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Pinned Bottom Actions: Save, Share & New
        Container(
          decoration: BoxDecoration(
            color: isDark ? NeoColors.darkBg : NeoColors.lightBg,
            border: Border(
              top: BorderSide(
                color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
                width: 2.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                offset: const Offset(0, -4),
                blurRadius: 10,
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeoButton(
                label: 'SAVE TO DEVICE',
                icon: const Icon(
                  Icons.download_rounded,
                  color: NeoColors.borderLight,
                ),
                backgroundColor: NeoColors.green,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: () async {
                  final proceed = await NeoDownloadDialog.show(
                    context,
                    title: 'Download ${state.results.length} Compressed Photos',
                    subtitle:
                        'Export all optimized images instantly to your device gallery',
                  );
                  if (!proceed) return;

                  final saver = getIt<FileSaveService>();
                  File? lastSaved;
                  for (final res in state.results) {
                    lastSaved = await saver.saveFileToPublicStorage(
                      sourceFile: res.compressedFile,
                      subFolder: 'Compressed',
                    );
                  }
                  if (context.mounted) {
                    NeoToast.showSuccess(
                      context,
                      '🎉 Saved ${state.results.length} compressed photo(s) to Gallery!',
                      onTap: () => saver.openFileOrDirectory(
                        file: lastSaved,
                        subFolder: 'Compressed',
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      label: 'SHARE FILES',
                      icon: const Icon(
                        Icons.share_rounded,
                        color: NeoColors.borderLight,
                        size: 18,
                      ),
                      backgroundColor: NeoColors.cyan,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: () {
                        final xFiles = state.results
                            .map((r) => XFile(r.compressedFile.path))
                            .toList();
                        final origin = FileShareService.getOrigin(context);
                        getIt<FileShareService>().shareFiles(
                          files: xFiles,
                          text: 'Compressed with PicsTools!',
                          sharePositionOrigin: origin,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NeoButton(
                      label: 'COMPRESS MORE',
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: NeoColors.borderLight,
                        size: 18,
                      ),
                      backgroundColor: NeoColors.yellow,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: () => bloc.add(ResetCompressorEvent()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCol(String label, String val, Color color) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color.withValues(alpha: 0.7),
          ),
        ),
        Text(
          val,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CompressTapPreviewBadge extends StatefulWidget {
  const _CompressTapPreviewBadge();

  @override
  State<_CompressTapPreviewBadge> createState() =>
      _CompressTapPreviewBadgeState();
}

class _CompressTapPreviewBadgeState extends State<_CompressTapPreviewBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark
                  ? NeoColors.purple.withValues(
                      alpha: 0.25 + (_controller.value * 0.15),
                    )
                  : NeoColors.purple.withValues(
                      alpha: 0.10 + (_controller.value * 0.08),
                    ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: (isDark ? NeoColors.softPurple : NeoColors.purple)
                    .withValues(alpha: 0.6 + (_controller.value * 0.4)),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 13,
                  color: isDark ? NeoColors.softPurple : NeoColors.purple,
                ),
                const SizedBox(width: 4),
                Text(
                  'TAP TO PREVIEW',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    color: isDark ? NeoColors.softPurple : NeoColors.purple,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
