import '../../../../core/widgets/neo_back_button.dart';
import 'dart:io';
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
import '../../../../core/utils/file_utils.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/file_save_service.dart';
import '../../bloc/cropper_bloc.dart';

class CropView extends StatelessWidget {
  const CropView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CropperBloc(cropperService: getIt(), historyService: getIt()),
      child: const _CropViewContent(),
    );
  }
}

class _CropViewContent extends StatelessWidget {
  const _CropViewContent();

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = getIt<ImagePickerService>();
    final bloc = context.read<CropperBloc>();
    final file = await picker.pickSingleImage(source: source);
    if (file != null) {
      bloc.add(SelectCropImageEvent(file));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const NeoBackButton(),
        title: Text(
          'Crop & Rotate',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<CropperBloc, CropperState>(
          listener: (context, state) {
            if (state is CropperErrorState) {
              NeoToast.showError(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is CropperInitialState) {
              return _buildEmptyState(context, isDark);
            } else if (state is CropperConfiguredState) {
              return _buildConfigurationState(context, state, isDark);
            } else if (state is CropperProcessingState) {
              return _buildProcessingState(context, isDark);
            } else if (state is CropperSuccessState) {
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
              backgroundColor: NeoColors.pink,
              radius: 50,
              shadow: 5,
            ),
            child: Icon(
              Icons.crop_rounded,
              size: 50,
              color: NeoColors.getContrastColor(NeoColors.pink),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Crop, Rotate & Flip',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Drag handles visually on the photo to crop. Lock aspect ratios (1:1, 4:3, 16:9), rotate or flip.',
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
            backgroundColor: NeoColors.softPink,
            shadowOffset: 4,
            onTap: () => _pickImage(context, ImageSource.gallery),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.pink,
                    radius: 12,
                    shadow: 2,
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: NeoColors.getContrastColor(NeoColors.pink),
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
                        'Pick existing photo to crop',
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
                        'Take Photo with Camera',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Capture instant photo to crop',
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

  Widget _buildConfigurationState(
    BuildContext context,
    CropperConfiguredState state,
    bool isDark,
  ) {
    final bloc = context.read<CropperBloc>();

    final ratios = [
      {'name': 'Free', 'val': null},
      {'name': '1:1 Square', 'val': 1.0},
      {'name': '4:3 Standard', 'val': 4.0 / 3.0},
      {'name': '3:4 Portrait', 'val': 3.0 / 4.0},
      {'name': '16:9 Wide', 'val': 16.0 / 9.0},
      {'name': '9:16 Story', 'val': 9.0 / 16.0},
    ];

    return Column(
      children: [
        // Interactive Canvas
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: NeoCard(
              backgroundColor: isDark
                  ? NeoColors.darkSurface
                  : NeoColors.lightSurface,
              padding: const EdgeInsets.all(8),
              shadowOffset: 4,
              child: NeoCropCanvas(
                imageFile: state.file,
                aspectRatio: state.selectedRatioValue,
                rotationAngle: state.rotationAngle,
                flipHorizontal: state.flipHorizontal,
                flipVertical: state.flipVertical,
                onCropChanged: (rect) {
                  bloc.add(UpdateNormCropRectEvent(rect));
                },
              ),
            ),
          ),
        ),

        // Controls Drawer
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
              // Toolbar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildToolActionBtn(
                    icon: Icons.rotate_right_rounded,
                    label: 'Rotate 90°',
                    onTap: () => bloc.add(Rotate90ClockwiseEvent()),
                    isDark: isDark,
                  ),
                  _buildToolActionBtn(
                    icon: Icons.flip_rounded,
                    label: 'Flip Horiz',
                    isActive: state.flipHorizontal,
                    onTap: () => bloc.add(ToggleFlipHorizontalEvent()),
                    isDark: isDark,
                  ),
                  _buildToolActionBtn(
                    icon: Icons.swap_vert_rounded,
                    label: 'Flip Vert',
                    isActive: state.flipVertical,
                    onTap: () => bloc.add(ToggleFlipVerticalEvent()),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Ratios
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ratios.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final r = ratios[index];
                    final isSelected = state.selectedRatioName == r['name'];
                    return GestureDetector(
                      onTap: () => bloc.add(
                        SetCropAspectRatioEvent(
                          r['name'] as String,
                          r['val'] as double?,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: NeoStyles.neoDecoration(
                          backgroundColor: isSelected
                              ? NeoColors.pink
                              : (isDark ? NeoColors.darkBg : NeoColors.lightBg),
                          radius: 10,
                          shadow: isSelected ? 3 : 1,
                        ),
                        child: Text(
                          r['name'] as String,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? NeoColors.borderLight : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              NeoButton(
                label: 'APPLY CROP & SAVE',
                backgroundColor: NeoColors.pink,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: () => bloc.add(StartCropEvent()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: NeoCard(
        backgroundColor: isActive
            ? NeoColors.pink
            : (isDark ? NeoColors.darkBg : NeoColors.lightBg),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shadowOffset: 2,
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? NeoColors.borderLight : null,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? NeoColors.borderLight : null,
              ),
            ),
          ],
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
              backgroundColor: NeoColors.pink,
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
            'Processing Crop & Rotate...',
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
    CropperSuccessState state,
    bool isDark,
  ) {
    final bloc = context.read<CropperBloc>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          NeoCard(
            backgroundColor: NeoColors.softPink,
            shadowOffset: 5,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const NeoBadge(
                  label: 'CROP SUCCESSFUL',
                  backgroundColor: NeoColors.pink,
                  fontSize: 12,
                ),
                const SizedBox(height: 12),
                Text(
                  '${state.result.croppedWidth} x ${state.result.croppedHeight} px',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.borderLight,
                  ),
                ),
                Text(
                  'File Size: ${FileUtils.formatBytes(state.result.croppedSizeBytes)}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: NeoColors.borderLight.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          NeoCard(
            backgroundColor: isDark
                ? NeoColors.darkSurface
                : NeoColors.lightSurface,
            padding: const EdgeInsets.all(12),
            shadowOffset: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                state.result.croppedFile,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
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
              final saved = await saver.saveFileToPublicStorage(
                sourceFile: state.result.croppedFile,
                subFolder: 'Cropped',
              );
              if (context.mounted) {
                NeoToast.showSuccess(
                  context,
                  '🎉 Saved cropped photo to Gallery!\n${saved.path.split(Platform.pathSeparator).last}',
                );
              }
            },
          ),
          const SizedBox(height: 12),
          NeoButton(
            label: 'SHARE CROPPED PHOTO',
            icon: const Icon(Icons.share_rounded, color: NeoColors.borderLight),
            backgroundColor: NeoColors.pink,
            fullWidth: true,
            onPressed: () {
              final box = context.findRenderObject() as RenderBox?;
              final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;
              Share.shareXFiles([
                XFile(state.result.croppedFile.path),
              ], text: 'Cropped with PicsTools!', sharePositionOrigin: origin);
            },
          ),
          const SizedBox(height: 12),
          NeoButton(
            label: 'CROP ANOTHER IMAGE',
            icon: const Icon(
              Icons.refresh_rounded,
              color: NeoColors.borderLight,
            ),
            backgroundColor: NeoColors.yellow,
            fullWidth: true,
            onPressed: () => bloc.add(ResetCropperEvent()),
          ),
        ],
      ),
    );
  }
}
