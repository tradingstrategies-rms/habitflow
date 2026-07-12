import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

/// [FirebaseAuthService] is the Firebase implementation of [AuthService].
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

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
  Future<String?> signUpWithEmail(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user?.uid;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
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
