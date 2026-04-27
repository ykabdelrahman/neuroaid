import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neuroaid/src/core/models/booking_model.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';
import 'package:neuroaid/src/features/appointment/appointment_card.dart';

class AppointmentsList extends StatelessWidget {
  final List<BookingModel> bookings;
  final String status;
  final String action;
  final Function(int) onAction;

  const AppointmentsList({
    super.key,
    required this.bookings,
    required this.status,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.calendarXmark,
              size: 50,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No $status appointments',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemBuilder: (_, i) => AppointmentCard(
        booking: bookings[i],
        status: status,
        action: action,
        onAction: onAction,
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: bookings.length,
    );
  }
}
