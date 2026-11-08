import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/utils/snackbar_utils.dart';
import 'package:haramaya_campus_connect/core/widgets/empty_state_widget.dart';
import 'package:haramaya_campus_connect/core/widgets/error_widget.dart';
import 'package:haramaya_campus_connect/core/widgets/loading_widget.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:haramaya_campus_connect/features/notifications/domain/models/notification_model.dart';
import 'package:haramaya_campus_connect/features/notifications/presentation/providers/notification_provider.dart';
import 'package:haramaya_campus_connect/features/notifications/presentation/widgets/announcement_detail_sheet.dart';
import 'package:haramaya_campus_connect/features/notifications/presentation/widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(notificationFeedProvider);
    final user = ref.watch(currentUserModelProvider);
    final activeFilter = ref.watch(notificationFilterProvider);
    final announcements = ref.watch(announcementsProvider).value ?? [];
    final personalNotifications =
        ref.watch(userNotificationsProvider).value ?? [];
    final readAnnouncementIds = ref.watch(readAnnouncementsProvider);

    final unreadAnnouncementsCount =
        announcements.where((a) => !readAnnouncementIds.contains(a.id)).length;
    final unreadPersonalCount =
        personalNotifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (user != null)
            TextButton.icon(
              onPressed: () async {
                // Mark personal notifications read in Firestore
                await ref
                    .read(notificationRepositoryProvider)
                    .markAllAsRead(user.uid);

                // Mark all announcements read in local cache
                final allAnnouncementIds =
                    announcements.map((a) => a.id).toList();
                await ref
                    .read(readAnnouncementsProvider.notifier)
                    .markAllAsRead(allAnnouncementIds);

                if (context.mounted) {
                  SnackBarUtils.showSuccess(
                    context,
                    'All notifications marked as read',
                  );
                }
              },
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Read all'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterChips(
            context,
            ref,
            activeFilter: activeFilter,
            unreadAnnouncements: unreadAnnouncementsCount,
            unreadPersonal: unreadPersonalCount,
          ),

          // Notification List / Feed
          Expanded(
            child: feedAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return _buildEmptyState(activeFilter);
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(announcementsProvider);
                    ref.invalidate(userNotificationsProvider);
                  },
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return NotificationTile(
                        item: item,
                        onTap: () {
                          if (item.isAnnouncement) {
                            ref
                                .read(readAnnouncementsProvider.notifier)
                                .markAsRead(item.id);
                            AnnouncementDetailSheet.show(
                              context,
                              item.announcement!,
                            );
                          } else {
                            if (!item.isRead) {
                              ref
                                  .read(notificationRepositoryProvider)
                                  .markAsRead(item.id);
                            }
                            _handleTargetNavigation(context, item);
                          }
                        },
                        onDismissed: () {
                          if (item.isAnnouncement) {
                            final isAdmin = user?.role.isAdmin ?? false;
                            if (isAdmin) {
                              ref
                                  .read(notificationRepositoryProvider)
                                  .deleteAnnouncement(item.id);
                            } else {
                              ref
                                  .read(readAnnouncementsProvider.notifier)
                                  .markAsRead(item.id);
                            }
                          } else {
                            ref
                                .read(notificationRepositoryProvider)
                                .deleteNotification(item.id);
                          }
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const AppLoadingWidget(),
              error: (err, _) => AppErrorWidget(
                message: 'Failed to load notifications',
                details: err.toString(),
                onRetry: () {
                  ref.invalidate(announcementsProvider);
                  ref.invalidate(userNotificationsProvider);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef ref, {
    required NotificationFilter activeFilter,
    required int unreadAnnouncements,
    required int unreadPersonal,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _chip(
            label: 'All',
            isSelected: activeFilter == NotificationFilter.all,
            badgeCount: unreadAnnouncements + unreadPersonal,
            onTap: () => ref.read(notificationFilterProvider.notifier).state =
                NotificationFilter.all,
          ),
          const SizedBox(width: 8),
          _chip(
            label: 'Announcements',
            isSelected: activeFilter == NotificationFilter.announcements,
            badgeCount: unreadAnnouncements,
            onTap: () => ref.read(notificationFilterProvider.notifier).state =
                NotificationFilter.announcements,
          ),
          const SizedBox(width: 8),
          _chip(
            label: 'Activity',
            isSelected: activeFilter == NotificationFilter.activity,
            badgeCount: unreadPersonal,
            onTap: () => ref.read(notificationFilterProvider.notifier).state =
                NotificationFilter.activity,
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool isSelected,
    required int badgeCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceVariant.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(NotificationFilter filter) {
    switch (filter) {
      case NotificationFilter.announcements:
        return const EmptyStateWidget(
          icon: Icons.campaign_outlined,
          title: 'No Announcements Yet',
          subtitle:
              'Official university notices and administrative alerts will appear here.',
        );
      case NotificationFilter.activity:
        return const EmptyStateWidget(
          icon: Icons.notifications_none_rounded,
          title: 'No Activity Updates',
          subtitle:
              'Event reminders, registration confirmations, and club updates will appear here.',
        );
      case NotificationFilter.all:
        return const EmptyStateWidget(
          icon: Icons.notifications_none_rounded,
          title: 'No Notifications Yet',
          subtitle:
              'Campus alerts, event updates, and club announcements will appear here.',
        );
    }
  }

  void _handleTargetNavigation(
      BuildContext context, NotificationFeedItem item) {
    final targetId = item.targetId;
    final targetType = item.targetType;
    if (targetId == null || targetId.isEmpty) return;

    if (targetType == 'event') {
      context.push('/events/$targetId');
    } else if (targetType == 'club') {
      context.push('/clubs/$targetId');
    }
  }
}
