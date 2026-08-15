import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';

class ModelDownloadingCard extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final String receivedSize;
  final String totalSize;
  final int percentage;
  final VoidCallback onCancel;
  final bool isDark;

  const ModelDownloadingCard({
    super.key,
    required this.progress,
    required this.receivedSize,
    required this.totalSize,
    required this.percentage,
    required this.onCancel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? NeoColors.borderDark : NeoColors.borderLight;

    return NeoCard(
      backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.softYellow,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: NeoColors.yellow,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: NeoColors.borderLight, width: 1.5),
                ),
                child: Text(
                  '⚡ DOWNLOADING MODEL',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.borderLight,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                '$percentage%',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: NeoColors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Downloading BiRefNet Lite',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? NeoColors.textPrimaryDark : NeoColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            '$receivedSize / $totalSize',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? NeoColors.textSecondaryDark
                  : NeoColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),

          // High-Contrast Neo Progress Bar
          Container(
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141416) : NeoColors.lightSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 2),
            ),
            padding: const EdgeInsets.all(2.5),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth * progress.clamp(0.0, 1.0);
                return Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: barWidth,
                    decoration: BoxDecoration(
                      color: NeoColors.purple,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: NeoColors.purple),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Please keep the app open until the download completes.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? NeoColors.textSecondaryDark
                        : NeoColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Cancel Button
          NeoButton(
            label: 'Cancel Download',
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: NeoColors.red,
            ),
            backgroundColor: isDark ? const Color(0xFF332222) : NeoColors.softPink,
            textColor: NeoColors.red,
            fullWidth: true,
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
