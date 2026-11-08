import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/widgets/empty_state_widget.dart';
import 'package:haramaya_campus_connect/core/widgets/error_widget.dart';
import 'package:haramaya_campus_connect/core/widgets/loading_widget.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:haramaya_campus_connect/features/clubs/presentation/providers/club_provider.dart';
import 'package:haramaya_campus_connect/features/clubs/presentation/widgets/club_card.dart';

class ClubsScreen extends ConsumerWidget {
  const ClubsScreen({super.key});

  static const List<String> categories = [
    'All',
    'Academic',
    'Technology',
    'Sports',
    'Arts & Culture',
    'Social & Charity',
    'Environmental',
    'Innovation',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(clubsStreamProvider);
    final filter = ref.watch(clubFilterProvider);
    final user = ref.watch(currentUserModelProvider);
    final canCreate = user?.role.isOrganizer ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Clubs & Societies'),
      ),
      floatingActionButton: canCreate
          ? Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FloatingActionButton.extended(
                onPressed: () => context.push('/clubs/create'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('New Club'),
              ),
            )
          : null,
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search clubs...',
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
                ref.read(clubFilterProvider.notifier).setSearch(val);
              },
            ),
          ),

          // Categories Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: categories.map((cat) {
                final isSelected = filter.category == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(clubFilterProvider.notifier).setCategory(cat);
                    },
                    selectedColor: AppColors.primaryContainer,
                    checkmarkColor: AppColors.primary,
                  ),
                );
              }).toList(),
            ),
          ),

          // Clubs Grid
          Expanded(
            child: clubsAsync.when(
              data: (clubs) {
                if (clubs.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.groups_outlined,
                    title: 'No Clubs Found',
                    subtitle: 'Try a different search query or category.',
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(clubsStreamProvider);
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: clubs.length,
                    itemBuilder: (context, index) {
                      final club = clubs[index];
                      return ClubCard(
                        club: club,
                        onTap: () => context.push('/clubs/${club.id}'),
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
                      ref.invalidate(clubsStreamProvider);
                    });
                  });
                  return const AppLoadingWidget();
                }
                return AppErrorWidget(
                  message: 'Failed to load clubs',
                  details: err.toString(),
                  onRetry: () => ref.invalidate(clubsStreamProvider),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

