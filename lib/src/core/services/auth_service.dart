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
    log('🔐 AuthService: Login attempt → $email [${AppwriteService.endpoint}]');
    try {
      final session = await _appwrite.account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      log('✅ AuthService: Session created — sessionId: ${session.$id}, userId: ${session.userId}');

      final user = await _getOrCreateUserProfile(session.userId, email);
      await _saveUser(user);

      log('✅ AuthService: Login successful — user: ${user.name} (${user.id})');
      return AuthResponse(accessToken: session.$id, user: user);
    } on AppwriteException catch (e) {
      log('❌ AuthService: Login failed [code: ${e.code}] — ${e.message}');
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
    log('📝 AuthService: Register attempt → $email [${AppwriteService.endpoint}]');
    try {
      // Create Appwrite account
      log('AuthService: [1/3] Creating Appwrite account...');
      await _appwrite.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      log('AuthService: [1/3] Account created');

      // Create session
      log('AuthService: [2/3] Creating session...');
      final session = await _appwrite.account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      log('AuthService: [2/3] Session created — userId: ${session.userId}');

      // Create user profile document
      log('AuthService: [3/3] Creating user profile document...');
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
      log('AuthService: [3/3] Profile document created — docId: ${doc.$id}');

      final user = UserModel.fromJson(doc.data..addAll({'\$id': doc.$id}));
      await _saveUser(user);

      log('✅ AuthService: Register successful — user: ${user.name} (${user.id})');
      return AuthResponse(accessToken: session.$id, user: user);
    } on AppwriteException catch (e) {
      log('❌ AuthService: Register failed [code: ${e.code}] — ${e.message}');
      throw Exception(e.message ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    log('🚪 AuthService: Logout — deleting current session');
    try {
      await _appwrite.account.deleteSession(sessionId: 'current');
      log('✅ AuthService: Session deleted');
    } catch (e) {
      log('⚠️ AuthService: Session delete failed (ignored): $e');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    log('AuthService: Local user cache cleared');
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
    log('✏️ AuthService: Updating profile for user ${user.id} (${user.email})');
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
      log('✅ AuthService: Profile updated successfully');
      return updated;
    } on AppwriteException catch (e) {
      log('❌ AuthService: Profile update failed [code: ${e.code}] — ${e.message}');
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
    log('AuthService: Fetching user profile — userId: $userId');
    try {
      final doc = await _appwrite.databases.getDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.usersCollection,
        documentId: userId,
      );
      log('✅ AuthService: Profile found — ${doc.data['name']}');
      return UserModel.fromJson(doc.data..addAll({'\$id': doc.$id}));
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        log('⚠️ AuthService: Profile not found, creating minimal document...');
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
        log('✅ AuthService: Minimal profile created — ${doc.$id}');
        return UserModel.fromJson(doc.data..addAll({'\$id': doc.$id}));
      }
      log('❌ AuthService: Profile fetch failed [code: ${e.code}] — ${e.message}');
      rethrow;
    }
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
}
