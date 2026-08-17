import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/monetization/in_app_purchase_service.dart';
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

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
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

        // Free users do not see ANY sync/account widget
        if (!isPro && !isSignedIn) {
          return const SizedBox.shrink();
        }

        // State 1: Pro User & Signed In / Linked Account
        if (isSignedIn && userEmail != null) {
          return _buildSignedInCard(context, userEmail, displayName, userAge);
        }

        // State 2: Pro User (Not linked to email account yet)
        return _buildProUnlinkedCard(context);
      },
    );
  }

  Widget _buildSignedInCard(
    BuildContext context,
    String email,
    String? displayName,
    int? age,
  ) {
    final nameText = displayName != null && displayName.isNotEmpty
        ? (age != null ? '$displayName ($age yrs)' : displayName)
        : null;

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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: NeoColors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: NeoColors.green, width: 1.5),
                  ),
                  child: const Icon(
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
                              nameText ?? 'Connected Pro Account',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const NeoBadge(
                            label: 'SYNCED',
                            backgroundColor: NeoColors.green,
                            textColor: NeoColors.textPrimaryLight,
                          ),
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
            const SizedBox(height: 12),
            Text(
              'Your export history and Pro subscription are safely synced and backed up in the cloud.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProUnlinkedCard(BuildContext context) {
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
                          const SizedBox(width: 6),
                          const NeoBadge(
                            label: 'PRO',
                            backgroundColor: NeoColors.yellow,
                            textColor: NeoColors.textPrimaryLight,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ready to Link Account',
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
              'Link your email account to back up your history & sync your Pro status across all your devices.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            NeoButton(
              label: 'LINK ACCOUNT TO SYNC',
              backgroundColor: NeoColors.purple,
              textColor: Colors.white,
              icon: const Icon(Icons.link_rounded, color: Colors.white, size: 18),
              fullWidth: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              onPressed: () => AuthDialog.show(context, isSignUp: true),
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
