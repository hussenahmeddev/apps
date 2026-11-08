import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/features/events/domain/enums/event_category.dart';
import 'package:haramaya_campus_connect/features/events/presentation/providers/event_provider.dart';

class EventFilterBar extends ConsumerWidget {
  const EventFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(eventFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: currentFilter.category == null,
            onSelected: (_) {
              ref.read(eventFilterProvider.notifier).setCategory(null);
            },
            selectedColor: AppColors.primaryContainer,
            checkmarkColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          ...EventCategory.values.map((category) {
            final isSelected = currentFilter.category == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(
                  category.icon,
                  size: 16,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                label: Text(category.displayName),
                selected: isSelected,
                onSelected: (_) {
                  ref.read(eventFilterProvider.notifier).setCategory(category);
                },
                selectedColor: AppColors.primaryContainer,
                checkmarkColor: AppColors.primary,
              ),
            );
          }),
        ],
      ),
    );
  }
}

