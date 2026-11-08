import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/theme/app_text_styles.dart';
import 'package:haramaya_campus_connect/core/utils/snackbar_utils.dart';
import 'package:haramaya_campus_connect/core/widgets/cached_image.dart';
import 'package:haramaya_campus_connect/core/widgets/custom_button.dart';
import 'package:haramaya_campus_connect/core/widgets/error_widget.dart';
import 'package:haramaya_campus_connect/core/widgets/loading_widget.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:haramaya_campus_connect/features/clubs/presentation/providers/club_provider.dart';
import 'package:haramaya_campus_connect/features/events/presentation/widgets/event_card.dart';

class ClubDetailScreen extends ConsumerStatefulWidget {
  final String clubId;

  const ClubDetailScreen({super.key, required this.clubId});

  @override
  ConsumerState<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends ConsumerState<ClubDetailScreen> {
  bool _isProcessing = false;

  Future<void> _toggleMembership(bool isMember) async {
    final user = ref.read(currentUserModelProvider);
    if (user == null) {
      SnackBarUtils.showWarning(context, 'Please sign in first');
      return;
    }

    setState(() => _isProcessing = true);
    try {
      if (isMember) {
        await ref.read(clubRepositoryProvider).leaveClub(
              clubId: widget.clubId,
              userId: user.uid,
            );
        if (mounted) SnackBarUtils.showInfo(context, 'Left the club');
      } else {
        await ref.read(clubRepositoryProvider).joinClub(
              clubId: widget.clubId,
              userId: user.uid,
            );
        if (mounted) SnackBarUtils.showSuccess(context, 'Joined the club!');
      }
      ref.invalidate(clubDetailProvider(widget.clubId));
    } catch (e) {
      if (mounted) SnackBarUtils.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clubAsync = ref.watch(clubDetailProvider(widget.clubId));
    final eventsAsync = ref.watch(clubEventsProvider(widget.clubId));
    final currentUser = ref.watch(currentUserModelProvider);

    return Scaffold(
      body: clubAsync.when(
        data: (club) {
          if (club == null) {
            return const AppErrorWidget(message: 'Club not found');
          }

          final isMember = currentUser != null && club.isMember(currentUser.uid);

          return CustomScrollView(
            slivers: [
              // Club Header
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedImage(
                        imageUrl: club.coverImageUrl,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 24),
                            CachedAvatar(
                              imageUrl: club.imageUrl,
                              name: club.name,
                              radius: 40,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Club Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              club.name,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.headlineMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                club.category,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('Members', '${club.memberCount}'),
                          Container(
                            height: 30,
                            width: 1,
                            color: AppColors.divider,
                          ),
                          _buildStatItem(
                            'Organizer',
                            club.organizerName.split(' ').first,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Join / Leave Button
                      CustomButton(
                        label: isMember ? 'Member ✓ (Leave Club)' : 'Join Club',
                        isOutlined: isMember,
                        backgroundColor:
                            isMember ? AppColors.error : AppColors.primary,
                        foregroundColor:
                            isMember ? AppColors.error : Colors.white,
                        isLoading: _isProcessing,
                        onPressed: () => _toggleMembership(isMember),
                      ),
                      const SizedBox(height: 28),

                      // About Section
                      const Text('About Club', style: AppTextStyles.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        club.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Meeting Info
                      if (club.meetingSchedule != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Meetings: ${club.meetingSchedule!}',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],

                      if (club.contactEmail != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              club.contactEmail!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      const Divider(height: 32),
                      const Text('Club Events', style: AppTextStyles.titleLarge),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Club's events list
              eventsAsync.when(
                data: (events) {
                  if (events.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No scheduled events for this club yet.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event = events[index];
                        return EventCard(
                          event: event,
                          onTap: () => context.push('/events/${event.id}'),
                        );
                      },
                      childCount: events.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: AppLoadingWidget(),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $e')),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          );
        },
        loading: () => const AppLoadingWidget(),
        error: (err, _) => AppErrorWidget(
          message: 'Error loading club details',
          details: err.toString(),
          onRetry: () => ref.invalidate(clubDetailProvider(widget.clubId)),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

