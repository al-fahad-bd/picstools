import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_doodles.dart';
import '../../../../core/widgets/neo_tool_graphics.dart';
import '../../models/tool_item.dart';

class ToolCardItem extends StatefulWidget {
  final ToolItem tool;
  final bool isDark;
  final VoidCallback onTap;

  const ToolCardItem({
    super.key,
    required this.tool,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<ToolCardItem> createState() => _ToolCardItemState();
}

class _ToolCardItemState extends State<ToolCardItem> {
  bool _isPressed = false;

  Widget _buildToolGraphic(String toolId) {
    switch (toolId) {
      case 'compress':
        return CompressToolGraphic(isDark: widget.isDark);
      case 'pdf':
        return PdfToolGraphic(isDark: widget.isDark);
      case 'resize':
        return ResizeToolGraphic(isDark: widget.isDark);
      case 'crop':
        return CropToolGraphic(isDark: widget.isDark);
      case 'convert':
        return ConvertToolGraphic(isDark: widget.isDark);
      case 'id_photo':
        return IdPhotoToolGraphic(isDark: widget.isDark);
      case 'signature':
        return SignatureToolGraphic(isDark: widget.isDark);
      case 'remove_bg':
      case 'remove':
      case 'social':
        return RemoveBgToolGraphic(isDark: widget.isDark);
      default:
        return CompressToolGraphic(isDark: widget.isDark);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark
        ? NeoColors.darkSurface
        : widget.tool.softColor;
    final shadowBorderColor = widget.isDark
        ? NeoColors.borderDark
        : NeoColors.borderLight;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _isPressed ? 3.0 : 0.0,
          _isPressed ? 3.0 : 0.0,
          0,
        ),
        padding: const EdgeInsets.all(12),
        decoration: NeoStyles.neoDecoration(
          backgroundColor: cardBg,
          borderColor: shadowBorderColor,
          radius: 16,
          shadow: _isPressed ? 1.5 : 4.5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Tag Badge & Sparkle Icon Doodle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: NeoBadge(
                    label: widget.tool.tag,
                    backgroundColor: widget.isDark
                        ? widget.tool.accentColor
                        : NeoColors.lightSurface,
                    textColor: widget.isDark
                        ? NeoColors.getContrastColor(widget.tool.accentColor)
                        : NeoColors.borderLight,
                    fontSize: 8.5,
                  ),
                ),
                const SizedBox(width: 4),
                NeoSparkleDoodle(size: 16, color: widget.tool.accentColor),
              ],
            ),
            const SizedBox(height: 8),

            // Middle Hero Container: Custom Neo Mini Illustration
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF1E1E24)
                      : NeoColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: shadowBorderColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: shadowBorderColor,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Center(child: _buildToolGraphic(widget.tool.id)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Bottom Info: Title + Arrow & Subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.tool.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: widget.isDark
                          ? NeoColors.textPrimaryDark
                          : NeoColors.textPrimaryLight,
                      height: 1.15,
                    ),
                  ),
                ),
                widget.tool.title == 'Remove Background'
                    ? const SizedBox.shrink()
                    : Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: widget.isDark
                            ? NeoColors.textPrimaryDark
                            : NeoColors.borderLight,
                      ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              widget.tool.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: widget.isDark
                    ? NeoColors.textSecondaryDark
                    : NeoColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
