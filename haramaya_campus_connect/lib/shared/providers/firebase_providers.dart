import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the FirebaseAuth instance.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provides the FirebaseFirestore instance.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provides the FirebaseStorage instance.
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

/// Stream of the currently authenticated Firebase user.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Current authenticated user (nullable).
final currentFirebaseUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

