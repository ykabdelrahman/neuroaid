import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

/// API Constants for NeuroAid Backend Gateway
///
/// This class centralizes all API configuration for connecting to the
/// Python API Gateway which routes to all microservices.
class ApiConstants {
  // ==================== Gateway Configuration ====================

  /// Gateway port (all requests go through this port)
  static const int gatewayPort = 8080;

  /// 🔧 Network IP for Physical Device Testing (FALLBACK ONLY)
  /// This is used ONLY as a fallback if no server config is saved
  /// Users should configure their server IP via the Server Config screen
  ///
  /// HOW TO FIND YOUR IP:
  /// - Windows: Run 'ipconfig' and look for 'IPv4 Address' under your WiFi adapter
  /// - Mac: Run 'ifconfig | grep "inet " | grep -v 127.0.0.1'
  /// - Linux: Run 'ip addr show' or 'hostname -I'
  ///
  /// EXAMPLE IPs:
  /// - 192.168.1.x (common home routers)
  /// - 192.168.0.x (common home routers)
  /// - 10.0.0.x (some home/office networks)
  ///
  /// ⚠️ NOTE: This is automatically detected from your backend server
  /// Update this only if you want to change the default fallback IP
  static const String _networkIp = '192.168.62.47';

  /// Localhost URL (for iOS Simulator and Web)
  static const String _localhostUrl = 'http://localhost:$gatewayPort';

  /// Android Emulator URL (10.0.2.2 is the special alias for host machine)
  /// ⚠️ COMMENTED OUT - Currently focusing on physical device testing
  static const String _androidEmulatorUrl = 'http://10.0.2.2:$gatewayPort';

  /// Network URL (for physical devices on same network)
  static const String _networkUrl = 'http://$_networkIp:$gatewayPort';

  /// Environment-based URL (can be set during build time)
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  // ==================== Dynamic Base URL ====================

  static String? _cachedBaseUrl;

  /// Initialize and load saved server configuration
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIp = prefs.getString('server_ip');
      final savedPort = prefs.getInt('server_port');

