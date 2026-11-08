import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/theme/app_text_styles.dart';
import 'package:haramaya_campus_connect/core/widgets/cached_image.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:haramaya_campus_connect/features/clubs/presentation/providers/club_provider.dart';
import 'package:haramaya_campus_connect/features/events/presentation/providers/event_provider.dart';
import 'package:haramaya_campus_connect/features/profile/presentation/widgets/profile_stats.dart';
import 'package:haramaya_campus_connect/features/profile/presentation/widgets/settings_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserModelProvider);
    final userClubsAsync = ref.watch(userJoinedClubsProvider);
    final userRegistrationsAsync = ref.watch(userRegistrationsStreamProvider);

    final clubsCount = userClubsAsync.value?.length ?? 0;
    final eventsCount = userRegistrationsAsync.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Profile Header
            Center(
              child: Column(
                children: [
                  CachedAvatar(
                    imageUrl: user?.photoUrl,
                    name: user?.fullName ?? 'U',
                    radius: 46,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.fullName ?? 'Haramaya Student',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      user?.role.displayName.toUpperCase() ?? 'STUDENT',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Stats
            ProfileStats(
              clubsCount: clubsCount,
              eventsCount: eventsCount,
              studyYear: user?.year ?? 1,
            ),
            const SizedBox(height: 24),

            // Student Details Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Academic Information',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Student ID',
                    user?.studentId ?? 'Not specified',
                  ),
                  const Divider(height: 16),
                  _buildDetailRow(
                    'Department',
                    user?.department ?? 'Not specified',
                  ),
                  if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                    const Divider(height: 16),
                    _buildDetailRow('Phone', user.phone!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Menu Options
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.event_available_rounded,
                    title: 'My Registered Events',
                    subtitle: '$eventsCount upcoming events',
                    onTap: () => context.push('/profile/events'),
                  ),
                  const Divider(height: 1, indent: 56),
                  SettingsTile(
                    icon: Icons.groups_rounded,
                    title: 'My Clubs',
                    subtitle: '$clubsCount active memberships',
                    onTap: () => context.push('/profile/clubs'),
                  ),

                  // Admin Dashboard access for Admin role
                  if (user?.role.isAdmin ?? false) ...[
                    const Divider(height: 1, indent: 56),
                    SettingsTile(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Admin Management Panel',
                      subtitle: 'User roles, announcements & stats',
                      iconColor: AppColors.categoryCultural,
                      onTap: () => context.push('/admin/dashboard'),
                    ),
                  ],

                  const Divider(height: 1, indent: 56),
                  SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About App',
                    subtitle: 'Version 1.0.0 (Production)',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Haramaya Campus Connect',
                        applicationVersion: '1.0.0',
                        applicationLegalese:
                            '© 2026 Haramaya University. All rights reserved.',
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  SettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    iconColor: AppColors.error,
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text(
                            'Are you sure you want to sign out of your account?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await ref.read(authNotifierProvider.notifier).signOut();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

