import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_cubit.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_state.dart';
import 'package:neuroaid/src/core/routes/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: Text('Please login to view profile'));
          }

          final user = state.user;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Profile Picture
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.user,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0E7772),
                          shape: BoxShape.circle,
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.pen,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // User Name
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 4),

                // Phone Number
                Text(
                  _formatPhoneNumber(user.phone),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 32),

                // Menu Items
                _buildMenuItem(
                  context,
                  icon: FontAwesomeIcons.userPen,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.editProfile);
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: FontAwesomeIcons.calendarCheck,
                  title: 'My Appointments',
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.appointments);
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: FontAwesomeIcons.bell,
                  title: 'Notifications',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.notificationSettings,
                    );
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: FontAwesomeIcons.gear,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.settingsScreen);
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: FontAwesomeIcons.shieldHalved,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.pushNamed(context, '/privacy-policy');
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: FontAwesomeIcons.rightFromBracket,
                  title: 'Log Out',
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                  showDivider: false,
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                FaIcon(icon, size: 20, color: Colors.grey.shade700),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 60,
            endIndent: 24,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }

  String _formatPhoneNumber(String phone) {
    if (phone.length > 6) {
      return '+${phone.substring(0, 5)}${'*' * (phone.length - 5)}';
    }
    return phone;
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF0E7772)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF0E7772),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.read<AuthCubit>().logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRouter.login,
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E7772),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Yes, Logout',
                        style: TextStyle(
                          color: Colors.white,
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
      ),
    );
  }
}
