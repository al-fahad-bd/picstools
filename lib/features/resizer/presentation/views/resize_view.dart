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
import '../../../../core/widgets/neo_text_field.dart';
import '../../../../core/widgets/neo_slider.dart';
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
      create: (context) => ResizerBloc(
        resizerService: getIt(),
        historyService: getIt(),
      ),
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
              if (_widthController.text.isEmpty || _heightController.text.isEmpty) {
                _widthController.text = state.targetWidth.toString();
                _heightController.text = state.targetHeight.toString();
              }
            }
            if (state is ResizerErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: NeoColors.red,
                ),
              );
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
              color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
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
                  child: const Icon(Icons.photo_library_rounded, color: NeoColors.borderLight),
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
    ResizerConfiguredState state,
    bool isDark,
  ) {
    final bloc = context.read<ResizerBloc>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Image Preview Frame
          NeoCard(
            backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
            shadowOffset: 4,
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    state.files.first,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: NeoBadge(
                    label: '${state.targetWidth} x ${state.targetHeight} px',
                    backgroundColor: NeoColors.cyan,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
                        'Original: ${state.originalWidth} x ${state.originalHeight} px',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                      Text(
                        '${state.files.length} photo(s) selected',
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  onPressed: () => bloc.add(ResetResizerEvent()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Custom Dimension Inputs
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
                    if (state.maintainAspectRatio && state.originalWidth > 0) {
                      h = ((w / state.originalWidth) * state.originalHeight).round();
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
                    if (state.maintainAspectRatio && state.originalHeight > 0) {
                      w = ((h / state.originalHeight) * state.originalWidth).round();
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
            backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
            shadowOffset: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      state.maintainAspectRatio ? Icons.lock_rounded : Icons.lock_open_rounded,
                      color: state.maintainAspectRatio ? NeoColors.yellow : Colors.grey,
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
                  onChanged: (_) => bloc.add(ToggleMaintainAspectRatioEvent()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Percentage Resize Slider
          NeoCard(
            backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
            child: NeoSlider(
              label: 'Percentage Scale',
              value: state.percentage,
              min: 10,
              max: 100,
              divisions: 90,
              activeColor: NeoColors.cyan,
              onChanged: (val) {
                bloc.add(SetPercentageResizeEvent(val));
                final newW = (state.originalWidth * (val / 100.0)).round();
                final newH = (state.originalHeight * (val / 100.0)).round();
                _widthController.text = newW.toString();
                _heightController.text = newH.toString();
              },
            ),
          ),
          const SizedBox(height: 24),

          // Resolution Presets
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

          NeoButton(
            label: 'RESIZE IMAGE(S)',
            icon: const Icon(Icons.aspect_ratio_rounded, color: NeoColors.borderLight),
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
          backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
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
            width: 90,
            height: 90,
            decoration: NeoStyles.neoDecoration(
              backgroundColor: NeoColors.cyan,
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
                backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
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
                  sourceFile: res.resizedFile,
                  subFolder: 'Resized',
                );
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saved resized photo(s) to Downloads/PicsTools/Resized!'),
                    backgroundColor: NeoColors.green,
                  ),
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
              final xFiles = state.results.map((r) => XFile(r.resizedFile.path)).toList();
              Share.shareXFiles(xFiles, text: 'Resized with PicsTools!');
            },
          ),
          const SizedBox(height: 12),
          NeoButton(
            label: 'RESIZE ANOTHER IMAGE',
            icon: const Icon(Icons.refresh_rounded, color: NeoColors.borderLight),
            backgroundColor: NeoColors.yellow,
            fullWidth: true,
            onPressed: () => bloc.add(ResetResizerEvent()),
          ),
        ],
      ),
    );
  }
}
