import 'package:flutter/material.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';
import 'package:neuroaid/src/core/utils/validators.dart';
import 'package:neuroaid/src/features/auth/phone_verified_screen.dart';
import 'package:neuroaid/src/shared/widgets/app_text_field.dart';
import 'package:neuroaid/src/shared/widgets/primary_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Navigate to success screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PhoneVerifiedScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Title
                Text(
                  'Reset Password',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  'Lorem ipsum dolor sit amet consectetur. Sed nulla tellus ligula vel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // Password Field
                AppTextField(
                  hint: 'Input password',
                  label: 'Password*',
                  controller: _passwordController,
                  obscure: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: Validators.password,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // Confirm Password Field
                AppTextField(
                  hint: 'Input password',
                  label: 'Confirmation Password*',
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
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      );
                    },
                  ),
                  validator: Validators.confirmPassword(
                    _passwordController.text,
                  ),
                  textInputAction: TextInputAction.done,
                ),

                const SizedBox(height: 40),

                // Confirm Button
                PrimaryButton(label: 'Confirm', onPressed: _handleConfirm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
