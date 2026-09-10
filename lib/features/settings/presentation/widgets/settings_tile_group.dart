import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_switch.dart';
import 'sound_selection_bottom_sheet.dart';

class SettingsTileGroup extends StatelessWidget {
  final bool isDark;
  final ThemeMode themeMode;
  final bool isSoundEnabled;
  final String currentTrackId;
  final bool isDeveloperUnlocked;
  final ValueChanged<ThemeMode> onChangeThemeMode;
  final ValueChanged<bool> onToggleSound;
  final ValueChanged<String> onSelectTrack;
  final VoidCallback onTapVersion;

  const SettingsTileGroup({
    super.key,
    required this.isDark,
    required this.themeMode,
    required this.isSoundEnabled,
    required this.currentTrackId,
    required this.isDeveloperUnlocked,
    required this.onChangeThemeMode,
    required this.onToggleSound,
    required this.onSelectTrack,
    required this.onTapVersion,
  });

  Widget _buildThemeChip({
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChangeThemeMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: NeoStyles.neoDecoration(
            backgroundColor: isSelected
                ? NeoColors.yellow
                : (isDark ? NeoColors.darkBg : NeoColors.lightBg),
            radius: 10,
            shadow: isSelected ? 2 : 1,
            borderColor: isSelected
                ? (isDark ? Colors.white : NeoColors.borderLight)
                : (isDark
                      ? NeoColors.borderDark.withValues(alpha: 0.5)
                      : Colors.grey[400]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? NeoColors.borderLight
                    : (isDark
                          ? NeoColors.textSecondaryDark
                          : NeoColors.textSecondaryLight),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? NeoColors.borderLight
                      : (isDark
                            ? NeoColors.textPrimaryDark
                            : NeoColors.textPrimaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
      child: Column(
        children: [
          // Theme Mode Selector
          Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        themeMode == ThemeMode.light
                            ? Icons.light_mode_rounded
                            : (themeMode == ThemeMode.dark
                                  ? Icons.dark_mode_rounded
                                  : Icons.brightness_auto_rounded),
                        color: isDark ? NeoColors.yellow : NeoColors.purple,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'App Theme',
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              themeMode == ThemeMode.system
                                  ? 'System Default (Matches device)'
                                  : (themeMode == ThemeMode.light
                                        ? 'Light Mode'
                                        : 'Dark Mode'),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                color: isDark
                                    ? NeoColors.textSecondaryDark
                                    : NeoColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildThemeChip(
                        label: 'System',
                        icon: Icons.smartphone_rounded,
                        mode: ThemeMode.system,
                        isSelected: themeMode == ThemeMode.system,
                      ),
                      const SizedBox(width: 8),
                      _buildThemeChip(
                        label: 'Light',
                        icon: Icons.wb_sunny_rounded,
                        mode: ThemeMode.light,
                        isSelected: themeMode == ThemeMode.light,
                      ),
                      const SizedBox(width: 8),
                      _buildThemeChip(
                        label: 'Dark',
                        icon: Icons.nightlight_round,
                        mode: ThemeMode.dark,
                        isSelected: themeMode == ThemeMode.dark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(),

          InkWell(
            onTap: onTapVersion,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'App Version',
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '1.0.0',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),

          InkWell(
            onTap: () => context.push('/privacy_policy'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Privacy Policy',
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
          const Divider(),

          InkWell(
            onTap: () {
              SoundSelectionBottomSheet.show(
                context: context,
                isDark: isDark,
                isSoundEnabled: isSoundEnabled,
                currentTrackId: currentTrackId,
                onToggleSound: onToggleSound,
                onSelectTrack: onSelectTrack,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  Icon(
                    Icons.music_note_rounded,
                    color: NeoColors.cyan,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            Text(
                              'Background Sound',
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? NeoColors.darkBg
                                    : NeoColors.softCyan,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDark
                                      ? NeoColors.borderDark
                                      : NeoColors.cyan,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                AudioService.tracks
                                    .firstWhere(
                                      (t) => t.id == currentTrackId,
                                      orElse: () => AudioService.tracks.first,
                                    )
                                    .title,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? NeoColors.cyan
                                      : NeoColors.borderLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          isSoundEnabled
                              ? 'Tap to choose from 5 relaxing audio loops'
                              : 'Audio muted • Tap to customize tracks',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            color: isDark
                                ? NeoColors.textSecondaryDark
                                : NeoColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  NeoSwitch(
                    value: isSoundEnabled,
                    activeTrackColor: NeoColors.cyan,
                    onChanged: onToggleSound,
                  ),
                ],
              ),
            ),
          ),

          if (isDeveloperUnlocked) ...[
            const Divider(),
            InkWell(
              onTap: () => context.push('/developer'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.code_rounded, color: NeoColors.cyan),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Developer Details',
                        style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
