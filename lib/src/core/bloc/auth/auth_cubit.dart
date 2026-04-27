import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_state.dart';
import 'package:neuroaid/src/core/services/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  // Check current auth status on app start
  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getUser();
        final token = await _authService.getToken();
        if (user != null && token != null) {
          emit(AuthAuthenticated(user: user, token: token));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(user: response.user, token: response.accessToken));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Register
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    String role = 'client',
  }) async {
    emit(AuthLoading());
    try {
      final response = await _authService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
      );
      emit(AuthAuthenticated(user: response.user, token: response.accessToken));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Logout
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Get saved credentials
  Future<Map<String, String>?> getSavedCredentials() async {
    return await _authService.getCredentials();
  }

  // Update Profile
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user;
      final token = (state as AuthAuthenticated).token;

      emit(AuthLoading());
      try {
        final updatedUser = currentUser.copyWith(
          name: name,
          email: email,
          phone: phone,
        );

        final result = await _authService.updateUserProfile(updatedUser);
        emit(AuthAuthenticated(user: result, token: token));
      } catch (e) {
        emit(AuthError(e.toString()));
        // Revert to authenticated state with old user data if update fails
        // Or keep it in error state depending on UX requirements.
        // Usually better to show error and stay authenticated.
        // For now, let's just re-emit the old state if we could, but we lost it.
        // Ideally we should have kept it.
        // Let's reload user from service to be safe or just re-emit the old user if we had it in a variable.
        // We have currentUser.
        emit(AuthAuthenticated(user: currentUser, token: token));
      }
    }
  }
}
