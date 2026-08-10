import 'dart:io';
import 'dart:math' as math;
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
import '../../../../core/services/service_locator.dart';
import '../../domain/entities/bg_remover_params.dart';
import '../bloc/bg_remover_bloc.dart';
import '../bloc/bg_remover_event.dart';
import '../bloc/bg_remover_state.dart';

class BgRemoverView extends StatelessWidget {
  const BgRemoverView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BgRemoverBloc>(
      create: (_) => getIt<BgRemoverBloc>(),
      child: const _BgRemoverContent(),
    );
  }
}

class _BgRemoverContent extends StatefulWidget {
  const _BgRemoverContent();

  @override
  State<_BgRemoverContent> createState() => _BgRemoverContentState();
}

class _BgRemoverContentState extends State<_BgRemoverContent> {
  final ImagePicker _picker = ImagePicker();
  double _threshold = 30.0;
  String _bgMode = 'transparent';

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null && context.mounted) {
      context.read<BgRemoverBloc>().add(
            SelectImageEvent(File(picked.path)),
          );
    }
  }

  void _triggerProcess(BuildContext context) {
    final params = BgRemoverParams(
      threshold: _threshold,
      bgMode: _bgMode,
    );
    context.read<BgRemoverBloc>().add(
          ProcessSegmentationEvent(params),
        );
  }

  Future<void> _shareImage(File processedFile) async {
    await Share.shareXFiles(
      [XFile(processedFile.path)],
      text: 'Background Removed Image via PicsTools',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Background Remover',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: NeoBadge(
              label: 'AI MASK & TRANSPARENT PNG',
              backgroundColor: NeoColors.purple,
              fontSize: 9.5,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocConsumer<BgRemoverBloc, BgRemoverState>(
            listener: (context, state) {
              if (state is BgRemoverFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: NeoColors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              File? displayFile;
              File? processedFile;
              bool isProcessing = state is BgRemoverProcessing;

              if (state is BgRemoverProcessing) {
                displayFile = state.originalImage;
              } else if (state is BgRemoverSuccess) {
                displayFile = state.processedImage;
                processedFile = state.processedImage;
              }

              return Column(
                children: [
                  // Main Interactive Canvas Box
                  Expanded(
                    child: NeoCard(
                      backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
                      shadowOffset: 5,
                      padding: const EdgeInsets.all(12),
                      child: displayFile == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: NeoStyles.neoDecoration(
                                      backgroundColor: NeoColors.softPurple,
                                      radius: 20,
                                      shadow: 3,
                                    ),
                                    child: const Icon(
                                      Icons.auto_fix_high_rounded,
                                      size: 48,
                                      color: NeoColors.borderLight,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Select Image to Remove BG',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '9-step TFLite neural mask & alpha channel segmentation',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12.5,
                                      color: isDark
                                          ? NeoColors.textSecondaryDark
                                          : NeoColors.textSecondaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      NeoButton(
                                        label: 'GALLERY',
                                        icon: const Icon(Icons.photo_library_rounded, size: 18),
                                        backgroundColor: NeoColors.purple,
                                        onPressed: () => _pickImage(context, ImageSource.gallery),
                                      ),
                                      const SizedBox(width: 12),
                                      NeoButton(
                                        label: 'CAMERA',
                                        icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                        backgroundColor: NeoColors.yellow,
                                        onPressed: () => _pickImage(context, ImageSource.camera),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: _CheckerboardPainter(isDark: isDark),
                                        ),
                                      ),
                                      Center(
                                        child: Image.file(
                                          displayFile,
                                          key: ValueKey(
                                            '${displayFile.path}_${displayFile.lastModifiedSync().millisecondsSinceEpoch}',
                                          ),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isProcessing)
                                  Container(
                                    color: Colors.black54,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const CircularProgressIndicator(color: NeoColors.purple),
                                          const SizedBox(height: 14),
                                          Text(
                                            'Computing Mask & Alpha Matte...',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Interactive Controls Section
                  if (displayFile != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildModeChip(context, 'transparent', 'Transparent', isDark),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildModeChip(context, 'white', 'White BG', isDark),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildModeChip(context, 'black', 'Dark BG', isDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Tolerance Slider
                    Row(
                      children: [
                        Text(
                          'Tolerance:',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _threshold,
                            min: 5,
                            max: 80,
                            activeColor: NeoColors.purple,
                            inactiveColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                            onChanged: (val) {
                              setState(() => _threshold = val);
                            },
                            onChangeEnd: (_) => _triggerProcess(context),
                          ),
                        ),
                        Text(
                          '${_threshold.round()}%',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: NeoButton(
                            label: 'NEW PHOTO',
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
                            onPressed: () => _pickImage(context, ImageSource.gallery),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NeoButton(
                            label: 'EXPORT PNG',
                            icon: const Icon(Icons.share_rounded, size: 18),
                            backgroundColor: NeoColors.purple,
                            onPressed: processedFile != null ? () => _shareImage(processedFile!) : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModeChip(BuildContext context, String mode, String label, bool isDark) {
    final isSelected = _bgMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() => _bgMode = mode);
        _triggerProcess(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: NeoStyles.neoDecoration(
          backgroundColor: isSelected
              ? NeoColors.purple
              : (isDark ? NeoColors.darkSurface : NeoColors.lightSurface),
          radius: 10,
          shadow: isSelected ? 2.5 : 1,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isSelected
                ? Colors.white
                : (isDark ? NeoColors.textPrimaryDark : NeoColors.textPrimaryLight),
          ),
        ),
      ),
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  final bool isDark;
  _CheckerboardPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    const double squareSize = 12.0;
    final paint1 = Paint()
      ..color = isDark ? const Color(0xFF2A2A38) : const Color(0xFFE2E4E9);
    final paint2 = Paint()
      ..color = isDark ? const Color(0xFF1E1E28) : const Color(0xFFF4F5F8);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint2);

    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        final bool isEven = ((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 0;
        if (isEven) {
          canvas.drawRect(
            Rect.fromLTWH(
              x,
              y,
              math.min(squareSize, size.width - x),
              math.min(squareSize, size.height - y),
            ),
            paint1,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

