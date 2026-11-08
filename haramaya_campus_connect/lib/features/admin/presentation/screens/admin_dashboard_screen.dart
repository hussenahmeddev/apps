import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/theme/app_text_styles.dart';
import 'package:haramaya_campus_connect/core/widgets/error_widget.dart';
import 'package:haramaya_campus_connect/core/widgets/loading_widget.dart';
import 'package:haramaya_campus_connect/features/admin/presentation/providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(adminStatsProvider);
        },
        child: statsAsync.when(
          data: (stats) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Overview',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${stats.totalUsers} Total Users',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats Cards Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.3,
                    children: [
                      _buildStatCard(
                        'Total Students',
                        '${stats.totalStudents}',
                        Icons.school_rounded,
                        AppColors.primary,
                      ),
                      _buildStatCard(
                        'Active Events',
                        '${stats.totalEvents}',
                        Icons.event_note_rounded,
                        AppColors.categorySports,
                      ),
                      _buildStatCard(
                        'Registered Clubs',
                        '${stats.totalClubs}',
                        Icons.groups_rounded,
                        AppColors.categoryCultural,
                      ),
                      _buildStatCard(
                        'Registrations',
                        '${stats.totalRegistrations}',
                        Icons.how_to_reg_rounded,
                        AppColors.info,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Role Breakdown Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildRoleCountChip('Students', stats.totalStudents, AppColors.primary),
                        Container(height: 28, width: 1, color: AppColors.divider),
                        _buildRoleCountChip('Organizers', stats.totalOrganizers, AppColors.categoryCultural),
                        Container(height: 28, width: 1, color: AppColors.divider),
                        _buildRoleCountChip('Admins', stats.totalAdmins, AppColors.error),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Management Actions
                  const Text(
                    'Management Actions',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 12),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.manage_accounts_rounded,
                          color: AppColors.primary,
                        ),
                        title: const Text('Manage User Roles'),
                        subtitle: const Text('Promote organizers, view students'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () => context.push('/admin/users'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.campaign_rounded,
                          color: AppColors.error,
                        ),
                        title: const Text('Broadcast Announcement'),
                        subtitle: const Text('Publish urgent alerts to all students'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () => context.push('/admin/announcements/create'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.secondary,
                        ),
                        title: const Text('Create University Event'),
                        subtitle: const Text('Post official institution events'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () => context.push('/events/create'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.group_add_rounded,
                          color: AppColors.primary,
                        ),
                        title: const Text('Register New Club'),
                        subtitle: const Text('Found a student club or society'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () => context.push('/clubs/create'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const AppLoadingWidget(),
        error: (e, _) => AppErrorWidget(
          message: 'Failed to load admin stats',
          details: e.toString(),
          onRetry: () => ref.invalidate(adminStatsProvider),
        ),
      ),
    ),
  );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                title,
                style: AppTextStyles.caption.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCountChip(String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

