import 'package:flutter/material.dart';
import '../constants/neo_colors.dart';
import '../constants/neo_styles.dart';

class NeoSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeTrackColor;
  final Color inactiveTrackColor;

  const NeoSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeTrackColor = NeoColors.yellow,
    this.inactiveTrackColor = const Color(0xFFE4E4E7),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderClr = isDark ? NeoColors.borderDark : NeoColors.borderLight;
    final trackClr = value
        ? activeTrackColor
        : (isDark ? const Color(0xFF2C2C34) : inactiveTrackColor);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 54,
        height: 30,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: trackClr,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderClr,
            width: NeoStyles.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: borderClr,
              offset: const Offset(1.5, 1.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value
                  ? NeoColors.borderLight
                  : (isDark ? NeoColors.textPrimaryDark : NeoColors.lightSurface),
              shape: BoxShape.circle,
              border: Border.all(
                color: borderClr,
                width: 1.5,
              ),
            ),
            child: Icon(
              value ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              size: 11,
              color: value
                  ? NeoColors.yellow
                  : (isDark ? NeoColors.darkBg : NeoColors.textSecondaryLight),
            ),
          ),
        ),
      ),
    );
  }
}
