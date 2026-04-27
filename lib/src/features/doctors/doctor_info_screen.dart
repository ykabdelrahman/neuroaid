import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_cubit.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_state.dart';
import 'package:neuroaid/src/core/bloc/doctors/doctors_cubit.dart';
import 'package:neuroaid/src/core/bloc/doctors/doctors_state.dart';
import 'package:neuroaid/src/core/models/doctor_model.dart';
import 'package:neuroaid/src/core/routes/app_router.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';
import 'package:neuroaid/src/shared/widgets/primary_button.dart';

class DoctorInfoScreen extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorInfoScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Doctor Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          BlocBuilder<DoctorsCubit, DoctorsState>(
            builder: (context, state) {
              bool isFavorite = false;
              if (state is DoctorsLoaded) {
                isFavorite = state.favorites.any((d) => d.id == doctor.id);
              }
              return IconButton(
                icon: FaIcon(
                  isFavorite
                      ? FontAwesomeIcons.solidHeart
                      : FontAwesomeIcons.heart,
                  color: isFavorite ? Colors.red : AppColors.textPrimary,
                ),
                onPressed: () {
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
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Doctor Profile Header
                  _buildProfileHeader(),
                  const SizedBox(height: 24),

                  // Stats Row
                  _buildStatsRow(),
                  const SizedBox(height: 24),

                  // About Section
                  _buildSectionTitle('About Doctor'),
                  const SizedBox(height: 8),
                  Text(
                    '${doctor.name} is a top specialist in ${doctor.specialty} at NeuroAid Clinic. With over ${doctor.experience} of experience, they have dedicated their career to providing exceptional care and advanced treatments for patients with neurological conditions.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Working Hours
                  _buildSectionTitle('Working Hours'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.clock,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mon - Fri, 09:00 AM - 05:00 PM',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.calendarCheck,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Next Available: ${doctor.nextAvailable}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Bottom Action Button
          Container(
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
            child: PrimaryButton(
              label: 'Book Appointment',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.schedule,
                  arguments: doctor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: NetworkImage(doctor.image),
            onBackgroundImageError: (_, __) {},
            child: doctor.image.isEmpty
                ? const FaIcon(
                    FontAwesomeIcons.userDoctor,
                    size: 40,
                    color: AppColors.primary,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          doctor.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          doctor.specialty,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.solidStar,
              color: Colors.amber,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              doctor.rating.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(width: 4),
            Text(
              '(${doctor.reviews} Reviews)',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: FontAwesomeIcons.users,
            value: '1000+',
            label: 'Patients',
            color: Colors.blue,
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            icon: FontAwesomeIcons.briefcaseMedical,
            value: doctor.experience,
            label: 'Experience',
            color: Colors.green,
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            icon: FontAwesomeIcons.solidStar,
            value: doctor.rating.toString(),
            label: 'Rating',
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: FaIcon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.2));
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
