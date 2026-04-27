import 'package:flutter/material.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';
import 'package:neuroaid/src/core/utils/validators.dart';
import 'package:neuroaid/src/shared/widgets/app_text_field.dart';
import 'package:neuroaid/src/shared/widgets/primary_button.dart';

class PasswordManagerScreen extends StatefulWidget {
  const PasswordManagerScreen({super.key});

  @override
  State<PasswordManagerScreen> createState() => _PasswordManagerScreenState();
}

class _PasswordManagerScreenState extends State<PasswordManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Password & Security'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Choose a strong password with at least 8 characters',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Current Password
              Text(
                'Current Password',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              AppTextField(
                hint: 'Enter current password',
                controller: _currentPasswordController,
                obscure: _obscureCurrentPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(
                      () => _obscureCurrentPassword = !_obscureCurrentPassword,
                    );
                  },
                ),
                validator: Validators.required,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),

              // New Password
              Text(
                'New Password',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              AppTextField(
                hint: 'Enter new password',
                controller: _newPasswordController,
                obscure: _obscureNewPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() => _obscureNewPassword = !_obscureNewPassword);
                  },
                ),
                validator: Validators.password,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),

              // Password Strength Indicator
              _PasswordStrengthIndicator(password: _newPasswordController.text),
              const SizedBox(height: 24),

              // Confirm Password
              Text(
                'Confirm New Password',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              AppTextField(
                hint: 'Re-enter new password',
                controller: _confirmPasswordController,
                obscure: _obscureConfirmPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
                  },
                ),
                validator: Validators.confirmPassword(
                  _newPasswordController.text,
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),

              // Change Password Button
              PrimaryButton(
                label: _isLoading ? 'Changing Password...' : 'Change Password',
                onPressed: _isLoading ? () {} : _handleChangePassword,
              ),
              const SizedBox(height: 16),

              // Forgot Password Link
              Center(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset link sent to your email'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Forgot current password?'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const _PasswordStrengthIndicator({required this.password});

  double get _strength {
    if (password.isEmpty) return 0;
    if (password.length < 6) return 0.25;
    if (password.length < 8) return 0.5;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    int score = 0;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasDigits) score++;
    if (hasSpecialCharacters) score++;

    return (score / 4) * 0.5 + 0.5;
  }

  Color get _color {
    if (_strength < 0.33) return AppColors.danger;
    if (_strength < 0.66) return AppColors.warning;
    return AppColors.success;
  }

  String get _label {
    if (_strength < 0.33) return 'Weak';
    if (_strength < 0.66) return 'Medium';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _strength,
                  backgroundColor: AppColors.border,
                  color: _color,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _label,
              style: TextStyle(
                color: _color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Use uppercase, lowercase, numbers, and symbols',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
