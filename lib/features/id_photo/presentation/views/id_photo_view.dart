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
import '../../../../core/widgets/neo_crop_canvas.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/file_save_service.dart';
import '../../models/id_photo_preset.dart';
import '../../services/id_photo_service.dart';
import '../../bloc/id_photo_bloc.dart';
import '../widgets/face_guide_overlay.dart';

class IdPhotoView extends StatelessWidget {
  const IdPhotoView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IdPhotoBloc(
        idPhotoService: getIt(),
        historyService: getIt(),
      ),
      child: const _IdPhotoViewContent(),
    );
  }
}

class _IdPhotoViewContent extends StatelessWidget {
  const _IdPhotoViewContent();

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = getIt<ImagePickerService>();
    final bloc = context.read<IdPhotoBloc>();
    final file = await picker.pickSingleImage(source: source);
    if (file != null) {
      bloc.add(SelectPhotoEvent(file));
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: NeoColors.red,
                ),
              );
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
              color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 28),

          // Preset Standards Showcase Grid
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Supported Passport Standards',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: IdPhotoPreset.defaultPresets.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final p = IdPhotoPreset.defaultPresets[index];
                return NeoCard(
                  backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
                  padding: const EdgeInsets.all(12),
                  shadowOffset: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NeoBadge(
                        label: p.country,
                        backgroundColor: NeoColors.orange,
                        fontSize: 10,
                      ),
                      Text(
                        p.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${p.widthMm} x ${p.heightMm} mm',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
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
                  child: const Icon(Icons.photo_library_rounded, color: NeoColors.borderLight),
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
                const Icon(Icons.chevron_right_rounded, color: NeoColors.borderLight),
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
                  child: const Icon(Icons.camera_alt_rounded, color: NeoColors.borderLight),
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
              backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
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
                    dropdownColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isDark ? NeoColors.textPrimaryDark : NeoColors.textPrimaryLight,
                    ),
                    items: IdPhotoPreset.defaultPresets.map((p) {
                      return DropdownMenuItem<IdPhotoPreset>(
                        value: p,
                        child: Text('${p.country} (${p.widthMm.round()}x${p.heightMm.round()}mm)'),
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
              Row(
                children: [
                  Text(
                    'Background:',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: bgColors.map((bg) {
                          final c = bg['color'] as Color;
                          final isSelected = state.bgColor == c;
                          return GestureDetector(
                            onTap: () => bloc.add(SetBackgroundColorEvent(c)),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: NeoStyles.neoDecoration(
                                backgroundColor: c,
                                radius: 8,
                                shadow: isSelected ? 3 : 1,
                              ),
                              child: Text(
                                bg['name'] as String,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: NeoColors.borderLight,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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
                      onTap: () => bloc.add(const SetPrintSheetTypeEvent(PrintSheetType.single)),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSheetChip(
                      label: '4x6" (6 Photos)',
                      isSelected: state.sheetType == PrintSheetType.sheet4x6,
                      onTap: () => bloc.add(const SetPrintSheetTypeEvent(PrintSheetType.sheet4x6)),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSheetChip(
                      label: 'A4 (24 Photos)',
                      isSelected: state.sheetType == PrintSheetType.sheetA4,
                      onTap: () => bloc.add(const SetPrintSheetTypeEvent(PrintSheetType.sheetA4)),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              NeoButton(
                label: 'GENERATE PASSPORT PHOTO & SHEET',
                icon: const Icon(Icons.badge_rounded, color: NeoColors.borderLight),
                backgroundColor: NeoColors.orange,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: () => bloc.add(StartProcessingIdPhotoEvent()),
              ),
            ],
          ),
        ),
      ],
    );
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
          backgroundColor: isSelected ? NeoColors.orange : (isDark ? NeoColors.darkBg : NeoColors.lightBg),
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
                valueColor: AlwaysStoppedAnimation<Color>(NeoColors.borderLight),
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
                      backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
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
                        backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
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
            icon: const Icon(Icons.download_rounded, color: NeoColors.borderLight),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saved Passport Photo & Print Sheet PDF to Downloads/PicsTools/ID_Photos!'),
                    backgroundColor: NeoColors.green,
                  ),
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
                if (res.printSheetPdfFile != null) XFile(res.printSheetPdfFile!.path),
              ];
              Share.shareXFiles(files, text: 'Created with PicsTools!');
            },
          ),
          const SizedBox(height: 12),
          NeoButton(
            label: 'CREATE ANOTHER ID PHOTO',
            icon: const Icon(Icons.refresh_rounded, color: NeoColors.borderLight),
            backgroundColor: NeoColors.yellow,
            fullWidth: true,
            onPressed: () => bloc.add(ResetIdPhotoEvent()),
          ),
        ],
      ),
    );
  }
}
