import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_cubit.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_state.dart';
import 'package:neuroaid/src/core/bloc/booking/booking_cubit.dart';
import 'package:neuroaid/src/core/bloc/booking/booking_state.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';
import 'package:neuroaid/src/features/appointment/appointments_list.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<BookingCubit>().loadBookings(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'My Appointments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is BookingLoaded) {
            final bookings = state.bookings;
            final upcoming = bookings
                .where((b) => b.status == 'upcoming' || b.status == 'pending')
                .toList();

            return AppointmentsList(
              bookings: upcoming,
              status: 'Upcoming',
              action: 'Cancel',
              onAction: (id) {
                final authState = context.read<AuthCubit>().state;
                if (authState is AuthAuthenticated) {
                  context.read<BookingCubit>().cancelBooking(
                    id,
                    authState.user.id,
                  );
                }
              },
            );
          } else if (state is BookingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.circleExclamation,
                    size: 40,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () {
                      final authState = context.read<AuthCubit>().state;
                      if (authState is AuthAuthenticated) {
                        context.read<BookingCubit>().loadBookings(
                          authState.user.id,
                        );
                      }
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No appointments found'));
          }
        },
      ),
    );
  }
}
