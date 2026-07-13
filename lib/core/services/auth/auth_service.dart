import 'dart:async';

/// [HFUser] represents a minimal HabitFlow user profile.
class HFUser {
  const HFUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.emailVerified,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
}

/// [AuthService] defines the interface for authentication operations.
abstract class AuthService {
  /// Stream of authentication state changes.
  Stream<String?> get authStateChanges;

  /// Signs in with email and password.
  Future<String?> signInWithEmail(String email, String password);

  /// Signs in with Google.
  Future<String?> signInWithGoogle();

  /// Signs in with Apple.
  Future<String?> signInWithApple();

  /// Signs in anonymously.
  Future<String?> signInAnonymously();

  /// Signs up with email and password.
  Future<String?> signUpWithEmail(String email, String password);

  /// Signs out the current user.
  Future<void> signOut();

  /// Reloads the current user.
  Future<void> reload();

  /// Deletes the current user's account.
  Future<void> deleteAccount();

  /// Reauthenticates the user with email and password.
  Future<void> reauthenticate(String email, String password);

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail(String email);

  /// Sends an email verification to the current user.
  Future<void> sendEmailVerification();

  /// Gets the current user's unique ID.
  String? get currentUserId;

  /// Gets the current user profile.
  HFUser? get currentUser;

  /// Returns true if a user is currently signed in.
  bool get isLoggedIn;
}

/// [NoOpAuthService] is a placeholder for development.
class NoOpAuthService implements AuthService {
  @override
  Stream<String?> get authStateChanges => Stream.value(null);

  @override
  Future<String?> signInWithEmail(String email, String password) async => null;

  @override
  Future<String?> signInWithGoogle() async => null;

  @override
  Future<String?> signInWithApple() async => null;

  @override
  Future<String?> signInAnonymously() async => null;

  @override
  Future<String?> signUpWithEmail(String email, String password) async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> reload() async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> reauthenticate(String email, String password) async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  String? get currentUserId => null;

  @override
  HFUser? get currentUser => null;

  @override
  bool get isLoggedIn => false;
}
