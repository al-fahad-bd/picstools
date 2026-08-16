import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../bloc/signature_bloc.dart';
import 'neo_signature_canvas.dart';

class SignatureDrawView extends StatelessWidget {
  final SignatureInitialState state;
  final bool isDark;
  final GlobalKey canvasKey;

  const SignatureDrawView({
    super.key,
    required this.state,
    required this.isDark,
    required this.canvasKey,
  });

  @override
  Widget build(BuildContext context) {
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
              key: canvasKey,
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
                      canvasKey.currentContext?.findRenderObject()
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
}
