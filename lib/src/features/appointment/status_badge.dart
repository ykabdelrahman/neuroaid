import 'package:flutter/material.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;

    switch (status.toLowerCase()) {
      case 'upcoming':
        color = AppColors.primary;
        bgColor = AppColors.primaryLight;
        break;
      case 'completed':
        color = Colors.green;
        bgColor = Colors.green.withOpacity(0.1);
        break;
      case 'canceled':
        color = Colors.red;
        bgColor = Colors.red.withOpacity(0.1);
        break;
      default:
        color = Colors.grey;
        bgColor = Colors.grey.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
