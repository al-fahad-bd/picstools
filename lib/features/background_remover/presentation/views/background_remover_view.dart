import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/neo_colors.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/widgets/neo_back_button.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../bloc/background_remover_bloc.dart';
import '../bloc/background_remover_event.dart';
import '../bloc/background_remover_state.dart';
import '../widgets/bg_remover_loading_card.dart';
import '../widgets/model_download_card.dart';
import '../widgets/model_downloading_card.dart';
import '../widgets/ready_picker_card.dart';
import '../widgets/processing_card.dart';
import '../widgets/bg_removal_success_view.dart';
import '../widgets/bg_removal_error_card.dart';

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
  int _previewMode = 0; // 0 = Split Slider, 1 = Transparent Only, 2 = Original Only
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
    NeoToast.show(context, message, color: color, icon: icon);
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
        leading: const NeoBackButton(),
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
              child: _buildStateContent(context, state, isDark),
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
  ) {
    if (state is BackgroundRemoverLoadingState) {
      return BgRemoverLoadingCard(
        message: state.message,
        isDark: isDark,
      );
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
      return ReadyPickerCard(
        modelInfo: state.modelInfo,
        isDark: isDark,
        onPickImage: (source) => _pickImage(context, source),
      );
    }

    if (state is BackgroundRemovingState) {
      return ProcessingCard(
        originalImage: state.originalImage,
        isDark: isDark,
      );
    }

    if (state is BackgroundRemovalSuccessState) {
      return BgRemovalSuccessView(
        result: state.result,
        previewMode: _previewMode,
        isDark: isDark,
        isSaving: _isSaving,
        onSelectMode: (mode) {
          _playSound('click');
          setState(() => _previewMode = mode);
        },
        onSave: () => _saveResult(context, state.result.transparentPngFile),
        onShare: () => _shareResult(state.result.transparentPngFile),
        onReset: () {
          _playSound('click');
          context.read<BackgroundRemoverBloc>().add(
                ResetBackgroundRemoverEvent(),
              );
        },
      );
    }

    if (state is BackgroundRemoverErrorState) {
      return BgRemovalErrorCard(
        message: state.message,
        isDark: isDark,
        onRetry: () {
          _playSound('click');
          context.read<BackgroundRemoverBloc>().add(
                ResetBackgroundRemoverEvent(),
              );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
