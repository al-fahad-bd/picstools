import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';

class PreviewModeTabs extends StatelessWidget {
  final int selectedIndex;
  final bool isDark;
  final ValueChanged<int> onSelectMode;

  const PreviewModeTabs({
    super.key,
    required this.selectedIndex,
    required this.isDark,
    required this.onSelectMode,
  });

  static const List<String> _tabs = [
    'Split View',
    'Cutout Only',
    'Original',
  ];

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? NeoColors.borderDark : NeoColors.borderLight;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final idx = entry.key;
          final title = entry.value;
          final isSelected = selectedIndex == idx;

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelectMode(idx),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? NeoColors.purple : NeoColors.yellow)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(
                          color: isDark
                              ? NeoColors.borderDark
                              : NeoColors.borderLight,
                          width: 1.5,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected
                          ? (isDark ? NeoColors.lightSurface : NeoColors.borderLight)
                          : (isDark
                                ? NeoColors.textSecondaryDark
                                : NeoColors.textSecondaryLight),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
