// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_typography.dart';
import 'package:ray_club_app/features/workout/models/workout_model.dart';
import 'package:ray_club_app/features/workout/viewmodels/states/workout_state.dart';

class WorkoutFilterBar extends StatelessWidget {
  final List<String> categories;
  final WorkoutFilter currentFilter;
  final Function(String) onCategorySelected;
  final Function(int) onDurationSelected;
  final Function(String) onDifficultySelected;
  final VoidCallback onResetFilters;

  const WorkoutFilterBar({
    Key? key,
    required this.categories,
    required this.currentFilter,
    required this.onCategorySelected,
    required this.onDurationSelected,
    required this.onDifficultySelected,
    required this.onResetFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterTitle(context),
          _buildCategoryFilter(context),
          _buildDurationFilter(context),
          _buildDifficultyFilter(context),
          _buildResetButton(context),
        ],
      ),
    );
  }

  Widget _buildFilterTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            'Filtros',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (currentFilter != const WorkoutFilter())
            InkWell(
              onTap: onResetFilters,
              child: Text(
                'Limpar',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    // Adicionar "Todos" como primeira opção
    final allCategories = ['Todos', ...categories];
    
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isSelected = index == 0 
              ? currentFilter.category.isEmpty 
              : currentFilter.category.toLowerCase() == category.toLowerCase();
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: isSelected,
              label: Text(category),
              labelStyle: AppTypography.bodySmall.copyWith(
                color: isSelected ? AppColors.white : AppColors.textLight,
              ),
              backgroundColor: AppColors.backgroundMedium,
              selectedColor: AppColors.primary,
              onSelected: (selected) {
                onCategorySelected(index == 0 ? '' : category);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDurationFilter(BuildContext context) {
    // Opções de duração em minutos
    final durationOptions = [0, 15, 30, 45, 60, 90];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'Duração',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: durationOptions.length,
            itemBuilder: (context, index) {
              final duration = durationOptions[index];
              final isSelected = currentFilter.maxDuration == duration;
              final label = duration == 0 
                ? 'Todos' 
                : duration == 90 
                  ? '90+ min' 
                  : '$duration min';
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(label),
                  labelStyle: AppTypography.bodySmall.copyWith(
                    color: isSelected ? AppColors.white : AppColors.textLight,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: AppColors.backgroundMedium,
                  selectedColor: AppColors.primary,
                  onSelected: (selected) {
                    onDurationSelected(duration);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyFilter(BuildContext context) {
    return const SizedBox.shrink(); // Removido filtro de dificuldade
  }

  Widget _buildResetButton(BuildContext context) {
    if (currentFilter == const WorkoutFilter()) {
      return const SizedBox(height: 8);
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onResetFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            'Limpar todos os filtros',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
          ),
        ),
      ),
    );
  }
} 
