/// [AuthFailure] represents errors that can occur during authentication.
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  factory AuthFailure.fromCode(String code) {
    switch (code) {
      case 'user-not-found':
        return const AuthFailure('No user found with this email.');
      case 'wrong-password':
        return const AuthFailure('Invalid password.');
      case 'email-already-in-use':
        return const AuthFailure('This email is already registered.');
      case 'invalid-email':
        return const AuthFailure('The email address is invalid.');
      case 'weak-password':
        return const AuthFailure('The password is too weak.');
      case 'network-request-failed':
        return const AuthFailure('Network error. Please check your connection.');
      case 'user-disabled':
        return const AuthFailure('This account has been disabled.');
      case 'too-many-requests':
        return const AuthFailure('Too many attempts. Please try again later.');
      case 'operation-not-allowed':
        return const AuthFailure('Operation not allowed.');
      default:
        return const AuthFailure('An unexpected error occurred. Please try again.');
    }
  }

  @override
  String toString() => message;
}
