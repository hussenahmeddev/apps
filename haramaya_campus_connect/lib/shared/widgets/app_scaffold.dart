import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/features/notifications/presentation/providers/notification_provider.dart';

class AppScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    // Haptic feedback on tab switch
    HapticFeedback.lightImpact();
    navigationShell.goBranch(
      index,
      // If tapping the already-selected tab, pop to the initial location
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);
    final unreadCount = unreadCountAsync.value ?? 0;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      // Handle Android back button: if not on Home tab, go to Home first
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _onTap(0);
        }
      },
      child: Scaffold(
        body: navigationShell,
        extendBody: false,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              // Extra padding if system nav uses gesture (bottomPadding == 0)
              // to keep tap targets comfortable; otherwise SafeArea handles it
              padding: EdgeInsets.only(
                bottom: bottomPadding > 0 ? 0 : 4,
              ),
              child: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onTap,
                animationDuration: const Duration(milliseconds: 400),
                elevation: 0,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                indicatorColor: AppColors.primaryContainer,
                height: 68,
                labelBehavior:
                    NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.home_outlined, size: 24),
                    selectedIcon: Icon(Icons.home_rounded, size: 24),
                    label: 'Home',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.event_outlined, size: 24),
                    selectedIcon: Icon(Icons.event_rounded, size: 24),
                    label: 'Events',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.groups_outlined, size: 24),
                    selectedIcon: Icon(Icons.groups_rounded, size: 24),
                    label: 'Clubs',
                  ),
                  NavigationDestination(
                    icon: Badge(
                      isLabelVisible: unreadCount > 0,
                      label: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: AppColors.error,
                      textColor: AppColors.textOnDark,
                      child: const Icon(
                          Icons.notifications_outlined, size: 24),
                    ),
                    selectedIcon: Badge(
                      isLabelVisible: unreadCount > 0,
                      label: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: AppColors.error,
                      textColor: AppColors.textOnDark,
                      child: const Icon(
                          Icons.notifications_rounded, size: 24),
                    ),
                    label: 'Notifications',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded, size: 24),
                    selectedIcon: Icon(Icons.person_rounded, size: 24),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
