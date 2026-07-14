import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/authentication/domain/auth_repository.dart';
import 'package:habitflow/features/authentication/data/auth_providers.dart';

/// [AuthController] manages the authentication state and operations for the UI.
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._repository) : super(const AsyncValue.data(null));

  final AuthRepository _repository;

  Future<void> login(String email, String password) async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    debugPrint("[LOGIN] AuthController.login() called");
    state = await AsyncValue.guard(() => _repository.login(email, password));
  }

  Future<void> loginWithGoogle() async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    debugPrint("[GOOGLE] AuthController.googleSignIn() called");
    state = await AsyncValue.guard(() => _repository.loginWithGoogle());
  }

  Future<void> register(String email, String password) async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    debugPrint("[REGISTER] AuthController.register() called");
    state = await AsyncValue.guard(() => _repository.register(email, password));
  }

  Future<void> loginWithApple() async {
    throw UnimplementedError('Apple Login is not implemented yet.');
  }

  Future<void> loginAnonymously() async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.loginAnonymously());
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.sendPasswordResetEmail(email));
  }

  Future<void> sendEmailVerification() async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.sendEmailVerification());
  }

  Future<void> logout() async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.logout());
  }
}

/// Provider for [AuthController].
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});
