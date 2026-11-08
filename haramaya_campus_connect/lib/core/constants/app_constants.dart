class AppConstants {
  AppConstants._();

  // App
  static const String appName = 'Haramaya Campus Connect';
  static const String universityName = 'Haramaya University';
  static const String universityMotto = 'Knowledge is Power';

  // Pagination
  static const int defaultPageSize = 20;
  static const int eventsPageSize = 15;
  static const int clubsPageSize = 15;
  static const int notificationsPageSize = 25;

  // Limits
  static const int maxEventCapacity = 10000;
  static const int minEventCapacity = 1;
  static const int maxClubDescriptionLength = 2000;
  static const int maxEventDescriptionLength = 5000;
  static const int maxAnnouncementLength = 3000;
  static const int maxBioLength = 500;

  // Image
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const double profileImageSize = 512;
  static const double eventImageWidth = 1200;
  static const double eventImageHeight = 800;

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration cacheExpiry = Duration(hours: 1);

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Layout
  static const double horizontalPadding = 16.0;
  static const double verticalPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double inputBorderRadius = 12.0;
}

