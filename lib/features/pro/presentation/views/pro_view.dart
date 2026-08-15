import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/services/service_locator.dart';
import '../bloc/pro_bloc.dart';
import '../widgets/pro_header.dart';
import '../widgets/pro_feature_card.dart';

class ProView extends StatelessWidget {
  const ProView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProBloc>()..add(LoadProStatusEvent()),
      child: const _ProViewContent(),
    );
  }
}

class _ProViewContent extends StatelessWidget {
  const _ProViewContent();

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
          NeoToast.showError(
            context,
            state.message,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ProLoadingState;
        final isPro = (state is ProLoadedState && state.isPro) ||
            (state is ProPurchaseSuccessState && state.isPro) ||
            (state is ProErrorState && state.isPro);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              ProHeader(isDark: isDark),
              const SizedBox(height: 24),
              ProFeatureCard(
                icon: Icons.block_rounded,
                label: 'Remove All Advertisements',
                isDark: isDark,
              ),
              ProFeatureCard(
                icon: Icons.layers_rounded,
                label: 'Unlimited Batch Processing',
                isDark: isDark,
              ),
              ProFeatureCard(
                icon: Icons.high_quality_rounded,
                label: 'Ultra HD Lossless Engine',
                isDark: isDark,
              ),
              ProFeatureCard(
                icon: Icons.picture_as_pdf_rounded,
                label: 'Advanced PDF Export & Encryption',
                isDark: isDark,
              ),
              const SizedBox(height: 32),
              NeoButton(
                label: isPro
                    ? 'PRO MEMBERSHIP ACTIVE ✓'
                    : 'UPGRADE NOW - \$2.99 / MONTH',
                backgroundColor: isPro ? NeoColors.green : NeoColors.yellow,
                fullWidth: true,
                isLoading: isLoading,
                padding: const EdgeInsets.symmetric(vertical: 16),
                onPressed: (isLoading || isPro)
                    ? null
                    : () {
                        context.read<ProBloc>().add(PurchaseProEvent());
                      },
              ),
              const SizedBox(height: 12),
              if (!isPro)
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
            ],
          ),
        );
      },
    );
  }
}
