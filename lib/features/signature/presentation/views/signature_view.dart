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
import '../../../../core/utils/file_utils.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/file_save_service.dart';
import '../widgets/neo_signature_canvas.dart';
import '../../bloc/signature_bloc.dart';

class SignatureView extends StatelessWidget {
  const SignatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignatureBloc(
        signatureService: getIt(),
        historyService: getIt(),
      ),
      child: const _SignatureViewContent(),
    );
  }
}

class _SignatureViewContent extends StatefulWidget {
  const _SignatureViewContent();

  @override
  State<_SignatureViewContent> createState() => _SignatureViewContentState();
}

class _SignatureViewContentState extends State<_SignatureViewContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _scanPaperSignature(BuildContext context, ImageSource source) async {
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
          'Digital Signature Creator',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: NeoColors.yellow,
          indicatorWeight: 3.5,
          labelStyle: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
          unselectedLabelStyle: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'DRAW SIGNATURE'),
            Tab(text: 'SCAN PAPER SIGNATURE'),
          ],
        ),
      ),
      body: BlocConsumer<SignatureBloc, SignatureState>(
        listener: (context, state) {
          if (state is SignatureErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: NeoColors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SignatureProcessingState) {
            return _buildProcessingState(context, isDark);
          } else if (state is SignatureSuccessState) {
            return _buildSuccessState(context, state, isDark);
          } else if (state is SignatureInitialState) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildDrawTab(context, state, isDark),
                _buildScanTab(context, isDark),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDrawTab(BuildContext context, SignatureInitialState state, bool isDark) {
    final bloc = context.read<SignatureBloc>();
    final inkColors = [
      {'name': 'Black', 'color': Colors.black},
      {'name': 'Blue', 'color': const Color(0xFF0033CC)},
      {'name': 'Red', 'color': const Color(0xFFD32F2F)},
      {'name': 'Navy', 'color': const Color(0xFF0A192F)},
    ];

    final penWidths = [
      {'name': 'Fine', 'val': 2.0},
      {'name': 'Medium', 'val': 4.0},
      {'name': 'Bold', 'val': 6.5},
    ];

    return Column(
      children: [
        // Interactive Drawing Canvas
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: NeoCard(
              key: _canvasKey,
              backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
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
                      backgroundColor: isDark ? NeoColors.darkBg : NeoColors.lightBg,
                    ),
                  ),

                  // Signature Guideline
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 2,
                      color: Colors.grey.withValues(alpha: 0.4),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 16,
                    child: Text(
                      'Sign on line above',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: Colors.grey,
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
                              color: isSelected ? NeoColors.yellow : NeoColors.borderLight,
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
                        onPressed: state.strokes.isNotEmpty ? () => bloc.add(UndoStrokeEvent()) : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: NeoColors.red),
                        onPressed: state.strokes.isNotEmpty ? () => bloc.add(ClearCanvasEvent()) : null,
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: NeoStyles.neoDecoration(
                            backgroundColor: isSelected
                                ? NeoColors.yellow
                                : (isDark ? NeoColors.darkBg : NeoColors.lightBg),
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
                icon: const Icon(Icons.check_rounded, color: NeoColors.borderLight),
                backgroundColor: NeoColors.yellow,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: () {
                  final renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
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

  Widget _buildScanTab(BuildContext context, bool isDark) {
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
              color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
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
                  child: const Icon(Icons.camera_alt_rounded, color: NeoColors.borderLight),
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
                const Icon(Icons.chevron_right_rounded, color: NeoColors.borderLight),
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
                  child: const Icon(Icons.photo_library_rounded, color: NeoColors.borderLight),
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
                const Icon(Icons.chevron_right_rounded, color: NeoColors.borderLight),
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
                valueColor: AlwaysStoppedAnimation<Color>(NeoColors.borderLight),
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
                      backgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.all(12),
                      shadowOffset: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          res.transparentPngFile,
                          height: 100,
                          fit: BoxFit.contain,
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          res.solidBackgroundFile,
                          height: 100,
                          fit: BoxFit.contain,
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
            icon: const Icon(Icons.download_rounded, color: NeoColors.borderLight),
            backgroundColor: NeoColors.green,
            fullWidth: true,
            onPressed: () async {
              final saver = getIt<FileSaveService>();
              await saver.saveFileToPublicStorage(
                sourceFile: res.transparentPngFile,
                subFolder: 'Signatures',
              );
              await saver.saveFileToPublicStorage(
                sourceFile: res.solidBackgroundFile,
                subFolder: 'Signatures',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saved Transparent PNG & White Signature to Downloads/PicsTools/Signatures!'),
                    backgroundColor: NeoColors.green,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          NeoButton(
            label: 'SHARE SIGNATURE',
            icon: const Icon(Icons.share_rounded, color: NeoColors.borderLight),
            backgroundColor: NeoColors.yellow,
            fullWidth: true,
            onPressed: () {
              final files = [
                XFile(res.transparentPngFile.path),
                XFile(res.solidBackgroundFile.path),
              ];
              Share.shareXFiles(files, text: 'Digital Signature created with PicsTools!');
            },
          ),
          const SizedBox(height: 12),
          NeoButton(
            label: 'CREATE NEW SIGNATURE',
            icon: const Icon(Icons.refresh_rounded, color: NeoColors.borderLight),
            backgroundColor: NeoColors.cyan,
            fullWidth: true,
            onPressed: () => bloc.add(ResetSignatureEvent()),
          ),
        ],
      ),
    );
  }
}
