import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/neo_colors.dart';
import '../constants/neo_styles.dart';

/// Clean, Ultra-Legible Neo-Brutalist Mini Illustrations for the 8 Home Tools
/// Built with zero text clipping, zero badge overlap, and maximum visual clarity.

class CompressToolGraphic extends StatelessWidget {
  final bool isDark;
  const CompressToolGraphic({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top row: badge + percentage chip
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: NeoColors.yellow,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: NeoColors.borderLight, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: NeoColors.borderLight, offset: Offset(1.5, 1.5)),
                ],
              ),
              child: Text(
                '⚡ -90%',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: NeoColors.borderLight,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Main Graphic: Shrinking photo card frame
        Container(
          width: 86,
          height: 46,
          decoration: NeoStyles.neoDecoration(
            backgroundColor: isDark ? const Color(0xFF222226) : NeoColors.softYellow,
            radius: 10,
            shadow: 2.5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Original file icon
              Icon(
                Icons.image_outlined,
                size: 20,
                color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
              ),
              // Arrow shrink indicator
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: NeoColors.yellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 12,
                  color: NeoColors.borderLight,
                ),
              ),
              // Compressed small file icon
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: NeoColors.yellow,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: NeoColors.borderLight, width: 1.5),
                ),
                child: const Icon(
                  Icons.compress_rounded,
                  size: 16,
                  color: NeoColors.borderLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PdfToolGraphic extends StatelessWidget {
  final bool isDark;
  const PdfToolGraphic({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Back Document Page
        Transform.rotate(
          angle: -0.12,
          child: Container(
            width: 60,
            height: 60,
            decoration: NeoStyles.neoDecoration(
              backgroundColor: NeoColors.softPurple,
              radius: 8,
              shadow: 1.5,
            ),
          ),
        ),

        // Front Document Page
        Container(
          width: 68,
          height: 62,
          decoration: NeoStyles.neoDecoration(
            backgroundColor: isDark ? const Color(0xFF222226) : NeoColors.lightSurface,
            radius: 10,
            shadow: 2.5,
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PDF Red Pill Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: NeoColors.red,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: NeoColors.borderLight, width: 1.2),
                ),
                child: Text(
                  'PDF',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              // Document text line placeholders
              Container(
                height: 3.5,
                width: 32,
                decoration: BoxDecoration(
                  color: NeoColors.purple.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 3),
              Container(
                height: 3.5,
                width: 22,
                decoration: BoxDecoration(
                  color: NeoColors.purple.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),

        // Purple PDF Export Icon Badge on Bottom-Right
        Positioned(
          bottom: -4,
          right: 2,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: NeoStyles.neoDecoration(
              backgroundColor: NeoColors.purple,
              radius: 8,
              shadow: 2,
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class ResizeToolGraphic extends StatelessWidget {
  final bool isDark;
  const ResizeToolGraphic({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Main Canvas Frame
        Container(
          width: 92,
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : NeoColors.softCyan,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: NeoColors.borderLight, width: 2),
            boxShadow: const [
              BoxShadow(color: NeoColors.borderLight, offset: Offset(2, 2)),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Dimension Badge (100% visible, centered, zero clipping)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: NeoColors.cyan,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: NeoColors.borderLight, width: 1.5),
                ),
                child: Text(
                  '1080 × 1920',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.borderLight,
                  ),
                ),
              ),

              // Top-Left Corner Anchor Node
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: NeoColors.yellow,
                    border: Border.all(color: NeoColors.borderLight, width: 1.2),
                  ),
                ),
              ),

              // Bottom-Right Corner Anchor Node
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: NeoColors.yellow,
                    border: Border.all(color: NeoColors.borderLight, width: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CropToolGraphic extends StatelessWidget {
  final bool isDark;
  const CropToolGraphic({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top 90° angle chip (placed above frame to prevent overlap)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: NeoColors.pink,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: NeoColors.borderLight, width: 1.2),
                boxShadow: const [
                  BoxShadow(color: NeoColors.borderLight, offset: Offset(1.2, 1.2)),
                ],
              ),
              child: Text(
                '🔄 90° ROTATE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),

        // Angled Crop Viewfinder Frame
        Container(
          width: 76,
          height: 44,
          decoration: NeoStyles.neoDecoration(
            backgroundColor: isDark ? const Color(0xFF2B1F2D) : NeoColors.softPink,
            radius: 8,
            shadow: 2,
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: NeoColors.pink,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: NeoColors.borderLight, width: 1.5),
              ),
              child: const Icon(
                Icons.crop_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ConvertToolGraphic extends StatelessWidget {
  final bool isDark;
  const ConvertToolGraphic({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Format Conversion Row: JPG -> WEBP (Zero truncation, zero overlap!)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left Pill: JPG
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B2E24) : NeoColors.softGreen,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: NeoColors.borderLight, width: 1.5),
              ),
              child: Text(
                'JPG',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? NeoColors.green : NeoColors.borderLight,
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Swap Arrow Circle
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: NeoColors.green,
                shape: BoxShape.circle,
                border: Border.all(color: NeoColors.borderLight, width: 1.2),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 12,
                color: NeoColors.borderLight,
              ),
            ),
            const SizedBox(width: 4),

            // Right Pill: WEBP
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: NeoColors.green,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: NeoColors.borderLight, width: 1.5),
              ),
              child: Text(
                'WEBP',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: NeoColors.borderLight,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // HQ LOSSLESS Badge (Placed neatly below the row with no overlap!)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: NeoColors.yellow,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: NeoColors.borderLight, width: 1.2),
            boxShadow: const [
              BoxShadow(color: NeoColors.borderLight, offset: Offset(1.2, 1.2)),
            ],
          ),
          child: Text(
            'HQ LOSSLESS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              color: NeoColors.borderLight,
            ),
          ),
        ),
      ],
    );
  }
}

class IdPhotoToolGraphic extends StatelessWidget {
  final bool isDark;
  const IdPhotoToolGraphic({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Dimension badge above frame (zero head overlap!)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: NeoColors.orange,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: NeoColors.borderLight, width: 1.2),
                boxShadow: const [
                  BoxShadow(color: NeoColors.borderLight, offset: Offset(1.2, 1.2)),
                ],
              ),
              child: Text(
                '📏 35 × 45 mm',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),

        // Passport Avatar Frame (Head fully visible!)
        Container(
          width: 72,
          height: 44,
          decoration: NeoStyles.neoDecoration(
            backgroundColor: isDark ? const Color(0xFF2C221B) : NeoColors.softOrange,
            radius: 10,
            shadow: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar Silhouette
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: NeoColors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: NeoColors.borderLight, width: 1.2),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 4,
                    width: 24,
                    decoration: BoxDecoration(
                      color: NeoColors.orange,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    height: 3,
                    width: 16,
                    decoration: BoxDecoration(
                      color: NeoColors.orange.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SignatureToolGraphic extends StatelessWidget {
  final bool isDark;
  const SignatureToolGraphic({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // PNG CLEAR Badge above signature canvas
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: NeoColors.yellow,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: NeoColors.borderLight, width: 1.2),
                boxShadow: const [
                  BoxShadow(color: NeoColors.borderLight, offset: Offset(1.2, 1.2)),
                ],
              ),
              child: Text(
                '✨ PNG CLEAR',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: NeoColors.borderLight,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),

        // Signature stroke canvas
        Container(
          width: 82,
          height: 44,
          decoration: NeoStyles.neoDecoration(
            backgroundColor: isDark ? const Color(0xFF1A2638) : NeoColors.softCyan,
            radius: 10,
            shadow: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.gesture_rounded,
                size: 26,
                color: isDark ? NeoColors.cyan : NeoColors.blue,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: NeoColors.blue,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: NeoColors.borderLight, width: 1.2),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SocialToolGraphic extends StatelessWidget {
  final bool isDark;
  const SocialToolGraphic({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Social presets label
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: NeoColors.pink,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: NeoColors.borderLight, width: 1.2),
                boxShadow: const [
                  BoxShadow(color: NeoColors.borderLight, offset: Offset(1.2, 1.2)),
                ],
              ),
              child: Text(
                '📱 IG • YT • TIKTOK',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),

        // Aspect ratio frames
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1:1 Instagram box
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: NeoColors.softYellow,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: NeoColors.borderLight, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '1:1',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.borderLight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 9:16 Story box
            Container(
              width: 24,
              height: 38,
              decoration: BoxDecoration(
                color: NeoColors.yellow,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: NeoColors.borderLight, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '9:16',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.borderLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

