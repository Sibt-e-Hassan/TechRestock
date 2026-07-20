import 'package:firebase_auth/firebase_auth.dart';

/// User-facing messages for Firebase Authentication errors.
String friendlyAuthErrorMessage(FirebaseAuthException exception) {
  switch (exception.code) {
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'user-disabled':
      return 'This account has been disabled. Contact support for help.';
    case 'user-not-found':
      return 'No account found with this email.';
    case 'wrong-password':
    case 'invalid-credential':
    case 'invalid-login-credentials':
      return 'Incorrect email or password. Please try again.';
    case 'email-already-in-use':
      return 'An account already exists with this email.';
    case 'weak-password':
      return 'Password is too weak. Use at least 6 characters.';
    case 'operation-not-allowed':
      return 'Email sign-in is not enabled. Contact support.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait a moment and try again.';
    case 'network-request-failed':
      return 'Network error. Check your internet connection and try again.';
    default:
      return exception.message ?? 'Authentication failed. Please try again.';
  }
}

String friendlyGenericAuthError(Object error) {
  final message = error.toString().toLowerCase();
  if (message.contains('network') ||
      message.contains('socket') ||
      message.contains('connection')) {
    return 'Network error. Check your internet connection and try again.';
  }
  return 'Something went wrong. Please try again.';
}
