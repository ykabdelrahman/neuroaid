import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthService(this._apiService);

  // Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    log('AuthService: Attempting login for email: $email');
    try {
      final response = await _apiService.post(
        ApiConstants.authLogin, // Updated to use gateway route
        data: {'email': email, 'password': password},
      );

      log('AuthService: Login API response received: ${response.data}');

      final authResponse = AuthResponse.fromJson(response.data);

      // Save token and user data
      await _saveAuthData(authResponse);

      // Save credentials for auto-fill
      await saveCredentials(email, password);

      // Set token in API service
      _apiService.setToken(authResponse.accessToken);

      log('AuthService: Login successful for user: ${authResponse.user.email}');
      return authResponse;
    } catch (e) {
      log('AuthService: Login failed. Error: $e');
      rethrow;
    }
  }

  // Register
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    String role = 'client',
    bool isActive = true,
  }) async {
    log(
      'AuthService: Attempting register for email: $email, name: $name, role: $role',
    );
    try {
      final response = await _apiService.post(
        ApiConstants.authRegister, // Updated to use gateway route
        data: {
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
          'role': role,
          'isActive': isActive,
        },
      );

      log('AuthService: Register API response received: ${response.data}');

      final authResponse = AuthResponse.fromJson(response.data);

      // Save token and user data
      await _saveAuthData(authResponse);

      // Set token in API service
      _apiService.setToken(authResponse.accessToken);

      log(
        'AuthService: Register successful for user: ${authResponse.user.email}',
      );
      return authResponse;
    } catch (e) {
      log('AuthService: Register failed. Error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    log('AuthService: Attempting logout');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      _apiService.clearToken();
      log('AuthService: Logout successful. Local data cleared.');
    } catch (e) {
      log('AuthService: Logout failed. Error: $e');
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final isLoggedIn = token != null && token.isNotEmpty;
      log('AuthService: isLoggedIn check: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      log('AuthService: isLoggedIn check failed. Error: $e');
      return false;
    }
  }

  // Get saved token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return token;
    } catch (e) {
      log('AuthService: getToken failed. Error: $e');
      return null;
    }
  }

  // Get saved user
  Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson == null) {
        log('AuthService: No saved user data found');
        return null;
      }

      log('AuthService: Retrieving saved user data: $userJson');

      // Parse JSON string to Map
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      return UserModel.fromJson(userMap);
    } catch (e) {
      log('AuthService: Error getting user: $e');
      return null;
    }
  }

  // Initialize auth (call on app start)
  Future<void> initAuth() async {
    log('AuthService: Initializing auth...');
    try {
      final token = await getToken();
      if (token != null) {
        _apiService.setToken(token);
        log('AuthService: Auth initialized with existing token');
      } else {
        log('AuthService: No existing token found during initialization');
      }
    } catch (e) {
      log('AuthService: Error initializing auth: $e');
    }
  }

  // Save auth data to local storage
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    log('AuthService: Saving auth data locally...');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, authResponse.accessToken);
      await prefs.setString(_userKey, jsonEncode(authResponse.user.toJson()));
      log('AuthService: Auth data saved successfully');
    } catch (e) {
      log('AuthService: Error saving auth data: $e');
      rethrow;
    }
  }

  // Save credentials
  Future<void> saveCredentials(String email, String password) async {
    log('AuthService: Saving credentials for $email');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
      log('AuthService: Credentials saved successfully');
    } catch (e) {
      log('AuthService: Error saving credentials: $e');
    }
  }

  // Get saved credentials
  Future<Map<String, String>?> getCredentials() async {
    log('AuthService: Retrieving saved credentials...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('saved_email');
      final password = prefs.getString('saved_password');

      if (email != null && password != null) {
        log('AuthService: Credentials found for $email');
        return {'email': email, 'password': password};
      }
      log('AuthService: No saved credentials found');
      return null;
    } catch (e) {
      log('AuthService: Error retrieving credentials: $e');
      return null;
    }
  }

  // Clear credentials
  Future<void> clearCredentials() async {
    log('AuthService: Clearing saved credentials');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      log('AuthService: Credentials cleared');
    } catch (e) {
      log('AuthService: Error clearing credentials: $e');
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile(UserModel user) async {
    log('AuthService: Updating user profile for id: ${user.id}');
    try {
      // Update on backend
      final response = await _apiService.patch(
        ApiConstants.userById(
          user.id.toString(),
        ), // Updated to use gateway route
        data: user.toJson(),
      );

      log('AuthService: Update API response received: ${response.data}');

      final updatedUser = UserModel.fromJson(response.data);

      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));

      log('AuthService: User profile updated successfully');
      return updatedUser;
    } catch (e) {
      log('AuthService: Error updating user profile: $e');
      rethrow;
    }
  }
}
