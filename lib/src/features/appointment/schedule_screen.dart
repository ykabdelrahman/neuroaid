import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_cubit.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_state.dart';
import 'package:neuroaid/src/core/bloc/booking/booking_cubit.dart';
import 'package:neuroaid/src/core/bloc/booking/booking_state.dart';
import 'package:neuroaid/src/core/models/booking_model.dart';
import 'package:neuroaid/src/core/models/doctor_model.dart';
import 'package:neuroaid/src/core/routes/app_router.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';
import 'package:neuroaid/src/shared/widgets/primary_button.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleScreen extends StatefulWidget {
  final DoctorModel doctor;
  const ScheduleScreen({super.key, required this.doctor});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime focused = DateTime.now();
  DateTime? selected;
  int selectedSlot = -1;
  final List<TimeOfDay> slots = List.generate(
    12,
    (i) => TimeOfDay(hour: 9 + (i ~/ 2), minute: (i % 2) * 30),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Schedule Appointment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.paymentSuccess,
              (route) => route.isFirst,
            );
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Info Summary
                    _buildDoctorSummary(),
                    const SizedBox(height: 24),

                    // Calendar
                    _buildSectionTitle('Select Date'),
                    const SizedBox(height: 12),
                    _buildCalendar(),
                    const SizedBox(height: 24),

                    // Time Slots
                    _buildSectionTitle('Available Time'),
                    const SizedBox(height: 12),
                    _buildTimeSlots(),
                  ],
                ),
              ),
            ),

            // Bottom Action Area
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: NetworkImage(widget.doctor.image),
            onBackgroundImageError: (_, __) {},
            child: widget.doctor.image.isEmpty
                ? const FaIcon(
                    FontAwesomeIcons.userDoctor,
                    color: AppColors.primary,
                    size: 24,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.doctor.specialty,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: focused,
        selectedDayPredicate: (day) => isSameDay(selected, day),
        onDaySelected: (sel, foc) => setState(() {
          selected = sel;
          focused = foc;
        }),
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        enabledDayPredicate: (day) {
          return day.weekday != DateTime.friday;
        },
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(slots.length, (i) {
        final t = slots[i];
        final label = DateFormat(
          'hh:mm a',
        ).format(DateTime(0, 1, 1, t.hour, t.minute));
        final isSelected = i == selectedSlot;

        return InkWell(
          onTap: () => setState(() => selectedSlot = i),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          return PrimaryButton(
            label: state is BookingLoading
                ? 'Processing...'
                : 'Confirm Appointment',
            onPressed:
                (selected != null &&
                    selectedSlot >= 0 &&
                    state is! BookingLoading)
                ? _confirmBooking
                : () {}, // Disable button logic handled inside PrimaryButton usually, but here we pass empty callback if disabled logic isn't built-in to PrimaryButton for 'null'
            // Assuming PrimaryButton handles disabled state if onPressed is null or we can manage it.
            // Let's check PrimaryButton implementation. It usually takes VoidCallback.
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  void _confirmBooking() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final t = slots[selectedSlot];
      final timeString = DateFormat(
        'hh:mm a',
      ).format(DateTime(0, 1, 1, t.hour, t.minute));

      final booking = BookingModel(
        id: 0, // Auto-generated
        userId: authState.user.id,
        doctorId: widget.doctor.id,
        doctorName: widget.doctor.name,
        doctorSpecialty: widget.doctor.specialty,
        date: selected!,
        time: timeString,
        status: 'upcoming',
      );

      context.read<BookingCubit>().createBooking(booking);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to book an appointment')),
      );
    }
  }
}
