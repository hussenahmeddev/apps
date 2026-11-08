import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haramaya_campus_connect/core/errors/failures.dart';
import 'package:haramaya_campus_connect/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:haramaya_campus_connect/features/auth/domain/models/user_model.dart';
import 'package:haramaya_campus_connect/features/auth/domain/repositories/auth_repository.dart';
import 'package:haramaya_campus_connect/shared/providers/firebase_providers.dart';
import 'package:haramaya_campus_connect/shared/services/notification_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final currentUserStreamProvider = StreamProvider<UserModel?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) {
    return Stream.value(null);
  }
  return ref.watch(authRepositoryProvider).getUserStream(authUser.uid);
});

final currentUserModelProvider = Provider<UserModel?>((ref) {
  return ref.watch(currentUserStreamProvider).value;
});

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Sync FCM token (non-critical, don't let it block sign-in)
      try {
        final token = await NotificationService.instance.getToken();
        if (token != null) {
          await _repository.updateFcmToken(uid: user.uid, token: token);
        }
      } catch (_) {
        // FCM token sync is optional; ignore errors
      }
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } on Failure catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    } catch (e) {
      String errorMsg = e.toString().replaceFirst('Exception: ', '');
      if (e.toString().contains('CONFIGURATION_NOT_FOUND') ||
          e.toString().contains('operation-not-allowed')) {
        errorMsg =
            'Email/Password sign-in is not enabled. Please enable it in the Firebase Console under Authentication > Sign-in method.';
      } else if (e.toString().contains('network')) {
        errorMsg = 'Network error. Check your connection and try again.';
      } else if (e.toString().contains('permission-denied')) {
        errorMsg =
            'Firestore Permission Denied: Update Firestore Security Rules in Firebase Console.';
      }
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: errorMsg,
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? studentId,
    String? department,
    int? year,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repository.registerWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        studentId: studentId,
        department: department,
        year: year,
      );
      // Sync FCM token (non-critical, don't let it block registration)
      try {
        final token = await NotificationService.instance.getToken();
        if (token != null) {
          await _repository.updateFcmToken(uid: user.uid, token: token);
        }
      } catch (_) {
        // FCM token sync is optional; ignore errors
      }
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } on Failure catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    } catch (e) {
      String errorMsg = e.toString().replaceFirst('Exception: ', '');
      if (e.toString().contains('CONFIGURATION_NOT_FOUND') ||
          e.toString().contains('operation-not-allowed')) {
        errorMsg =
            'Email/Password sign-in is not enabled. Please enable it in the Firebase Console under Authentication > Sign-in method.';
      } else if (e.toString().contains('network')) {
        errorMsg = 'Network error. Check your connection and try again.';
      } else if (e.toString().contains('email-already-in-use')) {
        errorMsg = 'An account already exists with this email address. Please sign in.';
      } else if (e.toString().contains('weak-password')) {
        errorMsg = 'The password is too weak. Use at least 6 characters.';
      } else if (e.toString().contains('invalid-email')) {
        errorMsg = 'The email address is not valid.';
      } else if (e.toString().contains('permission-denied')) {
        errorMsg =
            'Firestore Permission Denied: Update Firestore Security Rules in Firebase Console.';
      }
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: errorMsg,
      );
    }
  }

  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repository.sendPasswordResetEmail(email);
      state = state.copyWith(status: AuthStatus.initial);
    } on Failure catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repository.signInWithGoogle();
      // Sync FCM token (non-critical)
      try {
        final token = await NotificationService.instance.getToken();
        if (token != null) {
          await _repository.updateFcmToken(uid: user.uid, token: token);
        }
      } catch (_) {}
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } on Failure catch (e) {
      // If user cancelled, just reset to initial (not an error)
      if (e.message.contains('cancelled')) {
        state = state.copyWith(status: AuthStatus.initial);
        return;
      }
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    } catch (e) {
      String errorMsg = e.toString().replaceFirst('Exception: ', '');
      if (e.toString().contains('network')) {
        errorMsg = 'Network error. Check your connection and try again.';
      } else if (e.toString().contains('permission-denied')) {
        errorMsg = 'Firestore Permission Denied: Update Firestore Security Rules in Firebase Console.';
      }
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: errorMsg,
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to sign out',
      );
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

