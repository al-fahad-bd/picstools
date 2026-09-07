import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/services/service_locator.dart';
import '../bloc/pro_bloc.dart';
import '../widgets/pro_image_hero.dart';
import '../widgets/pro_plan_selector.dart';
import '../widgets/pro_benefits_list.dart';
import '../widgets/pro_trust_badges.dart';
import '../widgets/pro_active_dashboard.dart';

class ProView extends StatelessWidget {
  final VoidCallback? onNavigateToHome;

  const ProView({super.key, this.onNavigateToHome});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProBloc>()..add(LoadProStatusEvent()),
      child: _ProViewContent(onNavigateToHome: onNavigateToHome),
    );
  }
}

class _ProViewContent extends StatefulWidget {
  final VoidCallback? onNavigateToHome;

  const _ProViewContent({this.onNavigateToHome});

  @override
  State<_ProViewContent> createState() => _ProViewContentState();
}

class _ProViewContentState extends State<_ProViewContent> {
  ProPlanType _selectedPlan = ProPlanType.annual;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<ProBloc, ProState>(
      listener: (context, state) {
        if (state is ProPurchaseSuccessState) {
          NeoToast.showSuccess(
            context,
            state.message,
            icon: Icons.verified_rounded,
          );
        } else if (state is ProErrorState) {
          NeoToast.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is ProLoadingState;
        final isPro =
            (state is ProLoadedState && state.isPro) ||
            (state is ProPurchaseSuccessState && state.isPro) ||
            (state is ProErrorState && state.isPro);

        return RefreshIndicator(
          color: NeoColors.yellow,
          backgroundColor: isDark
              ? NeoColors.darkSurface
              : NeoColors.lightSurface,
          onRefresh: () async {
            context.read<ProBloc>().add(RefreshProStatusEvent());
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isPro) ...[
                  // ---------------- PRO ACTIVE VIP DASHBOARD ----------------
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ProActiveDashboard(
                      isDark: isDark,
                      onNavigateToHome: widget.onNavigateToHome,
                      onManageSubscription: () {
                        context.read<ProBloc>().add(ManageSubscriptionEvent());
                      },
                    ),
                  ),
                ] else ...[
                  // ---------------- COMMERCIAL PAYWALL VIEW ----------------
                  // 1. Edge-to-Edge Hero Image (Hero image with unobstructed subject & phone)
                  ProImageHero(isDark: isDark),

                  // 2. Paywall Options & Conversion Components
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Headline and feature overview
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: NeoColors.pink,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'CREATIVE STUDIO ACCESS',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Get PicsTools Pro',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? NeoColors.textPrimaryDark
                                : NeoColors.textPrimaryLight,
                            height: 1.15,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Batch processing, high-speed editing, and 100% ad-free experience.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? NeoColors.textSecondaryDark
                                : NeoColors.textSecondaryLight,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Interactive Plan Selector (Annual 50% OFF vs Monthly)
                        ProPlanSelector(
                          isDark: isDark,
                          initialPlan: _selectedPlan,
                          onPlanChanged: (plan) {
                            setState(() => _selectedPlan = plan);
                          },
                        ),
                        const SizedBox(height: 16),

                        // High-Converting Purchase Action CTA Button
                        NeoButton(
                          label: _selectedPlan == ProPlanType.annual
                              ? 'START 7-DAY FREE TRIAL • \$17.99/YR'
                              : 'UPGRADE NOW • \$2.99 / MONTH',
                          icon: const Icon(
                            Icons.star_rounded,
                            color: Colors.black,
                            size: 20,
                          ),
                          backgroundColor: NeoColors.yellow,
                          textColor: Colors.black,
                          fullWidth: true,
                          isLoading: isLoading,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<ProBloc>().add(
                                    PurchaseProEvent(),
                                  );
                                },
                        ),
                        const SizedBox(height: 6),

                        Center(
                          child: Text(
                            _selectedPlan == ProPlanType.annual
                                ? '✨ 7 days free, then \$17.99/year (\$1.49/mo). Cancel anytime.'
                                : '⚡ Renews monthly at \$2.99. Cancel anytime in 1 tap.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? NeoColors.textSecondaryDark
                                  : NeoColors.textSecondaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Core Pro Benefits List (Clean & Accurate)
                        ProBenefitsList(isDark: isDark),
                        const SizedBox(height: 20),

                        // Security & Guarantee Badges
                        ProTrustBadges(isDark: isDark),
                        const SizedBox(height: 20),

                        // Secondary Action: Restore Purchases
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              icon: Icon(
                                Icons.restore_rounded,
                                size: 16,
                                color: isDark
                                    ? NeoColors.textSecondaryDark
                                    : NeoColors.textSecondaryLight,
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      context.read<ProBloc>().add(
                                        RestorePurchasesEvent(),
                                      );
                                    },
                              label: Text(
                                'Restore Purchases',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? NeoColors.textSecondaryDark
                                      : NeoColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Legal & Privacy Note
                        Center(
                          child: Text(
                            'Payment charged via Google Play / App Store account at confirmation. Subscription auto-renews unless cancelled in account settings at least 24 hours before end of billing period.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              color: isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade500,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
