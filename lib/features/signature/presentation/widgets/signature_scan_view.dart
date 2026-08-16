import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_card.dart';

class SignatureScanView extends StatelessWidget {
  final bool isDark;
  final void Function(BuildContext context, ImageSource source) onPickImage;

  const SignatureScanView({
    super.key,
    required this.isDark,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
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
              Icons.document_scanner_rounded,
              size: 50,
              color: NeoColors.borderLight,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Scan Paper Signature',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Sign on any white paper with a pen, then take a photo. PicsTools will auto-clean shadows & extract pure vector-like ink.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                height: 1.4,
                color: isDark
                    ? NeoColors.textSecondaryDark
                    : NeoColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(height: 32),

          NeoCard(
            backgroundColor: NeoColors.softYellow,
            shadowOffset: 4,
            onTap: () => onPickImage(context, ImageSource.camera),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.yellow,
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
            onTap: () => onPickImage(context, ImageSource.gallery),
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
}
