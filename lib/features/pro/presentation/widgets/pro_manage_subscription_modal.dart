import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';

class ProManageSubscriptionModal extends StatelessWidget {
  final bool isDark;
  final VoidCallback onManageOnStore;

  const ProManageSubscriptionModal({
    super.key,
    required this.isDark,
    required this.onManageOnStore,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isDark,
    required VoidCallback onManageOnStore,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProManageSubscriptionModal(
        isDark: isDark,
        onManageOnStore: onManageOnStore,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? NeoColors.borderDark : NeoColors.borderLight;
    final isApple = !kIsWeb && Platform.isIOS;
    final storeName = isApple ? 'Apple App Store' : 'Google Play';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? NeoColors.darkBg : const Color(0xFFFFFDF8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: borderColor,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: 10,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF404048)
                        : const Color(0xFFD4D4D8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Header Row: Store Badge + Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeoBadge(
                    label: isApple ? '🍎 APPLE SUBSCRIPTION' : '🤖 GOOGLE PLAY BILLING',
                    backgroundColor: NeoColors.green,
                    textColor: Colors.black,
                    fontSize: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? NeoColors.darkSurface : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: borderColor,
                          width: 1.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: borderColor,
                            offset: const Offset(1.5, 1.5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                'Manage Subscription',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your payment is securely processed and managed by $storeName.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? NeoColors.textSecondaryDark
                      : NeoColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),

              // Guidance Card
              NeoCard(
                backgroundColor: isDark ? NeoColors.darkSurface : Colors.white,
                borderColor: borderColor,
                shadowOffset: 2,
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.store_rounded,
                      iconBg: NeoColors.yellow,
                      title: 'Official Store Billing',
                      description:
                          'Google & Apple policies require all subscription cancellations and renewals to be handled in the official store.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.shield_rounded,
                      iconBg: NeoColors.green,
                      title: 'Keep Benefits Until Period Ends',
                      description:
                          'If you cancel, you will continue to enjoy 100% Pro access with zero ads and all AI tools until your current billing cycle finishes.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.cancel_outlined,
                      iconBg: NeoColors.cyan,
                      title: 'Cancel Anytime in 1 Tap',
                      description:
                          'You can pause, switch between monthly/annual, or cancel with no cancellation fees.',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Action Buttons
              NeoButton(
                label: 'OPEN IN $storeName'.toUpperCase(),
                icon: const Icon(
                  Icons.open_in_new_rounded,
                  size: 17,
                  color: Colors.black,
                ),
                backgroundColor: NeoColors.yellow,
                textColor: Colors.black,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: () {
                  Navigator.of(context).pop();
                  onManageOnStore();
                },
              ),
              const SizedBox(height: 8),

              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Keep My Subscription',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? NeoColors.textSecondaryDark
                        : NeoColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: Colors.black),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? NeoColors.textSecondaryDark
                      : NeoColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
