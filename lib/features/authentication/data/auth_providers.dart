import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/features/authentication/domain/auth_repository.dart';
import 'package:habitflow/features/authentication/data/firebase_auth_repository.dart';

/// Provider for [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return FirebaseAuthRepository(authService);
});

/// Stream provider for auth state changes.
final authStateProvider = StreamProvider<String?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
