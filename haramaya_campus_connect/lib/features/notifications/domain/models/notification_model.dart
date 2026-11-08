import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  eventUpdate('event_update', 'Event Update'),
  eventReminder('event_reminder', 'Event Reminder'),
  registration('registration', 'Registration'),
  clubUpdate('club_update', 'Club Update'),
  announcement('announcement', 'Announcement'),
  system('system', 'System');

  final String value;
  final String displayName;

  const NotificationType(this.value, this.displayName);

  static NotificationType fromString(String? value) {
    return NotificationType.values.firstWhere(
      (n) => n.value == value,
      orElse: () => NotificationType.system,
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? targetId;
  final String? targetType;
  final String userId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.targetId,
    this.targetType,
    required this.userId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    DateTime parsedDate;
    final createdRaw = data['createdAt'];
    if (createdRaw is Timestamp) {
      parsedDate = createdRaw.toDate();
    } else if (createdRaw is String) {
      parsedDate = DateTime.tryParse(createdRaw) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return NotificationModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: NotificationType.fromString(data['type'] as String?),
      targetId: data['targetId'] as String?,
      targetType: data['targetType'] as String?,
      userId: data['userId'] as String? ?? '',
      isRead: data['isRead'] as bool? ?? false,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'type': type.value,
      'targetId': targetId,
      'targetType': targetType,
      'userId': userId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    String? targetId,
    String? targetType,
    String? userId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      userId: userId ?? this.userId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NotificationModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String authorId;
  final String authorName;
  final String priority; // low, normal, high, urgent
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.authorId,
    required this.authorName,
    this.priority = 'normal',
    this.isActive = true,
    required this.createdAt,
    this.expiresAt,
  });

  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    DateTime parsedDate;
    final createdRaw = data['createdAt'];
    if (createdRaw is Timestamp) {
      parsedDate = createdRaw.toDate();
    } else if (createdRaw is String) {
      parsedDate = DateTime.tryParse(createdRaw) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    DateTime? parsedExpires;
    final expiresRaw = data['expiresAt'];
    if (expiresRaw is Timestamp) {
      parsedExpires = expiresRaw.toDate();
    } else if (expiresRaw is String) {
      parsedExpires = DateTime.tryParse(expiresRaw);
    }

    return AnnouncementModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Campus Administration',
      priority: data['priority'] as String? ?? 'normal',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: parsedDate,
      expiresAt: parsedExpires,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'authorId': authorId,
      'authorName': authorName,
      'priority': priority,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isUrgent => priority == 'urgent';
  bool get isHigh => priority == 'high';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AnnouncementModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class NotificationFeedItem {
  final AnnouncementModel? announcement;
  final NotificationModel? notification;
  final bool isRead;

  NotificationFeedItem.announcement(
    this.announcement, {
    this.isRead = false,
  }) : notification = null;

  NotificationFeedItem.notification(
    this.notification,
  )   : announcement = null,
        isRead = notification?.isRead ?? false;

  bool get isAnnouncement => announcement != null;
  String get id => isAnnouncement ? announcement!.id : notification!.id;
  String get title =>
      isAnnouncement ? announcement!.title : notification!.title;
  String get body =>
      isAnnouncement ? announcement!.content : notification!.body;
  DateTime get createdAt =>
      isAnnouncement ? announcement!.createdAt : notification!.createdAt;

  NotificationType get type =>
      isAnnouncement ? NotificationType.announcement : notification!.type;

  String get priority => announcement?.priority ?? 'normal';
  String get authorName => announcement?.authorName ?? 'Campus Administration';
  String? get targetId => notification?.targetId;
  String? get targetType => notification?.targetType;
}
