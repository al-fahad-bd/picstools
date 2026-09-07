import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_switch.dart';

class _EqualizerBars extends StatefulWidget {
  final Color barColor;
  final bool isPlaying;

  const _EqualizerBars({
    required this.barColor,
    required this.isPlaying,
  });

  @override
  State<_EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<_EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _EqualizerBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final val = _controller.value;
        final h1 = 4.0 + 10.0 * (0.5 + 0.5 * math.sin(val * math.pi));
        final h2 = 14.0 - 9.0 * (0.5 + 0.5 * math.cos(val * math.pi));
        final h3 = 6.0 + 8.0 * (0.5 + 0.5 * math.cos(val * math.pi * 1.5));
        final h4 = 13.0 - 7.0 * (0.5 + 0.5 * math.sin(val * math.pi * 1.2));

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(h1),
            const SizedBox(width: 2.5),
            _buildBar(h2),
            const SizedBox(width: 2.5),
            _buildBar(h3),
            const SizedBox(width: 2.5),
            _buildBar(h4),
          ],
        );
      },
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 3.2,
      height: height.clamp(3.0, 16.0),
      decoration: BoxDecoration(
        color: widget.barColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

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
    final screenHeight = MediaQuery.of(context).size.height;
    // Set an optimal maximum height so it doesn't touch the status bar / notch
    final sheetMaxHeight = screenHeight * 0.85;
    final borderColor = isDark ? NeoColors.borderDark : NeoColors.borderLight;

    return Container(
      constraints: BoxConstraints(maxHeight: sheetMaxHeight),
      decoration: BoxDecoration(
        color: isDark ? NeoColors.darkBg : const Color(0xFFFFFDF8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: borderColor,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: 10,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF404048) : const Color(0xFFD4D4D8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Header Row: Studio Badge & Minimal Neo Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const NeoBadge(
                    label: '🎧 FOCUS AUDIO',
                    backgroundColor: NeoColors.yellow,
                    textColor: Colors.black,
                    fontSize: 10.5,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? NeoColors.darkSurface : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: borderColor,
                          width: 1.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: borderColor,
                            offset: const Offset(1.5, 1.5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title & Subtitle
              Text(
                'Background Music',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Curated ambient loops to keep you calm and focused while creating.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? NeoColors.textSecondaryDark
                      : NeoColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 14),

              // Master Audio Control Deck
              NeoCard(
                backgroundColor: isDark ? NeoColors.darkSurface : Colors.white,
                borderColor: _isSoundEnabled ? borderColor : (isDark ? const Color(0xFF333338) : const Color(0xFFE4E4E7)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                shadowOffset: _isSoundEnabled ? 3 : 1,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _isSoundEnabled
                            ? NeoColors.yellow
                            : (isDark
                                ? const Color(0xFF28282E)
                                : const Color(0xFFEEEEF0)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black,
                          width: 1.8,
                        ),
                        boxShadow: _isSoundEnabled
                            ? const [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(1.5, 1.5),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          _isSoundEnabled
                              ? Icons.graphic_eq_rounded
                              : Icons.volume_off_rounded,
                          size: 20,
                          color: _isSoundEnabled ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Audio Engine',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _isSoundEnabled
                                      ? NeoColors.green
                                      : (isDark
                                          ? const Color(0xFF333338)
                                          : const Color(0xFFE4E4E7)),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _isSoundEnabled ? '● LIVE' : 'MUTED',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: _isSoundEnabled
                                        ? Colors.black
                                        : (isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isSoundEnabled
                                ? 'Continuous ambient playback active'
                                : 'Audio playback is currently paused',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
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
                      activeTrackColor: NeoColors.yellow,
                      onChanged: _handleToggleSound,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'CHOOSE SOUNDTRACK',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? NeoColors.textSecondaryDark
                      : NeoColors.textSecondaryLight,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),

              // Scrollable Track List with High-End Studio Styling
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: AudioService.tracks.length,
                  itemBuilder: (context, index) {
                    final track = AudioService.tracks[index];
                    final isSelected = track.id == _selectedTrackId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: NeoCard(
                        backgroundColor: isSelected
                            ? (isDark
                                ? const Color(0xFF262316)
                                : const Color(0xFFFFFDE7))
                            : (isDark
                                ? NeoColors.darkSurface
                                : Colors.white),
                        borderColor: isSelected
                            ? (isDark ? NeoColors.yellow : Colors.black)
                            : (isDark
                                ? const Color(0xFF2E3038)
                                : const Color(0xFFE4E4E7)),
                        shadowOffset: isSelected ? 3.5 : 1,
                        padding: const EdgeInsets.all(12),
                        onTap: () => _handleSelectTrack(track.id),
                        child: Row(
                          children: [
                            // Vinyl / Disc Icon Container
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? NeoColors.yellow
                                    : (isDark
                                        ? const Color(0xFF282830)
                                        : const Color(0xFFF4F4F6)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : (isDark
                                          ? const Color(0xFF404048)
                                          : const Color(0xFFD4D4D8)),
                                  width: isSelected ? 1.8 : 1.2,
                                ),
                                boxShadow: isSelected
                                    ? const [
                                        BoxShadow(
                                          color: Colors.black,
                                          offset: Offset(1.5, 1.5),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Icon(
                                  track.icon,
                                  size: 20,
                                  color: isSelected
                                      ? Colors.black
                                      : (isDark
                                          ? Colors.white70
                                          : Colors.black87),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Track Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        track.title,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w900,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? (isDark
                                                  ? NeoColors.yellow
                                                  : Colors.black)
                                              : (isDark
                                                  ? const Color(0xFF282830)
                                                  : const Color(0xFFEEEEF2)),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          track.tag,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w900,
                                            color: isSelected
                                                ? (isDark
                                                    ? Colors.black
                                                    : Colors.white)
                                                : (isDark
                                                    ? Colors.grey.shade400
                                                    : Colors.black54),
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    track.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? NeoColors.textSecondaryDark
                                          : NeoColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Trailing State Indicator
                            if (isSelected && _isSoundEnabled)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF121214)
                                      : Colors.black,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isDark
                                        ? NeoColors.yellow
                                        : Colors.black,
                                    width: 1.2,
                                  ),
                                ),
                                child: const _EqualizerBars(
                                  barColor: NeoColors.yellow,
                                  isPlaying: true,
                                ),
                              )
                            else if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF282830)
                                      : Colors.black,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ACTIVE',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? NeoColors.yellow
                                        : Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF404048)
                                        : const Color(0xFFD4D4D8),
                                    width: 1.8,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Fixed Bottom Action Button (Pinned)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: NeoButton(
                  label: 'DONE',
                  icon: const Icon(
                    Icons.check_rounded,
                    color: Colors.black,
                    size: 19,
                  ),
                  backgroundColor: NeoColors.yellow,
                  textColor: Colors.black,
                  fullWidth: true,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
