import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/services/service_locator.dart';
import '../bloc/pro_bloc.dart';
import '../widgets/pro_video_hero.dart';
import '../widgets/pro_plan_selector.dart';
import '../widgets/pro_comparison_table.dart';
import '../widgets/pro_social_proof.dart';
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
          backgroundColor:
              isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
          onRefresh: () async {
            context.read<ProBloc>().add(RefreshProStatusEvent());
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero, // Edge-to-edge for video hero
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
                  // 1. Full-Width 0-Padding Background Video Hero (Top to Middle of screen)
                  ProVideoHero(isDark: isDark),

                  // 2. Paywall Options & Conversion Components with standard side padding
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4),

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
                                  context
                                      .read<ProBloc>()
                                      .add(PurchaseProEvent());
                                },
                        ),
                        const SizedBox(height: 8),

                        Center(
                          child: Text(
                            _selectedPlan == ProPlanType.annual
                                ? '✨ 7 days free, then \$17.99/year (\$1.49/mo). Cancel anytime.'
                                : '⚡ Renews monthly at \$2.99. Cancel anytime in 1 tap.',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? NeoColors.textSecondaryDark
                                  : NeoColors.textSecondaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Feature Comparison Table
                        ProComparisonTable(isDark: isDark),
                        const SizedBox(height: 16),

                        // Creator Reviews & Social Proof
                        ProSocialProof(isDark: isDark),
                        const SizedBox(height: 16),

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
                                      context
                                          .read<ProBloc>()
                                          .add(RestorePurchasesEvent());
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
                        const SizedBox(height: 24),
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
