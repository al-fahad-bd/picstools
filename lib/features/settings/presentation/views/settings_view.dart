import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/widgets/app_native_ad.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/monetization/in_app_purchase_service.dart';
import '../../../../core/services/cloud_sync_service.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/services/auth_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/settings_tile_group.dart';
import '../widgets/ai_model_card.dart';
import '../widgets/account_sync_card.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    getIt<CloudSyncService>().refreshStatus();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: getIt<SettingsBloc>()..add(RefreshAiModelStatusEvent()),
        ),
        BlocProvider.value(
          value: getIt<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
      ],
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

        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final authService = getIt<AuthBloc>().authService;
            final isSignedIn = authState is AuthStateChangedState
                ? (authState.isSignedIn && !authState.isAnonymous)
                : (authService.isSignedIn && !authService.isAnonymous);

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

                  // Account & Cloud Sync Section
                  AccountSyncCard(isDark: isDark),

                  // General Settings (Theme, Version, Privacy, Sound, Dev details)
                  SettingsTileGroup(
                    isDark: isDark,
                    themeMode: loaded.themeMode,
                    isSoundEnabled: loaded.isSoundEnabled,
                    currentTrackId: loaded.currentTrackId,
                    isDeveloperUnlocked: loaded.isDeveloperUnlocked,
                    isSignedIn: isSignedIn,
                    onDeleteAccount: () => _confirmDeleteAccount(context, isDark),
                    onChangeThemeMode: (mode) {
                      context.read<SettingsBloc>().add(ChangeThemeModeEvent(mode));
                    },
                    onToggleSound: (val) {
                      context.read<SettingsBloc>().add(ToggleSoundEvent(val));
                    },
                    onSelectTrack: (trackId) {
                      context.read<SettingsBloc>().add(
                        SelectSoundTrackEvent(trackId),
                      );
                    },
                    onTapVersion: () {
                      context.read<SettingsBloc>().add(TapDeveloperEvent());
                    },
                  ),
                  // Native Advanced Ad (Strictly for Free users)
                  if (!getIt<InAppPurchaseService>().isProUser()) ...[
                    const SizedBox(height: 16),
                    const AppNativeAd(
                      templateType: TemplateType.medium,
                      margin: EdgeInsets.symmetric(vertical: 8),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    const SizedBox(height: 24),
                  ],

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
      },
    );
  }

  void _confirmDeleteAccount(BuildContext context, bool isDark) {
    final authService = getIt<AuthService>();
    final cooldownRemaining = authService.accountDeletionCooldownRemaining;
    if (cooldownRemaining != null && cooldownRemaining.inSeconds > 0) {
      final hours = cooldownRemaining.inHours;
      final minutes = cooldownRemaining.inMinutes % 60;
      final timeStr = hours > 0
          ? '$hours hr ${minutes > 0 ? '$minutes min' : ''}'
          : '$minutes min';
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? Colors.white24 : NeoColors.borderLight,
              width: 2,
            ),
          ),
          title: Row(
            children: [
              const Icon(Icons.schedule_rounded, color: NeoColors.yellow, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Deletion Cooldown',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'To protect cloud resources and prevent system abuse, account deletion is limited to once every 24 hours.\n\nPlease try again in $timeStr.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NeoColors.yellow,
                foregroundColor: NeoColors.borderLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Got It',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );
      return;
    }

    bool alsoDeleteLocalHistory = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? Colors.white24 : NeoColors.borderLight,
                width: 2,
              ),
            ),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: NeoColors.red, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Delete Account?',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This will permanently delete your account credentials and remove your cloud sync profile.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    setDialogState(() {
                      alsoDeleteLocalHistory = !alsoDeleteLocalHistory;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: alsoDeleteLocalHistory
                            ? NeoColors.red
                            : (isDark ? Colors.white24 : Colors.grey[300]!),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: alsoDeleteLocalHistory,
                            activeColor: NeoColors.red,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onChanged: (val) {
                              setDialogState(() {
                                alsoDeleteLocalHistory = val ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Also delete all local history & photos on this device',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: alsoDeleteLocalHistory
                                  ? NeoColors.red
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: NeoColors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  Navigator.of(dialogCtx).pop();
                  if (alsoDeleteLocalHistory) {
                    await getIt<HistoryService>().clearHistory();
                  } else {
                    await getIt<HistoryService>().resetSyncStatus();
                  }
                  if (context.mounted) {
                    context.read<AuthBloc>().add(DeleteAccountEvent());
                  }
                  await getIt<CloudSyncService>().refreshStatus();
                },
                child: Text(
                  'Delete Account',
                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
