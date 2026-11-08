import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haramaya_campus_connect/core/constants/firebase_constants.dart';
import 'package:haramaya_campus_connect/core/errors/failures.dart';
import 'package:haramaya_campus_connect/features/notifications/domain/models/notification_model.dart';
import 'package:haramaya_campus_connect/shared/providers/firebase_providers.dart';

abstract class NotificationRepository {
  Stream<List<NotificationModel>> getUserNotifications(String userId);
  Stream<int> getUnreadCount(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String notificationId);
  Stream<List<AnnouncementModel>> getAnnouncements();
  Future<void> createAnnouncement(AnnouncementModel announcement);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    // Avoid composite index: query one field, sort client-side
    return _firestore
        .collection(FirebaseConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list.take(50).toList();
    });
  }

  @override
  Stream<int> getUnreadCount(String userId) {
    // Avoid composite index: query one field, filter client-side
    return _firestore
        .collection(FirebaseConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.where((doc) => doc.data()['isRead'] == false).length);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw FirestoreFailure(message: e.toString());
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      // Avoid composite index: query one field, filter client-side
      final allDocs = await _firestore
          .collection(FirebaseConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in allDocs.docs) {
        if (doc.data()['isRead'] == false) {
          batch.update(doc.reference, {'isRead': true});
        }
      }
      await batch.commit();
    } catch (e) {
      throw FirestoreFailure(message: e.toString());
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.notificationsCollection)
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw FirestoreFailure(message: e.toString());
    }
  }

  @override
  Stream<List<AnnouncementModel>> getAnnouncements() {
    // Avoid composite index: query one field, sort client-side
    return _firestore
        .collection(FirebaseConstants.announcementsCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => AnnouncementModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list.take(20).toList();
    });
  }

  @override
  Future<void> createAnnouncement(AnnouncementModel announcement) async {
    try {
      await _firestore
          .collection(FirebaseConstants.announcementsCollection)
          .add(announcement.toFirestore());
    } catch (e) {
      throw FirestoreFailure(message: e.toString());
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(firestore: ref.watch(firestoreProvider));
});

final userNotificationsProvider =
    StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return Stream.value([]);
  return ref
      .watch(notificationRepositoryProvider)
      .getUserNotifications(user.uid);
});

final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return Stream.value(0);
  return ref.watch(notificationRepositoryProvider).getUnreadCount(user.uid);
});

final announcementsProvider =
    StreamProvider<List<AnnouncementModel>>((ref) async* {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) {
    yield [];
    return;
  }

  try {
    await FirebaseAuth.instance.currentUser?.getIdToken();
  } catch (_) {}

  final repo = ref.watch(notificationRepositoryProvider);

  int retries = 0;
  while (true) {
    try {
      final stream = repo.getAnnouncements();
      await for (final announcements in stream) {
        yield announcements;
      }
      break;
    } catch (e) {
      if (retries < 3) {
        retries++;
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }
      rethrow;
    }
  }
});
