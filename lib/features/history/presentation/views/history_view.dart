import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_loader.dart';
import '../../../../core/services/service_locator.dart';
import '../bloc/history_bloc.dart';
import '../widgets/history_item_card.dart';
import '../widgets/history_empty_view.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HistoryBloc>()..add(LoadHistoryEvent()),
      child: const _HistoryViewContent(),
    );
  }
}

class _HistoryViewContent extends StatelessWidget {
  const _HistoryViewContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'History',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              BlocBuilder<HistoryBloc, HistoryState>(
                builder: (context, state) {
                  if (state is HistoryLoadedState && state.items.isNotEmpty) {
                    return TextButton(
                      onPressed: () {
                        context.read<HistoryBloc>().add(ClearHistoryEvent());
                      },
                      child: Text(
                        'CLEAR ALL',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: NeoColors.red,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<HistoryBloc, HistoryState>(
              builder: (context, state) {
                if (state is HistoryLoadingState) {
                  return const Center(
                    child: NeoLoader.large(
                      size: 38,
                      color: NeoColors.cyan,
                      secondaryColor: NeoColors.yellow,
                    ),
                  );
                }

                if (state is HistoryLoadedState && state.items.isNotEmpty) {
                  return ListView.separated(
                    itemCount: state.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return HistoryItemCard(
                        item: item,
                        isDark: isDark,
                        onDelete: () {
                          context.read<HistoryBloc>().add(
                                DeleteHistoryItemEvent(item.id),
                              );
                        },
                      );
                    },
                  );
                }

                return HistoryEmptyView(isDark: isDark);
              },
            ),
          ),
        ],
      ),
    );
  }
}
