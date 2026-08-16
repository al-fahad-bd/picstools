import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_loader.dart';
import 'privacy_badge.dart';

class ProcessingCard extends StatelessWidget {
  final File originalImage;
  final bool isDark;

  const ProcessingCard({
    super.key,
    required this.originalImage,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? NeoColors.borderDark : NeoColors.borderLight;

    return Column(
      children: [
        NeoCard(
          backgroundColor: isDark
              ? NeoColors.darkSurface
              : NeoColors.softYellow,
          borderColor: borderColor,
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Thumbnail preview of original
              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(originalImage, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),

              const NeoLoader.large(
                size: 44,
                color: NeoColors.purple,
                secondaryColor: NeoColors.yellow,
              ),
              const SizedBox(height: 18),

              Text(
                'Removing Background...',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? NeoColors.textPrimaryDark
                      : NeoColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                'Running BiRefNet Lite ONNX on-device inference',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? NeoColors.textSecondaryDark
                      : NeoColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PrivacyBadge(isDark: isDark),
      ],
    );
  }
}
