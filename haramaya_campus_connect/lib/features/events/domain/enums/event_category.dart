import 'package:flutter/material.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';

enum EventCategory {
  academic('academic', 'Academic', Icons.school_rounded, AppColors.categoryAcademic),
  sports('sports', 'Sports', Icons.sports_soccer_rounded, AppColors.categorySports),
  cultural('cultural', 'Cultural', Icons.palette_rounded, AppColors.categoryCultural),
  social('social', 'Social', Icons.people_rounded, AppColors.categorySocial),
  technology('technology', 'Technology', Icons.computer_rounded, AppColors.categoryTech),
  health('health', 'Health', Icons.health_and_safety_rounded, AppColors.categoryHealth),
  workshop('workshop', 'Workshop', Icons.build_rounded, AppColors.tertiary),
  seminar('seminar', 'Seminar', Icons.mic_rounded, AppColors.info),
  other('other', 'Other', Icons.category_rounded, AppColors.textSecondary);

  final String value;
  final String displayName;
  final IconData icon;
  final Color color;

  const EventCategory(this.value, this.displayName, this.icon, this.color);

  static EventCategory fromString(String? value) {
    return EventCategory.values.firstWhere(
      (cat) => cat.value == value,
      orElse: () => EventCategory.other,
    );
  }
}

enum EventStatus {
  draft('draft', 'Draft'),
  published('published', 'Published'),
  ongoing('ongoing', 'Ongoing'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  final String value;
  final String displayName;

  const EventStatus(this.value, this.displayName);

  static EventStatus fromString(String? value) {
    return EventStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => EventStatus.draft,
    );
  }
}

