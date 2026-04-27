import 'package:flutter/material.dart';
import 'package:neuroaid/src/core/models/doctor_model.dart';
import 'package:neuroaid/src/features/auth/login_screen.dart';
import 'package:neuroaid/src/features/auth/register_screen.dart';
import 'package:neuroaid/src/features/auth/forgot_password_screen.dart';
import 'package:neuroaid/src/features/auth/verification_code_screen.dart';
import 'package:neuroaid/src/features/auth/reset_password_screen.dart';
import 'package:neuroaid/src/features/auth/phone_verified_screen.dart';
import 'package:neuroaid/src/features/auth/welcome_screen.dart' as auth_welcome;
import 'package:neuroaid/src/features/bootstrap/splash_screen.dart';
import 'package:neuroaid/src/features/bootstrap/welcome_screen.dart';
import 'package:neuroaid/src/features/bootstrap/onboarding_screen.dart';
import 'package:neuroaid/src/features/bootstrap/role_selection_screen.dart';
import 'package:neuroaid/src/features/home/home_screen.dart';
import 'package:neuroaid/src/features/doctors/doctors_list_screen.dart';
import 'package:neuroaid/src/features/doctors/doctor_info_screen.dart';
import 'package:neuroaid/src/features/doctors/rating_screen.dart';
import 'package:neuroaid/src/features/doctors/favorites_screen.dart';
import 'package:neuroaid/src/features/appointment/appointments_screen.dart';
import 'package:neuroaid/src/features/appointment/schedule_screen.dart';
import 'package:neuroaid/src/features/payment/payment_method_screen.dart';
import 'package:neuroaid/src/features/payment/add_card_screen.dart';
import 'package:neuroaid/src/features/payment/payment_summary_screen.dart';
import 'package:neuroaid/src/features/payment/payment_success_screen.dart';
import 'package:neuroaid/src/features/profile/profile_screen.dart';
import 'package:neuroaid/src/features/profile/edit_profile_screen.dart';
import 'package:neuroaid/src/features/profile/settings_screen.dart';
import 'package:neuroaid/src/features/profile/notification_settings_screen.dart';
import 'package:neuroaid/src/features/profile/password_manager_screen.dart';
import 'package:neuroaid/src/features/profile/help_center_screen.dart';
import 'package:neuroaid/src/features/chat_ai/chat_ai_screen.dart';
import 'package:neuroaid/src/core/models/booking_model.dart';
import 'package:neuroaid/src/features/appointment/booking_details_screen.dart';
import 'package:neuroaid/src/features/search/search_screen.dart';
import 'package:neuroaid/src/features/search/filter_screen.dart';
import 'package:neuroaid/src/features/profile/privacy_policy_screen.dart';
import 'package:neuroaid/src/features/scan/scan_screen.dart';
import 'package:neuroaid/src/features/notifications/notification_screen.dart';
import 'package:neuroaid/src/features/bootstrap/server_config_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String serverConfig = '/server-config';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
  static const String welcome = '/welcome';
  static const String authWelcome = '/auth-welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verificationCode = '/verification-code';
  static const String resetPassword = '/reset-password';
  static const String phoneVerified = '/phone-verified';
  static const String home = '/home';
  static const String doctors = '/doctors';
  static const String doctorInfo = '/doctor-info';
  static const String rating = '/rating';
  static const String favorites = '/favorites';
  static const String schedule = '/schedule';
  static const String appointments = '/appointments';
  static const String paymentMethod = '/payment-method';
  static const String addCard = '/add-card';
  static const String paymentSummary = '/payment-summary';
  static const String paymentSuccess = '/payment-success';
  static const String profileOverview = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settingsScreen = '/settings';
  static const String notificationSettings = '/notification-settings';
  static const String passwordManager = '/password-manager';
  static const String helpCenter = '/help-center';
  static const String chatAi = '/chat-ai';
  static const String bookingDetails = '/booking-details';
  static const String searchScreen = '/search';
  static const String filterScreen = '/filter';
  static const String privacyPolicy = '/privacy-policy';
  static const String scanScreen = '/scan';
  static const String notifications = '/notifications';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _material(const SplashScreen());
      case serverConfig:
        return _material(const ServerConfigScreen());
      case onboarding:
        return _material(const OnboardingScreen());
      case roleSelection:
        return _material(const RoleSelectionScreen());
      case welcome:
        return _material(const WelcomeScreen());
      case authWelcome:
        return _material(const auth_welcome.WelcomeScreen());
      case login:
        return _material(const LoginScreen());
      case register:
        return _material(const RegisterScreen());
      case forgotPassword:
        return _material(const ForgotPasswordScreen());
      case verificationCode:
        final email = settings.arguments as String?;
        return _material(VerificationCodeScreen(email: email ?? ''));
      case resetPassword:
        return _material(const ResetPasswordScreen());
      case phoneVerified:
        return _material(const PhoneVerifiedScreen());
      case home:
        return _material(const HomeScreen());
      case doctors:
        return _material(const DoctorsListScreen());
      case doctorInfo:
        final doctor = settings.arguments as DoctorModel;
        return _material(DoctorInfoScreen(doctor: doctor));
      case rating:
        return _material(const RatingScreen());
      case favorites:
        return _material(const FavoritesScreen());
      case schedule:
        final doctor = settings.arguments as DoctorModel;
        return _material(ScheduleScreen(doctor: doctor));
      case appointments:
        return _material(const AppointmentsScreen());
      case paymentMethod:
        return _material(const PaymentMethodScreen());
      case addCard:
        return _material(const AddCardScreen());
      case paymentSummary:
        return _material(const PaymentSummaryScreen());
      case paymentSuccess:
        return _material(const PaymentSuccessScreen());
      case profileOverview:
        return _material(const ProfileScreen());
      case editProfile:
        return _material(const EditProfileScreen());
      case settingsScreen:
        return _material(const SettingsScreen());
      case notificationSettings:
        return _material(const NotificationSettingsScreen());
      case passwordManager:
        return _material(const PasswordManagerScreen());
      case helpCenter:
        return _material(const HelpCenterScreen());
      case chatAi:
        return _material(const ChatAIScreen());
      case bookingDetails:
        final booking = settings.arguments as BookingModel;
        return _material(BookingDetailsScreen(booking: booking));
      case searchScreen:
        return _material(const SearchScreen());
      case filterScreen:
        return _material(const FilterScreen());
      case privacyPolicy:
        return _material(const PrivacyPolicyScreen());
      case scanScreen:
        return _material(const ScanScreen());
      case notifications:
        return _material(const NotificationScreen());
      default:
        return _material(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static MaterialPageRoute _material(Widget page) =>
      MaterialPageRoute(builder: (_) => page);
}
