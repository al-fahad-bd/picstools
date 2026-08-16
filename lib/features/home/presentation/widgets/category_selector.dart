import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final bool isDark;
  final ValueChanged<String> onSelectCategory;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.isDark,
    required this.onSelectCategory,
  });

  static const List<String> categories = [
    'ALL',
    'POPULAR',
    'EDIT',
    'CONVERT',
    'UTILITIES',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => onSelectCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: NeoStyles.neoDecoration(
                  backgroundColor: isSelected
                      ? NeoColors.yellow
                      : (isDark
                            ? NeoColors.darkSurface
                            : NeoColors.lightSurface),
                  borderColor: isDark
                      ? NeoColors.borderDark
                      : NeoColors.borderLight,
                  radius: 12,
                  shadow: isSelected ? 3 : 1.5,
                  showShadow: true,
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isSelected
                        ? NeoColors.borderLight
                        : (isDark
                              ? NeoColors.textPrimaryDark
                              : NeoColors.textPrimaryLight),
                    letterSpacing: 0.5,
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
