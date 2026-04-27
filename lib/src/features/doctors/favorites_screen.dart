import 'package:flutter/material.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_cubit.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_state.dart';
import 'package:neuroaid/src/core/bloc/doctors/doctors_cubit.dart';
import 'package:neuroaid/src/core/bloc/doctors/doctors_state.dart';
import 'package:neuroaid/src/core/models/doctor_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<DoctorsCubit>().loadFavorites(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Favorite Doctors',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<DoctorsCubit, DoctorsState>(
        builder: (context, state) {
          if (state is DoctorsLoaded) {
            final favorites = state.favorites;
            if (favorites.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _FavoriteCard(doctor: favorites[index]);
              },
            );
          } else if (state is DoctorsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.circleExclamation,
                    size: 50,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      final authState = context.read<AuthCubit>().state;
                      if (authState is AuthAuthenticated) {
                        context.read<DoctorsCubit>().loadFavorites(
                          authState.user.id,
                        );
                      }
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.heartCircleXmark,
                size: 50,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No favorite doctors yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Start adding doctors to your favorites\nfor quick access',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final DoctorModel doctor;
  const _FavoriteCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        child: Row(
          children: [
            // Doctor Image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: doctor.image.isNotEmpty
                    ? Image.network(
                        doctor.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primaryLight,
                            child: const Center(
                              child: FaIcon(
                                FontAwesomeIcons.userDoctor,
                                color: AppColors.primary,
                                size: 30,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.primaryLight,
                        child: const Center(
                          child: FaIcon(
                            FontAwesomeIcons.userDoctor,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.solidCircleCheck,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Professional Doctor',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.specialty,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to doctor details or booking
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Make Appointment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Favorite Button
            Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  final authState = context.read<AuthCubit>().state;
                  if (authState is AuthAuthenticated) {
                    context.read<DoctorsCubit>().toggleFavorite(
                      authState.user.id,
                      doctor,
                    );
                  }
                },
                icon: const FaIcon(FontAwesomeIcons.solidHeart, size: 20),
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
