import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/recipe_filter.dart';
import '../viewmodels/recipe_filter_view_model.dart';

/// Widget principal de filtros de receitas
class RecipeFilterWidget extends ConsumerWidget {
  const RecipeFilterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(recipeFilterProvider);
    final filterViewModel = ref.read(recipeFilterProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com título e limpar filtros
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (filterViewModel.hasSelectedFilters)
                TextButton(
                  onPressed: () => filterViewModel.clearAllFilters(),
                  child: Text(
                    'Limpar todos',
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Resumo dos filtros selecionados
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: filterViewModel.hasSelectedFilters 
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: filterViewModel.hasSelectedFilters 
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.textLight.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              filterViewModel.getSelectedFiltersText(),
              style: AppTextStyles.smallText.copyWith(
                color: filterViewModel.hasSelectedFilters 
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: filterViewModel.hasSelectedFilters 
                    ? FontWeight.w600 
                    : FontWeight.normal,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Categorias de filtros
          if (filterState.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            _buildFilterCategories(context, ref, filterViewModel),
          
          const SizedBox(height: 24),
          
          // Botões de ação
          _buildActionButtons(context, ref, filterViewModel),
        ],
      ),
    );
  }

  Widget _buildFilterCategories(BuildContext context, WidgetRef ref, RecipeFilterViewModel viewModel) {
    return Column(
      children: RecipeFilterCategory.values.map((category) {
        final filtersInCategory = viewModel.getFiltersByCategory(category);
        final selectedCount = viewModel.getSelectedCountByCategory(category);
        
        if (filtersInCategory.isEmpty) return const SizedBox.shrink();
        
        return _buildFilterCategory(
          context,
          ref,
          category,
          filtersInCategory,
          selectedCount,
          viewModel,
        );
      }).toList(),
    );
  }

  Widget _buildFilterCategory(
    BuildContext context,
    WidgetRef ref,
    RecipeFilterCategory category,
    List<RecipeFilter> filters,
    int selectedCount,
    RecipeFilterViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textLight.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        leading: Text(
          BrunaRecipeFilters.getCategoryIcon(category),
          style: const TextStyle(fontSize: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                BrunaRecipeFilters.getCategoryDisplayName(category),
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (selectedCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$selectedCount',
                  style: AppTextStyles.chipText.copyWith(
                    color: AppColors.surface,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filters.map((filter) {
              final filterCounts = ref.watch(filterCountsProvider);
              final count = filterCounts[filter.id] ?? 0;
              
              return _buildFilterChip(
                filter,
                count,
                () => viewModel.toggleFilter(filter.id),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterChip(RecipeFilter filter, int count, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: filter.isSelected 
              ? AppColors.primary 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: filter.isSelected 
                ? AppColors.primary 
                : AppColors.textLight.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filter.name,
              style: AppTextStyles.chipText.copyWith(
                color: filter.isSelected 
                    ? AppColors.surface 
                    : AppColors.textDark,
                fontWeight: filter.isSelected 
                    ? FontWeight.w600 
                    : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Text(
                '($count)',
                style: AppTextStyles.chipText.copyWith(
                  color: filter.isSelected 
                      ? AppColors.surface.withOpacity(0.8)
                      : AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Botões de ação (Aplicar e Fechar)
  Widget _buildActionButtons(BuildContext context, WidgetRef ref, RecipeFilterViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Botão Limpar (se tiver filtros selecionados)
          if (viewModel.hasSelectedFilters) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => viewModel.clearAllFilters(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Limpar',
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          
          // Botão Aplicar/Fechar
          Expanded(
            flex: viewModel.hasSelectedFilters ? 2 : 1,
            child: ElevatedButton(
              onPressed: () {
                // Aplicar filtros (já aplicam automaticamente via provider)
                Navigator.of(context).pop();
                
                // Feedback visual
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      viewModel.hasSelectedFilters 
                          ? 'Filtros aplicados! ✨'
                          : 'Exibindo todas as receitas',
                      style: AppTextStyles.smallText.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                viewModel.hasSelectedFilters ? 'Aplicar Filtros' : 'Fechar',
                style: AppTextStyles.buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet com filtros expandidos
class RecipeFilterBottomSheet extends ConsumerWidget {
  const RecipeFilterBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: const RecipeFilterWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const RecipeFilterWidget();
  }
}

/// Widget compacto para mostrar filtros selecionados
class CompactFilterDisplay extends ConsumerWidget {
  const CompactFilterDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterViewModel = ref.read(recipeFilterProvider.notifier);
    
    return GestureDetector(
      onTap: () => RecipeFilterBottomSheet.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filterViewModel.hasSelectedFilters 
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.textLight.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.filter_list,
              color: filterViewModel.hasSelectedFilters 
                  ? AppColors.primary 
                  : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                filterViewModel.getSelectedFiltersText(),
                style: AppTextStyles.cardSubtitle.copyWith(
                  color: filterViewModel.hasSelectedFilters 
                      ? AppColors.primary 
                      : AppColors.textSecondary,
                  fontWeight: filterViewModel.hasSelectedFilters 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.expand_more,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
} 