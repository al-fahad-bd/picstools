import '../../../../core/widgets/neo_back_button.dart';
import 'dart:io';
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
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/file_save_service.dart';
import '../widgets/neo_signature_canvas.dart';
import '../../bloc/signature_bloc.dart';
import '../../services/signature_service.dart';

class SignatureView extends StatelessWidget {
  const SignatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SignatureBloc(signatureService: getIt(), historyService: getIt()),
      child: const _SignatureViewContent(),
    );
  }
}

class _SignatureViewContent extends StatefulWidget {
  const _SignatureViewContent();

  @override
  State<_SignatureViewContent> createState() => _SignatureViewContentState();
}

class _SignatureViewContentState extends State<_SignatureViewContent> {
  String?
  _selectedMode; // null = Selection screen, 'draw' = Draw Canvas, 'scan' = Scan Paper
  final GlobalKey _canvasKey = GlobalKey();

  Future<void> _scanPaperSignature(
    BuildContext context,
    ImageSource source,
  ) async {
    final picker = getIt<ImagePickerService>();
    final bloc = context.read<SignatureBloc>();
    final file = await picker.pickSingleImage(source: source);
    if (file != null) {
      bloc.add(ScanPaperSignatureEvent(file));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String appBarTitle = 'Digital Signature Creator';
    if (_selectedMode == 'draw') {
      appBarTitle = 'Draw Digital Signature';
    } else if (_selectedMode == 'scan') {
      appBarTitle = 'Scan Paper Signature';
    }

    return Scaffold(
      appBar: AppBar(
        leading: NeoBackButton(
          onPressed: () {
            if (_selectedMode != null) {
              setState(() {
                _selectedMode = null;
              });
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          appBarTitle,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<SignatureBloc, SignatureState>(
          listener: (context, state) {
            if (state is SignatureErrorState) {
              NeoToast.showError(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is SignatureProcessingState) {
              return _buildProcessingState(context, isDark);
            } else if (state is SignatureSuccessState) {
              return _buildSuccessState(context, state, isDark);
            } else if (state is SignatureInitialState) {
              if (_selectedMode == 'draw') {
                return _buildDrawView(context, state, isDark);
              } else if (_selectedMode == 'scan') {
                return _buildScanView(context, isDark);
              } else {
                return _buildModeSelectionView(context, isDark);
              }
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // Mode Selection Screen: 2 Separate Container Cards
  Widget _buildModeSelectionView(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: NeoStyles.neoDecoration(
              backgroundColor: isDark
                  ? NeoColors.darkSurface
                  : NeoColors.lightSurface,
              radius: 16,
              shadow: 3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.yellow,
                        radius: 12,
                        shadow: 2,
                      ),
                      child: const Icon(
                        Icons.gesture_rounded,
                        color: NeoColors.borderLight,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Digital Signature',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Choose how you want to create your signature',
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
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Option 1: Draw Signature Container Card
          NeoCard(
            backgroundColor: NeoColors.softYellow,
            shadowOffset: 5,
            padding: const EdgeInsets.all(20),
            onTap: () => setState(() => _selectedMode = 'draw'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.yellow,
                        radius: 14,
                        shadow: 3,
                      ),
                      child: const Icon(
                        Icons.draw_rounded,
                        size: 36,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    const NeoBadge(
                      label: 'TOUCH CANVAS',
                      backgroundColor: NeoColors.yellow,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Draw Signature',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.borderLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Draw directly on touchscreen canvas using custom ink colors (Black, Blue, Red, Navy) & adjustable pen thicknesses.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    height: 1.35,
                    color: NeoColors.borderLight.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.borderLight,
                        radius: 10,
                        shadow: 2,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'START DRAWING',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: NeoColors.yellow,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: NeoColors.yellow,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Option 2: Scan Paper Signature Container Card
          NeoCard(
            backgroundColor: NeoColors.softCyan,
            shadowOffset: 5,
            padding: const EdgeInsets.all(20),
            onTap: () => setState(() => _selectedMode = 'scan'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.cyan,
                        radius: 14,
                        shadow: 3,
                      ),
                      child: const Icon(
                        Icons.scanner_rounded,
                        size: 36,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    const NeoBadge(
                      label: 'AI AUTO-REMOVE',
                      backgroundColor: NeoColors.cyan,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Scan Paper Signature',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.borderLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Snap a photo of your signature on paper. PicsTools automatically removes paper background & converts it to transparent PNG.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    height: 1.35,
                    color: NeoColors.borderLight.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.borderLight,
                        radius: 10,
                        shadow: 2,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'SCAN PAPER',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: NeoColors.cyan,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: NeoColors.cyan,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawView(
    BuildContext context,
    SignatureInitialState state,
    bool isDark,
  ) {
    final bloc = context.read<SignatureBloc>();
    final inkColors = [
      {'name': 'Black', 'color': Colors.black},
      {'name': 'Blue', 'color': const Color(0xFF0033CC)},
      {'name': 'Red', 'color': const Color(0xFFD32F2F)},
      {'name': 'Navy', 'color': const Color(0xFF0A192F)},
      {'name': 'White', 'color': Colors.white},
    ];

    final penWidths = [
      {'name': 'Fine', 'val': 2.0},
      {'name': 'Medium', 'val': 4.0},
      {'name': 'Bold', 'val': 6.5},
    ];

    final isWhiteInk = state.inkColor == Colors.white;
    final canvasBgColor = isWhiteInk ? const Color(0xFF1E293B) : Colors.white;

    return Column(
      children: [
        // Interactive Drawing Canvas
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: NeoCard(
              key: _canvasKey,
              backgroundColor: canvasBgColor,
              padding: const EdgeInsets.all(4),
              shadowOffset: 4,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: NeoSignatureCanvas(
                      strokes: state.strokes,
                      currentStroke: state.currentStroke,
                      onPanStart: (pt) => bloc.add(AddStrokePointEvent(pt)),
                      onPanUpdate: (pt) => bloc.add(AddStrokePointEvent(pt)),
                      onPanEnd: () => bloc.add(EndStrokeEvent()),
                      backgroundColor: canvasBgColor,
                    ),
                  ),

                  // Signature Guideline Line & Hint
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 2,
                      color: isWhiteInk
                          ? Colors.white.withValues(alpha: 0.4)
                          : const Color(0xFF94A3B8).withValues(alpha: 0.6),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    right: 16,
                    child: Text(
                      'Sign on line above',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isWhiteInk
                            ? Colors.white70
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Controls Toolbar
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
            children: [
              // Ink Color & Pen Size Toolbar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ink Colors
                  Row(
                    children: inkColors.map((c) {
                      final color = c['color'] as Color;
                      final isSelected = state.inkColor == color;
                      return GestureDetector(
                        onTap: () => bloc.add(SetInkColorEvent(color)),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? NeoColors.yellow
                                  : NeoColors.borderLight,
                              width: isSelected ? 3 : 1.5,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Undo & Clear
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.undo_rounded),
                        onPressed: state.strokes.isNotEmpty
                            ? () => bloc.add(UndoStrokeEvent())
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: NeoColors.red,
                        ),
                        onPressed: state.strokes.isNotEmpty
                            ? () => bloc.add(ClearCanvasEvent())
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Pen Thickness Chips
              Row(
                children: [
                  Text(
                    'Thickness:',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: penWidths.map((w) {
                      final val = w['val'] as double;
                      final isSelected = state.strokeWidth == val;
                      return GestureDetector(
                        onTap: () => bloc.add(SetStrokeWidthEvent(val)),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: NeoStyles.neoDecoration(
                            backgroundColor: isSelected
                                ? NeoColors.yellow
                                : (isDark
                                      ? NeoColors.darkBg
                                      : NeoColors.lightBg),
                            radius: 8,
                            shadow: isSelected ? 2 : 1,
                          ),
                          child: Text(
                            w['name'] as String,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? NeoColors.borderLight : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              NeoButton(
                label: 'EXPORT SIGNATURE (TRANSPARENT & WHITE)',
                backgroundColor: NeoColors.yellow,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: () {
                  final renderBox =
                      _canvasKey.currentContext?.findRenderObject()
                          as RenderBox?;
                  final size = renderBox?.size ?? const Size(350, 300);
                  bloc.add(StartExportSignatureEvent(size));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScanView(BuildContext context, bool isDark) {
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
              Icons.scanner_rounded,
              size: 50,
              color: NeoColors.borderLight,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Scan Handwritten Paper Signature',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Snap a photo of your signature on paper. PicsTools automatically removes paper background and converts it into a transparent digital signature PNG.',
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
            onTap: () => _scanPaperSignature(context, ImageSource.camera),
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
                        'Scan Paper with Camera',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                      Text(
                        'Instant auto-background removal',
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
            backgroundColor: NeoColors.softPurple,
            shadowOffset: 4,
            onTap: () => _scanPaperSignature(context, ImageSource.gallery),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.purple,
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
                        'Pick Paper Photo from Gallery',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                      Text(
                        'Select existing photo of signature',
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

  Widget _buildProcessingState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: NeoStyles.neoDecoration(
              backgroundColor: NeoColors.yellow,
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
            'Exporting Digital Signature...',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSignatureMultiple(
    BuildContext context,
    List<File> files,
    String label,
  ) async {
    final saver = getIt<FileSaveService>();
    for (final f in files) {
      await saver.saveFileToPublicStorage(
        sourceFile: f,
        subFolder: 'Signatures',
      );
    }
    if (context.mounted) {
      NeoToast.showSuccess(
        context,
        '🎉 Saved $label to Gallery & Files!',
        icon: Icons.draw_rounded,
      );
    }
  }

  void _showSaveOptionsModal(
    BuildContext context,
    SignatureExportResult res,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(
                color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
                width: 2.5,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Save Signature Options',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select format option to download to your device',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: isDark
                          ? NeoColors.textSecondaryDark
                          : NeoColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.cyan,
                        radius: 10,
                        shadow: 1.5,
                      ),
                      child: const Icon(
                        Icons.texture_rounded,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    title: Text(
                      'Transparent PNG',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Ideal for overlaying on documents & dark backgrounds',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _saveSignatureMultiple(context, [
                        res.transparentPngFile,
                      ], 'Transparent PNG');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.yellow,
                        radius: 10,
                        shadow: 1.5,
                      ),
                      child: const Icon(
                        Icons.crop_square_rounded,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    title: Text(
                      'White Background Only (JPG)',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Ideal for forms, printing & official records',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _saveSignatureMultiple(context, [
                        res.solidBackgroundFile,
                      ], 'White Background Signature');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.green,
                        radius: 10,
                        shadow: 1.5,
                      ),
                      child: const Icon(
                        Icons.style_rounded,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    title: Text(
                      'Save Both Versions (Transparent & White)',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Downloads Transparent PNG & White JPG',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _saveSignatureMultiple(context, [
                        res.transparentPngFile,
                        res.solidBackgroundFile,
                      ], 'Both Signature Formats');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showShareOptionsModal(
    BuildContext context,
    SignatureExportResult res,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(
                color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
                width: 2.5,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share Signature Options',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select which signature format you want to share',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: isDark
                          ? NeoColors.textSecondaryDark
                          : NeoColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.cyan,
                        radius: 10,
                        shadow: 1.5,
                      ),
                      child: const Icon(
                        Icons.texture_rounded,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    title: Text(
                      'Share Transparent PNG Only',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Transparent background signature',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      final box = context.findRenderObject() as RenderBox?;
                      final origin = box != null
                          ? box.localToGlobal(Offset.zero) & box.size
                          : null;
                      Share.shareXFiles(
                        [XFile(res.transparentPngFile.path)],
                        text: 'Transparent Digital Signature',
                        sharePositionOrigin: origin,
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.yellow,
                        radius: 10,
                        shadow: 1.5,
                      ),
                      child: const Icon(
                        Icons.crop_square_rounded,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    title: Text(
                      'Share White Background Only (JPG)',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Guaranteed visibility on all apps & documents',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      final box = context.findRenderObject() as RenderBox?;
                      final origin = box != null
                          ? box.localToGlobal(Offset.zero) & box.size
                          : null;
                      Share.shareXFiles(
                        [XFile(res.solidBackgroundFile.path)],
                        text: 'White Background Signature',
                        sharePositionOrigin: origin,
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: NeoStyles.neoDecoration(
                        backgroundColor: NeoColors.green,
                        radius: 10,
                        shadow: 1.5,
                      ),
                      child: const Icon(
                        Icons.style_rounded,
                        color: NeoColors.borderLight,
                      ),
                    ),
                    title: Text(
                      'Share Both Formats',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Shares Transparent PNG & White JPG',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      final box = context.findRenderObject() as RenderBox?;
                      final origin = box != null
                          ? box.localToGlobal(Offset.zero) & box.size
                          : null;
                      Share.shareXFiles(
                        [
                          XFile(res.transparentPngFile.path),
                          XFile(res.solidBackgroundFile.path),
                        ],
                        text: 'Digital Signatures (Transparent & White BG)',
                        sharePositionOrigin: origin,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImagePreviewDialog(
    BuildContext context,
    File imageFile,
    String title,
    bool isDark,
  ) {
    String bgMode = title.contains('Transparent') ? 'checkered' : 'white';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            Widget bgWidget;
            if (bgMode == 'dark') {
              bgWidget = Container(color: const Color(0xFF0F172A));
            } else if (bgMode == 'white') {
              bgWidget = Container(color: Colors.white);
            } else {
              bgWidget = CustomPaint(
                painter: CheckeredPatternPainter(squareSize: 12),
              );
            }

            return Dialog(
              backgroundColor: isDark
                  ? NeoColors.darkSurface
                  : NeoColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
                  width: 2.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(dialogCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Background Mode Selector Toggle for Previewing Dark Mode vs Light Mode
                    if (title.contains('Transparent'))
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Preview Background: ',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            ChoiceChip(
                              label: const Text(
                                'Checkered',
                                style: TextStyle(fontSize: 10),
                              ),
                              selected: bgMode == 'checkered',
                              onSelected: (val) {
                                if (val) {
                                  setModalState(() => bgMode = 'checkered');
                                }
                              },
                            ),
                            const SizedBox(width: 4),
                            ChoiceChip(
                              label: const Text(
                                'Dark Mode',
                                style: TextStyle(fontSize: 10),
                              ),
                              selected: bgMode == 'dark',
                              selectedColor: NeoColors.yellow,
                              onSelected: (val) {
                                if (val) setModalState(() => bgMode = 'dark');
                              },
                            ),
                            const SizedBox(width: 4),
                            ChoiceChip(
                              label: const Text(
                                'White',
                                style: TextStyle(fontSize: 10),
                              ),
                              selected: bgMode == 'white',
                              onSelected: (val) {
                                if (val) setModalState(() => bgMode = 'white');
                              },
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),

                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: NeoColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            Positioned.fill(child: bgWidget),
                            Positioned.fill(
                              child: InteractiveViewer(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Image.file(
                                    imageFile,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildSuccessState(
    BuildContext context,
    SignatureSuccessState state,
    bool isDark,
  ) {
    final bloc = context.read<SignatureBloc>();
    final res = state.result;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          NeoCard(
            backgroundColor: NeoColors.softYellow,
            shadowOffset: 5,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const NeoBadge(
                  label: 'SIGNATURE READY',
                  backgroundColor: NeoColors.yellow,
                  fontSize: 12,
                ),
                const SizedBox(height: 12),
                Text(
                  '${res.widthPx} x ${res.heightPx} px (Auto-Cropped)',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.borderLight,
                  ),
                ),
                Text(
                  'File Size: ${FileUtils.formatBytes(res.fileSizeBytes)}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: NeoColors.borderLight.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Dual Previews: Transparent & White Background
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Transparent PNG',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    NeoCard(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      shadowOffset: 3,
                      onTap: () => _showImagePreviewDialog(
                        context,
                        res.transparentPngFile,
                        'Transparent PNG Signature',
                        isDark,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: CheckeredPatternPainter(
                                    squareSize: 8,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.file(
                                    res.transparentPngFile,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'White Background',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    NeoCard(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      shadowOffset: 3,
                      onTap: () => _showImagePreviewDialog(
                        context,
                        res.solidBackgroundFile,
                        'White Background Signature',
                        isDark,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.file(
                              res.solidBackgroundFile,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            onPressed: () => _showSaveOptionsModal(context, res, isDark),
          ),
          const SizedBox(height: 12),
          NeoButton(
            label: 'SHARE SIGNATURE',
            icon: const Icon(Icons.share_rounded, color: NeoColors.borderLight),
            backgroundColor: NeoColors.yellow,
            fullWidth: true,
            onPressed: () => _showShareOptionsModal(context, res, isDark),
          ),
          const SizedBox(height: 12),
          NeoButton(
            label: 'CREATE NEW SIGNATURE',
            icon: const Icon(
              Icons.refresh_rounded,
              color: NeoColors.borderLight,
            ),
            backgroundColor: NeoColors.cyan,
            fullWidth: true,
            onPressed: () {
              bloc.add(ResetSignatureEvent());
              setState(() {
                _selectedMode = null;
              });
            },
          ),
        ],
      ),
    );
  }
}

class CheckeredPatternPainter extends CustomPainter {
  final double squareSize;

  CheckeredPatternPainter({this.squareSize = 8.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLight = Paint()..color = const Color(0xFFF1F5F9);
    final paintDark = Paint()..color = const Color(0xFFCBD5E1);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintLight);

    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        final isDark =
            ((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 1;
        if (isDark) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, squareSize, squareSize),
            paintDark,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
