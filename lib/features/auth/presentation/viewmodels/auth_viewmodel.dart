import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';

/// ViewModel handling the authentication business logic.
/// Uses AsyncNotifier to automatically handle Loading, Data, and Error states.
class AuthViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state is 'data' (not doing anything).
  }

  /// Sign In user
  Future<void> signIn(String email, String password) async {
    final authRepository = ref.read(authRepositoryProvider);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await authRepository.signInWithEmailPassword(email, password);
    });
  }

  /// Sign Up user
  Future<void> signUp(String name, String email, String password) async {
    final authRepository = ref.read(authRepositoryProvider);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await authRepository.signUpWithEmailPassword(email, password, name);
    });
  }

  /// Sign out user
  Future<void> signOut() async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.signOut();
  }
}
