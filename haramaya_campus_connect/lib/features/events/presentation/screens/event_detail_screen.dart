import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/theme/app_text_styles.dart';
import 'package:haramaya_campus_connect/core/utils/date_utils.dart';
import 'package:haramaya_campus_connect/core/widgets/cached_image.dart';
import 'package:haramaya_campus_connect/core/widgets/error_widget.dart';
import 'package:haramaya_campus_connect/core/widgets/loading_widget.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:haramaya_campus_connect/features/events/presentation/providers/event_provider.dart';
import 'package:haramaya_campus_connect/features/events/presentation/widgets/registration_button.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));
    final user = ref.watch(currentUserModelProvider);

    return Scaffold(
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return const AppErrorWidget(message: 'Event not found');
          }

          final isOrganizer = user != null &&
              (event.organizerId == user.uid || user.role.isAdmin);

          return CustomScrollView(
            slivers: [
              // Hero Image Header
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedImage(
                        imageUrl: event.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black45,
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  if (isOrganizer)
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.white),
                      onPressed: () => context.push('/events/edit/${event.id}'),
                    ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: event.category.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          event.category.displayName,
                          style: TextStyle(
                            color: event.category.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        event.title,
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Date Card
                      _buildInfoTile(
                        icon: Icons.calendar_today_rounded,
                        title: AppDateUtils.fullDate(event.startDateTime),
                        subtitle:
                            '${AppDateUtils.time(event.startDateTime)} - ${AppDateUtils.time(event.endDateTime)}',
                      ),
                      const SizedBox(height: 14),

                      // Location Card
                      _buildInfoTile(
                        icon: Icons.location_on_rounded,
                        title: event.location,
                        subtitle:
                            event.locationDetails ?? 'Main Campus, Haramaya',
                      ),
                      const SizedBox(height: 14),

                      // Organizer Card
                      _buildInfoTile(
                        icon: Icons.person_rounded,
                        title: event.organizerName,
                        subtitle: event.clubName != null
                            ? 'Club: ${event.clubName}'
                            : 'Organizer',
                      ),
                      const SizedBox(height: 20),

                      // Capacity Progress Bar
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Attendance Capacity',
                                  style: AppTextStyles.titleSmall,
                                ),
                                Text(
                                  '${event.registeredCount} / ${event.capacity} Registered',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: event.fillPercentage,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                              backgroundColor: Colors.white,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                event.isFull
                                    ? AppColors.error
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'About Event',
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Registration Button
                      RegistrationButton(event: event),
                      SizedBox(
                          height: 36 + MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const AppLoadingWidget(),
        error: (err, _) => AppErrorWidget(
          message: 'Error loading event details',
          details: err.toString(),
          onRetry: () => ref.invalidate(eventDetailProvider(eventId)),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
