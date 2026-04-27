import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_cubit.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_state.dart';
import 'package:neuroaid/src/core/routes/app_router.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';
import 'package:neuroaid/src/features/home/BannerSection.dart';
import 'package:neuroaid/src/features/home/DoctorCardsSection.dart';
import 'package:neuroaid/src/features/home/SearchBar.dart';

class HomeTab extends StatelessWidget {
  const HomeTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryLight,
                  child: const FaIcon(
                    FontAwesomeIcons.user,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // User Name
                Expanded(
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      String userName = 'Mohamed Ali';
                      if (state is AuthAuthenticated) {
                        userName = state.user.name;
                      }
                      return Text(
                        userName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),

                // Notification Icon
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.notifications);
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.bell,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          SearchBarSection(),

          const SizedBox(height: 24),

          // Banner Sectionn
          BannerSection(),

          const SizedBox(height: 32),

          // Find Doctors Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Find Doctors',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.doctors);
                  },
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Doctor Cards
          DoctorCardsSection(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