      if (savedIp != null && savedPort != null) {
        _cachedBaseUrl = 'http://$savedIp:$savedPort';
        if (kDebugMode) {
          print('🌐 Loaded saved server config: $_cachedBaseUrl');
        }
      } else {
        if (kDebugMode) {
          print('🌐 No saved server config, using default');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error loading server config: $e');
      }
    }
  }

  /// Get the appropriate base URL based on platform
  ///
  /// Priority:
  /// 1. Custom URL set via setCustomUrl() or from SharedPreferences
  /// 2. Environment variable
  /// 3. Platform-specific defaults
  static String get baseUrl {
    if (_cachedBaseUrl != null) {
      // Log the cached URL on every access during debug mode
      if (kDebugMode) {
        print('🌐 Connecting to Backend: $_cachedBaseUrl');
      }
      return _cachedBaseUrl!;
    }

    // Check for environment variable first
    if (_envBaseUrl.isNotEmpty) {
      _cachedBaseUrl = _envBaseUrl;
      if (kDebugMode) {
        print('🌐 Connecting to Backend: $_cachedBaseUrl (from environment)');
      }
      return _cachedBaseUrl!;
    }

    // Platform-specific URL selection
    if (kIsWeb) {
      _cachedBaseUrl = _localhostUrl;
    } else if (Platform.isAndroid) {
      // Use network IP for physical devices
      if (kDebugMode) {
        _cachedBaseUrl = _networkUrl;
        print('🌐 Connecting to Backend: $_cachedBaseUrl');
      } else {
        // Production mode: use network URL by default
        _cachedBaseUrl = _networkUrl;
      }
    } else if (Platform.isIOS) {
      _cachedBaseUrl = _localhostUrl;
    } else {
      _cachedBaseUrl = _localhostUrl;
    }

    if (kDebugMode && _cachedBaseUrl != null) {
      print('🌐 Connecting to Backend: $_cachedBaseUrl');
    }

    return _cachedBaseUrl!;
  }

  /// Reset cached URL (useful for switching between emulator/physical device)
  static void reset() {
    _cachedBaseUrl = null;
  }

  /// Set custom base URL (for testing or switching to production)
  ///
  /// Example:
  /// ```dart
  /// // For physical device on same network
  /// ApiConstants.setCustomUrl('http://192.168.1.6:8080');
  ///
  /// // For production
  /// ApiConstants.setCustomUrl('https://api.neuroaid.com');
  /// ```
  static void setCustomUrl(String url) {
    _cachedBaseUrl = url;
  }

  /// Use network URL (for physical device testing)
  static void useNetworkUrl() {
    _cachedBaseUrl = _networkUrl;
  }

  /// Use emulator URL
  static void useEmulatorUrl() {
    _cachedBaseUrl = Platform.isAndroid ? _androidEmulatorUrl : _localhostUrl;
  }

  // ==================== API Route Prefixes ====================

  /// Main application routes (auth, users, scans, bookings, etc.)
  /// Gateway forwards /api/main/* to Main Flask Server (port 5000)
  static const String mainApiPrefix = '/api/main';

  /// AI service routes
  /// Gateway forwards /api/ai/* to AI Services (ports 5001, 5002)
  static const String aiApiPrefix = '/api/ai';

  // ==================== Main API Endpoints ====================

  // Auth Endpoints
  static const String authLogin = '$mainApiPrefix/auth/login';
  static const String authRegister = '$mainApiPrefix/auth/register';

  // User Endpoints
  static const String users = '$mainApiPrefix/users';
  static String userById(String id) => '$mainApiPrefix/users/$id';
  static const String currentUser = '$mainApiPrefix/users/me';

  // Scan Endpoints
  static const String scans = '$mainApiPrefix/scans';
  static String scanById(String id) => '$mainApiPrefix/scans/$id';

  // Doctor Endpoints
  static const String doctors = '$mainApiPrefix/doctors';
  static String doctorById(String id) => '$mainApiPrefix/doctors/$id';

  // Booking Endpoints
  static const String bookings = '$mainApiPrefix/bookings';
  static String bookingById(String id) => '$mainApiPrefix/bookings/$id';

  // FAQ Endpoints
  static const String faqs = '$mainApiPrefix/faqs';
  static String faqById(String id) => '$mainApiPrefix/faqs/$id';

  // Favorites Endpoints
  static const String favorites = '$mainApiPrefix/favorites';
  static String favoriteById(String id) => '$mainApiPrefix/favorites/$id';

  // Health Check
  static const String health = '$mainApiPrefix/health';
  static const String gatewayHealth = '/health'; // Gateway's own health check

  // ==================== AI Endpoints (gateway, legacy) ====================

  /// AI Chatbot endpoint
  static const String aiChat = '$aiApiPrefix/chat';

  /// Stroke Risk Assessment endpoint
  static const String aiStrokeAssessment = '$aiApiPrefix/assessment';

  /// Stroke Image Analysis endpoint
  static const String aiStrokeImagePredict =
      '$aiApiPrefix/stroke-image/predict';

  /// Scan Image Analysis endpoint (if you have this service)
  static const String aiScanImage = '$mainApiPrefix/ai/scan-image';

  // ==================== Production AI Service URLs ====================

  /// OpenRouter API (used for chatbot — nuro-chatbot service is not yet routed)
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String openRouterApiKey =
      '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';
  static const String openRouterModel = 'openai/gpt-4o-mini';
  static const String openRouterChatEndpoint = '/chat/completions';

  /// Deployed stroke risk prediction service (Scikit-Learn ML model)
  static const String strokeQaServiceUrl =
      'https://nuro-qa.baselembaby.cloud';

  /// Deployed stroke image detection service (TensorFlow/Keras)
  static const String strokeImageServiceUrl =
      'https://nuro-image.baselembaby.cloud';

  /// Face stroke detection service (MediaPipe FaceMesh)
  static const String strokeFaceServiceUrl = 'http://13.60.37.44:5000';

  /// Hand stroke detection service (MediaPipe Hands)
  static const String strokeHandServiceUrl = 'http://13.60.37.44:5001';

  // Endpoints on each production service
  static const String strokeQaPredict = '/predict';
  static const String strokeImagePredict = '/predict';
  static const String strokeFacePredict = '/predict';
  static const String strokeHandPredict = '/predict_hand';

  // ==================== Timeouts ====================

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ==================== Headers ====================

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ==================== Utility Methods ====================

  /// Get full URL for an endpoint
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Check if using emulator
  static bool get isEmulator {
    if (kIsWeb) return false;
    return Platform.isAndroid && baseUrl.contains('10.0.2.2');
  }

  /// Get current environment info
  static Map<String, dynamic> getEnvironmentInfo() {
    return {
      'baseUrl': baseUrl,
      'platform': kIsWeb
          ? 'Web'
          : Platform.isAndroid
          ? 'Android'
          : Platform.isIOS
          ? 'iOS'
          : 'Unknown',
      'isEmulator': isEmulator,
      'gatewayPort': gatewayPort,
      'networkIP': _networkIp,
      'debugMode': kDebugMode,
    };
  }

  /// Print current configuration (for debugging)
  static void printConfig() {
    print('═' * 60);
    print('🌐 NeuroAid API Configuration');
    print('═' * 60);
    print('Base URL: $baseUrl');
    print('Gateway Port: $gatewayPort');
    print('Platform: ${getEnvironmentInfo()['platform']}');
    print('Is Emulator: $isEmulator');
    print('Debug Mode: $kDebugMode');
    print('Network IP: $_networkIp');
    print('═' * 60);
  }

  /// Test connection to server
  /// Returns true if server is reachable, false otherwise
  static Future<bool> testConnection(String url) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '$url/health',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (kDebugMode) {
        print('✅ Connection test successful: ${response.statusCode}');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Connection test failed: $e');
      }
      return false;
    }
  }

  /// Check if server configuration exists
  static Future<bool> hasServerConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('server_ip') && prefs.containsKey('server_port');
    } catch (e) {
      return false;
    }
  }
}
