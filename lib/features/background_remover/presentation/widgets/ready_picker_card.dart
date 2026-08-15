import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../domain/entities/ai_model_info.dart';
import 'privacy_badge.dart';

class ReadyPickerCard extends StatelessWidget {
  final AiModelInfo modelInfo;
  final bool isDark;
  final Function(ImageSource) onPickImage;

  const ReadyPickerCard({
    super.key,
    required this.modelInfo,
    required this.isDark,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? NeoColors.borderDark : NeoColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeoCard(
          backgroundColor: isDark
              ? NeoColors.darkSurface
              : NeoColors.softPurple,
          borderColor: borderColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Banner Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: NeoColors.green,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Text(
                      '✓ AI MODEL READY',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.borderLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    modelInfo.displayName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? NeoColors.textSecondaryDark
                          : NeoColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Select Image for Instant Cutout',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? NeoColors.textPrimaryDark
                      : NeoColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Choose any photo with people, products, animals, or objects. The AI runs locally to extract a continuous alpha mask with ultra-fine edge details.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? NeoColors.textSecondaryDark
                      : NeoColors.textSecondaryLight,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Choose from Gallery Button
              NeoButton(
                label: 'Choose Photo from Gallery',
                icon: const Icon(
                  Icons.photo_library_rounded,
                  size: 18,
                  color: NeoColors.borderLight,
                ),
                backgroundColor: NeoColors.yellow,
                textColor: NeoColors.borderLight,
                fullWidth: true,
                onPressed: () => onPickImage(ImageSource.gallery),
              ),
              const SizedBox(height: 12),

              // Take Photo Button
              NeoButton(
                label: 'Take Photo with Camera',
                icon: Icon(
                  Icons.camera_alt_rounded,
                  size: 18,
                  color: isDark
                      ? NeoColors.textPrimaryDark
                      : NeoColors.textPrimaryLight,
                ),
                backgroundColor: isDark
                    ? const Color(0xFF26262B)
                    : NeoColors.lightSurface,
                textColor: isDark
                    ? NeoColors.textPrimaryDark
                    : NeoColors.textPrimaryLight,
                fullWidth: true,
                onPressed: () => onPickImage(ImageSource.camera),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PrivacyBadge(isDark: isDark),
      ],
    );
  }
}
