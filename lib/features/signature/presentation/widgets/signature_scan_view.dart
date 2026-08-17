import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_crop_canvas.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/service_locator.dart';

import 'neo_rotation_control.dart';

typedef OnExtractSignatureCallback = void Function({
  required File photoFile,
  required double cropXRatio,
  required double cropYRatio,
  required double cropWidthRatio,
  required double cropHeightRatio,
  required num rotationAngle,
});

class SignatureScanView extends StatefulWidget {
  final bool isDark;
  final OnExtractSignatureCallback onExtractSignature;

  const SignatureScanView({
    super.key,
    required this.isDark,
    required this.onExtractSignature,
  });

  @override
  State<SignatureScanView> createState() => _SignatureScanViewState();
}

class _SignatureScanViewState extends State<SignatureScanView> {
  File? _selectedFile;
  double _baseRotation90 = 0.0;
  double _fineAngle = 0.0;
  Rect _normCropRect = const Rect.fromLTWH(0.05, 0.05, 0.9, 0.9);

  double get _totalRotationAngle => (_baseRotation90 + _fineAngle);

  Future<void> _pickImage(ImageSource source) async {
    final picker = getIt<ImagePickerService>();
    final file = await picker.pickSingleImage(source: source);
    if (file != null && mounted) {
      setState(() {
        _selectedFile = file;
        _baseRotation90 = 0.0;
        _fineAngle = 0.0;
        _normCropRect = const Rect.fromLTWH(0.05, 0.05, 0.9, 0.9);
      });
    }
  }

  void _processAndExtract() {
    if (_selectedFile == null) return;
    widget.onExtractSignature(
      photoFile: _selectedFile!,
      cropXRatio: _normCropRect.left,
      cropYRatio: _normCropRect.top,
      cropWidthRatio: _normCropRect.width,
      cropHeightRatio: _normCropRect.height,
      rotationAngle: _totalRotationAngle,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedFile != null) {
      return _buildCropAndAlignState(context);
    }
    return _buildSelectionState(context);
  }

  Widget _buildSelectionState(BuildContext context) {
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
              'Sign on any white paper with a pen, then snap a photo. You can crop, rotate, and align it perfectly before automatic ink extraction.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                height: 1.4,
                color: widget.isDark
                    ? NeoColors.textSecondaryDark
                    : NeoColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(height: 32),

          NeoCard(
            backgroundColor: NeoColors.softYellow,
            shadowOffset: 4,
            onTap: () => _pickImage(ImageSource.camera),
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
                        'Snap photo with live crop & alignment',
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
            onTap: () => _pickImage(ImageSource.gallery),
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
                        'Select existing photo to crop & scan',
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

  Widget _buildCropAndAlignState(BuildContext context) {
    final formattedAngle = _totalRotationAngle == _totalRotationAngle.roundToDouble()
        ? '${_totalRotationAngle.toInt()}°'
        : '${_totalRotationAngle.toStringAsFixed(1)}°';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info bar
          NeoCard(
            backgroundColor: NeoColors.softYellow,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shadowOffset: 3,
            child: Row(
              children: [
                const Icon(
                  Icons.crop_rotate_rounded,
                  size: 22,
                  color: NeoColors.borderLight,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crop & Align Signature',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                      Text(
                        'Straighten any tilt and crop unwanted marks',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: NeoColors.borderLight.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                NeoBadge(
                  label: formattedAngle,
                  backgroundColor: NeoColors.cyan,
                  fontSize: 11,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Interactive Crop Canvas Frame
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isDark
                      ? NeoColors.borderDark
                      : NeoColors.borderLight,
                  width: 2.5,
                ),
                color: widget.isDark ? Colors.black26 : Colors.black12,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: NeoCropCanvas(
                  imageFile: _selectedFile!,
                  rotationAngle: _totalRotationAngle,
                  initialNormCropRect: _normCropRect,
                  onCropChanged: (rect) {
                    _normCropRect = rect;
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Continuous Rotation & Straightening Panel
          NeoRotationControl(
            baseRotation90: _baseRotation90,
            fineAngle: _fineAngle,
            isDark: widget.isDark,
            onFineAngleChanged: (val) {
              setState(() => _fineAngle = val);
            },
            onRotate90: () {
              setState(() {
                _baseRotation90 = (_baseRotation90 + 90.0) % 360.0;
              });
            },
            onReset: () {
              setState(() {
                _baseRotation90 = 0.0;
                _fineAngle = 0.0;
              });
            },
          ),
          const SizedBox(height: 10),

          // Action row: Change Photo & Extract Signature
          Row(
            children: [
              NeoButton(
                label: 'CHANGE PHOTO',
                icon: const Icon(
                  Icons.photo_library_outlined,
                  size: 16,
                  color: NeoColors.borderLight,
                ),
                backgroundColor: widget.isDark
                    ? NeoColors.darkSurface
                    : NeoColors.lightSurface,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                onPressed: () {
                  setState(() {
                    _selectedFile = null;
                    _baseRotation90 = 0.0;
                    _fineAngle = 0.0;
                  });
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NeoButton(
                  label: 'EXTRACT SIGNATURE',
                  icon: const Icon(
                    Icons.auto_fix_high_rounded,
                    size: 16,
                    color: NeoColors.borderLight,
                  ),
                  backgroundColor: NeoColors.yellow,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: _processAndExtract,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
