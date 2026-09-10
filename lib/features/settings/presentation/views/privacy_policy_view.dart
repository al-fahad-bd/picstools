import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_back_button.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/cloud_sync_service.dart';
import '../bloc/auth_bloc.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) =>
          AuthBloc(authService: getIt<AuthService>())
            ..add(CheckAuthStatusEvent()),
      child: const _PrivacyPolicyContent(),
    );
  }
}

class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent();

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
              const Icon(
                Icons.schedule_rounded,
                color: NeoColors.yellow,
                size: 24,
              ),
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
                const Icon(
                  Icons.warning_amber_rounded,
                  color: NeoColors.red,
                  size: 24,
                ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF1F5F9),
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
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const NeoBackButton(),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthErrorState) {
              NeoToast.showError(context, state.errorMessage);
            } else if (state is AuthSuccessMessageState) {
              NeoToast.showSuccess(context, state.message);
            }
          },
          builder: (context, authState) {
            final authService = getIt<AuthService>();
            final isSignedIn = authState is AuthStateChangedState
                ? (authState.isSignedIn && !authState.isAnonymous)
                : (authService.isSignedIn && !authService.isAnonymous);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Guarantee Card
                  NeoCard(
                    backgroundColor: NeoColors.softGreen,
                    shadowOffset: 5,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const NeoBadge(
                          label: '100% ON-DEVICE PROCESSING GUARANTEE',
                          backgroundColor: NeoColors.green,
                          fontSize: 11,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your Photos Never Leave Your Phone for Processing',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: NeoColors.borderLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Unlike other photo apps that transmit your private images to remote servers to run AI models, PicsTools processes all image tools—AI background removal, compression, resizing, cropping, format conversion, PDF compilation, and ID photos—strictly offline on your device processor. Your photos are NEVER uploaded or sent to external servers for processing.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: NeoColors.borderLight.withValues(
                              alpha: 0.85,
                            ),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Policy Section 1: Anonymous & Account-Free Access
                  _buildPolicySection(
                    title: '1. Fully Usable Without an Account',
                    icon: Icons.no_accounts_rounded,
                    color: NeoColors.cyan,
                    isDark: isDark,
                    content:
                        'PicsTools does not require you to create an account or sign in. You can use all editing and image processing tools completely anonymously. An anonymous local identifier is maintained only to store your theme and preferences locally on your device.',
                  ),
                  const SizedBox(height: 16),

                  // Policy Section 2: Optional Multi-Device Cloud Sync
                  _buildPolicySection(
                    title: '2. Optional Cloud Sync for Multi-Device Access',
                    icon: Icons.cloud_sync_rounded,
                    color: NeoColors.purple,
                    iconColor: Colors.white,
                    isDark: isDark,
                    content:
                        'If you explicitly choose to sign in (via Google or Email), PicsTools provides optional cloud backup so you can access your saved history across multiple devices. Only your exported result images and history timestamps are stored in private, encrypted cloud storage (Cloudflare R2 & Firebase). This sync feature exists solely for your multi-device convenience—your photos are never sold, never shared, and never used to train public AI models.',
                  ),
                  const SizedBox(height: 16),

                  // Policy Section 3: Permissions Usage
                  _buildPolicySection(
                    title: '3. Device Permissions Usage',
                    icon: Icons.lock_outline_rounded,
                    color: NeoColors.yellow,
                    isDark: isDark,
                    content:
                        '• Camera Permission: Used exclusively to capture document photos, passport portraits, or handwritten paper signatures when initiated by you.\n'
                        '• Photos & Storage Permission: Used exclusively to load images selected by you for editing and to save exported files to your device\'s public Downloads/PicsTools folder.',
                  ),
                  const SizedBox(height: 16),

                  // Policy Section 4: Third-Party Services
                  _buildPolicySection(
                    title: '4. Third-Party Services',
                    icon: Icons.ad_units_rounded,
                    color: NeoColors.pink,
                    iconColor: Colors.white,
                    isDark: isDark,
                    content:
                        '• Google AdMob: Displays standard non-intrusive mobile ads for free users.\n'
                        '• Firebase & Cloudflare R2: Used solely to authenticate your account and securely back up your history across devices if you choose to sign in.',
                  ),
                  const SizedBox(height: 16),

                  // Policy Section 5: Data Control & Account Deletion
                  _buildPolicySection(
                    title: '5. Data Control & Account Deletion',
                    icon: Icons.folder_special_rounded,
                    color: NeoColors.orange,
                    iconColor: Colors.white,
                    isDark: isDark,
                    content:
                        'You maintain 100% control over your data. You can clear your local processing history anytime using the button below. If you created an account, you can also permanently delete your account and its cloud credentials directly below.',
                  ),
                  const SizedBox(height: 28),

                  // Clear History Action
                  NeoButton(
                    label: 'CLEAR ALL LOCAL HISTORY LOGS',
                    icon: const Icon(
                      Icons.delete_sweep_rounded,
                      color: NeoColors.borderLight,
                    ),
                    backgroundColor: NeoColors.orange,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onPressed: () async {
                      final history = getIt<HistoryService>();
                      await history.clearHistory();
                      if (context.mounted) {
                        NeoToast.showSuccess(
                          context,
                          'All local processing history cleared successfully!',
                          icon: Icons.delete_outline_rounded,
                        );
                      }
                    },
                  ),

                  // Delete Account Action (Visible when signed in)
                  if (isSignedIn) ...[
                    const SizedBox(height: 14),
                    NeoButton(
                      label: 'DELETE ACCOUNT & CLOUD DATA',
                      icon: const Icon(
                        Icons.delete_forever_rounded,
                        color: Colors.white,
                      ),
                      backgroundColor: NeoColors.red,
                      textColor: Colors.white,
                      fullWidth: true,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onPressed: () => _confirmDeleteAccount(context, isDark),
                    ),
                  ],
                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      'PicsTools v1.0.0 • Updated September 2026',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
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
        ),
      ),
    );
  }

  Widget _buildPolicySection({
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    required String content,
    Color? iconColor,
  }) {
    return NeoCard(
      backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
      padding: const EdgeInsets.all(16),
      shadowOffset: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: NeoStyles.neoDecoration(
                  backgroundColor: color,
                  radius: 8,
                  shadow: 2,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: iconColor ?? NeoColors.borderLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              height: 1.45,
              color: isDark
                  ? NeoColors.textSecondaryDark
                  : NeoColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
