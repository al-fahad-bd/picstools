import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_switch.dart';

class SoundSelectionBottomSheet extends StatefulWidget {
  final bool isDark;
  final bool isSoundEnabled;
  final String currentTrackId;
  final ValueChanged<bool> onToggleSound;
  final ValueChanged<String> onSelectTrack;

  const SoundSelectionBottomSheet({
    super.key,
    required this.isDark,
    required this.isSoundEnabled,
    required this.currentTrackId,
    required this.onToggleSound,
    required this.onSelectTrack,
  });

  static Future<void> show({
    required BuildContext context,
    required bool isDark,
    required bool isSoundEnabled,
    required String currentTrackId,
    required ValueChanged<bool> onToggleSound,
    required ValueChanged<String> onSelectTrack,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SoundSelectionBottomSheet(
        isDark: isDark,
        isSoundEnabled: isSoundEnabled,
        currentTrackId: currentTrackId,
        onToggleSound: onToggleSound,
        onSelectTrack: onSelectTrack,
      ),
    );
  }

  @override
  State<SoundSelectionBottomSheet> createState() =>
      _SoundSelectionBottomSheetState();
}

class _SoundSelectionBottomSheetState extends State<SoundSelectionBottomSheet> {
  late bool _isSoundEnabled;
  late String _selectedTrackId;

  @override
  void initState() {
    super.initState();
    _isSoundEnabled = widget.isSoundEnabled;
    _selectedTrackId = widget.currentTrackId;
  }

  void _handleSelectTrack(String trackId) {
    setState(() {
      _selectedTrackId = trackId;
      _isSoundEnabled = true;
    });
    widget.onSelectTrack(trackId);
  }

  void _handleToggleSound(bool enabled) {
    setState(() {
      _isSoundEnabled = enabled;
    });
    widget.onToggleSound(enabled);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
          width: 3,
        ),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar with high-contrast Cyan Badge & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const NeoBadge(
                  label: '🎵 AMBIENT SOUNDSCAPES',
                  backgroundColor: NeoColors.cyan,
                  textColor: Colors.black,
                  fontSize: 11,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? NeoColors.borderDark
                            : NeoColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              'Background Music',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select copyright-free relaxing audio loop for focus and creativity',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: isDark
                    ? NeoColors.textSecondaryDark
                    : NeoColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),

            // Master Toggle Card (Single cohesive Cyan theme)
            NeoCard(
              backgroundColor: isDark
                  ? (_isSoundEnabled
                      ? const Color(0xFF083344)
                      : NeoColors.darkBg)
                  : (_isSoundEnabled
                      ? NeoColors.softCyan
                      : NeoColors.lightBg),
              borderColor: _isSoundEnabled
                  ? NeoColors.cyan
                  : (isDark ? NeoColors.borderDark : NeoColors.borderLight),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shadowOffset: 2,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isSoundEnabled
                          ? NeoColors.cyan
                          : (isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? NeoColors.borderDark
                            : NeoColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _isSoundEnabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      size: 20,
                      color: _isSoundEnabled
                          ? Colors.black
                          : (isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Background Music Loop',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          _isSoundEnabled
                              ? 'Audio loop is active'
                              : 'Audio is muted',
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
                    value: _isSoundEnabled,
                    activeTrackColor: NeoColors.cyan,
                    onChanged: _handleToggleSound,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Text(
              'CHOOSE SOUNDTRACK',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isDark
                    ? NeoColors.textSecondaryDark
                    : NeoColors.textSecondaryLight,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),

            // Track List (Consistent single Cyan theme with high contrast text and icons)
            ...AudioService.tracks.map((track) {
              final isSelected = track.id == _selectedTrackId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NeoCard(
                  backgroundColor: isSelected
                      ? (isDark
                          ? const Color(0xFF083344)
                          : NeoColors.softCyan)
                      : (isDark
                          ? NeoColors.darkSurface
                          : NeoColors.lightSurface),
                  borderColor: isSelected
                      ? NeoColors.cyan
                      : (isDark
                          ? NeoColors.borderDark
                          : NeoColors.borderLight),
                  shadowOffset: isSelected ? 3 : 1,
                  padding: const EdgeInsets.all(12),
                  onTap: () => _handleSelectTrack(track.id),
                  child: Row(
                    children: [
                      // Icon box: Vibrant Cyan with black icon when selected, neutral when unselected
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: NeoStyles.neoDecoration(
                          backgroundColor: isSelected
                              ? NeoColors.cyan
                              : (isDark
                                  ? NeoColors.darkBg
                                  : Colors.grey.shade100),
                          radius: 12,
                          shadow: isSelected ? 2 : 1,
                          borderColor: isSelected
                              ? NeoColors.borderLight
                              : (isDark
                                  ? NeoColors.borderDark
                                  : Colors.grey.shade400),
                        ),
                        child: Icon(
                          track.icon,
                          size: 22,
                          color: isSelected
                              ? Colors.black
                              : (isDark
                                  ? Colors.white
                                  : Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  track.title,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                NeoBadge(
                                  label: track.tag,
                                  backgroundColor: isSelected
                                      ? NeoColors.cyan
                                      : (isDark
                                          ? NeoColors.darkBg
                                          : Colors.grey.shade200),
                                  textColor: isSelected
                                      ? Colors.black
                                      : (isDark
                                          ? Colors.grey.shade300
                                          : Colors.black87),
                                  fontSize: 9,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              track.description,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey.shade300
                                    : NeoColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isSelected && _isSoundEnabled)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: NeoColors.cyan,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: NeoColors.borderLight,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.graphic_eq_rounded,
                            size: 16,
                            color: Colors.black,
                          ),
                        )
                      else if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 22,
                          color: NeoColors.cyan,
                        )
                      else
                        Icon(
                          Icons.radio_button_unchecked_rounded,
                          size: 20,
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade400,
                        ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),
            NeoButton(
              label: 'DONE',
              icon: const Icon(
                Icons.check_rounded,
                color: Colors.black,
                size: 18,
              ),
              backgroundColor: NeoColors.cyan,
              textColor: Colors.black,
              fullWidth: true,
              padding: const EdgeInsets.symmetric(vertical: 13),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
