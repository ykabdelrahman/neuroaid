import 'package:flutter/material.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? rightIcon;
  final bool light;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.rightIcon,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: light
            ? null
            : const LinearGradient(
                colors: [
                  Color(0xFF107B92), // Teal
                  Color(0xFF31aac2), // Blue
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: light ? AppColors.primaryLight : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: light ? AppColors.primary : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (rightIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    rightIcon,
                    color: light ? AppColors.primary : Colors.white,
                    size: 22,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
