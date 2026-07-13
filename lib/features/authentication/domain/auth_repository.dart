import 'package:habitflow/core/services/auth/auth_service.dart';

/// [AuthRepository] defines the domain-level interface for authentication.
abstract class AuthRepository {
  /// Stream of the current user's ID.
  Stream<String?> get authStateChanges;

  /// Logs in a user with email and password.
  Future<void> login(String email, String password);

  /// Logs in with Google.
  Future<void> loginWithGoogle();

  /// Logs in with Apple.
  Future<void> loginWithApple();

  /// Logs in anonymously.
  Future<void> loginAnonymously();

  /// Registers a new user.
  Future<void> register(String email, String password);

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail(String email);

  /// Sends an email verification.
  Future<void> sendEmailVerification();

  /// Logs out the current user.
  Future<void> logout();

  /// Gets the current user profile.
  HFUser? get currentUser;
}
