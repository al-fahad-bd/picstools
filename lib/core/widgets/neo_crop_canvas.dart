import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/neo_colors.dart';

enum CropHandleType {
  none,
  move,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  top,
  bottom,
  left,
  right,
}

class NeoCropCanvas extends StatefulWidget {
  final File imageFile;
  final double? aspectRatio; // null = free crop
  final int rotationAngle; // 0, 90, 180, 270
  final bool flipHorizontal;
  final bool flipVertical;
  final ValueChanged<Rect> onCropChanged; // Normalized rect (0.0 - 1.0)

  const NeoCropCanvas({
    super.key,
    required this.imageFile,
    this.aspectRatio,
    this.rotationAngle = 0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    required this.onCropChanged,
  });

  @override
  State<NeoCropCanvas> createState() => _NeoCropCanvasState();
}

class _NeoCropCanvasState extends State<NeoCropCanvas> {
  // Normalized crop rectangle relative to image bounds (0.0 to 1.0)
  Rect _normCropRect = const Rect.fromLTWH(0.05, 0.05, 0.9, 0.9);
  CropHandleType _activeHandle = CropHandleType.none;
  Offset? _dragStartOffset;
  Rect? _initialNormRect;
  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  @override
  void didUpdateWidget(NeoCropCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageFile.path != widget.imageFile.path ||
        oldWidget.rotationAngle != widget.rotationAngle) {
      _loadImageDimensions();
    } else if (oldWidget.aspectRatio != widget.aspectRatio) {
      _applyAspectRatioConstraint();
    }
  }

  void _loadImageDimensions() {
    final image = FileImage(widget.imageFile);
    image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((info, _) {
        if (!mounted) return;
        final rawW = info.image.width.toDouble();
        final rawH = info.image.height.toDouble();
        final isRotated90or270 =
            widget.rotationAngle == 90 || widget.rotationAngle == 270;
        setState(() {
          _imageSize = isRotated90or270 ? Size(rawH, rawW) : Size(rawW, rawH);
          _applyAspectRatioConstraint();
        });
      }),
    );
  }

  Rect _calculateImageRect(Size containerSize) {
    if (_imageSize == null ||
        _imageSize!.width <= 0 ||
        _imageSize!.height <= 0) {
      return Offset.zero & containerSize;
    }

    final imageAR = _imageSize!.width / _imageSize!.height;
    final containerAR = containerSize.width / containerSize.height;

    double renderW, renderH;
    if (imageAR > containerAR) {
      renderW = containerSize.width;
      renderH = containerSize.width / imageAR;
    } else {
      renderH = containerSize.height;
      renderW = containerSize.height * imageAR;
    }

    final left = (containerSize.width - renderW) / 2.0;
    final top = (containerSize.height - renderH) / 2.0;

    return Rect.fromLTWH(left, top, renderW, renderH);
  }

  void _applyAspectRatioConstraint() {
    if (widget.aspectRatio == null) {
      _normCropRect = const Rect.fromLTWH(0.05, 0.05, 0.9, 0.9);
      widget.onCropChanged(_normCropRect);
      return;
    }

    final r = widget.aspectRatio!;
    final imageAR = (_imageSize != null && _imageSize!.height > 0)
        ? _imageSize!.width / _imageSize!.height
        : 1.0;

    final normAR = r / imageAR;

    double normW = 0.85;
    double normH = 0.85;

    if (normAR >= 1.0) {
      normH = (normW / normAR).clamp(0.15, 0.95);
    } else {
      normW = (normH * normAR).clamp(0.15, 0.95);
    }

    final l = ((1.0 - normW) / 2.0).clamp(0.0, 1.0 - normW);
    final t = ((1.0 - normH) / 2.0).clamp(0.0, 1.0 - normH);

    setState(() {
      _normCropRect = Rect.fromLTWH(l, t, normW, normH);
    });
    widget.onCropChanged(_normCropRect);
  }

  CropHandleType _hitTestHandle(Offset localTouch, Rect displayCropRect) {
    const handleSize = 30.0;

    // Check 4 Corners
    final tl = displayCropRect.topLeft;
    if ((localTouch - tl).distance <= handleSize) return CropHandleType.topLeft;

    final tr = displayCropRect.topRight;
    if ((localTouch - tr).distance <= handleSize) return CropHandleType.topRight;

    final bl = displayCropRect.bottomLeft;
    if ((localTouch - bl).distance <= handleSize) return CropHandleType.bottomLeft;

    final br = displayCropRect.bottomRight;
    if ((localTouch - br).distance <= handleSize) return CropHandleType.bottomRight;

    // Check 4 Edges
    final topMid = Offset(displayCropRect.center.dx, displayCropRect.top);
    if ((localTouch - topMid).distance <= handleSize) return CropHandleType.top;

    final botMid = Offset(displayCropRect.center.dx, displayCropRect.bottom);
    if ((localTouch - botMid).distance <= handleSize) return CropHandleType.bottom;

    final leftMid = Offset(displayCropRect.left, displayCropRect.center.dy);
    if ((localTouch - leftMid).distance <= handleSize) return CropHandleType.left;

    final rightMid = Offset(displayCropRect.right, displayCropRect.center.dy);
    if ((localTouch - rightMid).distance <= handleSize) return CropHandleType.right;

    // Inside Box -> Move
    if (displayCropRect.contains(localTouch)) {
      return CropHandleType.move;
    }

    return CropHandleType.none;
  }

  void _onPanStart(DragStartDetails details, Size containerSize) {
    final imageRect = _calculateImageRect(containerSize);
    final displayCropRect = Rect.fromLTWH(
      imageRect.left + _normCropRect.left * imageRect.width,
      imageRect.top + _normCropRect.top * imageRect.height,
      _normCropRect.width * imageRect.width,
      _normCropRect.height * imageRect.height,
    );

    _activeHandle = _hitTestHandle(details.localPosition, displayCropRect);
    _dragStartOffset = details.localPosition;
    _initialNormRect = _normCropRect;
  }

  void _onPanUpdate(DragUpdateDetails details, Size containerSize) {
    if (_activeHandle == CropHandleType.none ||
        _dragStartOffset == null ||
        _initialNormRect == null) {
      return;
    }

    final imageRect = _calculateImageRect(containerSize);
    if (imageRect.width <= 0 || imageRect.height <= 0) return;

    final dxNorm =
        (details.localPosition.dx - _dragStartOffset!.dx) / imageRect.width;
    final dyNorm =
        (details.localPosition.dy - _dragStartOffset!.dy) / imageRect.height;

    double left = _initialNormRect!.left;
    double top = _initialNormRect!.top;
    double right = _initialNormRect!.right;
    double bottom = _initialNormRect!.bottom;

    switch (_activeHandle) {
      case CropHandleType.move:
        final w = _initialNormRect!.width;
        final h = _initialNormRect!.height;
        left = (_initialNormRect!.left + dxNorm).clamp(0.0, 1.0 - w);
        top = (_initialNormRect!.top + dyNorm).clamp(0.0, 1.0 - h);
        right = left + w;
        bottom = top + h;
        break;

      case CropHandleType.topLeft:
        left = (_initialNormRect!.left + dxNorm).clamp(0.0, right - 0.1);
        top = (_initialNormRect!.top + dyNorm).clamp(0.0, bottom - 0.1);
        break;

      case CropHandleType.topRight:
        right = (_initialNormRect!.right + dxNorm).clamp(left + 0.1, 1.0);
        top = (_initialNormRect!.top + dyNorm).clamp(0.0, bottom - 0.1);
        break;

      case CropHandleType.bottomLeft:
        left = (_initialNormRect!.left + dxNorm).clamp(0.0, right - 0.1);
        bottom = (_initialNormRect!.bottom + dyNorm).clamp(top + 0.1, 1.0);
        break;

      case CropHandleType.bottomRight:
        right = (_initialNormRect!.right + dxNorm).clamp(left + 0.1, 1.0);
        bottom = (_initialNormRect!.bottom + dyNorm).clamp(top + 0.1, 1.0);
        break;

      case CropHandleType.top:
        top = (_initialNormRect!.top + dyNorm).clamp(0.0, bottom - 0.1);
        break;

      case CropHandleType.bottom:
        bottom = (_initialNormRect!.bottom + dyNorm).clamp(top + 0.1, 1.0);
        break;

      case CropHandleType.left:
        left = (_initialNormRect!.left + dxNorm).clamp(0.0, right - 0.1);
        break;

      case CropHandleType.right:
        right = (_initialNormRect!.right + dxNorm).clamp(left + 0.1, 1.0);
        break;

      case CropHandleType.none:
        break;
    }

    // Apply aspect ratio constraint if set and resizing
    if (widget.aspectRatio != null && _activeHandle != CropHandleType.move) {
      final r = widget.aspectRatio!;
      final imageAR = (_imageSize != null && _imageSize!.height > 0)
          ? _imageSize!.width / _imageSize!.height
          : 1.0;
      final normAR = r / imageAR;

      final newW = right - left;
      final newH = newW / normAR;
      if (top + newH <= 1.0) {
        bottom = top + newH;
      } else {
        bottom = 1.0;
        right = (left + (bottom - top) * normAR).clamp(left + 0.1, 1.0);
      }
    }

    final newRect = Rect.fromLTRB(left, top, right, bottom);
    setState(() {
      _normCropRect = newRect;
    });
    widget.onCropChanged(_normCropRect);
  }

  void _onPanEnd(DragEndDetails details) {
    _activeHandle = CropHandleType.none;
    _dragStartOffset = null;
    _initialNormRect = null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerSize =
            Size(constraints.maxWidth, constraints.maxHeight);
        final imageRect = _calculateImageRect(containerSize);

        return GestureDetector(
          onPanStart: (d) => _onPanStart(d, containerSize),
          onPanUpdate: (d) => _onPanUpdate(d, containerSize),
          onPanEnd: _onPanEnd,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Image preview
              Positioned.fill(
                child: Transform.rotate(
                  angle: (widget.rotationAngle * 3.14159) / 180.0,
                  child: Transform(
                    transform: Matrix4.diagonal3Values(
                      widget.flipHorizontal ? -1.0 : 1.0,
                      widget.flipVertical ? -1.0 : 1.0,
                      1.0,
                    ),
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.contain,
                        width: containerSize.width,
                        height: containerSize.height,
                      ),
                    ),
                  ),
                ),
              ),

              // Dimmed Mask & Neo-Brutalist Grid Overlay aligned to image bounds
              Positioned.fill(
                child: CustomPaint(
                  painter: _NeoCropPainter(
                    normCropRect: _normCropRect,
                    imageRect: imageRect,
                    accentColor: NeoColors.yellow,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NeoCropPainter extends CustomPainter {
  final Rect normCropRect;
  final Rect imageRect;
  final Color accentColor;

  _NeoCropPainter({
    required this.normCropRect,
    required this.imageRect,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cropRect = Rect.fromLTWH(
      imageRect.left + normCropRect.left * imageRect.width,
      imageRect.top + normCropRect.top * imageRect.height,
      normCropRect.width * imageRect.width,
      normCropRect.height * imageRect.height,
    );

    // 1. Draw dimmed mask outside crop rect but inside image bounds
    final maskPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final fullPath = Path()..addRect(imageRect);
    final cropPath = Path()..addRect(cropRect);
    final diffPath = Path.combine(PathOperation.difference, fullPath, cropPath);

    canvas.drawPath(diffPath, maskPaint);

    // 2. Draw Neo-Brutalist crop border line
    final borderPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final outlinePaint = Paint()
      ..color = NeoColors.borderLight
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    canvas.drawRect(cropRect, outlinePaint);
    canvas.drawRect(cropRect, borderPaint);

    // 3. Draw Rule-of-Thirds grid lines inside crop box
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final w3 = cropRect.width / 3.0;
    final h3 = cropRect.height / 3.0;

    // Vertical grid lines
    canvas.drawLine(
      Offset(cropRect.left + w3, cropRect.top),
      Offset(cropRect.left + w3, cropRect.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left + w3 * 2, cropRect.top),
      Offset(cropRect.left + w3 * 2, cropRect.bottom),
      gridPaint,
    );

    // Horizontal grid lines
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + h3),
      Offset(cropRect.right, cropRect.top + h3),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + h3 * 2),
      Offset(cropRect.right, cropRect.top + h3 * 2),
      gridPaint,
    );

    // 4. Draw 8 Neo-Brutalist handle badges (Corners & Edges)
    _drawHandle(canvas, cropRect.topLeft);
    _drawHandle(canvas, cropRect.topRight);
    _drawHandle(canvas, cropRect.bottomLeft);
    _drawHandle(canvas, cropRect.bottomRight);

    _drawHandle(canvas, Offset(cropRect.center.dx, cropRect.top));
    _drawHandle(canvas, Offset(cropRect.center.dx, cropRect.bottom));
    _drawHandle(canvas, Offset(cropRect.left, cropRect.center.dy));
    _drawHandle(canvas, Offset(cropRect.right, cropRect.center.dy));
  }

  void _drawHandle(Canvas canvas, Offset center) {
    const handleRadius = 7.0;

    final fillPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = NeoColors.borderLight
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final shadowPaint = Paint()
      ..color = NeoColors.borderLight
      ..style = PaintingStyle.fill;

    // Handle Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + const Offset(2, 2),
          width: handleRadius * 2,
          height: handleRadius * 2,
        ),
        const Radius.circular(3),
      ),
      shadowPaint,
    );

    // Handle Fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: handleRadius * 2,
          height: handleRadius * 2,
        ),
        const Radius.circular(3),
      ),
      fillPaint,
    );

    // Handle Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: handleRadius * 2,
          height: handleRadius * 2,
        ),
        const Radius.circular(3),
      ),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NeoCropPainter oldDelegate) {
    return oldDelegate.normCropRect != normCropRect ||
        oldDelegate.imageRect != imageRect ||
        oldDelegate.accentColor != accentColor;
  }
}

