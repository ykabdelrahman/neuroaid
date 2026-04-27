import 'package:flutter/material.dart';
import 'package:neuroaid/src/core/routes/app_router.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';
import 'package:neuroaid/src/shared/widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Hi ,',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your Virtual\nHealthcare Assistant',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Caring for your health with intelligent precision',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Get Started',
                onPressed: () => Navigator.pushNamed(context, AppRouter.login),
                rightIcon: Icons.arrow_forward_rounded,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRouter.register),
                  child: const Text('Create account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
