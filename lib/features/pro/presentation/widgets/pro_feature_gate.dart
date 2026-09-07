import 'package:flutter/material.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/monetization/in_app_purchase_service.dart';
import 'pro_upsell_bottom_sheet.dart';

class ProFeatureGate extends StatelessWidget {
  final Widget child;
  final String featureName;

  const ProFeatureGate({
    super.key,
    required this.child,
    required this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    final isPro = getIt<InAppPurchaseService>().isProUser();

    if (isPro) {
      return child;
    }

    return Stack(
      children: [
        Opacity(
          opacity: 0.5,
          child: IgnorePointer(
            child: child,
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ProUpsellBottomSheet.show(context, featureName: featureName);
              },
              splashColor: Colors.black.withValues(alpha: 0.1),
              highlightColor: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  'PRO',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
