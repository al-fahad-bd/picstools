import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_text_field.dart';
import '../../../../core/widgets/neo_doodles.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/monetization/in_app_purchase_service.dart';
import '../bloc/home_bloc.dart';
import '../widgets/home_header.dart';
import '../widgets/category_selector.dart';
import '../widgets/tool_card_item.dart';
import '../widgets/pro_banner_card.dart';

class HomeView extends StatelessWidget {
  final VoidCallback? onNavigateToPro;

  const HomeView({super.key, this.onNavigateToPro});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeBloc>(),
      child: _HomeViewContent(onNavigateToPro: onNavigateToPro),
    );
  }
}

class _HomeViewContent extends StatelessWidget {
  final VoidCallback? onNavigateToPro;

  const _HomeViewContent({this.onNavigateToPro});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPro = getIt<InAppPurchaseService>().isProUser();

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final loadedState = state is HomeLoadedState
            ? state
            : const HomeLoadedState(allTools: [], filteredTools: []);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with App Icon and PRO badge
              HomeHeader(
                isDark: isDark,
                isPro: isPro,
                onProTap: onNavigateToPro ?? () => context.push('/pro'),
              ),
              const SizedBox(height: 18),

              // Title Header with Highlight Pill
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          color: isDark
                              ? NeoColors.textPrimaryDark
                              : NeoColors.textPrimaryLight,
                        ),
                        children: [
                          const TextSpan(text: '8 Essential '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: NeoColors.yellow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: NeoColors.borderLight,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: NeoColors.borderLight,
                                    offset: Offset(2, 2),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Text(
                                'IMAGE TOOLS',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: NeoColors.borderLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const NeoSparkleDoodle(size: 24, color: NeoColors.cyan),
                ],
              ),
              const SizedBox(height: 14),

              // Search Field
              NeoTextField(
                hintText: 'Search tools (compress, resize, pdf)...',
                prefixIcon: const Icon(Icons.search_rounded),
                onChanged: (q) =>
                    context.read<HomeBloc>().add(SearchToolsEvent(q)),
              ),
              const SizedBox(height: 16),

              // Category Selector
              CategorySelector(
                selectedCategory: loadedState.selectedCategory,
                isDark: isDark,
                onSelectCategory: (cat) =>
                    context.read<HomeBloc>().add(FilterCategoryEvent(cat)),
              ),
              const SizedBox(height: 18),

              // Tools Grid
              if (loadedState.filteredTools.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: isDark
                        ? NeoColors.darkSurface
                        : NeoColors.lightSurface,
                    radius: 16,
                    shadow: 4,
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: NeoColors.borderLight,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No Tools Found',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try searching for another keyword like "compress" or "pdf".',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: isDark
                              ? NeoColors.textSecondaryDark
                              : NeoColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: loadedState.filteredTools.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.74,
                  ),
                  itemBuilder: (context, index) {
                    final tool = loadedState.filteredTools[index];
                    return ToolCardItem(
                      tool: tool,
                      isDark: isDark,
                      onTap: () => context.push(tool.route),
                    );
                  },
                ),
              const SizedBox(height: 24),

              // Featured Pro Banner
              ProBannerCard(
                isPro: isPro,
                onTap: onNavigateToPro ?? () => context.push('/pro'),
              ),
            ],
          ),
        );
      },
    );
  }
}
