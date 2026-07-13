import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'auth_service.dart';

/// [FirebaseAuthService] is the Firebase implementation of [AuthService].
class FirebaseAuthService implements AuthService {
  FirebaseAuthService(this._auth, this._googleSignIn);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  @override
  Stream<String?> get authStateChanges => 
      _auth.authStateChanges().map((user) => user?.uid);

  @override
  Future<String?> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user?.uid;
  }

  @override
  Future<String?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user?.uid;
  }

  @override
  Future<String?> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final OAuthCredential credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user?.uid;
  }

  @override
  Future<String?> signInAnonymously() async {
    final userCredential = await _auth.signInAnonymously();
    return userCredential.user?.uid;
  }

  @override
  Future<String?> signUpWithEmail(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user?.uid;
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<void> reload() async {
    await _auth.currentUser?.reload();
  }

  @override
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  @override
  Future<void> reauthenticate(String email, String password) async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      final credential = EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credential);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  HFUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return HFUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }

  @override
  bool get isLoggedIn => _auth.currentUser != null;
}
