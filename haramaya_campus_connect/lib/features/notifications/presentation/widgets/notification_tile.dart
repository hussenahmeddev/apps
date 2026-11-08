import 'package:flutter/material.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/theme/app_text_styles.dart';
import 'package:haramaya_campus_connect/core/utils/date_utils.dart';
import 'package:haramaya_campus_connect/features/notifications/domain/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationFeedItem item;
  final VoidCallback onTap;
  final VoidCallback? onDismissed;

  const NotificationTile({
    super.key,
    required this.item,
    required this.onTap,
    this.onDismissed,
  });

  IconData _getIcon() {
    if (item.isAnnouncement) {
      return Icons.campaign_rounded;
    }
    switch (item.type) {
      case NotificationType.eventUpdate:
      case NotificationType.eventReminder:
        return Icons.event_note_rounded;
      case NotificationType.registration:
        return Icons.how_to_reg_rounded;
      case NotificationType.clubUpdate:
        return Icons.groups_rounded;
      case NotificationType.announcement:
        return Icons.campaign_rounded;
      case NotificationType.system:
        return Icons.info_outline_rounded;
    }
  }

  Color _getColor() {
    if (item.isAnnouncement) {
      final p = item.priority;
      if (p == 'urgent') return AppColors.error;
      if (p == 'high') return const Color(0xFFF57C00); // Orange
      return AppColors.primary;
    }
    switch (item.type) {
      case NotificationType.eventUpdate:
        return AppColors.primary;
      case NotificationType.eventReminder:
        return AppColors.tertiary;
      case NotificationType.registration:
        return AppColors.success;
      case NotificationType.clubUpdate:
        return AppColors.categoryCultural;
      case NotificationType.announcement:
        return AppColors.error;
      case NotificationType.system:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    final content = InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: item.isRead
              ? Colors.transparent
              : AppColors.primaryContainer.withValues(alpha: 0.15),
          border: const Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon in colored container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIcon(), size: 22, color: color),
            ),
            const SizedBox(width: 12),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.isAnnouncement) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.priority.toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight:
                                item.isRead ? FontWeight.w500 : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        AppDateUtils.relative(item.createdAt),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                        ),
                      ),
                      if (item.isAnnouncement) ...[
                        Text(
                          ' • ${item.authorName}',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onDismissed != null) {
      return Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismissed!(),
        background: Container(
          color: AppColors.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        child: content,
      );
    }

    return content;
  }
}
