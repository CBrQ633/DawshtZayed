import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/data/repositories/auth_repository.dart';

class AuthViewModel extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AsyncValue.data(null));

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        metadata: metadata,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signInWithGoogle();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authViewModelProvider = StateNotifierProvider.autoDispose<AuthViewModel, AsyncValue<void>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository);
});
