import 'package:flutter/material.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/theme/app_text_styles.dart';
import 'package:haramaya_campus_connect/core/widgets/cached_image.dart';
import 'package:haramaya_campus_connect/features/clubs/domain/models/club_model.dart';

class ClubCard extends StatelessWidget {
  final ClubModel club;
  final VoidCallback onTap;

  const ClubCard({
    super.key,
    required this.club,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedAvatar(
                imageUrl: club.imageUrl,
                name: club.name,
                radius: 36,
              ),
              const SizedBox(height: 12),
              Text(
                club.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  club.category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.groups_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${club.memberCount} members',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

