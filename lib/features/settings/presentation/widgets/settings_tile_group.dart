import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_switch.dart';

class SettingsTileGroup extends StatelessWidget {
  final bool isDark;
  final bool isSoundEnabled;
  final bool isDeveloperUnlocked;
  final ValueChanged<bool> onToggleSound;
  final VoidCallback onTapVersion;

  const SettingsTileGroup({
    super.key,
    required this.isDark,
    required this.isSoundEnabled,
    required this.isDeveloperUnlocked,
    required this.onToggleSound,
    required this.onTapVersion,
  });

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      backgroundColor: isDark
          ? NeoColors.darkSurface
          : NeoColors.lightSurface,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(
                'App Version',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Text(
                '1.0.0',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: onTapVersion,
            ),
          ),
          const Divider(),
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: Text(
                'Privacy Policy',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/privacy_policy'),
            ),
          ),
          const Divider(),
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(
                Icons.music_note_rounded,
                color: isDark ? NeoColors.yellow : NeoColors.purple,
              ),
              title: Text(
                'Background Sound',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Relaxing ambient music loop',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  color: isDark
                      ? NeoColors.textSecondaryDark
                      : NeoColors.textSecondaryLight,
                ),
              ),
              trailing: NeoSwitch(
                value: isSoundEnabled,
                activeTrackColor: NeoColors.yellow,
                onChanged: onToggleSound,
              ),
            ),
          ),
          if (isDeveloperUnlocked) ...[
            const Divider(),
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: const Icon(
                  Icons.code_rounded,
                  color: NeoColors.cyan,
                ),
                title: Text(
                  'Developer Details',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/developer'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
