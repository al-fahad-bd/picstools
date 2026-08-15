import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/services/service_locator.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/settings_tile_group.dart';
import '../widgets/ai_model_card.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SettingsBloc>()..add(LoadSettingsEvent()),
      child: const _SettingsViewContent(),
    );
  }
}

class _SettingsViewContent extends StatelessWidget {
  const _SettingsViewContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoadedState) {
          if (state.toastMessage != null) {
            NeoToast.show(
              context,
              state.toastMessage!,
              color: state.isDeveloperNewlyUnlocked
                  ? NeoColors.purple
                  : (state.toastMessage!.contains('deleted')
                      ? NeoColors.pink
                      : NeoColors.cyan),
              icon: state.isDeveloperNewlyUnlocked
                  ? Icons.verified_rounded
                  : (state.toastMessage!.contains('deleted')
                      ? Icons.delete_forever_rounded
                      : Icons.terminal_rounded),
            );
          }
          if (state.isDeveloperNewlyUnlocked) {
            context.push('/developer');
          }
        }
      },
      builder: (context, state) {
        final loaded = state is SettingsLoadedState
            ? state
            : const SettingsLoadedState(
                isSoundEnabled: true,
                isDeveloperUnlocked: false,
              );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),

              // General Settings (Version, Privacy, Sound, Dev details)
              SettingsTileGroup(
                isDark: isDark,
                isSoundEnabled: loaded.isSoundEnabled,
                isDeveloperUnlocked: loaded.isDeveloperUnlocked,
                onToggleSound: (val) {
                  context.read<SettingsBloc>().add(ToggleSoundEvent(val));
                },
                onTapVersion: () {
                  context.read<SettingsBloc>().add(TapDeveloperEvent());
                },
              ),
              const SizedBox(height: 24),

              // AI Models Section
              Text(
                'AI Models (On-Device)',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              AiModelCard(
                modelInfo: loaded.aiModelInfo,
                isDark: isDark,
                isDeleting: loaded.isDeletingModel,
                onDeleteModel: () {
                  context.read<SettingsBloc>().add(DeleteAiModelEvent());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
