import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/widgets/empty_state_widget.dart';
import 'package:haramaya_campus_connect/core/widgets/error_widget.dart';
import 'package:haramaya_campus_connect/core/widgets/loading_widget.dart';
import 'package:haramaya_campus_connect/features/events/presentation/providers/event_provider.dart';

class UserRegisteredEventsScreen extends ConsumerWidget {
  const UserRegisteredEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrationsAsync = ref.watch(userRegistrationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Registered Events'),
      ),
      body: registrationsAsync.when(
        data: (registrations) {
          if (registrations.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.event_available_outlined,
              title: 'No Registered Events',
              subtitle: 'Browse campus events and reserve your spot!',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: registrations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final reg = registrations[index];
              return Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.event_seat_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    reg.eventTitle,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Status: ${reg.status.displayName}'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => context.push('/events/${reg.eventId}'),
                ),
              );
            },
          );
        },
        loading: () => const AppLoadingWidget(),
        error: (err, _) => AppErrorWidget(
          message: 'Failed to load registrations',
          details: err.toString(),
        ),
      ),
    );
  }
}

