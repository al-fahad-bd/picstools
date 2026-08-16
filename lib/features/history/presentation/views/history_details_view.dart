import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_back_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../signature/presentation/widgets/checkered_pattern_painter.dart';

class HistoryDetailsView extends StatelessWidget {
  final HistoryItem item;

  const HistoryDetailsView({super.key, required this.item});

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

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        now.year == dt.year && now.month == dt.month && now.day == dt.day;

    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute $ampm';

    if (isToday) {
      return 'Today at $timeStr';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $timeStr';
  }

  Future<void> _saveFile(BuildContext context, File file) async {
    if (!file.existsSync()) {
      NeoToast.showError(
        context,
        'Source file is no longer available on disk.',
      );
      return;
    }

    try {
      final saver = getIt<FileSaveService>();
      final isPdf = file.path.toLowerCase().endsWith('.pdf');
      await saver.saveFileToPublicStorage(
        sourceFile: file,
        subFolder: isPdf ? 'Documents' : 'Processed',
      );
      if (context.mounted) {
        NeoToast.showSuccess(
          context,
          '🎉 Saved to ${isPdf ? 'Documents' : 'Gallery & Files'}!',
          icon: isPdf
              ? Icons.picture_as_pdf_rounded
              : Icons.download_done_rounded,
        );
      }
    } catch (e) {
      if (context.mounted) {
        NeoToast.showError(context, 'Failed to save file: $e');
      }
    }
  }

  void _shareFile(BuildContext context, File file) {
    if (!file.existsSync()) {
      NeoToast.showError(
        context,
        'Source file is no longer available on disk.',
      );
      return;
    }

    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    Share.shareXFiles(
      [XFile(file.path)],
      text: 'Shared from PicsTools (${item.toolName})',
      sharePositionOrigin: origin,
    );
  }

