import 'package:flutter/material.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/theme/app_text_styles.dart';
import 'package:haramaya_campus_connect/core/utils/date_utils.dart';
import 'package:haramaya_campus_connect/features/notifications/domain/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismissed,
  });

  IconData _getIcon(NotificationType type) {
    switch (type) {
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

  Color _getColor(NotificationType type) {
    switch (type) {
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
    final color = _getColor(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.transparent
                : AppColors.primaryContainer.withValues(alpha: 0.15),
            border: const Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(_getIcon(notification.type), size: 22, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
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
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppDateUtils.relative(notification.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
