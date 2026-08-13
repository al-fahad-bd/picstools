import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:path/path.dart' as path;

import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_crop_canvas.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../cropper/services/image_cropper_service.dart';
import '../../services/image_pdf_service.dart';
import '../../bloc/pdf_bloc.dart';

class PdfView extends StatelessWidget {
  const PdfView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PdfBloc(pdfService: getIt(), historyService: getIt()),
      child: const _PdfViewContent(),
    );
  }
}

class _PdfViewContent extends StatelessWidget {
  const _PdfViewContent();

  Future<void> _pickImage(
    BuildContext context,
    ImageSource source, {
    bool isAppend = false,
  }) async {
    final picker = getIt<ImagePickerService>();
    final bloc = context.read<PdfBloc>();

    if (source == ImageSource.gallery) {
      final files = await picker.pickMultipleImages();
      if (files.isNotEmpty) {
        if (isAppend) {
          bloc.add(AddPdfImagesEvent(files));
        } else {
          bloc.add(SelectPdfImagesEvent(files));
        }
      }
    } else {
      final file = await picker.pickSingleImage(source: ImageSource.camera);
      if (file != null) {
        if (isAppend) {
          bloc.add(AddPdfImagesEvent([file]));
        } else {
          bloc.add(SelectPdfImagesEvent([file]));
        }
      }
    }
  }

