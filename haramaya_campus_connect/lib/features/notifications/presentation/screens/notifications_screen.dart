import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/widgets/empty_state_widget.dart';
import 'package:haramaya_campus_connect/core/widgets/error_widget.dart';
import 'package:haramaya_campus_connect/core/widgets/loading_widget.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:haramaya_campus_connect/features/notifications/presentation/providers/notification_provider.dart';
import 'package:haramaya_campus_connect/features/notifications/presentation/widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);
    final user = ref.watch(currentUserModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (user != null)
            TextButton.icon(
              onPressed: () {
                ref
                    .read(notificationRepositoryProvider)
                    .markAllAsRead(user.uid);
              },
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Read all'),
            ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.notifications_none_rounded,
              title: 'No Notifications Yet',
              subtitle: 'Campus alerts, event updates, and club announcements will appear here.',
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(userNotificationsProvider);
            },
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return NotificationTile(
                  notification: item,
                  onTap: () {
                    if (!item.isRead) {
                      ref
                          .read(notificationRepositoryProvider)
                          .markAsRead(item.id);
                    }
                  },
                  onDismissed: () {
                    ref
                        .read(notificationRepositoryProvider)
                        .deleteNotification(item.id);
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
          onRetry: () => ref.invalidate(userNotificationsProvider),
        ),
      ),
    );
  }
}

