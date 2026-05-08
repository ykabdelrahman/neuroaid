import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:neuroaid/neuro_aid.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_cubit.dart';
import 'package:neuroaid/src/core/bloc/doctors/doctors_cubit.dart';
import 'package:neuroaid/src/core/bloc/booking/booking_cubit.dart';
import 'package:neuroaid/src/core/services/appwrite_service.dart';
import 'package:neuroaid/src/core/services/auth_service.dart';
import 'package:neuroaid/src/core/services/booking_service.dart';
import 'package:neuroaid/src/core/services/doctors_service.dart';
import 'package:neuroaid/src/core/services/scan_service.dart';
import 'package:neuroaid/src/core/services/faq_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final appwrite = AppwriteService();
  final authService = AuthService(appwrite);
  final doctorsService = DoctorsService(appwrite);
  final bookingService = BookingService(appwrite);
  final scanService = ScanService();
  final faqService = FaqService();

  final getIt = GetIt.instance;
  getIt.registerSingleton<AppwriteService>(appwrite);
  getIt.registerSingleton<AuthService>(authService);
  getIt.registerSingleton<DoctorsService>(doctorsService);
  getIt.registerSingleton<BookingService>(bookingService);
  getIt.registerSingleton<ScanService>(scanService);
  getIt.registerSingleton<FaqService>(faqService);

  await authService.initAuth();

  runApp(
    DevicePreview(
      enabled: false,
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
