import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_card.dart';

class ProComparisonTable extends StatelessWidget {
  final bool isDark;

  const ProComparisonTable({super.key, required this.isDark});

  static const List<({String feature, String free, String pro, IconData icon})>
      _features = [
    (
      feature: 'Advertisements',
      free: 'Ads & Sponsor Popups',
      pro: '100% Zero Ads & Popups',
      icon: Icons.block_rounded,
    ),
    (
      feature: 'Batch Processing',
      free: 'Single / Limited',
      pro: 'Unlimited Multi-Photo Batch',
      icon: Icons.burst_mode_rounded,
    ),
    (
      feature: 'Compression Precision',
      free: 'Basic Presets',
      pro: 'Custom Quality & Exact Size',
      icon: Icons.tune_rounded,
    ),
    (
      feature: 'Background Removal',
      free: 'Standard On-Device',
      pro: 'Instant High-Speed Cutout',
      icon: Icons.auto_awesome_rounded,
    ),
    (
      feature: 'Daily Exports',
      free: 'Standard Daily Limit',
      pro: 'Unlimited Daily Exports',
      icon: Icons.all_inclusive_rounded,
    ),
    (
      feature: 'Data & Privacy',
      free: '100% On-Device Only',
      pro: '100% On-Device & Private',
      icon: Icons.security_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
      padding: const EdgeInsets.all(16),
      shadowOffset: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FEATURE COMPARISON',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? NeoColors.textSecondaryDark
                      : NeoColors.textSecondaryLight,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'FREE',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: NeoColors.yellow,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: NeoColors.borderLight, width: 1),
                    ),
                    child: Text(
                      'PRO ⚡',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          ..._features.map((f) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        f.icon,
                        size: 16,
                        color: isDark ? NeoColors.cyan : NeoColors.purple,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f.feature,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 24),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.close_rounded,
                              size: 13,
                              color: NeoColors.pink,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                f.free,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 13,
                              color: NeoColors.green,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                f.pro,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? NeoColors.yellow : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
