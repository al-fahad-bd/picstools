import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_card.dart';

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
        // 1. Annual Best Value Plan (Highlighted)
        GestureDetector(
          onTap: () => _selectPlan(ProPlanType.annual),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              NeoCard(
                backgroundColor: _selectedPlan == ProPlanType.annual
                    ? (isDark
                          ? const Color(0xFF2A2400)
                          : const Color(0xFFFFFBEA))
                    : (isDark ? NeoColors.darkSurface : NeoColors.lightSurface),
                borderColor: _selectedPlan == ProPlanType.annual
                    ? NeoColors.yellow
                    : (isDark ? NeoColors.borderDark : NeoColors.borderLight),
                shadowOffset: _selectedPlan == ProPlanType.annual ? 4 : 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Custom Radio
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
                              ? NeoColors.borderLight
                              : (isDark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400),
                          width: 2,
                        ),
                      ),
                      child: _selectedPlan == ProPlanType.annual
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: NeoColors.borderLight,
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
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : NeoColors.borderLight,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const NeoBadge(
                                label: 'BEST VALUE',
                                backgroundColor: NeoColors.yellow,
                                textColor: Colors.black,
                                fontSize: 9,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '7 Days Free Trial • Billed \$17.99 / yr',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11.5,
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
                            fontSize: 20,
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
              // Floating Animated 50% OFF Badge
              Positioned(
                top: -10,
                right: 18,
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: NeoStyles.neoDecoration(
                      backgroundColor: NeoColors.pink,
                      radius: 8,
                      shadow: 2,
                    ),
                    child: Text(
                      '🔥 SAVE 50%',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Monthly Flexible Plan
        GestureDetector(
          onTap: () => _selectPlan(ProPlanType.monthly),
          child: NeoCard(
            backgroundColor: _selectedPlan == ProPlanType.monthly
                ? (isDark ? const Color(0xFF2A2400) : const Color(0xFFFFFBEA))
                : (isDark ? NeoColors.darkSurface : NeoColors.lightSurface),
            borderColor: _selectedPlan == ProPlanType.monthly
                ? NeoColors.yellow
                : (isDark ? NeoColors.borderDark : NeoColors.borderLight),
            shadowOffset: _selectedPlan == ProPlanType.monthly ? 4 : 2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Custom Radio
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
                          ? NeoColors.borderLight
                          : (isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400),
                      width: 2,
                    ),
                  ),
                  child: _selectedPlan == ProPlanType.monthly
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: NeoColors.borderLight,
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
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : NeoColors.borderLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cancel anytime • Pay month-to-month',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11.5,
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
                        fontSize: 20,
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
