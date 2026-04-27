import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_cubit.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_state.dart';
import 'package:neuroaid/src/core/bloc/doctors/doctors_cubit.dart';
import 'package:neuroaid/src/core/bloc/doctors/doctors_state.dart';
import 'package:neuroaid/src/core/routes/app_router.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';
import 'package:neuroaid/src/features/home/DoctorCard.dart';

class DoctorCardsSection extends StatelessWidget {
  const DoctorCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocBuilder<DoctorsCubit, DoctorsState>(
        builder: (context, state) {
          if (state is DoctorsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is DoctorsError) {
            return Center(
              child: Text(
                'Failed to load doctors',
                style: TextStyle(color: Colors.red[400]),
              ),
            );
          } else if (state is DoctorsLoaded) {
            final doctors = state.doctors;
            if (doctors.isEmpty) {
              return const Center(child: Text('No doctors found'));
            }

            // Display only first 5 doctors for the home screen section
            final displayDoctors = doctors.take(5).toList();

            return Column(
              children: displayDoctors.map((doctor) {
                final isFavorite = state.favorites.any(
                  (d) => d.id == doctor.id,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DoctorCard(
                    name: doctor.name,
                    specialty: doctor.specialty,
                    rating: doctor.rating.toString(),
                    time: doctor.nextAvailable,
                    isFavorite: isFavorite,
                    imageUrl: doctor.image,
                    onTap: () {
                      log(doctor.toString());
                      Navigator.pushNamed(
                        context,
                        AppRouter.doctorInfo,
                        arguments: doctor,
                      );
                    },
                    onFavoriteTap: () {
                      final authState = context.read<AuthCubit>().state;
                      if (authState is AuthAuthenticated) {
                        context.read<DoctorsCubit>().toggleFavorite(
                          authState.user.id,
                          doctor,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please login to save doctors'),
                          ),
                        );
                      }
                    },
                  ),
                );
              }).toList(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
