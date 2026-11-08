/// Base class for all application failures.
abstract class Failure {
  final String message;
  final String? code;
  final dynamic originalError;

  const Failure({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'Failure($code): $message';
}

/// Firebase Authentication failures.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code, super.originalError});

  factory AuthFailure.fromCode(String code, [String? customMessage]) {
    switch (code) {
      case 'email-already-in-use':
        return const AuthFailure(
          message: 'An account already exists with this email address. Try signing in.',
          code: 'email-already-in-use',
        );
      case 'invalid-email':
        return const AuthFailure(
          message: 'The email address is not valid.',
          code: 'invalid-email',
        );
      case 'operation-not-allowed':
        return const AuthFailure(
          message: 'This sign-in method is not enabled in Firebase Console.',
          code: 'operation-not-allowed',
        );
      case 'weak-password':
        return const AuthFailure(
          message: 'The password is too weak. Use at least 6 characters.',
          code: 'weak-password',
        );
      case 'user-disabled':
        return const AuthFailure(
          message: 'This account has been disabled. Contact support.',
          code: 'user-disabled',
        );
      case 'user-not-found':
        return const AuthFailure(
          message: 'No account found with this email address.',
          code: 'user-not-found',
        );
      case 'wrong-password':
        return const AuthFailure(
          message: 'Incorrect password. Please try again.',
          code: 'wrong-password',
        );
      case 'invalid-credential':
        return const AuthFailure(
          message: 'Invalid email or password. Please try again.',
          code: 'invalid-credential',
        );
      case 'too-many-requests':
        return const AuthFailure(
          message: 'Too many attempts. Please try again later.',
          code: 'too-many-requests',
        );
      case 'network-request-failed':
        return const AuthFailure(
          message: 'Network error. Check your internet connection and try again.',
          code: 'network-request-failed',
        );
      case 'permission-denied':
        return const AuthFailure(
          message: 'Permission denied: Please update Firestore Security Rules in Firebase Console.',
          code: 'permission-denied',
        );
      default:
        return AuthFailure(
          message: customMessage ?? 'Authentication error ($code). Please try again.',
          code: code,
        );
    }
  }
}

/// Firestore data failures.
class FirestoreFailure extends Failure {
  const FirestoreFailure({required super.message, super.code, super.originalError});

  factory FirestoreFailure.fromCode(String code) {
    switch (code) {
      case 'permission-denied':
        return const FirestoreFailure(
          message: 'You do not have permission to perform this action.',
          code: 'permission-denied',
        );
      case 'not-found':
        return const FirestoreFailure(
          message: 'The requested resource was not found.',
          code: 'not-found',
        );
      case 'already-exists':
        return const FirestoreFailure(
          message: 'This resource already exists.',
          code: 'already-exists',
        );
      case 'resource-exhausted':
        return const FirestoreFailure(
          message: 'Service temporarily unavailable. Try again later.',
          code: 'resource-exhausted',
        );
      case 'unavailable':
        return const FirestoreFailure(
          message: 'Service is currently unavailable. Check your connection.',
          code: 'unavailable',
        );
      default:
        return FirestoreFailure(
          message: 'An unexpected error occurred.',
          code: code,
        );
    }
  }
}

/// Firebase Storage failures.
class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code, super.originalError});
}

/// Generic server / network failures.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code, super.originalError});
}

/// Capacity-related failures (event registration).
class CapacityFailure extends Failure {
  const CapacityFailure({
    super.message = 'This event has reached its maximum capacity.',
    super.code = 'capacity-reached',
  });
}

/// Duplicate registration failure.
class DuplicateRegistrationFailure extends Failure {
  const DuplicateRegistrationFailure({
    super.message = 'You are already registered for this event.',
    super.code = 'duplicate-registration',
  });
}

