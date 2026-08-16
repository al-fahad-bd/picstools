import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/services/service_locator.dart';
import '../bloc/pro_bloc.dart';
import '../widgets/pro_header.dart';
import '../widgets/pro_feature_card.dart';

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

class _ProViewContent extends StatelessWidget {
  final VoidCallback? onNavigateToHome;

  const _ProViewContent({this.onNavigateToHome});

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
          color: NeoColors.pink,
          backgroundColor: isDark
              ? NeoColors.darkSurface
              : NeoColors.lightSurface,
          onRefresh: () async {
            context.read<ProBloc>().add(RefreshProStatusEvent());
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                ProHeader(isDark: isDark, isPro: isPro),
                const SizedBox(height: 24),
                if (isPro) ...[
                  // Pro Membership Card
                  NeoCard(
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE8F5E9),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              color: NeoColors.green,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'PLAN: MONTHLY PRO',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? NeoColors.textPrimaryDark
                                    : NeoColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your subscription is active and managed via the app store. You have unlimited access to all tools.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: isDark
                                ? NeoColors.textSecondaryDark
                                : NeoColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 14),
                        NeoButton(
                          label: 'MANAGE / CANCEL SUBSCRIPTION',
                          icon: Icon(
                            Icons.open_in_new_rounded,
                            size: 16,
                            color: isDark
                                ? NeoColors.textPrimaryDark
                                : NeoColors.textPrimaryLight,
                          ),
                          backgroundColor: isDark
                              ? NeoColors.darkSurface
                              : NeoColors.lightSurface,
                          textColor: isDark
                              ? NeoColors.textPrimaryDark
                              : NeoColors.textPrimaryLight,
                          fullWidth: true,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onPressed: () {
                            context.read<ProBloc>().add(
                              ManageSubscriptionEvent(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Unlocked Privileges Header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: NeoColors.yellow,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'UNLOCKED PRO PRIVILEGES',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isDark
                                ? NeoColors.textSecondaryDark
                                : NeoColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ProFeatureCard(
                    icon: Icons.block_rounded,
                    label: '100% Ad-Free Experience',
                    subtitle: 'Clean, distraction-free environment',
                    isUnlocked: true,
                    isDark: isDark,
                    accentColor: NeoColors.pink,
                  ),
                  ProFeatureCard(
                    icon: Icons.layers_rounded,
                    label: 'Unlimited Batch Processing',
                    subtitle: 'Process entire photo collections at once',
                    isUnlocked: true,
                    isDark: isDark,
                    accentColor: NeoColors.yellow,
                  ),
                  ProFeatureCard(
                    icon: Icons.high_quality_rounded,
                    label: 'Ultra HD Lossless Engine',
                    subtitle: 'Max clarity with zero quality loss',
                    isUnlocked: true,
                    isDark: isDark,
                    accentColor: NeoColors.cyan,
                  ),
                  ProFeatureCard(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'Advanced PDF & Security',
                    subtitle: 'High compression and PDF encryption',
                    isUnlocked: true,
                    isDark: isDark,
                    accentColor: NeoColors.purple,
                  ),
                  ProFeatureCard(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Full Neural AI Processing',
                    subtitle: 'High-speed local ONNX background removal',
                    isUnlocked: true,
                    isDark: isDark,
                    accentColor: NeoColors.green,
                  ),
                  const SizedBox(height: 20),
                  NeoButton(
                    label: 'EXPLORE PRO TOOLS',
                    icon: const Icon(
                      Icons.rocket_launch_rounded,
                      size: 18,
                      color: NeoColors.borderLight,
                    ),
                    backgroundColor: NeoColors.green,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onPressed: () {
                      if (onNavigateToHome != null) {
                        onNavigateToHome!();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                ] else ...[
                  ProFeatureCard(
                    icon: Icons.block_rounded,
                    label: 'Remove All Advertisements',
                    subtitle: 'Enjoy clean, uninterrupted workflows',
                    isDark: isDark,
                  ),
                  ProFeatureCard(
                    icon: Icons.layers_rounded,
                    label: 'Unlimited Batch Processing',
                    subtitle: 'Compress & convert multiple files',
                    isDark: isDark,
                  ),
                  ProFeatureCard(
                    icon: Icons.high_quality_rounded,
                    label: 'Ultra HD Lossless Engine',
                    subtitle: 'Studio-grade export resolution',
                    isDark: isDark,
                  ),
                  ProFeatureCard(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'Advanced PDF Export & Encryption',
                    subtitle: 'Protect documents with passwords',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  NeoButton(
                    label: 'UPGRADE NOW - \$2.99 / MONTH',
                    backgroundColor: NeoColors.yellow,
                    fullWidth: true,
                    isLoading: isLoading,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<ProBloc>().add(PurchaseProEvent());
                          },
                  ),
                ],
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<ProBloc>().add(RestorePurchasesEvent());
                        },
                  child: Text(
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
                const SizedBox(height: 10),
                Text(
                  'Pull down to refresh subscription status',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? NeoColors.textSecondaryDark.withValues(alpha: 0.6)
                        : NeoColors.textSecondaryLight.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
