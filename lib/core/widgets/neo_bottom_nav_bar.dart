import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/neo_colors.dart';
import '../constants/neo_styles.dart';

class NeoNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color activeColor;

  const NeoNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.activeColor,
  });
}

class NeoBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NeoNavItem> items;

  const NeoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? NeoColors.darkSurface : NeoColors.lightSurface;
    final borderColor = isDark ? NeoColors.borderDark : NeoColors.borderLight;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: NeoStyles.neoDecoration(
          backgroundColor: bg,
          borderColor: borderColor,
          radius: 20,
          shadow: 4,
        ),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == currentIndex;

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: isSelected
                  ? BoxDecoration(
                      color: item.activeColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: NeoColors.borderLight,
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    )
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    size: 22,
                    color: isSelected
                        ? NeoColors.borderLight
                        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: NeoColors.borderLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    ),
  );
}
}
