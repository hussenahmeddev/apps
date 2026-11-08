import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/theme/app_text_styles.dart';
import 'package:haramaya_campus_connect/core/widgets/cached_image.dart';
import 'package:haramaya_campus_connect/core/widgets/loading_widget.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:haramaya_campus_connect/features/clubs/presentation/providers/club_provider.dart';
import 'package:haramaya_campus_connect/features/events/presentation/providers/event_provider.dart';
import 'package:haramaya_campus_connect/features/events/presentation/widgets/event_card.dart';
import 'package:haramaya_campus_connect/features/home/presentation/widgets/announcements_section.dart';
import 'package:haramaya_campus_connect/features/home/presentation/widgets/featured_event_card.dart';
import 'package:haramaya_campus_connect/features/home/presentation/widgets/welcome_header.dart';
import 'package:haramaya_campus_connect/features/notifications/presentation/providers/notification_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserModelProvider);
    final featuredEventsAsync = ref.watch(featuredEventsProvider);
    final upcomingEventsAsync = ref.watch(upcomingEventsProvider);
    final popularClubsAsync = ref.watch(popularClubsProvider);
    final announcementsAsync = ref.watch(announcementsProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(featuredEventsProvider);
          ref.invalidate(upcomingEventsProvider);
          ref.invalidate(popularClubsProvider);
          ref.invalidate(announcementsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              WelcomeHeader(
                userName: user?.fullName ?? '',
                onSearchTap: () => context.go('/events'),
              ),
              const SizedBox(height: 20),

              // Quick Actions Grid
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // Featured Events Carousel
              featuredEventsAsync.when(
                data: (featuredEvents) {
                  if (featuredEvents.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Featured Events',
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 230,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: featuredEvents.length,
                          itemBuilder: (context, index) {
                            final event = featuredEvents[index];
                            return FeaturedEventCard(
                              event: event,
                              onTap: () => context.push('/events/${event.id}'),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
                loading: () => const SizedBox(
                  height: 150,
                  child: Center(child: AppLoadingWidget()),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Popular Clubs Horizontal Row
              popularClubsAsync.when(
                data: (clubs) {
                  if (clubs.isEmpty) {
                    return _buildEmptySection(
                      context,
                      icon: Icons.groups_rounded,
                      title: 'Campus Clubs',
                      subtitle:
                          'Join clubs to connect with students who share your interests. Explore academic, tech, sports, and cultural clubs.',
                      buttonLabel: 'Explore Clubs',
                      onTap: () => context.go('/clubs'),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Popular Clubs',
                              style: AppTextStyles.headlineSmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/clubs'),
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 130,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: clubs.length,
                          itemBuilder: (context, index) {
                            final club = clubs[index];
                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 12),
                              child: InkWell(
                                onTap: () => context.push('/clubs/${club.id}'),
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  children: [
                                    CachedAvatar(
                                      imageUrl: club.imageUrl,
                                      name: club.name,
                                      radius: 30,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      club.name,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => _buildEmptySection(
                  context,
                  icon: Icons.groups_rounded,
                  title: 'Campus Clubs',
                  subtitle:
                      'Join clubs to connect with students who share your interests. Explore academic, tech, sports, and cultural clubs.',
                  buttonLabel: 'Explore Clubs',
                  onTap: () => context.go('/clubs'),
                ),
              ),

              // Recent Announcements / Notices
              announcementsAsync.when(
                data: (notices) => AnnouncementsSection(announcements: notices),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Upcoming Events Section
              upcomingEventsAsync.when(
                data: (events) {
                  if (events.isEmpty) {
                    return _buildEmptySection(
                      context,
                      icon: Icons.event_rounded,
                      title: 'Upcoming Events',
                      subtitle:
                          'No upcoming events right now. Check back soon for campus seminars, workshops, sports events, and cultural programs.',
                      buttonLabel: 'Browse Events',
                      onTap: () => context.go('/events'),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Upcoming Events',
                              style: AppTextStyles.headlineSmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/events'),
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return EventCard(
                            event: event,
                            onTap: () => context.push('/events/${event.id}'),
                          );
                        },
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: AppLoadingWidget()),
                error: (_, __) => _buildEmptySection(
                  context,
                  icon: Icons.event_rounded,
                  title: 'Upcoming Events',
                  subtitle:
                      'No upcoming events right now. Check back soon for campus seminars, workshops, sports events, and cultural programs.',
                  buttonLabel: 'Browse Events',
                  onTap: () => context.go('/events'),
                ),
              ),

              // Campus Info Card
              _buildCampusInfoCard(context, user?.department),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.event_rounded,
                  label: 'Events',
                  color: AppColors.primary,
                  onTap: () => context.go('/events'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.groups_rounded,
                  label: 'Clubs',
                  color: const Color(0xFF5C6BC0),
                  onTap: () => context.go('/clubs'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.notifications_rounded,
                  label: 'Alerts',
                  color: const Color(0xFFEF6C00),
                  onTap: () => context.go('/notifications'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  color: const Color(0xFF00897B),
                  onTap: () => context.go('/profile'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 18),
            label: Text(buttonLabel),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampusInfoCard(BuildContext context, String? department) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(
                'Haramaya University',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Stay connected with your campus community. Discover events, join clubs, and never miss important announcements.',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          if (department != null && department.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.apartment_rounded,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    department,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
