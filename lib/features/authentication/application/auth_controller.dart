import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/authentication/domain/auth_repository.dart';
import 'package:habitflow/features/authentication/data/auth_providers.dart';

/// [AuthController] manages the authentication state and operations for the UI.
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._repository) : super(const AsyncValue.data(null));

  final AuthRepository _repository;

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.login(email, password));
  }

  Future<void> loginWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.loginWithGoogle());
  }

  Future<void> loginWithApple() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.loginWithApple());
  }

  Future<void> loginAnonymously() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.loginAnonymously());
  }

  Future<void> register(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.register(email, password));
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.logout());
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.sendPasswordResetEmail(email));
  }

  Future<void> sendEmailVerification() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.sendEmailVerification());
  }
}

/// Provider for [AuthController].
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});
