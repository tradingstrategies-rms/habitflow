import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/core/services/auth/auth_service.dart';
import 'package:habitflow/features/authentication/data/firebase_auth_repository.dart';
import 'package:habitflow/features/authentication/domain/auth_failures.dart';

class MockAuthService implements AuthService {
  String? lastEmail;
  String? lastPassword;
  bool shouldThrow = false;
  String? errorCode;

  @override
  Future<String?> signInWithEmail(String email, String password) async {
    if (shouldThrow) throw Exception('Generic error');
    lastEmail = email;
    lastPassword = password;
    return 'user123';
  }

  @override
  Future<void> signOut() async {}

  @override
  Stream<String?> get authStateChanges => Stream.value(null);

  @override
  HFUser? get currentUser => null;

  @override
  String? get currentUserId => null;

  @override
  Future<void> deleteAccount() async {}

  @override
  bool get isLoggedIn => false;

  @override
  Future<void> reauthenticate(String email, String password) async {}

  @override
  Future<void> reload() async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<String?> signInAnonymously() async => 'anon123';

  @override
  Future<String?> signInWithApple() async => 'apple123';

  @override
  Future<String?> signInWithGoogle() async => 'google123';

  @override
  Future<String?> signUpWithEmail(String email, String password) async => 'user123';
}

void main() {
  group('FirebaseAuthRepository', () {
    late FirebaseAuthRepository repository;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      repository = FirebaseAuthRepository(mockAuthService);
    });

    test('login calls auth service with correct credentials', () async {
      await repository.login('test@example.com', 'password123');
      expect(mockAuthService.lastEmail, 'test@example.com');
      expect(mockAuthService.lastPassword, 'password123');
    });

    test('login throws AuthFailure on generic error', () async {
      mockAuthService.shouldThrow = true;
      expect(
        () => repository.login('test@example.com', 'password123'),
        throwsA(isA<AuthFailure>()),
      );
    });
  });
}
