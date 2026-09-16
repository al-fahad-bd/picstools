import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../../core/widgets/neo_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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
import '../../bloc/converter_bloc.dart';

class ConvertView extends StatelessWidget {
  const ConvertView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ConverterBloc(converterService: getIt(), historyService: getIt()),
      child: const _ConvertViewContent(),
    );
  }
}

class _ConvertViewContent extends StatelessWidget {
  const _ConvertViewContent();

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = getIt<ImagePickerService>();
    final bloc = context.read<ConverterBloc>();

    if (source == ImageSource.gallery) {
      final files = await picker.pickMultipleImages();
      if (files.isNotEmpty) {
        bloc.add(SelectConvertImagesEvent(files));
      }
    } else {
      final file = await picker.pickSingleImage(source: ImageSource.camera);
      if (file != null) {
        bloc.add(SelectConvertImagesEvent([file]));
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
          'Convert Image Format',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<ConverterBloc, ConverterState>(
          listener: (context, state) {
            if (state is ConverterErrorState) {
              NeoToast.showError(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is ConverterInitialState) {
              return _buildEmptyState(context, isDark);
            } else if (state is ConverterConfiguredState) {
              return _buildConfigurationState(context, state, isDark);
            } else if (state is ConverterProcessingState) {
              return _buildProcessingState(context, state, isDark);
            } else if (state is ConverterSuccessState) {
              return _buildSuccessState(context, state, isDark);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final isPro = getIt<InAppPurchaseService>().isProUser();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: NeoStyles.neoDecoration(
              backgroundColor: NeoColors.green,
              radius: 50,
              shadow: 5,
            ),
            child: const Icon(
              Icons.transform_rounded,
              size: 50,
              color: NeoColors.borderLight,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Convert JPG, PNG & WebP',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Batch convert photos between JPG, PNG, and WebP formats instantly with quality control.',
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
            backgroundColor: NeoColors.softGreen,
            shadowOffset: 4,
            onTap: () => _pickImage(context, ImageSource.gallery),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.green,
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
            backgroundColor: isDark
                ? NeoColors.darkSurface
                : NeoColors.lightSurface,
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
                        'Capture instant photo to convert',
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

  Widget _buildConfigurationState(
    BuildContext context,
    ConverterConfiguredState state,
    bool isDark,
  ) {
    final bloc = context.read<ConverterBloc>();
    final allFormats = [
      {'name': 'JPG', 'sub': 'Standard Photo', 'color': NeoColors.yellow},
      {
        'name': 'PNG',
        'sub': 'Lossless & Transparency',
        'color': NeoColors.cyan,
      },
      {'name': 'WEBP', 'sub': 'Modern Web Format', 'color': NeoColors.green},
    ];

    bool allJpg =
        state.files.isNotEmpty &&
        state.files.every(
          (f) =>
              f.path.toLowerCase().endsWith('.jpg') ||
              f.path.toLowerCase().endsWith('.jpeg'),
        );
    bool allPng =
        state.files.isNotEmpty &&
        state.files.every((f) => f.path.toLowerCase().endsWith('.png'));
    bool allWebp =
        state.files.isNotEmpty &&
        state.files.every((f) => f.path.toLowerCase().endsWith('.webp'));

    final formats = allFormats.where((fmt) {
      if (allJpg && fmt['name'] == 'JPG') return false;
      if (allPng && fmt['name'] == 'PNG') return false;
      if (allWebp && fmt['name'] == 'WEBP') return false;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Photos Live Thumbnail Strip
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.files.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final file = state.files[index];
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 4),
                      child: NeoCard(
                        backgroundColor: isDark
                            ? NeoColors.darkSurface
                            : NeoColors.lightSurface,
                        padding: const EdgeInsets.all(4),
                        shadowOffset: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            width: 86,
                            height: 86,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => bloc.add(RemoveConvertImageEvent(index)),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: NeoColors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
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
          const SizedBox(height: 16),

          NeoCard(
            backgroundColor: NeoColors.softGreen,
            shadowOffset: 3,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.green,
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
                  child: Text(
                    '${state.files.length} Photo(s) Selected',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: NeoColors.borderLight,
                    ),
                  ),
                ),
                NeoButton(
                  label: 'CHANGE',
                  backgroundColor: NeoColors.yellow,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  onPressed: () => bloc.add(ResetConverterEvent()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Target Format',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: formats.map((fmt) {
              final isSelected = state.targetFormat == fmt['name'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NeoCard(
                  backgroundColor: isSelected
                      ? (fmt['color'] as Color)
                      : (isDark
                            ? NeoColors.darkSurface
                            : NeoColors.lightSurface),
                  shadowOffset: isSelected ? 4 : 2,
                  onTap: () =>
                      bloc.add(SetTargetFormatEvent(fmt['name'] as String)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fmt['name'] as String,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? NeoColors.borderLight : null,
                            ),
                          ),
                          Text(
                            fmt['sub'] as String,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: isSelected
                                  ? NeoColors.borderLight.withValues(alpha: 0.8)
                                  : (isDark
                                        ? NeoColors.textSecondaryDark
                                        : NeoColors.textSecondaryLight),
                            ),
                          ),
                        ],
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: NeoColors.borderLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          if (state.targetFormat != 'PNG') ...[
            NeoCard(
              backgroundColor: isDark
                  ? NeoColors.darkSurface
                  : NeoColors.lightSurface,
              child: NeoSlider(
                label: 'Encoder Quality',
                value: state.quality.toDouble(),
                min: 10,
                max: 100,
                divisions: 90,
                activeColor: NeoColors.green,
                onChanged: (val) =>
                    bloc.add(SetConvertQualityEvent(val.round())),
              ),
            ),
            const SizedBox(height: 36),
          ],

          NeoButton(
            label: 'CONVERT TO ${state.targetFormat}',
            icon: const Icon(
              Icons.transform_rounded,
              color: NeoColors.borderLight,
            ),
            backgroundColor: NeoColors.green,
            fullWidth: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
            onPressed: () {
              bloc.add(StartConversionEvent());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingState(
    BuildContext context,
    ConverterProcessingState state,
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
                  : NeoColors.softGreen,
              borderColor: isDark
                  ? NeoColors.borderDark
                  : NeoColors.borderLight,
              radius: 20,
              shadow: 4,
            ),
            child: const Center(
              child: NeoLoader.large(
                size: 46,
                color: NeoColors.green,
                secondaryColor: NeoColors.yellow,
                tertiaryColor: NeoColors.cyan,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Converting Images...',
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
              valueColor: const AlwaysStoppedAnimation<Color>(NeoColors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    ConverterSuccessState state,
    bool isDark,
  ) {
    final bloc = context.read<ConverterBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // High-Impact Conversion Complete Banner
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: NeoCard(
            backgroundColor: NeoColors.softGreen,
            shadowOffset: 4,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              children: [
                const NeoBadge(
                  label: 'CONVERSION COMPLETE',
                  backgroundColor: NeoColors.green,
                  fontSize: 12,
                ),
                const SizedBox(height: 10),
                Text(
                  '${state.results.length} File(s) Converted',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.borderLight,
                  ),
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
                'CONVERTED PHOTOS (${state.results.length})',
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
                    color: isDark ? NeoColors.softGreen : NeoColors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'TAP TO PREVIEW',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? NeoColors.softGreen : NeoColors.green,
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
              return NeoCard(
                backgroundColor: isDark
                    ? NeoColors.darkSurface
                    : NeoColors.lightSurface,
                onTap: () => _openImageViewerModal(
                  context,
                  item.convertedFile,
                  format: item.targetFormat,
                  sizeBytes: item.convertedSizeBytes,
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
                              item.convertedFile,
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
                                  'Format: ${item.targetFormat}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              NeoBadge(
                                label: item.targetFormat.toUpperCase(),
                                backgroundColor: NeoColors.yellow,
                                fontSize: 11,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Size: ${FileUtils.formatBytes(item.convertedSizeBytes)}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: isDark
                                  ? NeoColors.textSecondaryDark
                                  : NeoColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const _ConvertTapPreviewBadge(),
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
                    title: 'Download ${state.results.length} Converted Photo(s)',
                    subtitle:
                        'Export all converted files directly to your device storage',
                  );
                  if (!proceed) return;

                  final saver = getIt<FileSaveService>();
                  File? lastSaved;
                  for (final res in state.results) {
                    lastSaved = await saver.saveFileToPublicStorage(
                      sourceFile: res.convertedFile,
                      subFolder: 'Converted',
                    );
                  }
                  if (context.mounted) {
                    NeoToast.showSuccess(
                      context,
                      '🎉 Saved ${state.results.length} converted photo(s) to Gallery!',
                      onTap: () => saver.openFileOrDirectory(
                        file: lastSaved,
                        subFolder: 'Converted',
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
                            .map((r) => XFile(r.convertedFile.path))
                            .toList();
                        final origin = FileShareService.getOrigin(context);
                        getIt<FileShareService>().shareFiles(
                          files: xFiles,
                          text: 'Converted with PicsTools!',
                          sharePositionOrigin: origin,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NeoButton(
                      label: 'CONVERT MORE',
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: NeoColors.borderLight,
                        size: 18,
                      ),
                      backgroundColor: NeoColors.yellow,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: () => bloc.add(ResetConverterEvent()),
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

  void _openImageViewerModal(
    BuildContext context,
    File imageFile, {
    required String format,
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
                                '$format • ${FileUtils.formatBytes(sizeBytes)}',
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
                          backgroundColor: NeoColors.cyan,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                          onPressed: () {
                            final origin =
                                FileShareService.getOrigin(modalContext);
                            getIt<FileShareService>().shareFiles(
                              files: [XFile(imageFile.path)],
                              text: 'Converted with PicsTools!',
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
                              title: 'Download Converted Photo',
                              subtitle:
                                  'Save converted photo to your device storage',
                            );
                            if (!proceed) return;

                            final saver = getIt<FileSaveService>();
                            final saved = await saver.saveFileToPublicStorage(
                              sourceFile: imageFile,
                              subFolder: 'Converted',
                            );
                            if (modalContext.mounted) {
                              NeoToast.showSuccess(
                                modalContext,
                                '🎉 Saved to Gallery!\n${saved.path.split(Platform.pathSeparator).last}',
                                onTap: () => saver.openFileOrDirectory(
                                  file: saved,
                                  subFolder: 'Converted',
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
}

class _ConvertTapPreviewBadge extends StatefulWidget {
  const _ConvertTapPreviewBadge();

  @override
  State<_ConvertTapPreviewBadge> createState() =>
      _ConvertTapPreviewBadgeState();
}

class _ConvertTapPreviewBadgeState extends State<_ConvertTapPreviewBadge>
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
                  ? NeoColors.green.withValues(
                      alpha: 0.22 + (_controller.value * 0.15),
                    )
                  : NeoColors.green.withValues(
                      alpha: 0.15 + (_controller.value * 0.1),
                    ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: (isDark ? NeoColors.softGreen : NeoColors.green)
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
                  color: isDark ? NeoColors.softGreen : NeoColors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  'TAP TO PREVIEW',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    color: isDark ? NeoColors.softGreen : NeoColors.green,
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

