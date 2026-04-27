import 'dart:developer';

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiService {
  late final Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '',
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: ApiConstants.headers,
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add token to headers if available
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          log('🚀 REQUEST[${options.method}] => ${options.uri}');
          log('📦 Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log(
            '✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}',
          );
          log('📦 Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          log(
            '❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}',
          );
          log('📦 Error: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  // Set authentication token
  void setToken(String token) {
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear authentication token
  void clearToken() {
    _token = null;
    _dio.options.headers.remove('Authorization');
  }

  // Get current token
  String? get token => _token;

  // Update base URL (useful when server config changes)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
    log('🔄 ApiService base URL updated to: $newBaseUrl');
  }

  // Get current base URL
  String get baseUrl => _dio.options.baseUrl;

  // Generic GET request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic POST request
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic PUT request
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic PATCH request
  Future<Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic DELETE request
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler
  String _handleError(DioException error) {
    String errorMessage = 'An unexpected error occurred';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage =
            'Connection timeout. Please check if the backend server is running and reachable.';
        break;

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 400) {
          errorMessage = data is Map && data.containsKey('message')
              ? data['message']
              : 'Bad request. Please check your input.';
        } else if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          errorMessage = 'Access forbidden.';
        } else if (statusCode == 404) {
          errorMessage = 'Resource not found.';
        } else if (statusCode == 500) {
          errorMessage = 'Server error. Please try again later.';
        } else {
          errorMessage = data is Map && data.containsKey('message')
              ? data['message']
              : 'Error: $statusCode';
        }
        break;

      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled.';
        break;

      case DioExceptionType.connectionError:
        errorMessage = 'Cannot connect to server. Please ensure:\n'
            '1. Backend server is running\n'
            '2. You are on the same WiFi network\n'
            '3. Server IP in api_constants.dart is correct';
        break;

      case DioExceptionType.badCertificate:
        errorMessage = 'Certificate verification failed.';
        break;

      case DioExceptionType.unknown:
        errorMessage =
            'Connection failed. Please check if the backend server is running and accessible on your network.';
        break;
    }

    return errorMessage;
  }
}
