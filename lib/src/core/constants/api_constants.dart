import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // ==================== Production AI Service URLs ====================

  /// Groq API (chatbot)
  static const String openRouterBaseUrl = 'https://api.groq.com/openai/v1';
  static const String openRouterApiKey =
      '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';
  static const String openRouterModel = 'llama-3.3-70b-versatile';
  static const String openRouterChatEndpoint = '/chat/completions';

  /// Stroke risk prediction service (Scikit-Learn ML model)
  static const String strokeQaServiceUrl = 'https://nuro-qa.baselembaby.cloud';

  /// Stroke image detection service (TensorFlow/Keras)
  static const String strokeImageServiceUrl =
      'https://nuro-image.baselembaby.cloud';

  /// Face stroke detection service (MediaPipe FaceMesh)
  static const String strokeFaceServiceUrl = 'http://13.60.105.139:5000';

  /// Hand stroke detection service (MediaPipe Hands)
  static const String strokeHandServiceUrl = 'http://13.60.105.139:5001';

  // ==================== Main API Endpoints (for future backend) ====================

  static const String mainApiPrefix = '/api/main';

  static const String authLogin = '$mainApiPrefix/auth/login';
  static const String authRegister = '$mainApiPrefix/auth/register';

  static const String users = '$mainApiPrefix/users';
  static String userById(String id) => '$mainApiPrefix/users/$id';
  static const String currentUser = '$mainApiPrefix/users/me';

  static const String scans = '$mainApiPrefix/scans';
  static String scanById(String id) => '$mainApiPrefix/scans/$id';

  static const String doctors = '$mainApiPrefix/doctors';
  static String doctorById(String id) => '$mainApiPrefix/doctors/$id';

  static const String bookings = '$mainApiPrefix/bookings';
  static String bookingById(String id) => '$mainApiPrefix/bookings/$id';

  static const String faqs = '$mainApiPrefix/faqs';
  static String faqById(String id) => '$mainApiPrefix/faqs/$id';

  static const String favorites = '$mainApiPrefix/favorites';
  static String favoriteById(String id) => '$mainApiPrefix/favorites/$id';

  // ==================== AI Endpoints ====================

  static const String strokeQaPredict = '/predict';
  static const String strokeImagePredict = '/predict';
  static const String strokeFacePredict = '/predict';
  static const String strokeHandPredict = '/predict_hand';

  // ==================== Timeouts ====================

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);

  // ==================== Headers ====================

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ==================== Health Check Utility ====================

  static Future<bool> testConnection(String url) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Connection test failed: $e');
      return false;
    }
  }
}
