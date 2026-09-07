import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';

enum ProPlanType { annual, monthly }

class ProPlanSelector extends StatefulWidget {
  final bool isDark;
  final ValueChanged<ProPlanType> onPlanChanged;
  final ProPlanType initialPlan;

  const ProPlanSelector({
    super.key,
    required this.isDark,
    required this.onPlanChanged,
    this.initialPlan = ProPlanType.annual,
  });

  @override
  State<ProPlanSelector> createState() => _ProPlanSelectorState();
}

class _ProPlanSelectorState extends State<ProPlanSelector>
    with SingleTickerProviderStateMixin {
  late ProPlanType _selectedPlan;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _selectedPlan = widget.initialPlan;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _selectPlan(ProPlanType plan) {
    setState(() => _selectedPlan = plan);
    widget.onPlanChanged(plan);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Column(
      children: [
        // 1. Annual Best Value Plan (Highlighted with high border radius, no hard shadow)
        GestureDetector(
          onTap: () => _selectPlan(ProPlanType.annual),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: _selectedPlan == ProPlanType.annual
                      ? (isDark
                            ? const Color(0xFF26200A)
                            : const Color(0xFFFFFDE8))
                      : (isDark ? const Color(0xFF1E1E22) : Colors.white),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _selectedPlan == ProPlanType.annual
                        ? NeoColors.yellow
                        : (isDark
                              ? const Color(0xFF333338)
                              : const Color(0xFFE2E2E8)),
                    width: _selectedPlan == ProPlanType.annual ? 2.2 : 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    // Modern Rounded Radio
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedPlan == ProPlanType.annual
                            ? NeoColors.yellow
                            : Colors.transparent,
                        border: Border.all(
                          color: _selectedPlan == ProPlanType.annual
                              ? NeoColors.yellow
                              : (isDark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400),
                          width: 2,
                        ),
                      ),
                      child: _selectedPlan == ProPlanType.annual
                          ? const Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: Colors.black,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'ANNUAL ACCESS',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : Colors.black,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: NeoColors.yellow,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'BEST VALUE',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '7 Days Free Trial • Billed \$17.99 / yr',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? NeoColors.textSecondaryDark
                                  : NeoColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$1.49',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: isDark ? NeoColors.yellow : Colors.black,
                          ),
                        ),
                        Text(
                          '/ month',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? NeoColors.textSecondaryDark
                                : NeoColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Floating 50% OFF Badge (Rounded Pill)
              Positioned(
                top: -12,
                right: 18,
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: NeoColors.pink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '⚡️ SAVE 50%',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Monthly Flexible Plan (Rounded Card, No Shadow)
        GestureDetector(
          onTap: () => _selectPlan(ProPlanType.monthly),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: _selectedPlan == ProPlanType.monthly
                  ? (isDark ? const Color(0xFF26200A) : const Color(0xFFFFFDE8))
                  : (isDark ? const Color(0xFF1E1E22) : Colors.white),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _selectedPlan == ProPlanType.monthly
                    ? NeoColors.yellow
                    : (isDark
                          ? const Color(0xFF333338)
                          : const Color(0xFFE2E2E8)),
                width: _selectedPlan == ProPlanType.monthly ? 2.2 : 1.2,
              ),
            ),
            child: Row(
              children: [
                // Modern Rounded Radio
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedPlan == ProPlanType.monthly
                        ? NeoColors.yellow
                        : Colors.transparent,
                    border: Border.all(
                      color: _selectedPlan == ProPlanType.monthly
                          ? NeoColors.yellow
                          : (isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400),
                      width: 2,
                    ),
                  ),
                  child: _selectedPlan == ProPlanType.monthly
                      ? const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Colors.black,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MONTHLY FLEXIBLE',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Cancel anytime • Pay month-to-month',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? NeoColors.textSecondaryDark
                              : NeoColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$2.99',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      '/ month',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? NeoColors.textSecondaryDark
                            : NeoColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
