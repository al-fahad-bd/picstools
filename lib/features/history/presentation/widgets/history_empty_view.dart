import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';

class HistoryEmptyView extends StatelessWidget {
  final bool isDark;

  const HistoryEmptyView({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: NeoStyles.neoDecoration(
              backgroundColor: NeoColors.softCyan,
              radius: 40,
              shadow: 3,
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 48,
              color: NeoColors.borderLight,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Recent Operations',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Compressed or converted images will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: isDark
                  ? NeoColors.textSecondaryDark
                  : NeoColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
