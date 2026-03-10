import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../models/user_model.dart';
import '../../../services/storage_service.dart';
import '../../auth/providers/auth_provider.dart';

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

  // Plain callbacks — zero Riverpod types inside the class
  final void Function(UserModel)  _onUserUpdated;
  final UserModel?                _currentUser;

  ProfileNotifier({
    required ApiClient client,
    required void Function(UserModel) onUserUpdated,
    required UserModel? currentUser,
  })  : _client       = client,
        _onUserUpdated = onUserUpdated,
        _currentUser   = currentUser,
        super(const ProfileState());

  Future<void> updateProfile({
    required String name,
    String? signature,
  }) async {
    final prev = _currentUser;

    // ── Optimistic update — instant, silent ──
    if (prev != null) {
      final optimistic = UserModel(
        id:        prev.id,
        email:     prev.email,
        createdAt: prev.createdAt,
        name:      name,
        signature: signature ?? prev.signature,
      );
      _onUserUpdated(optimistic);
      await StorageService.saveUser(optimistic);
    }

    // ── Background sync ──
    try {
      final res = await _client.post(
        '/user/update.php',
        data: {
          'name':      name,
          'signature': signature ?? prev?.signature ?? '',
        },
      );
      final confirmed = UserModel.fromJson(
        res.data['user'] as Map<String, dynamic>,
      );
      _onUserUpdated(confirmed);
      await StorageService.saveUser(confirmed);
      state = state.copyWith(success: 'Saved.');
    } catch (e) {
      // ── Rollback ──
      if (prev != null) {
        _onUserUpdated(prev);
        await StorageService.saveUser(prev);
      }
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateSignatureOnly(String signature) async {
    await updateProfile(
      name:      _currentUser?.name ?? '',
      signature: signature,
    );
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
      state = state.copyWith(isLoading: false, success: 'Password changed.');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

// ── Provider ──
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  // Extract everything as plain values — no Ref stored anywhere
  final client = ref.read(apiClientProvider);

  final authState   = ref.read(authProvider);
  final currentUser = authState is AuthSuccess ? authState.user : null;

  // Capture notifier as a plain function pointer
  // This avoids any generic type mismatch entirely
  void onUserUpdated(UserModel u) {
    // Read notifier lazily inside callback — safe, no type stored
    try {
      ref.read(authProvider.notifier).updateUser(u);
    } catch (_) {}
  }

  return ProfileNotifier(
    client:        client,
    onUserUpdated: onUserUpdated,
    currentUser:   currentUser,
  );
});
