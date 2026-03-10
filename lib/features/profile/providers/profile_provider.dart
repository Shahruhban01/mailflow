// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../models/user_model.dart';
import '../../../services/storage_service.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  final String? success;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.success,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    String? success,
  }) =>
      ProfileState(
        isLoading: isLoading ?? this.isLoading,
        error:     error,
        success:   success,
      );
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ApiClient _client;

  ProfileNotifier(this._client) : super(const ProfileState());

  Future<void> updateProfile({
    required String name,
    String? signature,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _client.post(
        '/user/update.php',
        data: {
          'name':      name,
          'signature': signature,
        },
      );
      final user = UserModel.fromJson(
        res.data['user'] as Map<String, dynamic>,
      );
      await StorageService.saveUser(user);
      state = state.copyWith(
        isLoading: false,
        success: 'Profile updated successfully.',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow; // so the UI catch block also gets it
    }
  }

  Future<void> changePassword({
    required String current,
    required String newPass,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _client.post(
        '/user/password.php',
        data: {
          'current_password': current,
          'new_password':     newPass,
        },
      );
      state = state.copyWith(
        isLoading: false,
        success: 'Password changed successfully.',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.read(apiClientProvider));
});
