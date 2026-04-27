import 'dart:convert';
import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_response.dart';
import '../models/user_model.dart';
import 'appwrite_service.dart';

class AuthService {
  final AppwriteService _appwrite;
  static const String _userKey = 'user_data';

  AuthService(this._appwrite);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    log('AuthService: Login $email');
    try {
      final session = await _appwrite.account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      final user = await _getOrCreateUserProfile(session.userId, email);
      await _saveUser(user);

      log('AuthService: Login successful');
      return AuthResponse(accessToken: session.$id, user: user);
    } on AppwriteException catch (e) {
      log('AuthService: Login failed: ${e.message}');
      throw Exception(e.message ?? 'Login failed');
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    String role = 'client',
    bool isActive = true,
  }) async {
    log('AuthService: Register $email');
    try {
      // Create Appwrite account
      await _appwrite.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // Create session
      final session = await _appwrite.account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      // Create user profile document
      final doc = await _appwrite.databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.usersCollection,
        documentId: session.userId,
        data: {
          'name': name,
          'email': email,
          'role': role,
          'phone': phone,
          'isActive': isActive,
          'createdAt': DateTime.now().toIso8601String(),
          'password': '',
        },
      );

      final user = UserModel.fromJson(doc.data..addAll({'\$id': doc.$id}));
      await _saveUser(user);

      log('AuthService: Register successful');
      return AuthResponse(accessToken: session.$id, user: user);
    } on AppwriteException catch (e) {
      log('AuthService: Register failed: ${e.message}');
      throw Exception(e.message ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    log('AuthService: Logout');
    try {
      await _appwrite.account.deleteSession(sessionId: 'current');
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    try {
      await _appwrite.account.get();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      final sessions = await _appwrite.account.listSessions();
      if (sessions.sessions.isNotEmpty) {
        return sessions.sessions.first.$id;
      }
    } catch (_) {}
    return null;
  }

  Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        return UserModel.fromJson(jsonDecode(userJson));
      }
      // Fallback: fetch from Appwrite
      final account = await _appwrite.account.get();
      return await _getOrCreateUserProfile(account.$id, account.email);
    } catch (e) {
      log('AuthService: getUser error: $e');
      return null;
    }
  }

  Future<void> initAuth() async {
    log('AuthService: Init auth');
    // Session is managed by Appwrite SDK automatically — nothing extra needed
  }

  Future<UserModel> updateUserProfile(UserModel user) async {
    log('AuthService: Updating profile for ${user.id}');
    try {
      // Update Appwrite account name if changed
      await _appwrite.account.updateName(name: user.name);

      // Update user document
      final doc = await _appwrite.databases.updateDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.usersCollection,
        documentId: user.id,
        data: {
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'role': user.role,
          'isActive': user.isActive,
        },
      );

      final updated = UserModel.fromJson(doc.data..addAll({'\$id': doc.$id}));
      await _saveUser(updated);
      return updated;
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Update failed');
    }
  }

  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
    await prefs.setString('saved_password', password);
  }

  Future<Map<String, String>?> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('saved_email');
    final password = prefs.getString('saved_password');
    if (email != null && password != null) return {'email': email, 'password': password};
    return null;
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
  }

  // ── private helpers ──────────────────────────────────────────────────────

  Future<UserModel> _getOrCreateUserProfile(String userId, String email) async {
    try {
      final doc = await _appwrite.databases.getDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.usersCollection,
        documentId: userId,
      );
      return UserModel.fromJson(doc.data..addAll({'\$id': doc.$id}));
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        // Document doesn't exist yet — create a minimal one
        final doc = await _appwrite.databases.createDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.usersCollection,
          documentId: userId,
          data: {
            'name': email.split('@').first,
            'email': email,
            'role': 'client',
            'phone': '',
            'isActive': true,
            'createdAt': DateTime.now().toIso8601String(),
            'password': '',
          },
        );
        return UserModel.fromJson(doc.data..addAll({'\$id': doc.$id}));
      }
      rethrow;
    }
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
}
