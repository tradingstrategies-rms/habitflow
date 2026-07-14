import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    debugPrint("[LOGIN] Repository.login() called");
    try {
      debugPrint("[LOGIN] Calling FirebaseAuth.signInWithEmailAndPassword()");
      await _authService.signInWithEmail(email, password);
      debugPrint("[LOGIN] SUCCESS");
    } on FirebaseAuthException catch (e) {
      debugPrint("[LOGIN] FAILURE: type=${e.runtimeType}, code=${e.code}, message=${e.message}, stack=${StackTrace.current}");
      throw AuthFailure.fromCode(e.code);
    } catch (e) {
      debugPrint("[LOGIN] FAILURE: unexpected $e");
      throw const AuthFailure('Login failed. Please try again.');
    }
  }

  @override
  Future<void> loginWithGoogle() async {
    debugPrint("[GOOGLE] Repository.googleSignIn() called");
    try {
      debugPrint("[GOOGLE] Calling GoogleSignIn.signIn()");
      final userId = await _authService.signInWithGoogle();
      debugPrint("[GOOGLE] Calling FirebaseAuth.signInWithCredential()");
      if (userId == null) {
        debugPrint("[GOOGLE] FAILURE: userId is null");
        return;
      }
      debugPrint("[GOOGLE] SUCCESS");
    } on FirebaseAuthException catch (e) {
      debugPrint("[GOOGLE] FAILURE: type=${e.runtimeType}, code=${e.code}, message=${e.message}, stack=${StackTrace.current}");
      throw AuthFailure.fromCode(e.code);
    } catch (e) {
      debugPrint("[GOOGLE] FAILURE: unexpected $e");
      throw const AuthFailure('Google sign in failed.');
    }
  }

  @override
  Future<void> loginWithApple() async {
    throw UnimplementedError('Apple Login is not implemented yet.');
  }

  @override
  Future<void> loginAnonymously() async {
    throw UnimplementedError('Anonymous Login is not implemented yet.');
  }

  @override
  Future<void> register(String email, String password) async {
    debugPrint("[REGISTER] Repository.register() called");
    try {
      debugPrint("[REGISTER] Calling FirebaseAuthService.signUpWithEmail()");
      debugPrint("[REGISTER] Calling FirebaseAuth.createUserWithEmailAndPassword()");
      await _authService.signUpWithEmail(email, password);
      debugPrint("[REGISTER] SUCCESS");
    } on FirebaseAuthException catch (e) {
      debugPrint("[REGISTER] FAILURE: type=${e.runtimeType}, code=${e.code}, message=${e.message}, stack=${StackTrace.current}");
      throw AuthFailure.fromCode(e.code);
    } catch (e) {
      debugPrint("[REGISTER] FAILURE: unexpected $e");
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