  void _confirmDelete(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark
              ? NeoColors.darkSurface
              : NeoColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
              width: 2,
            ),
          ),
          title: Text(
            'Delete History Item?',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Are you sure you want to remove this record from your history?',
            style: GoogleFonts.spaceGrotesk(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'CANCEL',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NeoColors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final historyService = getIt<HistoryService>();
                await historyService.deleteHistoryItem(item.id);
                if (context.mounted) {
                  context.pop();
                  NeoToast.showSuccess(
                    context,
                    'History item deleted.',
                    icon: Icons.delete_outline_rounded,
                  );
                }
              },
              child: Text(
                'DELETE',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final processedFile = File(item.processedPath);
    final fileExists = processedFile.existsSync();
    final isPdf = item.processedPath.toLowerCase().endsWith('.pdf');
    final isPng = item.processedPath.toLowerCase().endsWith('.png');

    final toolColor = _getToolAccentColor(item.toolName);
    final toolIcon = _getToolIcon(item.toolName);
    final iconColor = _getToolIconColor(toolColor);

    final hasSavings =
        item.originalSizeBytes > item.processedSizeBytes &&
        item.originalSizeBytes > 0;
    final savingsPercent = FileUtils.calculateSavingsPercentage(
      item.originalSizeBytes,
      item.processedSizeBytes,
    );

    return Scaffold(
      appBar: AppBar(
        leading: const NeoBackButton(),
        title: Text(
          'History Details',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: NeoColors.red,
            ),
            tooltip: 'Delete Item',
            onPressed: () => _confirmDelete(context, isDark),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Result Image / Document Preview Card
              NeoCard(
                backgroundColor: isDark
                    ? NeoColors.darkSurface
                    : NeoColors.lightSurface,
                shadowOffset: 4,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 280,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? NeoColors.borderDark
                                : NeoColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        child: fileExists
                            ? (isPdf
                                  ? _buildPdfPreview(isDark)
                                  : Stack(
                                      children: [
                                        if (isPng)
                                          Positioned.fill(
                                            child: CustomPaint(
                                              painter: CheckeredPatternPainter(
                                                squareSize: 10,
                                              ),
                                            ),
                                          ),
                                        Positioned.fill(
                                          child: InteractiveViewer(
                                            maxScale: 4.0,
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              child: Image.file(
                                                processedFile,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ))
                            : _buildFileNotFoundNotice(isDark),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: NeoStyles.neoDecoration(
                                  backgroundColor: toolColor,
                                  radius: 8,
                                  shadow: 1.5,
                                ),
                                child: Icon(
                                  toolIcon,
                                  size: 16,
                                  color: iconColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.toolName,
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        NeoBadge(
                          label: isPdf
                              ? 'PDF DOCUMENT'
                              : (isPng ? 'TRANSPARENT PNG' : 'IMAGE'),
                          backgroundColor: isPdf
                              ? NeoColors.purple
                              : (isPng ? NeoColors.cyan : NeoColors.yellow),
                          fontSize: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Detailed Metrics Breakdown Card
              NeoCard(
                backgroundColor: isDark
                    ? NeoColors.darkSurface
                    : NeoColors.lightSurface,
                shadowOffset: 3,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Processing Information',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Timestamp row
                    _buildInfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Created Date',
                      value: _formatDate(item.timestamp),
                      isDark: isDark,
                    ),
                    const Divider(height: 20),

                    // Processed Size row
                    _buildInfoRow(
                      icon: Icons.storage_rounded,
                      label: 'Output File Size',
                      value: FileUtils.formatBytes(item.processedSizeBytes),
                      isDark: isDark,
                    ),

                    if (item.originalSizeBytes > 0 &&
                        item.originalSizeBytes != item.processedSizeBytes) ...[
                      const Divider(height: 20),
                      _buildInfoRow(
                        icon: Icons.compress_rounded,
                        label: 'Original Size',
                        value: FileUtils.formatBytes(item.originalSizeBytes),
                        isDark: isDark,
                      ),
                    ],

                    if (hasSavings) ...[
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.trending_down_rounded,
                                  size: 18,
                                  color: NeoColors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Storage Saved',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? NeoColors.textSecondaryDark
                                          : NeoColors.textSecondaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: NeoStyles.neoDecoration(
                                backgroundColor: NeoColors.green,
                                radius: 8,
                                shadow: 1.5,
                              ),
                              child: Text(
                                '-${savingsPercent.round()}% (${FileUtils.formatBytes(item.originalSizeBytes - item.processedSizeBytes)})',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: NeoColors.borderLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              if (fileExists) ...[
                NeoButton(
                  label: isPdf
                      ? 'SAVE PDF TO DOWNLOADS'
                      : 'SAVE TO DEVICE GALLERY',
                  icon: const Icon(
                    Icons.download_rounded,
                    color: NeoColors.borderLight,
                  ),
                  backgroundColor: NeoColors.green,
                  fullWidth: true,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onPressed: () => _saveFile(context, processedFile),
                ),
                const SizedBox(height: 12),
                NeoButton(
                  label: 'SHARE FILE',
                  icon: const Icon(
                    Icons.share_rounded,
                    color: NeoColors.borderLight,
                  ),
                  backgroundColor: NeoColors.yellow,
                  fullWidth: true,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onPressed: () => _shareFile(context, processedFile),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    radius: 12,
                    shadow: 1.5,
                  ),
                  child: Text(
                    '⚠️ The temporary file for this history item was cleared or moved.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? NeoColors.textSecondaryDark
                          : NeoColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isDark ? NeoColors.yellow : NeoColors.purple,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? NeoColors.textSecondaryDark
                        : NeoColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? NeoColors.textPrimaryDark
                  : NeoColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPdfPreview(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: NeoStyles.neoDecoration(
              backgroundColor: NeoColors.purple,
              radius: 20,
              shadow: 3,
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              size: 54,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'PDF Document Created',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ready to view, save, or share',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: isDark
                  ? NeoColors.textSecondaryDark
                  : NeoColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileNotFoundNotice(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image_rounded,
            size: 48,
            color: NeoColors.red,
          ),
          const SizedBox(height: 12),
          Text(
            'Temporary File Cleared',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
