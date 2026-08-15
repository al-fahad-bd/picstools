import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../bloc/background_remover_bloc.dart';
import '../bloc/background_remover_event.dart';
import '../bloc/background_remover_state.dart';
import '../widgets/checkerboard_container.dart';
import '../widgets/comparison_slider.dart';
import '../widgets/model_download_card.dart';
import '../widgets/model_downloading_card.dart';
import '../widgets/privacy_badge.dart';

class BackgroundRemoverView extends StatelessWidget {
  const BackgroundRemoverView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<BackgroundRemoverBloc>()..add(CheckModelStatusEvent()),
      child: const _BackgroundRemoverViewContent(),
    );
  }
}

class _BackgroundRemoverViewContent extends StatefulWidget {
  const _BackgroundRemoverViewContent();

  @override
  State<_BackgroundRemoverViewContent> createState() =>
      _BackgroundRemoverViewContentState();
}

class _BackgroundRemoverViewContentState
    extends State<_BackgroundRemoverViewContent> {
  int _previewMode =
      0; // 0 = Split Slider, 1 = Transparent Only, 2 = Original Only
  bool _isSaving = false;

  void _playSound(String type) {
    try {
      getIt<SoundService>().playClickSound();
    } catch (_) {}
  }

  void _showNeoToast(
    BuildContext context,
    String message, {
    Color color = NeoColors.green,
    IconData icon = Icons.check_circle_rounded,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        duration: const Duration(milliseconds: 2500),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: NeoStyles.neoDecoration(
            backgroundColor: color,
            radius: 16,
            shadow: 4,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: NeoColors.darkSurface),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.darkSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    _playSound('click');
    final picker = getIt<ImagePickerService>();
    final file = await picker.pickSingleImage(source: source);
    if (file != null && context.mounted) {
      context.read<BackgroundRemoverBloc>().add(SelectImageEvent(file));
    }
  }

  Future<void> _saveResult(BuildContext context, File pngFile) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    _playSound('save');

    try {
      final saveService = getIt<FileSaveService>();
      final savedFile = await saveService.saveFileToPublicStorage(
        sourceFile: pngFile,
        subFolder: 'RemovedBG',
      );

      if (context.mounted) {
        _showNeoToast(
          context,
          '🎉 Saved Transparent PNG to Gallery!\n${savedFile.path.split(Platform.pathSeparator).last}',
          color: NeoColors.green,
          icon: Icons.download_done_rounded,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showNeoToast(
          context,
          'Failed to save image: $e',
          color: NeoColors.pink,
          icon: Icons.error_outline_rounded,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _shareResult(File pngFile) async {
    _playSound('click');
    try {
      await Share.shareXFiles([
        XFile(pngFile.path, mimeType: 'image/png'),
      ], text: 'Transparent PNG created with Pics Tools');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? NeoColors.borderDark : NeoColors.borderLight;

    return Scaffold(
      backgroundColor: isDark ? NeoColors.darkBg : NeoColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark
            ? NeoColors.darkSurface
            : NeoColors.lightSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: NeoStyles.neoDecoration(
              backgroundColor: isDark
                  ? NeoColors.darkSurface
                  : NeoColors.lightSurface,
              radius: 10,
              shadow: 2,
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 18,
              color: isDark
                  ? NeoColors.textPrimaryDark
                  : NeoColors.textPrimaryLight,
            ),
          ),
          onPressed: () {
            _playSound('click');
            context.pop();
          },
        ),
        title: Row(
          children: [
            Text(
              'Remove BG',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: isDark
                    ? NeoColors.textPrimaryDark
                    : NeoColors.textPrimaryLight,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: NeoColors.purple,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor, width: 1.2),
              ),
              child: Text(
                '🤖 ON-DEVICE AI',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: NeoColors.lightSurface,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<BackgroundRemoverBloc, BackgroundRemoverState>(
          listener: (context, state) {
            if (state is BackgroundRemovalSuccessState) {
              _playSound('success');
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildStateContent(context, state, isDark, borderColor),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStateContent(
    BuildContext context,
    BackgroundRemoverState state,
    bool isDark,
    Color borderColor,
  ) {
    if (state is BackgroundRemoverLoadingState) {
      return _buildLoadingView(state.message, isDark, borderColor);
    }

    if (state is ModelNotDownloadedState) {
      return ModelDownloadCard(
        modelInfo: state.modelInfo,
        isDark: isDark,
        onDownload: () {
          _playSound('click');
          context.read<BackgroundRemoverBloc>().add(DownloadModelEvent());
        },
      );
    }

    if (state is ModelDownloadingState) {
      return ModelDownloadingCard(
        progress: state.progress,
        receivedSize: state.formattedReceivedSize,
        totalSize: state.formattedTotalSize,
        percentage: state.percentage,
        isDark: isDark,
        onCancel: () {
          _playSound('click');
          context.read<BackgroundRemoverBloc>().add(CancelDownloadEvent());
        },
      );
    }

    if (state is ModelReadyState) {
      return _buildReadyPickerView(context, state, isDark, borderColor);
    }

    if (state is BackgroundRemovingState) {
      return _buildProcessingView(state, isDark, borderColor);
    }

    if (state is BackgroundRemovalSuccessState) {
      return _buildSuccessView(context, state, isDark, borderColor);
    }

    if (state is BackgroundRemoverErrorState) {
      return _buildErrorView(context, state, isDark, borderColor);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingView(String message, bool isDark, Color borderColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: NeoCard(
          backgroundColor: isDark
              ? NeoColors.darkSurface
              : NeoColors.lightSurface,
          borderColor: borderColor,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const CircularProgressIndicator(
                strokeWidth: 3,
                color: NeoColors.purple,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? NeoColors.textPrimaryDark
                      : NeoColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadyPickerView(
    BuildContext context,
    ModelReadyState state,
    bool isDark,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeoCard(
          backgroundColor: isDark
              ? NeoColors.darkSurface
              : NeoColors.softPurple,
          borderColor: borderColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Banner Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: NeoColors.green,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Text(
                      '✓ AI MODEL READY',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.borderLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    state.modelInfo.displayName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? NeoColors.textSecondaryDark
                          : NeoColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Select Image for Instant Cutout',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? NeoColors.textPrimaryDark
                      : NeoColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Choose any photo with people, products, animals, or objects. The AI runs locally to extract a continuous alpha mask with ultra-fine edge details.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? NeoColors.textSecondaryDark
                      : NeoColors.textSecondaryLight,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Choose from Gallery Button
              NeoButton(
                label: 'Choose Photo from Gallery',
                icon: const Icon(
                  Icons.photo_library_rounded,
                  size: 18,
                  color: NeoColors.borderLight,
                ),
                backgroundColor: NeoColors.yellow,
                textColor: NeoColors.borderLight,
                fullWidth: true,
                onPressed: () => _pickImage(context, ImageSource.gallery),
              ),
              const SizedBox(height: 12),

              // Take Photo Button
              NeoButton(
                label: 'Take Photo with Camera',
                icon: Icon(
                  Icons.camera_alt_rounded,
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
                fullWidth: true,
                onPressed: () => _pickImage(context, ImageSource.camera),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PrivacyBadge(isDark: isDark),
      ],
    );
  }

  Widget _buildProcessingView(
    BackgroundRemovingState state,
    bool isDark,
    Color borderColor,
  ) {
    return Column(
      children: [
        NeoCard(
          backgroundColor: isDark
              ? NeoColors.darkSurface
              : NeoColors.softYellow,
          borderColor: borderColor,
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Thumbnail preview of original
              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(state.originalImage, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),

              const CircularProgressIndicator(
                strokeWidth: 3.5,
                color: NeoColors.purple,
              ),
              const SizedBox(height: 18),

              Text(
                'Removing Background...',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? NeoColors.textPrimaryDark
                      : NeoColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                'Running BiRefNet Lite ONNX on-device inference',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? NeoColors.textSecondaryDark
                      : NeoColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PrivacyBadge(isDark: isDark),
      ],
    );
  }

  Widget _buildSuccessView(
    BuildContext context,
    BackgroundRemovalSuccessState state,
    bool isDark,
    Color borderColor,
  ) {
    final result = state.result;
    final origKb = (result.originalSizeBytes / 1024).toStringAsFixed(1);
    final pngKb = (result.processedSizeBytes / 1024).toStringAsFixed(1);
    final durMs = result.duration.inMilliseconds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview Mode Toggle Tabs
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              _buildTabButton('Split View', 0, isDark),
              _buildTabButton('Cutout Only', 1, isDark),
              _buildTabButton('Original', 2, isDark),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Main Image Canvas Area
        if (_previewMode == 0) ...[
          ComparisonSlider(
            originalImage: result.originalFile,
            transparentImage: result.transparentPngFile,
            height: 360,
          ),
        ] else if (_previewMode == 1) ...[
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
          label: _isSaving ? 'Saving PNG...' : 'Save Transparent PNG',
          icon: const Icon(
            Icons.file_download_rounded,
            size: 18,
            color: NeoColors.borderLight,
          ),
          backgroundColor: NeoColors.yellow,
          textColor: NeoColors.borderLight,
          isLoading: _isSaving,
          fullWidth: true,
          onPressed: () => _saveResult(context, result.transparentPngFile),
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
                onPressed: () => _shareResult(result.transparentPngFile),
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
                onPressed: () {
                  _playSound('click');
                  context.read<BackgroundRemoverBloc>().add(
                    ResetBackgroundRemoverEvent(),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabButton(String title, int index, bool isDark) {
    final isSelected = _previewMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _playSound('click');
          setState(() => _previewMode = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? NeoColors.purple : NeoColors.yellow)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: isDark
                        ? NeoColors.borderDark
                        : NeoColors.borderLight,
                    width: 1.5,
                  )
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? NeoColors.lightSurface : NeoColors.borderLight)
                    : (isDark
                          ? NeoColors.textSecondaryDark
                          : NeoColors.textSecondaryLight),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    BackgroundRemoverErrorState state,
    bool isDark,
    Color borderColor,
  ) {
    return NeoCard(
      backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.softPink,
      borderColor: borderColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NeoColors.pink,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 28,
              color: NeoColors.lightSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark
                  ? NeoColors.textPrimaryDark
                  : NeoColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black26
                  : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: SelectableText(
              state.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? NeoColors.textSecondaryDark
                    : NeoColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(height: 20),
          NeoButton(
            label: 'Try Again',
            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
              color: NeoColors.borderLight,
            ),
            backgroundColor: NeoColors.yellow,
            textColor: NeoColors.borderLight,
            onPressed: () {
              _playSound('click');
              context.read<BackgroundRemoverBloc>().add(
                ResetBackgroundRemoverEvent(),
              );
            },
          ),
        ],
      ),
    );
  }
}
