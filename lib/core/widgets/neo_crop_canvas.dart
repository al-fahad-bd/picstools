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

  @override
  void initState() {
    super.initState();
    _applyAspectRatioConstraint();
  }

  @override
  void didUpdateWidget(NeoCropCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.aspectRatio != widget.aspectRatio) {
      _applyAspectRatioConstraint();
    }
  }

  void _applyAspectRatioConstraint() {
    if (widget.aspectRatio == null) return;
    final r = widget.aspectRatio!;
    double w = 0.8;
    double h = 0.8;

    if (r >= 1.0) {
      h = (w / r).clamp(0.15, 0.95);
    } else {
      w = (h * r).clamp(0.15, 0.95);
    }

    final l = (1.0 - w) / 2.0;
    final t = (1.0 - h) / 2.0;

    setState(() {
      _normCropRect = Rect.fromLTWH(l, t, w, h);
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

  void _onPanStart(DragStartDetails details, Size displaySize) {
    final displayCropRect = Rect.fromLTWH(
      _normCropRect.left * displaySize.width,
      _normCropRect.top * displaySize.height,
      _normCropRect.width * displaySize.width,
      _normCropRect.height * displaySize.height,
    );

    _activeHandle = _hitTestHandle(details.localPosition, displayCropRect);
    _dragStartOffset = details.localPosition;
    _initialNormRect = _normCropRect;
  }

  void _onPanUpdate(DragUpdateDetails details, Size displaySize) {
    if (_activeHandle == CropHandleType.none || _dragStartOffset == null || _initialNormRect == null) {
      return;
    }

    final dxNorm = (details.localPosition.dx - _dragStartOffset!.dx) / displaySize.width;
    final dyNorm = (details.localPosition.dy - _dragStartOffset!.dy) / displaySize.height;

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
      final newW = right - left;
      final newH = newW / r;
      if (top + newH <= 1.0) {
        bottom = top + newH;
      } else {
        bottom = 1.0;
        right = (left + (bottom - top) * r).clamp(left + 0.1, 1.0);
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
        final displaySize = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onPanStart: (d) => _onPanStart(d, displaySize),
          onPanUpdate: (d) => _onPanUpdate(d, displaySize),
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
                        width: displaySize.width,
                        height: displaySize.height,
                      ),
                    ),
                  ),
                ),
              ),

              // Dimmed Mask & Neo-Brutalist Grid Overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: _NeoCropPainter(
                    normCropRect: _normCropRect,
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
  final Color accentColor;

  _NeoCropPainter({
    required this.normCropRect,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cropRect = Rect.fromLTWH(
      normCropRect.left * size.width,
      normCropRect.top * size.height,
      normCropRect.width * size.width,
      normCropRect.height * size.height,
    );

    // 1. Draw dimmed mask outside crop rect
    final maskPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
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
        Rect.fromCenter(center: center + const Offset(2, 2), width: handleRadius * 2, height: handleRadius * 2),
        const Radius.circular(3),
      ),
      shadowPaint,
    );

    // Handle Fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: handleRadius * 2, height: handleRadius * 2),
        const Radius.circular(3),
      ),
      fillPaint,
    );

    // Handle Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: handleRadius * 2, height: handleRadius * 2),
        const Radius.circular(3),
      ),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NeoCropPainter oldDelegate) {
    return oldDelegate.normCropRect != normCropRect || oldDelegate.accentColor != accentColor;
  }
}
