import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/google_logo.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/monetization/in_app_purchase_service.dart';
import '../../../../core/services/cloud_sync_service.dart';
import '../bloc/auth_bloc.dart';
import 'auth_dialog.dart';

class AccountSyncCard extends StatelessWidget {
  final bool isDark;

  const AccountSyncCard({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final iapService = getIt<InAppPurchaseService>();
    final isPro = iapService.isProUser();

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthSuccessMessageState) {
          NeoToast.show(
            context,
            authState.message,
            color: NeoColors.green,
            icon: Icons.check_circle_rounded,
          );
        } else if (authState is AuthErrorState) {
          NeoToast.show(
            context,
            authState.errorMessage,
            color: NeoColors.pink,
            icon: Icons.error_outline_rounded,
          );
        }
      },
      builder: (context, authState) {
        final isLoading = authState is AuthLoadingState;

        final isSignedIn = authState is AuthStateChangedState
            ? (authState.isSignedIn && !authState.isAnonymous)
            : (authState is AuthSuccessMessageState
                ? (!authState.isAnonymous && authState.email != null)
                : (getIt<AuthBloc>().authService.isSignedIn &&
                    !getIt<AuthBloc>().authService.isAnonymous));

        final userEmail = authState is AuthStateChangedState
            ? authState.email
            : (authState is AuthSuccessMessageState
                ? authState.email
                : getIt<AuthBloc>().authService.userEmail);

        final displayName = authState is AuthStateChangedState
            ? authState.displayName
            : (authState is AuthSuccessMessageState
                ? authState.displayName
                : getIt<AuthBloc>().authService.displayName);

        final userAge = authState is AuthStateChangedState
            ? authState.age
            : getIt<AuthBloc>().authService.userAge;

        final photoUrl = authState is AuthStateChangedState
            ? authState.photoUrl
            : (authState is AuthSuccessMessageState
                ? authState.photoUrl
                : getIt<AuthBloc>().authService.photoUrl);

        // State 1: Signed In / Linked Account
        if (isSignedIn && userEmail != null) {
          return _buildSignedInCard(context, userEmail, displayName, userAge, photoUrl, isPro);
        }

        // State 2: Unlinked (Available to ALL users)
        return _buildUnlinkedCard(context, isLoading, isPro);
      },
    );
  }

  Widget _buildSignedInCard(
    BuildContext context,
    String email,
    String? displayName,
    int? age,
    String? photoUrl,
    bool isPro,
  ) {
    final nameText = displayName != null && displayName.isNotEmpty
        ? (age != null ? '$displayName ($age yrs)' : displayName)
        : null;
    final cloudSyncService = getIt<CloudSyncService>();

    return StreamBuilder<SyncStatus>(
      stream: cloudSyncService.statusStream,
      initialData: cloudSyncService.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? cloudSyncService.currentStatus;

        final badge = status.isFullySynced
            ? const NeoBadge(
                label: 'SYNCED',
                backgroundColor: NeoColors.green,
                textColor: NeoColors.textPrimaryLight,
              )
            : (status.pendingCount > 0
                ? NeoBadge(
                    label: '${status.pendingCount} UNSYNCED',
                    backgroundColor: NeoColors.yellow,
                    textColor: NeoColors.textPrimaryLight,
                  )
                : const NeoBadge(
                    label: 'READY',
                    backgroundColor: NeoColors.cyan,
                    textColor: NeoColors.textPrimaryLight,
                  ));

        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: NeoCard(
            borderColor: NeoColors.green,
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: NeoColors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: NeoColors.green, width: 1.5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: photoUrl != null && photoUrl.isNotEmpty
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.cloud_done_rounded,
                                color: NeoColors.green,
                                size: 22,
                              ),
                            )
                          : const Icon(
                              Icons.cloud_done_rounded,
                              color: NeoColors.green,
                              size: 22,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  nameText ?? (isPro ? 'Connected Pro Account' : 'Connected Account'),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              badge,
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: NeoColors.purple,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white12 : NeoColors.borderLight.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.cloud_outlined,
                            size: 16,
                            color: isDark ? Colors.white70 : NeoColors.textPrimaryLight,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${status.localCount} on device • ${status.syncedCount} backed up',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : NeoColors.textPrimaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status.lastSyncedAt != null
                            ? 'Last synced: ${_formatTime(status.lastSyncedAt!)}'
                            : 'No cloud backups yet',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: NeoButton(
                        label: status.isSyncing ? 'SYNCING...' : 'SYNC NOW',
                        icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                        backgroundColor: NeoColors.green,
                        textColor: NeoColors.textPrimaryLight,
                        borderColor: NeoColors.borderLight,
                        isLoading: status.isSyncing,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        onPressed: status.isSyncing
                            ? null
                            : () async {
                                final result = await cloudSyncService.syncNow();
                                if (context.mounted) {
                                  if (result.success) {
                                    NeoToast.show(
                                      context,
                                      result.uploadedCount > 0
                                          ? 'Synced ${result.uploadedCount} item(s) to cloud!'
                                          : (result.restoredCount > 0
                                              ? 'Restored ${result.restoredCount} item(s) from cloud!'
                                              : 'All items already up to date!'),
                                      color: NeoColors.green,
                                      icon: Icons.cloud_done_rounded,
                                    );
                                  } else {
                                    NeoToast.show(
                                      context,
                                      result.errorMessage ?? 'Sync failed',
                                      color: NeoColors.pink,
                                      icon: Icons.error_outline_rounded,
                                    );
                                  }
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmSignOut(context),
                        icon: const Icon(Icons.logout_rounded, size: 16),
                        label: Text(
                          'Sign Out',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white70 : NeoColors.textPrimaryLight,
                          side: BorderSide(
                            color: isDark ? Colors.white24 : NeoColors.borderLight,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildUnlinkedCard(BuildContext context, bool isLoading, bool isPro) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: NeoCard(
        borderColor: NeoColors.purple,
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFFAF5FF),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: NeoColors.purple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: NeoColors.purple, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.cloud_sync_rounded,
                    color: NeoColors.purple,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Cloud Backup & Sync',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (isPro) ...[
                            const SizedBox(width: 6),
                            const NeoBadge(
                              label: 'PRO',
                              backgroundColor: NeoColors.yellow,
                              textColor: NeoColors.textPrimaryLight,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Not Signed In',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Sign in to automatically back up your history & sync across all your devices.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            NeoButton(
              label: 'CONTINUE WITH GOOGLE',
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              textColor: isDark ? Colors.white : NeoColors.textPrimaryLight,
              borderColor: isDark ? Colors.white24 : NeoColors.borderLight,
              icon: const GoogleLogo(size: 20),
              isLoading: isLoading,
              fullWidth: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              onPressed: isLoading
                  ? null
                  : () {
                      context.read<AuthBloc>().add(SignInWithGoogleEvent());
                    },
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => AuthDialog.show(context, isSignUp: false),
                icon: Icon(
                  Icons.mail_outline_rounded,
                  size: 15,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                label: Text(
                  'Or sign in with email & password',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? Colors.white24 : NeoColors.borderLight,
            width: 2,
          ),
        ),
        title: Text(
          'Sign Out?',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        content: Text(
          'You will be switched back to guest mode. Your saved cloud history will be restored next time you sign in.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
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
              backgroundColor: NeoColors.pink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<AuthBloc>().add(SignOutEvent());
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
