class FirebaseConstants {
  FirebaseConstants._();

  // Collections
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String clubsCollection = 'clubs';
  static const String registrationsCollection = 'registrations';
  static const String notificationsCollection = 'notifications';
  static const String announcementsCollection = 'announcements';
  static const String clubMembersSubcollection = 'members';
  static const String eventRegistrationsSubcollection = 'registrations';

  // Storage paths
  static const String profileImagesPath = 'profile_images';
  static const String eventImagesPath = 'event_images';
  static const String clubImagesPath = 'club_images';
  static const String announcementImagesPath = 'announcement_images';

  // FCM Topics
  static const String allUsersTopic = 'all_users';
  static const String announcementsTopic = 'announcements';
  static const String eventsTopic = 'events';

  // Field names
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
  static const String dateTimeField = 'dateTime';
  static const String categoryField = 'category';
  static const String isActiveField = 'isActive';
  static const String statusField = 'status';
  static const String userIdField = 'userId';
  static const String clubIdField = 'clubId';
  static const String eventIdField = 'eventId';
  static const String roleField = 'role';
  static const String isReadField = 'isRead';
}

