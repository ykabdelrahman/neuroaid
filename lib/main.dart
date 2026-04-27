import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:neuroaid/neuro_aid.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_cubit.dart';
import 'package:neuroaid/src/core/bloc/doctors/doctors_cubit.dart';
import 'package:neuroaid/src/core/bloc/booking/booking_cubit.dart';
import 'package:neuroaid/src/core/services/api_service.dart';
import 'package:neuroaid/src/core/services/auth_service.dart';
import 'package:neuroaid/src/core/services/booking_service.dart';
import 'package:neuroaid/src/core/services/doctors_service.dart';
import 'package:neuroaid/src/core/services/scan_service.dart';
import 'package:neuroaid/src/core/services/faq_service.dart';
import 'package:neuroaid/src/core/constants/api_constants.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ApiConstants to load saved server configuration
  await ApiConstants.initialize();

  // Initialize Services (ApiService will now use the loaded config)
  final apiService = ApiService();

  // Update ApiService baseUrl after loading config to ensure it's in sync
  apiService.updateBaseUrl(ApiConstants.baseUrl);

  final authService = AuthService(apiService);
  final doctorsService = DoctorsService(apiService);
  final bookingService = BookingService(apiService);
  final scanService = ScanService(apiService);
  final faqService = FaqService(apiService);

  // Register services in GetIt
  final getIt = GetIt.instance;
  getIt.registerSingleton<ApiService>(apiService);
  getIt.registerSingleton<AuthService>(authService);
  getIt.registerSingleton<DoctorsService>(doctorsService);
  getIt.registerSingleton<BookingService>(bookingService);
  getIt.registerSingleton<ScanService>(scanService);
  getIt.registerSingleton<FaqService>(faqService);

  // Load saved token if any
  await authService.initAuth();

  runApp(
    DevicePreview(
      enabled: false, // Use !kReleaseMode to enable only in debug/profile
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(authService)..checkAuthStatus(),
          ),

          BlocProvider(
            create: (context) => DoctorsCubit(doctorsService)..loadDoctors(),
          ),

          BlocProvider(create: (context) => BookingCubit(bookingService)),
        ],
        child: const NeuroAid(),
      ),
    ),
  );
}
