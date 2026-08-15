import '../core/widgets/neo_back_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/neo_colors.dart';
import '../core/constants/neo_styles.dart';
import '../core/widgets/neo_button.dart';

class ToolPlaceholderView extends StatelessWidget {
  final String title;

  const ToolPlaceholderView({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const NeoBackButton(),
        title: Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: NeoStyles.neoDecoration(
                  backgroundColor: NeoColors.softCyan,
                  radius: 50,
                  shadow: 4,
                ),
                child: const Icon(Icons.build_circle_rounded, size: 60, color: NeoColors.borderLight),
              ),
              const SizedBox(height: 24),
              Text(
                '$title Module',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Architecture and design system ready for $title engine integration.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 30),
              NeoButton(
                label: 'BACK TO HOME',
                backgroundColor: NeoColors.yellow,
                fullWidth: true,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
