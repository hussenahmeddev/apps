import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haramaya_campus_connect/core/constants/firebase_constants.dart';
import 'package:haramaya_campus_connect/features/auth/domain/enums/user_role.dart';
import 'package:haramaya_campus_connect/features/auth/domain/models/user_model.dart';
import 'package:haramaya_campus_connect/shared/providers/firebase_providers.dart';

class AdminDashboardStats {
  final int totalUsers;
  final int totalStudents;
  final int totalOrganizers;
  final int totalAdmins;
  final int totalEvents;
  final int totalClubs;
  final int totalRegistrations;

  const AdminDashboardStats({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalOrganizers,
    required this.totalAdmins,
    required this.totalEvents,
    required this.totalClubs,
    required this.totalRegistrations,
  });
}

final adminStatsProvider = FutureProvider<AdminDashboardStats>((ref) async {
  final firestore = ref.watch(firestoreProvider);

  // Fetch all users to accurately calculate count per role
  final usersSnap = await firestore
      .collection(FirebaseConstants.usersCollection)
      .get();

  int studentsCount = 0;
  int organizersCount = 0;
  int adminsCount = 0;

  for (final doc in usersSnap.docs) {
    final role = doc.data()['role'] as String? ?? 'student';
    if (role == 'admin') {
      adminsCount++;
    } else if (role == 'club_organizer') {
      organizersCount++;
    } else {
      studentsCount++;
    }
  }

  final eventsSnap = await firestore
      .collection(FirebaseConstants.eventsCollection)
      .count()
      .get();
  final clubsSnap = await firestore
      .collection(FirebaseConstants.clubsCollection)
      .count()
      .get();
  final registrationsSnap = await firestore
      .collection(FirebaseConstants.registrationsCollection)
      .count()
      .get();

  return AdminDashboardStats(
    totalUsers: usersSnap.docs.length,
    totalStudents: studentsCount,
    totalOrganizers: organizersCount,
    totalAdmins: adminsCount,
    totalEvents: eventsSnap.count ?? 0,
    totalClubs: clubsSnap.count ?? 0,
    totalRegistrations: registrationsSnap.count ?? 0,
  );
});

final allUsersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection(FirebaseConstants.usersCollection)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
});

final adminActionProvider = Provider<AdminActions>((ref) {
  return AdminActions(firestore: ref.watch(firestoreProvider));
});

class AdminActions {
  final FirebaseFirestore _firestore;

  AdminActions({required FirebaseFirestore firestore}) : _firestore = firestore;

  Future<void> updateUserRole({
    required String uid,
    required UserRole newRole,
  }) async {
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .update({
      'role': newRole.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleUserStatus({
    required String uid,
    required bool isActive,
  }) async {
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

