import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:neuroaid/src/core/models/booking_model.dart';
import 'package:neuroaid/src/core/routes/app_router.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';
import 'package:neuroaid/src/features/appointment/Info_item.dart';
import 'package:neuroaid/src/features/appointment/status_badge.dart';

class AppointmentCard extends StatelessWidget {
  final BookingModel booking;
  final String status;
  final String action;
  final Function(String) onAction;

  const AppointmentCard({
    super.key,
    required this.booking,
    required this.status,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryLight,
                    child: FaIcon(
                      FontAwesomeIcons.userDoctor,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.doctorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1A1A1A), // Dark color for visibility
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.doctorSpecialty,
                        style: const TextStyle(
                          color: Color(0xFF666666), // Gray color for visibility
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: status),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            // Info Row
            Row(
              children: [
                Expanded(
                  child: InfoItem(
                    icon: FontAwesomeIcons.calendar,
                    text: DateFormat('MMM dd, yyyy').format(booking.date),
                  ),
                ),
                Expanded(
                  child: InfoItem(
                    icon: FontAwesomeIcons.clock,
                    text: booking.time,
                  ),
                ),
                Expanded(
                  child: InfoItem(
                    icon: FontAwesomeIcons.receipt,
                    text: '#${booking.id.length > 8 ? booking.id.substring(0, 8) : booking.id}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.bookingDetails,
                        arguments: booking,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Details',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onAction(booking.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: action == 'Cancel'
                          ? Colors.red.shade50
                          : AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      action,
                      style: TextStyle(
                        color: action == 'Cancel' ? Colors.red : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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
}
