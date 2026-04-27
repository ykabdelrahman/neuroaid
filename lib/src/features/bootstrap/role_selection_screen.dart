import 'package:flutter/material.dart';
import 'package:neuroaid/src/core/routes/app_router.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';
import 'package:neuroaid/src/shared/widgets/primary_button.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  void _handleContinue() {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your role'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Check if doctor role is selected
    if (_selectedRole == 'Doctor') {
      _showDoctorAlert();
      return;
    }

    // Navigate to auth welcome screen only if patient is selected
    Navigator.pushReplacementNamed(context, AppRouter.authWelcome);
  }

  void _showDoctorAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'تنبيه',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: const Text(
            'التطبيق الحالي مخصص للمرضى فقط.\nنسخة الأطباء ستكون متاحة قريباً.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.right,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'حسناً',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Title
              const Text(
                'Select your Role',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Select your role which suits your need',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),

              const SizedBox(height: 40),

              // Role Selection Label
              const Text(
                'Select Your Role :',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              // Doctor Option
              _buildRoleOption(
                role: 'Doctor',
                isSelected: _selectedRole == 'Doctor',
                onTap: () {
                  setState(() {
                    _selectedRole = 'Doctor';
                  });
                },
              ),

              const SizedBox(height: 16),

              // Patient Option
              _buildRoleOption(
                role: 'Patient',
                isSelected: _selectedRole == 'Patient',
                onTap: () {
                  setState(() {
                    _selectedRole = 'Patient';
                  });
                },
              ),

              const Spacer(),

              // Continue Button
              PrimaryButton(label: 'Continue', onPressed: _handleContinue),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required String role,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Radio Button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 16),

            // Role Text
            Text(
              role,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
