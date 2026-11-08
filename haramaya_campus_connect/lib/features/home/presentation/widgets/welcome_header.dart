import 'package:flutter/material.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/theme/app_text_styles.dart';

class WelcomeHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onSearchTap;

  const WelcomeHeader({
    super.key,
    required this.userName,
    this.onSearchTap,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Haramaya University',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (onSearchTap != null)
                IconButton(
                  onPressed: onSearchTap,
                  icon: const Icon(Icons.search_rounded, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _getGreeting(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            userName.isNotEmpty ? userName : 'Student',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

