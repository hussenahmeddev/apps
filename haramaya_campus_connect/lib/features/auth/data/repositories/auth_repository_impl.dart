import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:haramaya_campus_connect/core/constants/firebase_constants.dart';
import 'package:haramaya_campus_connect/core/errors/failures.dart';
import 'package:haramaya_campus_connect/features/auth/domain/enums/user_role.dart';
import 'package:haramaya_campus_connect/features/auth/domain/models/user_model.dart';
import 'package:haramaya_campus_connect/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentFirebaseUser => _auth.currentUser;

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  @override
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        // Auto-heal: If user exists in Auth but document was not saved to Firestore
        final now = DateTime.now();
        final fallbackUser = UserModel(
          uid: uid,
          email: email.trim().toLowerCase(),
          fullName: credential.user!.displayName ?? email.split('@').first,
          role: UserRole.student,
          joinedClubIds: const [],
          registeredEventIds: const [],
          isActive: true,
          emailVerified: credential.user!.emailVerified,
          createdAt: now,
          updatedAt: now,
        );
        try {
          await _firestore
              .collection(FirebaseConstants.usersCollection)
              .doc(uid)
              .set(fallbackUser.toFirestore());
          return fallbackUser;
        } on FirebaseException catch (e) {
          if (e.code == 'permission-denied') {
            throw const AuthFailure(
              message: 'Firestore Permission Denied: Update Firestore Security Rules in Firebase Console.',
              code: 'permission-denied',
            );
          }
          throw AuthFailure(
            message: 'Database error: ${e.message}',
            code: e.code,
          );
        }
      }

      final userModel = UserModel.fromFirestore(doc);
      if (!userModel.isActive) {
        await _auth.signOut();
        throw const AuthFailure(
          message: 'Your account has been deactivated. Please contact campus admin.',
          code: 'account-deactivated',
        );
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code, e.message);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthFailure(
          message: 'Firestore Permission Denied: Update Firestore Security Rules in Firebase Console.',
          code: 'permission-denied',
        );
      }
      throw AuthFailure(message: e.message ?? 'Authentication failed.', code: e.code);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure(message: e.toString());
    }
  }

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? studentId,
    String? department,
    int? year,
  }) async {
    UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Attempt sign-in in case previous registration succeeded in Auth but failed on Firestore
        try {
          credential = await _auth.signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
        } catch (_) {
          throw AuthFailure.fromCode(e.code, e.message);
        }
      } else {
        throw AuthFailure.fromCode(e.code, e.message);
      }
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }

    final uid = credential.user!.uid;
    final now = DateTime.now();

    // Enforce: role must be student on self-registration
    final newUser = UserModel(
      uid: uid,
      email: email.trim().toLowerCase(),
      fullName: fullName.trim(),
      studentId: studentId?.trim(),
      department: department?.trim(),
      year: year,
      role: UserRole.student,
      joinedClubIds: const [],
      registeredEventIds: const [],
      isActive: true,
      emailVerified: credential.user!.emailVerified,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .set(newUser.toFirestore());
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthFailure(
          message: 'Firestore Permission Denied: Update Firestore Security Rules in Firebase Console.',
          code: 'permission-denied',
        );
      }
      throw AuthFailure(
        message: 'Database error: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw AuthFailure(message: 'Database error: $e');
    }

    // Send verification email (non-blocking)
    try {
      await credential.user!.sendEmailVerification();
    } catch (_) {}

    return newUser;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthFailure(
          message: 'Google Sign-In was cancelled.',
          code: 'sign-in-cancelled',
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;
      final uid = firebaseUser.uid;

      // Check if user document already exists in Firestore
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        final userModel = UserModel.fromFirestore(doc);
        if (!userModel.isActive) {
          await _auth.signOut();
          await googleSignIn.signOut();
          throw const AuthFailure(
            message: 'Your account has been deactivated. Please contact campus admin.',
            code: 'account-deactivated',
          );
        }
        return userModel;
      }

      // Create new user document with student role
      final now = DateTime.now();
      final newUser = UserModel(
        uid: uid,
        email: firebaseUser.email ?? '',
        fullName: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
        photoUrl: firebaseUser.photoURL,
        role: UserRole.student,
        joinedClubIds: const [],
        registeredEventIds: const [],
        isActive: true,
        emailVerified: firebaseUser.emailVerified,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .set(newUser.toFirestore());

      return newUser;
    } on AuthFailure {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code, e.message);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthFailure(
          message: 'Firestore Permission Denied: Update Firestore Security Rules in Firebase Console.',
          code: 'permission-denied',
        );
      }
      throw AuthFailure(message: e.message ?? 'Google Sign-In failed.', code: e.code);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure(message: 'Google Sign-In failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Google as well (if signed in via Google)
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
      await _auth.signOut();
    } catch (e) {
      throw AuthFailure(message: 'Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Whitelist update fields to prevent privilege escalation
      final safeData = Map<String, dynamic>.from(data)
        ..remove('role')
        ..remove('email')
        ..remove('createdAt');
      safeData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update(safeData);
    } catch (e) {
      throw FirestoreFailure(message: e.toString());
    }
  }

  @override
  Future<void> updateFcmToken({
    required String uid,
    required String? token,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}

