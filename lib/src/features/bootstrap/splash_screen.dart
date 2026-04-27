import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_cubit.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_state.dart';
import 'package:neuroaid/src/core/routes/app_router.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';
import 'package:neuroaid/src/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    // Wait for splash animation
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    // Check if server configuration exists
    final hasConfig = await ApiConstants.hasServerConfig();
    final prefs = await SharedPreferences.getInstance();
    final skipConfig = prefs.getBool('skip_server_config') ?? false;

    // If no server config and user hasn't chosen to skip, show config screen
    if (!hasConfig && !skipConfig) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRouter.serverConfig);
      return;
    }

    // Check onboarding status
    final bool onboardingComplete =
        prefs.getBool('onboarding_complete') ?? false;

    if (!onboardingComplete) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
      return;
    }

    // Check auth status
    if (!mounted) return;
    final authCubit = context.read<AuthCubit>();
    await authCubit.checkAuthStatus();

    if (!mounted) return;
    final state = authCubit.state;

    if (state is AuthAuthenticated) {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    } else {
      // If onboarding is complete but not logged in, go to Welcome screen
      Navigator.of(context).pushReplacementNamed(AppRouter.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Decorative wave background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 300),
              painter: WavePainter(),
            ),
          ),

          // Logo in center
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brain Logo
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset('assets/Logo.png', fit: BoxFit.contain),
                ),
                const SizedBox(height: 24),

                // App Name
                const Text(
                  'Neuro Guard',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for wave decoration
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2D8CFF).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.3);

    // Create wave pattern
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.3 + 30 * Math.sin((i / size.width) * 2 * Math.pi),
      );
    }

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    final paint2 = Paint()
      ..color = const Color(0xFF2D8CFF).withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.4);

    for (double i = 0; i <= size.width; i++) {
      path2.lineTo(
        i,
        size.height * 0.4 +
            40 * Math.sin((i / size.width) * 2 * Math.pi + Math.pi),
      );
    }

    path2.lineTo(size.width, 0);
    path2.lineTo(0, 0);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Simple Math class for sin function
class Math {
  static double sin(double x) => x.sin();
  static const double pi = 3.14159265359;
}

extension on double {
  double sin() {
    // Simple sine approximation using Taylor series
    double x = this;
    while (x > Math.pi) x -= 2 * Math.pi;
    while (x < -Math.pi) x += 2 * Math.pi;

    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
}