  void _openPageCropSheet(
    BuildContext context,
    File originalFile,
    int pageIndex,
  ) {
    final bloc = context.read<PdfBloc>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Rect currentCropRect = const Rect.fromLTWH(0.05, 0.05, 0.9, 0.9);
    int rotationAngle = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: isDark ? NeoColors.darkBg : NeoColors.lightBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(color: NeoColors.borderLight, width: 3),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // Sheet Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Crop Page ${pageIndex + 1}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(modalContext),
                          ),
                        ],
                      ),
                    ),

                    // Crop Canvas
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: NeoCropCanvas(
                          imageFile: originalFile,
                          rotationAngle: rotationAngle,
                          onCropChanged: (rect) {
                            currentCropRect = rect;
                          },
                        ),
                      ),
                    ),

                    // Bottom Controls
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          NeoButton(
                            label: 'ROTATE 90°',
                            icon: const Icon(
                              Icons.rotate_right_rounded,
                              size: 20,
                              color: NeoColors.darkBg,
                            ),
                            backgroundColor: NeoColors.cyan,
                            onPressed: () {
                              setSheetState(() {
                                rotationAngle = (rotationAngle + 90) % 360;
                              });
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: NeoButton(
                              label: 'APPLY PAGE CROP',
                              icon: const Icon(
                                Icons.check_rounded,
                                size: 20,
                                color: NeoColors.darkBg,
                              ),
                              backgroundColor: NeoColors.yellow,
                              fullWidth: true,
                              onPressed: () async {
                                Navigator.pop(modalContext);
                                final cropper = getIt<ImageCropperService>();
                                final croppedRes = await cropper.processCrop(
                                  imageFile: originalFile,
                                  cropXRatio: currentCropRect.left,
                                  cropYRatio: currentCropRect.top,
                                  cropWidthRatio: currentCropRect.width,
                                  cropHeightRatio: currentCropRect.height,
                                  rotationAngle: rotationAngle,
                                );
                                bloc.add(
                                  UpdatePdfPageImageEvent(
                                    pageIndex,
                                    croppedRes.croppedFile,
                                  ),
                                );
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
      },
    );
  }

  void _openPdfPreviewModal(BuildContext context, File pdfFile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
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
                // Modal Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: NeoStyles.neoDecoration(
                              backgroundColor: NeoColors.purple,
                              radius: 8,
                              shadow: 2,
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf_rounded,
                              size: 18,
                              color: NeoColors.lightSurface,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'PDF Document Preview',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1.5),

                // Interactive PDF Viewer
                Expanded(
                  child: PdfPreview(
                    build: (format) => pdfFile.readAsBytesSync(),
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    canDebug: false,
                    allowPrinting: true,
                    allowSharing: true,
                    pdfFileName: path.basename(pdfFile.path),
                    scrollViewDecoration: BoxDecoration(
                      color: isDark ? NeoColors.darkBg : NeoColors.lightBg,
                    ),
                  ),
                ),
              ],
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
            child: const Icon(Icons.arrow_back_rounded, size: 18),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Image → PDF Converter',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<PdfBloc, PdfState>(
          listener: (context, state) {
            if (state is PdfErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: NeoColors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is PdfInitialState) {
              return _buildEmptyState(context, isDark);
            } else if (state is PdfConfiguredState) {
              return _buildConfigurationState(context, state, isDark);
            } else if (state is PdfProcessingState) {
              return _buildProcessingState(context, isDark);
            } else if (state is PdfSuccessState) {
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
              backgroundColor: NeoColors.purple,
              radius: 50,
              shadow: 5,
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              size: 50,
              color: NeoColors.lightSurface,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Convert Photos to PDF',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Snap document photos with camera or pick from gallery, crop individual pages, and export PDF.',
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
            backgroundColor: NeoColors.purple,
            shadowOffset: 4,
            onTap: () => _pickImage(context, ImageSource.gallery),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.lightSurface,
                    radius: 12,
                    shadow: 2,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: NeoColors.purple,
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
                          color: NeoColors.lightSurface,
                        ),
                      ),
                      Text(
                        'Pick multiple photos from device',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: NeoColors.lightSurface.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: NeoColors.lightSurface,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          NeoCard(
            backgroundColor: NeoColors.softCyan,
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
                        'Snap Document with Camera',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                      Text(
                        'Capture document photos instantly',
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
    PdfConfiguredState state,
    bool isDark,
  ) {
    final bloc = context.read<PdfBloc>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PDF Pages (Tap to Crop Page)',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_a_photo_rounded, size: 20),
                    onPressed: () =>
                        _pickImage(context, ImageSource.camera, isAppend: true),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 20,
                    ),
                    onPressed: () => _pickImage(
                      context,
                      ImageSource.gallery,
                      isAppend: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.files.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final file = state.files[index];
                return GestureDetector(
                  onTap: () => _openPageCropSheet(context, file, index),
                  child: NeoCard(
                    backgroundColor: isDark
                        ? NeoColors.darkSurface
                        : NeoColors.lightSurface,
                    padding: const EdgeInsets.all(6),
                    shadowOffset: 3,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            width: 95,
                            height: 125,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: NeoBadge(
                            label: 'P${index + 1}',
                            backgroundColor: NeoColors.purple,
                            fontSize: 9,
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: NeoColors.yellow,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.crop,
                              size: 14,
                              color: NeoColors.borderLight,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => bloc.add(RemovePdfPageEvent(index)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: NeoColors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 12,
                                color: NeoColors.borderLight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          NeoCard(
            backgroundColor: NeoColors.purple,
            shadowOffset: 3,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.lightSurface,
                    radius: 10,
                    shadow: 2,
                  ),
                  child: Center(
                    child: Text(
                      '${state.files.length}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.purple,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '${state.files.length} Page(s) in PDF',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: NeoColors.lightSurface,
                    ),
                  ),
                ),
                NeoButton(
                  label: 'CLEAR',
                  backgroundColor: NeoColors.yellow,
                  textColor: NeoColors.borderLight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  onPressed: () => bloc.add(ResetPdfEvent()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Paper Format
          Text(
            'Paper Format',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildChoiceChip(
                  label: 'A4 Page',
                  isSelected: state.pageFormat == PdfPageFormatType.a4,
                  color: NeoColors.purple,
                  onTap: () => bloc.add(
                    const SetPdfPageFormatEvent(PdfPageFormatType.a4),
                  ),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildChoiceChip(
                  label: 'US Letter',
                  isSelected: state.pageFormat == PdfPageFormatType.letter,
                  color: NeoColors.purple,
                  onTap: () => bloc.add(
                    const SetPdfPageFormatEvent(PdfPageFormatType.letter),
                  ),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildChoiceChip(
                  label: 'Original',
                  isSelected: state.pageFormat == PdfPageFormatType.original,
                  color: NeoColors.purple,
                  onTap: () => bloc.add(
                    const SetPdfPageFormatEvent(PdfPageFormatType.original),
                  ),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Orientation & Margins
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orientation',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildChoiceChip(
                            label: 'Portrait',
                            isSelected:
                                state.orientation == PdfOrientation.portrait,
                            color: NeoColors.cyan,
                            onTap: () => bloc.add(
                              const SetPdfOrientationEvent(
                                PdfOrientation.portrait,
                              ),
                            ),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildChoiceChip(
                            label: 'Landscape',
                            isSelected:
                                state.orientation == PdfOrientation.landscape,
                            color: NeoColors.cyan,
                            onTap: () => bloc.add(
                              const SetPdfOrientationEvent(
                                PdfOrientation.landscape,
                              ),
                            ),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'Page Margins',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildChoiceChip(
                  label: 'None',
                  isSelected: state.margin == PdfMarginType.none,
                  color: NeoColors.yellow,
                  onTap: () =>
                      bloc.add(const SetPdfMarginEvent(PdfMarginType.none)),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChoiceChip(
                  label: 'Small',
                  isSelected: state.margin == PdfMarginType.small,
                  color: NeoColors.yellow,
                  onTap: () =>
                      bloc.add(const SetPdfMarginEvent(PdfMarginType.small)),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChoiceChip(
                  label: 'Medium',
                  isSelected: state.margin == PdfMarginType.medium,
                  color: NeoColors.yellow,
                  onTap: () =>
                      bloc.add(const SetPdfMarginEvent(PdfMarginType.medium)),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),

          // Build Action Button
          NeoButton(
            label: 'CREATE PDF DOCUMENT',
            icon: const Icon(
              Icons.picture_as_pdf_rounded,
              color: NeoColors.lightSurface,
            ),
            backgroundColor: NeoColors.purple,
            textColor: NeoColors.lightSurface,
            fullWidth: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
            onPressed: () => bloc.add(StartPdfGenerationEvent()),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final isDarkAccent =
        isSelected && (color == NeoColors.purple || color == NeoColors.blue);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: NeoStyles.neoDecoration(
          backgroundColor: isSelected
              ? color
              : (isDark ? NeoColors.darkSurface : NeoColors.lightSurface),
          radius: 10,
          shadow: isSelected ? 3 : 1,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? (isDarkAccent
                        ? NeoColors.lightSurface
                        : NeoColors.borderLight)
                  : (isDark
                        ? NeoColors.textPrimaryDark
                        : NeoColors.textPrimaryLight),
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
              backgroundColor: NeoColors.purple,
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
            'Compiling PDF Document...',
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
    PdfSuccessState state,
    bool isDark,
  ) {
    final bloc = context.read<PdfBloc>();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeoCard(
                backgroundColor: NeoColors.purple,
                shadowOffset: 5,
                padding: const EdgeInsets.all(20),
                onTap: () =>
                    _openPdfPreviewModal(context, state.result.pdfFile),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const NeoBadge(
                          label: 'PDF READY',
                          backgroundColor: NeoColors.yellow,
                          textColor: NeoColors.borderLight,
                          fontSize: 12,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.touch_app_rounded,
                                size: 12,
                                color: NeoColors.lightSurface,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'TAP TO PREVIEW',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: NeoColors.lightSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${state.result.pageCount} Page PDF Document',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.lightSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'File Size: ${FileUtils.formatBytes(state.result.fileSizeBytes)}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: NeoColors.lightSurface.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 120),

              // Action Buttons
              NeoButton(
                label: 'SAVE TO DEVICE',
                icon: const Icon(
                  Icons.download_rounded,
                  color: NeoColors.borderLight,
                ),
                backgroundColor: NeoColors.green,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 16),
                onPressed: () async {
                  final saver = getIt<FileSaveService>();
                  final saved = await saver.saveFileToPublicStorage(
                    sourceFile: state.result.pdfFile,
                    subFolder: 'PDF',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Saved PDF to: ${saved.path}'),
                        backgroundColor: NeoColors.green,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),

              NeoButton(
                label: 'SHARE PDF DOCUMENT',
                icon: const Icon(
                  Icons.share_rounded,
                  color: NeoColors.lightSurface,
                ),
                backgroundColor: NeoColors.purple,
                textColor: NeoColors.lightSurface,
                fullWidth: true,
                onPressed: () {
                  final box = context.findRenderObject() as RenderBox?;
                  final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;
                  Share.shareXFiles([
                    XFile(state.result.pdfFile.path),
                  ], text: 'Created with PicsTools!', sharePositionOrigin: origin);
                },
              ),
              const SizedBox(height: 12),

              NeoButton(
                label: 'CREATE ANOTHER PDF',
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: NeoColors.borderLight,
                ),
                backgroundColor: NeoColors.yellow,
                fullWidth: true,
                onPressed: () => bloc.add(ResetPdfEvent()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
