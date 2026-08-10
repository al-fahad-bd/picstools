import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_slider.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/file_save_service.dart';
import '../../bloc/converter_bloc.dart';

class ConvertView extends StatelessWidget {
  const ConvertView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConverterBloc(
        converterService: getIt(),
        historyService: getIt(),
      ),
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
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: NeoStyles.neoDecoration(
              backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
              radius: 10,
              shadow: 2,
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 18),
          ),
          onPressed: () => context.pop(),
        ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: NeoColors.red,
                ),
              );
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
              color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
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
                  child: const Icon(Icons.photo_library_rounded, color: NeoColors.borderLight),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Photos to Convert',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                      Text(
                        'Batch selection supported',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: NeoColors.borderLight.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: NeoColors.borderLight),
              ],
            ),
          ),
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
    final formats = [
      {'name': 'JPG', 'sub': 'Standard Photo', 'color': NeoColors.yellow},
      {'name': 'PNG', 'sub': 'Lossless & Transparency', 'color': NeoColors.cyan},
      {'name': 'WEBP', 'sub': 'Modern Web Format', 'color': NeoColors.green},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Photos Live Thumbnail Strip
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.files.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final file = state.files[index];
                return NeoCard(
                  backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
                  padding: const EdgeInsets.all(4),
                  shadowOffset: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      file,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  backgroundColor: isSelected ? (fmt['color'] as Color) : (isDark ? NeoColors.darkSurface : NeoColors.lightSurface),
                  shadowOffset: isSelected ? 4 : 2,
                  onTap: () => bloc.add(SetTargetFormatEvent(fmt['name'] as String)),
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
                                  : (isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight),
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
                          child: const Icon(Icons.check, size: 16, color: Colors.white),
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
              backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
              child: NeoSlider(
                label: 'Encoder Quality',
                value: state.quality.toDouble(),
                min: 10,
                max: 100,
                divisions: 90,
                activeColor: NeoColors.green,
                onChanged: (val) => bloc.add(SetConvertQualityEvent(val.round())),
              ),
            ),
            const SizedBox(height: 36),
          ],

          NeoButton(
            label: 'CONVERT TO ${state.targetFormat}',
            icon: const Icon(Icons.transform_rounded, color: NeoColors.borderLight),
            backgroundColor: NeoColors.green,
            fullWidth: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
            onPressed: () => bloc.add(StartConversionEvent()),
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
            width: 90,
            height: 90,
            decoration: NeoStyles.neoDecoration(
              backgroundColor: NeoColors.green,
              radius: 45,
              shadow: 4,
            ),
            child: const Center(
              child: SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(NeoColors.borderLight),
                ),
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
              color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 12,
              backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          NeoCard(
            backgroundColor: NeoColors.softGreen,
            shadowOffset: 5,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const NeoBadge(
                  label: 'CONVERSION COMPLETE',
                  backgroundColor: NeoColors.green,
                  fontSize: 12,
                ),
                const SizedBox(height: 12),
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
          const SizedBox(height: 20),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.results.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = state.results[index];
              return NeoCard(
                backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        item.convertedFile,
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
                            'Format: ${item.targetFormat}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Size: ${FileUtils.formatBytes(item.convertedSizeBytes)}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          NeoButton(
            label: 'SAVE TO DEVICE',
            icon: const Icon(Icons.download_rounded, color: NeoColors.borderLight),
            backgroundColor: NeoColors.green,
            fullWidth: true,
            onPressed: () async {
              final saver = getIt<FileSaveService>();
              for (final res in state.results) {
                await saver.saveFileToPublicStorage(
                  sourceFile: res.convertedFile,
                  subFolder: 'Converted',
                );
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saved converted photo(s) to Downloads/PicsTools/Converted!'),
                    backgroundColor: NeoColors.green,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          NeoButton(
            label: 'SHARE CONVERTED FILE(S)',
            icon: const Icon(Icons.share_rounded, color: NeoColors.borderLight),
            backgroundColor: NeoColors.green,
            fullWidth: true,
            onPressed: () {
              final xFiles = state.results.map((r) => XFile(r.convertedFile.path)).toList();
              Share.shareXFiles(xFiles, text: 'Converted with PicsTools!');
            },
          ),
          const SizedBox(height: 12),
          NeoButton(
            label: 'CONVERT MORE PHOTOS',
            icon: const Icon(Icons.refresh_rounded, color: NeoColors.borderLight),
            backgroundColor: NeoColors.yellow,
            fullWidth: true,
            onPressed: () => bloc.add(ResetConverterEvent()),
          ),
        ],
      ),
    );
  }
}
