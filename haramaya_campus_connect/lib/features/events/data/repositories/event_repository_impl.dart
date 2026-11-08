import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haramaya_campus_connect/core/constants/firebase_constants.dart';
import 'package:haramaya_campus_connect/core/errors/failures.dart';
import 'package:haramaya_campus_connect/features/events/domain/enums/event_category.dart';
import 'package:haramaya_campus_connect/features/events/domain/models/event_model.dart';
import 'package:haramaya_campus_connect/features/events/domain/models/registration_model.dart';
import 'package:haramaya_campus_connect/features/events/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final FirebaseFirestore _firestore;

  EventRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<List<EventModel>> getEvents({
    EventCategory? category,
    String? searchQuery,
    bool upcomingOnly = true,
  }) {
    // Use simple query without compound orderBy to avoid composite index requirement
    Query query = _firestore
        .collection(FirebaseConstants.eventsCollection)
        .where('status', isEqualTo: EventStatus.published.value);

    if (category != null && category != EventCategory.other) {
      query = query.where('category', isEqualTo: category.value);
    }

    return query.snapshots().map((snapshot) {
      var list =
          snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();

      // Filter upcoming client-side to avoid composite index
      if (upcomingOnly) {
        final now = DateTime.now();
        list = list.where((e) => e.startDateTime.isAfter(now)).toList();
      }

      // Sort client-side
      list.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final queryLower = searchQuery.trim().toLowerCase();
        list = list
            .where((e) =>
                e.title.toLowerCase().contains(queryLower) ||
                e.location.toLowerCase().contains(queryLower) ||
                e.description.toLowerCase().contains(queryLower))
            .toList();
      }
      return list;
    });
  }

  @override
  Future<EventModel?> getEventById(String eventId) async {
    final doc = await _firestore
        .collection(FirebaseConstants.eventsCollection)
        .doc(eventId)
        .get();
    if (!doc.exists) return null;
    return EventModel.fromFirestore(doc);
  }

  @override
  Stream<List<EventModel>> getFeaturedEvents() {
    // Avoid composite index: query only one field, filter & sort client-side
    return _firestore
        .collection(FirebaseConstants.eventsCollection)
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .where((e) => e.status == EventStatus.published)
          .toList();
      list.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
      return list.take(5).toList();
    });
  }

  @override
  Stream<List<EventModel>> getUpcomingEvents({int limit = 10}) {
    // Avoid composite index: query one field, filter & sort client-side
    return _firestore
        .collection(FirebaseConstants.eventsCollection)
        .where('status', isEqualTo: EventStatus.published.value)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final list = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .where((e) => e.startDateTime.isAfter(now))
          .toList();
      list.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
      return list.take(limit).toList();
    });
  }

  @override
  Future<String> createEvent(EventModel event) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseConstants.eventsCollection)
          .add(event.toFirestore());
      return docRef.id;
    } catch (e) {
      throw FirestoreFailure(message: e.toString());
    }
  }

  @override
  Future<void> updateEvent(EventModel event) async {
    try {
      await _firestore
          .collection(FirebaseConstants.eventsCollection)
          .doc(event.id)
          .update(event.toFirestore());
    } catch (e) {
      throw FirestoreFailure(message: e.toString());
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.eventsCollection)
          .doc(eventId)
          .delete();
    } catch (e) {
      throw FirestoreFailure(message: e.toString());
    }
  }

  @override
  Future<void> registerForEvent({
    required String eventId,
    required String userId,
    required String userName,
  }) async {
    final eventRef =
        _firestore.collection(FirebaseConstants.eventsCollection).doc(eventId);
    final registrationRef = _firestore
        .collection(FirebaseConstants.registrationsCollection)
        .doc('${eventId}_$userId');
    final userRef =
        _firestore.collection(FirebaseConstants.usersCollection).doc(userId);

    return _firestore.runTransaction((transaction) async {
      final eventDoc = await transaction.get(eventRef);
      if (!eventDoc.exists) {
        throw const FirestoreFailure(message: 'Event not found.');
      }

      final event = EventModel.fromFirestore(eventDoc);

      // Check if registration exists
      final regDoc = await transaction.get(registrationRef);
      if (regDoc.exists &&
          regDoc.data()?['status'] == RegistrationStatus.registered.value) {
        throw const DuplicateRegistrationFailure();
      }

      // Check capacity
      if (event.isFull) {
        throw const CapacityFailure();
      }

      // Create registration record
      final reg = RegistrationModel(
        id: registrationRef.id,
        eventId: eventId,
        eventTitle: event.title,
        userId: userId,
        userName: userName,
        status: RegistrationStatus.registered,
        registeredAt: DateTime.now(),
      );

      transaction.set(registrationRef, reg.toFirestore());

      // Increment event registration count
      transaction.update(eventRef, {
        'registeredCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update user registeredEventIds
      transaction.update(userRef, {
        'registeredEventIds': FieldValue.arrayUnion([eventId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> cancelRegistration({
    required String eventId,
    required String userId,
  }) async {
    final eventRef =
        _firestore.collection(FirebaseConstants.eventsCollection).doc(eventId);
    final registrationRef = _firestore
        .collection(FirebaseConstants.registrationsCollection)
        .doc('${eventId}_$userId');
    final userRef =
        _firestore.collection(FirebaseConstants.usersCollection).doc(userId);

    return _firestore.runTransaction((transaction) async {
      final regDoc = await transaction.get(registrationRef);
      if (!regDoc.exists ||
          regDoc.data()?['status'] != RegistrationStatus.registered.value) {
        return; // Nothing to cancel
      }

      transaction.update(registrationRef, {
        'status': RegistrationStatus.cancelled.value,
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      transaction.update(eventRef, {
        'registeredCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(userRef, {
        'registeredEventIds': FieldValue.arrayRemove([eventId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Stream<bool> isUserRegistered({
    required String eventId,
    required String userId,
  }) {
    return _firestore
        .collection(FirebaseConstants.registrationsCollection)
        .doc('${eventId}_$userId')
        .snapshots()
        .map((doc) =>
            doc.exists &&
            doc.data()?['status'] == RegistrationStatus.registered.value);
  }

  @override
  Stream<List<RegistrationModel>> getUserRegistrations(String userId) {
    // Avoid composite index: query one field, filter & sort client-side
    return _firestore
        .collection(FirebaseConstants.registrationsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => RegistrationModel.fromFirestore(doc))
          .where((r) => r.status == RegistrationStatus.registered)
          .toList();
      list.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
      return list;
    });
  }
}
