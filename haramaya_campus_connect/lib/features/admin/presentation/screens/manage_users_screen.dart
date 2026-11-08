import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/utils/snackbar_utils.dart';
import 'package:haramaya_campus_connect/core/widgets/cached_image.dart';
import 'package:haramaya_campus_connect/core/widgets/empty_state_widget.dart';
import 'package:haramaya_campus_connect/core/widgets/error_widget.dart';
import 'package:haramaya_campus_connect/core/widgets/loading_widget.dart';
import 'package:haramaya_campus_connect/features/admin/presentation/providers/admin_provider.dart';
import 'package:haramaya_campus_connect/features/auth/domain/enums/user_role.dart';
import 'package:haramaya_campus_connect/features/auth/domain/models/user_model.dart';

class ManageUsersScreen extends ConsumerWidget {
  const ManageUsersScreen({super.key});

  void _showRoleDialog(BuildContext context, WidgetRef ref, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Change Role: ${user.fullName}'),
        content: RadioGroup<UserRole>(
          groupValue: user.role,
          onChanged: (newRole) async {
            Navigator.pop(ctx);
            if (newRole != null && newRole != user.role) {
              try {
                await ref
                    .read(adminActionProvider)
                    .updateUserRole(uid: user.uid, newRole: newRole);
                ref.invalidate(adminStatsProvider);
                if (context.mounted) {
                  SnackBarUtils.showSuccess(
                    context,
                    'Updated role to ${newRole.displayName}',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  SnackBarUtils.showError(context, e.toString());
                }
              }
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: UserRole.values.map((role) {
              return RadioListTile<UserRole>(
                title: Text(role.displayName),
                value: role,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.person_off_rounded,
              title: 'No Users Found',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = users[index];

              return Card(
                child: ListTile(
                  leading: CachedAvatar(
                    imageUrl: user.photoUrl,
                    name: user.fullName,
                    radius: 22,
                  ),
                  title: Text(
                    user.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${user.email} • ${user.department ?? "General"}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: user.role.isAdmin
                          ? AppColors.errorContainer
                          : user.role.isOrganizer
                              ? AppColors.tertiaryContainer
                              : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.role.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: user.role.isAdmin
                            ? AppColors.error
                            : user.role.isOrganizer
                                ? AppColors.warning
                                : AppColors.primary,
                      ),
                    ),
                  ),
                  onTap: () => _showRoleDialog(context, ref, user),
                ),
              );
            },
          );
        },
        loading: () => const AppLoadingWidget(),
        error: (err, _) => AppErrorWidget(
          message: 'Error loading users',
          details: err.toString(),
        ),
      ),
    );
  }
}

