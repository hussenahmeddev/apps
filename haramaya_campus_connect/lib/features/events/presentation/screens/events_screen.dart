import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/widgets/empty_state_widget.dart';
import 'package:haramaya_campus_connect/core/widgets/error_widget.dart';
import 'package:haramaya_campus_connect/core/widgets/loading_widget.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:haramaya_campus_connect/features/events/presentation/providers/event_provider.dart';
import 'package:haramaya_campus_connect/features/events/presentation/widgets/event_card.dart';
import 'package:haramaya_campus_connect/features/events/presentation/widgets/event_filter_bar.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsStreamProvider);
    final user = ref.watch(currentUserModelProvider);
    final canCreate = user?.role.isOrganizer ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Events'),
      ),
      floatingActionButton: canCreate
          ? Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FloatingActionButton.extended(
                onPressed: () => context.push('/events/create'),
                icon: const Icon(Icons.add_rounded, size: 22),
                label: const Text(
                  'New Event',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
            )
          : null,
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search events by name or venue...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                ref.read(eventFilterProvider.notifier).setSearchQuery(val);
              },
            ),
          ),

          // Categories Filter Chips
          const EventFilterBar(),

          // Events List
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.event_busy_rounded,
                    title: 'No Events Found',
                    subtitle: 'Check back soon or try selecting a different category.',
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(eventsStreamProvider);
                  },
                  child: ListView.builder(
                    itemCount: events.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return EventCard(
                        event: event,
                        onTap: () => context.push('/events/${event.id}'),
                      );
                    },
                  ),
                );
              },
              loading: () => const AppLoadingWidget(),
              error: (err, _) {
                if (err.toString().contains('permission-denied')) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Future.delayed(const Duration(milliseconds: 600), () {
                      ref.invalidate(eventsStreamProvider);
                    });
                  });
                  return const AppLoadingWidget();
                }
                return AppErrorWidget(
                  message: 'Failed to load events',
                  details: err.toString(),
                  onRetry: () => ref.invalidate(eventsStreamProvider),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

