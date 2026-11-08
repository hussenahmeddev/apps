import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haramaya_campus_connect/core/constants/firebase_constants.dart';
import 'package:haramaya_campus_connect/core/errors/failures.dart';
import 'package:haramaya_campus_connect/features/clubs/domain/models/club_model.dart';
import 'package:haramaya_campus_connect/features/clubs/domain/repositories/club_repository.dart';
import 'package:haramaya_campus_connect/features/events/domain/enums/event_category.dart';
import 'package:haramaya_campus_connect/features/events/domain/models/event_model.dart';

class ClubRepositoryImpl implements ClubRepository {
  final FirebaseFirestore _firestore;

  ClubRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<List<ClubModel>> getClubs({String? category, String? searchQuery}) {
    // Avoid composite index: query one field, filter & sort client-side
    Query query = _firestore
        .collection(FirebaseConstants.clubsCollection)
        .where('isActive', isEqualTo: true);

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      var list = snapshot.docs.map((doc) => ClubModel.fromFirestore(doc)).toList();

      // Sort by memberCount client-side
      list.sort((a, b) => b.memberCount.compareTo(a.memberCount));

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        list = list
            .where((c) =>
                c.name.toLowerCase().contains(q) ||
                c.description.toLowerCase().contains(q))
            .toList();
      }
      return list;
    });
  }

  @override
  Future<ClubModel?> getClubById(String clubId) async {
    final doc = await _firestore
        .collection(FirebaseConstants.clubsCollection)
        .doc(clubId)
        .get();
    if (!doc.exists) return null;
    return ClubModel.fromFirestore(doc);
  }

  @override
  Stream<List<ClubModel>> getPopularClubs({int limit = 8}) {
    // Avoid composite index: query one field, sort client-side
    return _firestore
        .collection(FirebaseConstants.clubsCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ClubModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.memberCount.compareTo(a.memberCount));
      return list.take(limit).toList();
    });
  }

  @override
  Stream<List<ClubModel>> getUserClubs(String userId) {
    // Single arrayContains query - no composite index needed
    return _firestore
        .collection(FirebaseConstants.clubsCollection)
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClubModel.fromFirestore(doc))
            .where((c) => c.isActive)
            .toList());
  }

  @override
  Future<String> createClub(ClubModel club) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseConstants.clubsCollection)
          .add(club.toFirestore());
      return docRef.id;
    } catch (e) {
      throw FirestoreFailure(message: e.toString());
    }
  }

  @override
  Future<void> updateClub(ClubModel club) async {
    try {
      await _firestore
          .collection(FirebaseConstants.clubsCollection)
          .doc(club.id)
          .update(club.toFirestore());
    } catch (e) {
      throw FirestoreFailure(message: e.toString());
    }
  }

  @override
  Future<void> joinClub({required String clubId, required String userId}) async {
    final clubRef = _firestore.collection(FirebaseConstants.clubsCollection).doc(clubId);
    final userRef = _firestore.collection(FirebaseConstants.usersCollection).doc(userId);

    return _firestore.runTransaction((transaction) async {
      final clubDoc = await transaction.get(clubRef);
      if (!clubDoc.exists) throw const FirestoreFailure(message: 'Club not found');

      transaction.update(clubRef, {
        'memberIds': FieldValue.arrayUnion([userId]),
        'memberCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(userRef, {
        'joinedClubIds': FieldValue.arrayUnion([clubId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> leaveClub({required String clubId, required String userId}) async {
    final clubRef = _firestore.collection(FirebaseConstants.clubsCollection).doc(clubId);
    final userRef = _firestore.collection(FirebaseConstants.usersCollection).doc(userId);

    return _firestore.runTransaction((transaction) async {
      transaction.update(clubRef, {
        'memberIds': FieldValue.arrayRemove([userId]),
        'memberCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(userRef, {
        'joinedClubIds': FieldValue.arrayRemove([clubId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Stream<List<EventModel>> getClubEvents(String clubId) {
    // Avoid composite index: query one field, filter & sort client-side
    return _firestore
        .collection(FirebaseConstants.eventsCollection)
        .where('clubId', isEqualTo: clubId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .where((e) => e.status == EventStatus.published)
          .toList();
      list.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
      return list;
    });
  }
}

