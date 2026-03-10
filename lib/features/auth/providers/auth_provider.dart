import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiClientProvider));
});

// Auth state
sealed class AuthState {}
class AuthInitial   extends AuthState {}
class AuthLoading   extends AuthState {}
class AuthSuccess   extends AuthState { final UserModel user; AuthSuccess(this.user); }
class AuthError     extends AuthState { final String msg; AuthError(this.msg); }
class AuthLoggedOut extends AuthState {}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;
  AuthNotifier(this._service) : super(AuthInitial()) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final token = await StorageService.getToken();
    final user  = await StorageService.getUser();
    if (token != null && user != null) {
      state = AuthSuccess(user);
    } else {
      state = AuthLoggedOut();
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthLoading();
    try {
      final user = await _service.login(email, password);
      state = AuthSuccess(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = AuthLoading();
    try {
      final user = await _service.register(name: name, email: email, password: password);
      state = AuthSuccess(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> logout() async {
    await _service.logout();
    state = AuthLoggedOut();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});
