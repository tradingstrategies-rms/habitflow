import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:habitflow/core/services/auth/auth_service.dart';
import 'package:habitflow/features/authentication/domain/auth_repository.dart';
import 'package:habitflow/features/authentication/domain/auth_failures.dart';

/// [FirebaseAuthRepository] implements [AuthRepository] using [AuthService].
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._authService);

  final AuthService _authService;

  @override
  Stream<String?> get authStateChanges => _authService.authStateChanges;

  @override
  Future<void> login(String email, String password) async {
    try {
      await _authService.signInWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    } catch (e) {
      throw const AuthFailure('Login failed. Please try again.');
    }
  }

  @override
  Future<void> loginWithGoogle() async {
    try {
      final userId = await _authService.signInWithGoogle();
      if (userId == null) {
        return;
      }
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    } catch (e) {
      throw const AuthFailure('Google sign in failed.');
    }
  }

  @override
  Future<void> loginWithApple() async {
    try {
      await _authService.signInWithApple();
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return;
      }
      throw const AuthFailure('Apple sign in failed.');
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    } catch (e) {
      throw const AuthFailure('Apple sign in failed.');
    }
  }

  @override
  Future<void> loginAnonymously() async {
    try {
      await _authService.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    } catch (e) {
      throw const AuthFailure('Anonymous sign in failed.');
    }
  }

  @override
  Future<void> register(String email, String password) async {
    try {
      await _authService.signUpWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    } catch (e) {
      throw const AuthFailure('Registration failed. Please try again.');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    } catch (e) {
      throw const AuthFailure('Could not send reset email.');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    } catch (e) {
      throw const AuthFailure('Could not send verification email.');
    }
  }

  @override
  Future<void> logout() async {
    await _authService.signOut();
  }

  @override
  HFUser? get currentUser => _authService.currentUser;
}
