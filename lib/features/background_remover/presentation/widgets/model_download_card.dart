import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../domain/entities/ai_model_info.dart';
import 'privacy_badge.dart';

class ModelDownloadCard extends StatelessWidget {
  final AiModelInfo modelInfo;
  final VoidCallback onDownload;
  final bool isDark;

  const ModelDownloadCard({
    super.key,
    required this.modelInfo,
    required this.onDownload,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? NeoColors.borderDark : NeoColors.borderLight;

    return Column(
      children: [
        NeoCard(
          backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.softPurple,
          borderColor: borderColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: NeoColors.purple,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Text(
                      '🤖 AI MODEL REQUIRED',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.lightSurface,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: NeoColors.yellow,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: NeoColors.borderLight, width: 1.2),
                    ),
                    child: Text(
                      'ONE-TIME SETUP',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.borderLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'High-Precision On-Device AI',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? NeoColors.textPrimaryDark : NeoColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'To remove backgrounds automatically without uploading your photos to any remote servers, download the AI segmentation model onto your device.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? NeoColors.textSecondaryDark
                      : NeoColors.textSecondaryLight,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Specs Table Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF26262B)
                      : NeoColors.lightSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Column(
                  children: [
                    _buildSpecRow(
                      icon: Icons.memory_rounded,
                      label: 'Model',
                      value: modelInfo.displayName,
                      color: NeoColors.cyan,
                    ),
                    const Divider(height: 14),
                    _buildSpecRow(
                      icon: Icons.downloading_rounded,
                      label: 'Download Size',
                      value: '~${modelInfo.formattedExpectedSize}',
                      color: NeoColors.yellow,
                    ),
                    const Divider(height: 14),
                    _buildSpecRow(
                      icon: Icons.wifi_off_rounded,
                      label: 'Offline Ready',
                      value: 'Works 100% Offline',
                      color: NeoColors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Download Button
              NeoButton(
                label: 'Download AI Model (~${modelInfo.formattedExpectedSize})',
                icon: const Icon(
                  Icons.download_rounded,
                  size: 18,
                  color: NeoColors.borderLight,
                ),
                backgroundColor: NeoColors.yellow,
                textColor: NeoColors.borderLight,
                fullWidth: true,
                onPressed: onDownload,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PrivacyBadge(isDark: isDark),
      ],
    );
  }

  Widget _buildSpecRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: NeoColors.borderLight, width: 1.2),
          ),
          child: Icon(icon, size: 14, color: NeoColors.borderLight),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark
                ? NeoColors.textSecondaryDark
                : NeoColors.textSecondaryLight,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isDark ? NeoColors.textPrimaryDark : NeoColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
