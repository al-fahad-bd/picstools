import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/widgets/neo_card.dart';

class HistoryItemCard extends StatelessWidget {
  final HistoryItem item;
  final bool isDark;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const HistoryItemCard({
    super.key,
    required this.item,
    required this.isDark,
    this.onDelete,
    this.onTap,
  });

  IconData _getToolIcon(String toolName) {
    final name = toolName.toLowerCase();
    if (name.contains('pdf')) return Icons.picture_as_pdf_rounded;
    if (name.contains('resize')) return Icons.aspect_ratio_rounded;
    if (name.contains('crop')) return Icons.crop_rounded;
    if (name.contains('convert')) return Icons.transform_rounded;
    if (name.contains('id photo') || name.contains('passport')) {
      return Icons.badge_rounded;
    }
    if (name.contains('signature')) return Icons.draw_rounded;
    if (name.contains('remove') ||
        name.contains('background') ||
        name.contains('bg')) {
      return Icons.auto_fix_high_rounded;
    }
    if (name.contains('social')) return Icons.share_rounded;
    return Icons.compress_rounded;
  }

  Color _getToolAccentColor(String toolName) {
    final name = toolName.toLowerCase();
    if (name.contains('pdf')) return NeoColors.purple;
    if (name.contains('resize')) return NeoColors.cyan;
    if (name.contains('crop')) return NeoColors.pink;
    if (name.contains('convert')) return NeoColors.green;
    if (name.contains('id photo') || name.contains('passport')) {
      return NeoColors.orange;
    }
    if (name.contains('signature')) return NeoColors.blue;
    if (name.contains('remove') ||
        name.contains('background') ||
        name.contains('bg')) {
      return NeoColors.purple;
    }
    if (name.contains('social')) return NeoColors.yellow;
    return NeoColors.yellow;
  }

  Color _getToolIconColor(Color toolColor) {
    if (toolColor == NeoColors.blue ||
        toolColor == NeoColors.purple ||
        toolColor == NeoColors.pink ||
        toolColor.computeLuminance() < 0.35) {
      return Colors.white;
    }
    return NeoColors.borderLight;
  }

  @override
  Widget build(BuildContext context) {
    final saved = FileUtils.calculateSavingsPercentage(
      item.originalSizeBytes,
      item.processedSizeBytes,
    );
    final toolIcon = _getToolIcon(item.toolName);
    final toolColor = _getToolAccentColor(item.toolName);
    final iconColor = _getToolIconColor(toolColor);
    final hasSavings =
        item.originalSizeBytes > item.processedSizeBytes &&
        item.originalSizeBytes > 0;
    final subtitleText = hasSavings
        ? 'Saved ${FileUtils.formatBytes(item.originalSizeBytes - item.processedSizeBytes)} (-${saved.round()}%)'
        : 'Processed • ${FileUtils.formatBytes(item.processedSizeBytes)}';

    return NeoCard(
      backgroundColor: isDark
          ? NeoColors.darkSurface
          : NeoColors.lightSurface,
      onTap: onTap ?? () => context.push('/history_details', extra: item),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: NeoStyles.neoDecoration(
              backgroundColor: toolColor,
              radius: 10,
              shadow: 2,
            ),
            child: Icon(toolIcon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.toolName,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitleText,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: isDark
                        ? NeoColors.textSecondaryDark
                        : NeoColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              color: isDark
                  ? NeoColors.textSecondaryDark
                  : NeoColors.textSecondaryLight,
              onPressed: onDelete,
            )
          else
            const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
