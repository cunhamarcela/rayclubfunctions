import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/features/goals/models/goal_period_filter.dart';
import 'package:ray_club_app/features/goals/viewmodels/weekly_goal_expanded_view_model.dart';

/// Widget para filtrar metas por período
class GoalPeriodFilterWidget extends ConsumerWidget {
  const GoalPeriodFilterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelState = ref.watch(weeklyGoalExpandedViewModelProvider);
    final viewModel = ref.read(weeklyGoalExpandedViewModelProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.filter_list_outlined,
            size: 20,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: GoalPeriodFilter.values.map((filter) {
                  final isSelected = viewModelState.currentFilter == filter;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        filter.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          viewModel.filterGoalsByPeriod(filter);
                        }
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: Theme.of(context).primaryColor,
                      checkmarkColor: Colors.white,
                      elevation: 0,
                      pressElevation: 1,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Contador de metas encontradas
          if (viewModelState.filteredGoals.isNotEmpty || viewModelState.currentWeekGoals.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_getDisplayGoalsCount(viewModelState)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _getDisplayGoalsCount(WeeklyGoalExpandedState state) {
    return state.currentFilter == GoalPeriodFilter.currentWeek 
        ? state.currentWeekGoals.length
        : state.filteredGoals.length;
  }
} 