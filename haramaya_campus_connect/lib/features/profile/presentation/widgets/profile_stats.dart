import 'package:flutter/material.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/theme/app_text_styles.dart';

class ProfileStats extends StatelessWidget {
  final int clubsCount;
  final int eventsCount;
  final int studyYear;

  const ProfileStats({
    super.key,
    required this.clubsCount,
    required this.eventsCount,
    this.studyYear = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem('Clubs Joined', '$clubsCount'),
          Container(height: 32, width: 1, color: AppColors.divider),
          _buildItem('Events Registered', '$eventsCount'),
          Container(height: 32, width: 1, color: AppColors.divider),
          _buildItem('Study Year', 'Year $studyYear'),
        ],
      ),
    );
  }

  Widget _buildItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

