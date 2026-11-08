import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:haramaya_campus_connect/features/admin/presentation/screens/create_announcement_screen.dart';
import 'package:haramaya_campus_connect/features/admin/presentation/screens/manage_users_screen.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/screens/login_screen.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/screens/register_screen.dart';
import 'package:haramaya_campus_connect/features/clubs/presentation/screens/club_detail_screen.dart';
import 'package:haramaya_campus_connect/features/clubs/presentation/screens/clubs_screen.dart';
import 'package:haramaya_campus_connect/features/clubs/presentation/screens/create_club_screen.dart';
import 'package:haramaya_campus_connect/features/events/presentation/screens/create_event_screen.dart';
import 'package:haramaya_campus_connect/features/events/presentation/screens/edit_event_screen.dart';
import 'package:haramaya_campus_connect/features/events/presentation/screens/event_detail_screen.dart';
import 'package:haramaya_campus_connect/features/events/presentation/screens/events_screen.dart';
import 'package:haramaya_campus_connect/features/home/presentation/screens/home_screen.dart';
import 'package:haramaya_campus_connect/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:haramaya_campus_connect/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:haramaya_campus_connect/features/profile/presentation/screens/profile_screen.dart';
import 'package:haramaya_campus_connect/features/profile/presentation/screens/user_registered_events_screen.dart';
import 'package:haramaya_campus_connect/shared/providers/firebase_providers.dart';
import 'package:haramaya_campus_connect/shared/widgets/app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorEventsKey = GlobalKey<NavigatorState>(debugLabel: 'events');
final _shellNavigatorClubsKey = GlobalKey<NavigatorState>(debugLabel: 'clubs');
final _shellNavigatorNotificationsKey =
    GlobalKey<NavigatorState>(debugLabel: 'notifications');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      // If user is not logged in and not on auth pages, go to login
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // If user is logged in and trying to go to auth pages, redirect to home
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // 5-Tab Bottom Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Home
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Tab 2: Events
          StatefulShellBranch(
            navigatorKey: _shellNavigatorEventsKey,
            routes: [
              GoRoute(
                path: '/events',
                builder: (context, state) => const EventsScreen(),
              ),
            ],
          ),

          // Tab 3: Clubs
          StatefulShellBranch(
            navigatorKey: _shellNavigatorClubsKey,
            routes: [
              GoRoute(
                path: '/clubs',
                builder: (context, state) => const ClubsScreen(),
              ),
            ],
          ),

          // Tab 4: Notifications
          StatefulShellBranch(
            navigatorKey: _shellNavigatorNotificationsKey,
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),

          // Tab 5: Profile
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Stacked Sub-routes (outside bottom nav)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/events/create',
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/events/edit/:id',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EditEventScreen(eventId: eventId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/events/:id',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EventDetailScreen(eventId: eventId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/clubs/create',
        builder: (context, state) => const CreateClubScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/clubs/:id',
        builder: (context, state) {
          final clubId = state.pathParameters['id']!;
          return ClubDetailScreen(clubId: clubId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/profile/events',
        builder: (context, state) => const UserRegisteredEventsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/profile/clubs',
        builder: (context, state) => const ClubsScreen(),
      ),

      // Admin routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/admin/users',
        builder: (context, state) => const ManageUsersScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/admin/announcements/create',
        builder: (context, state) => const CreateAnnouncementScreen(),
      ),
    ],
  );
});

