import 'package:firebase_auth/firebase_auth.dart';
import 'package:haramaya_campus_connect/features/auth/domain/models/user_model.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentFirebaseUser;
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> getUserStream(String uid);
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserModel> signInWithGoogle();
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? studentId,
    String? department,
    int? year,
  });
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  });
  Future<void> updateFcmToken({
    required String uid,
    required String? token,
  });
}

