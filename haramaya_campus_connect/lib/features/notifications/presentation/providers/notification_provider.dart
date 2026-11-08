import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haramaya_campus_connect/core/constants/firebase_constants.dart';
import 'package:haramaya_campus_connect/core/errors/failures.dart';
import 'package:haramaya_campus_connect/features/notifications/domain/models/notification_model.dart';
import 'package:haramaya_campus_connect/shared/providers/firebase_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NotificationRepository {
  Stream<List<NotificationModel>> getUserNotifications(String userId);
  Stream<int> getUnreadCount(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String notificationId);
  Stream<List<AnnouncementModel>> getAnnouncements();
  Future<void> createAnnouncement(AnnouncementModel announcement);
  Future<void> deleteAnnouncement(String announcementId);
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
    // Avoid composite index: query collection, filter and sort client-side
    return _firestore
        .collection(FirebaseConstants.announcementsCollection)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => AnnouncementModel.fromFirestore(doc))
          .where((a) => a.isActive && !a.isExpired)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list.take(30).toList();
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

  @override
  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.announcementsCollection)
          .doc(announcementId)
          .delete();
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

/// Local persistence for which campus announcements have been read by the user
class ReadAnnouncementsNotifier extends StateNotifier<Set<String>> {
  static const String _storageKey = 'read_announcement_ids';

  ReadAnnouncementsNotifier() : super({}) {
    _loadReadIds();
  }

  Future<void> _loadReadIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_storageKey) ?? [];
      state = list.toSet();
    } catch (e) {
      debugPrint('Error reading cached announcement read states: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    if (state.contains(id)) return;
    final updated = Set<String>.from(state)..add(id);
    state = updated;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, updated.toList());
    } catch (e) {
      debugPrint('Error saving announcement read state: $e');
    }
  }

  Future<void> markAllAsRead(List<String> ids) async {
    final updated = Set<String>.from(state)..addAll(ids);
    state = updated;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, updated.toList());
    } catch (e) {
      debugPrint('Error saving announcement read states: $e');
    }
  }

  bool isRead(String id) => state.contains(id);
}

final readAnnouncementsProvider =
    StateNotifierProvider<ReadAnnouncementsNotifier, Set<String>>((ref) {
  return ReadAnnouncementsNotifier();
});

/// Notification filter options for the Notifications screen
enum NotificationFilter {
  all('All'),
  announcements('Announcements'),
  activity('Activity');

  final String label;
  const NotificationFilter(this.label);
}

final notificationFilterProvider =
    StateProvider<NotificationFilter>((ref) => NotificationFilter.all);

/// Combined notification feed merging announcements and personal notifications
final notificationFeedProvider =
    Provider<AsyncValue<List<NotificationFeedItem>>>((ref) {
  final announcementsAsync = ref.watch(announcementsProvider);
  final notificationsAsync = ref.watch(userNotificationsProvider);
  final readAnnouncementIds = ref.watch(readAnnouncementsProvider);
  final activeFilter = ref.watch(notificationFilterProvider);

  // If both are loading, indicate loading
  if (announcementsAsync.isLoading && notificationsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  // If one errored and neither has value, propagate error
  if (announcementsAsync.hasError &&
      !announcementsAsync.hasValue &&
      !notificationsAsync.hasValue) {
    return AsyncValue.error(
      announcementsAsync.error!,
      announcementsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final announcements = announcementsAsync.value ?? [];
  final notifications = notificationsAsync.value ?? [];

  final List<NotificationFeedItem> items = [];

  // Add announcements if filter includes them
  if (activeFilter == NotificationFilter.all ||
      activeFilter == NotificationFilter.announcements) {
    for (final a in announcements) {
      items.add(NotificationFeedItem.announcement(
        a,
        isRead: readAnnouncementIds.contains(a.id),
      ));
    }
  }

  // Add personal notifications if filter includes them
  if (activeFilter == NotificationFilter.all ||
      activeFilter == NotificationFilter.activity) {
    for (final n in notifications) {
      items.add(NotificationFeedItem.notification(n));
    }
  }

  // Sort latest first
  items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return AsyncValue.data(items);
});

/// Combined unread count for bottom navigation badge
final combinedUnreadCountProvider = Provider<int>((ref) {
  final personalUnread = ref.watch(unreadNotificationCountProvider).value ?? 0;
  final announcements = ref.watch(announcementsProvider).value ?? [];
  final readIds = ref.watch(readAnnouncementsProvider);

  final unreadAnnouncements =
      announcements.where((a) => !readIds.contains(a.id)).length;
  return personalUnread + unreadAnnouncements;
});
