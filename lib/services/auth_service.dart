import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  final ApiClient _client;
  AuthService(this._client);

  Future<UserModel> login(String email, String password) async {
    final res = await _client.post(ApiEndpoints.login, data: {
      'email': email,
      'password': password,
    });
    final data = res.data as Map<String, dynamic>;
    await StorageService.saveToken(data['token'] as String);
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await StorageService.saveUser(user);
    return user;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _client.post(ApiEndpoints.register, data: {
      'name': name, 'email': email, 'password': password,
    });
    final data = res.data as Map<String, dynamic>;
    await StorageService.saveToken(data['token'] as String);
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await StorageService.saveUser(user);
    return user;
  }

  Future<void> forgotPassword(String email) async {
    await _client.post(ApiEndpoints.forgotPassword, data: {'email': email});
  }

  Future<void> logout() async {
    try { await _client.post(ApiEndpoints.logout); } catch (_) {}
    await StorageService.clearAll();
  }
}
