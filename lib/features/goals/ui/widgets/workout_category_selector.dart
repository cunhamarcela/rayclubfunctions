// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../models/unified_goal_model.dart';

/// **SELETOR DE CATEGORIA DE EXERCÍCIO**
/// 
/// Lista exatamente igual à tela de registro de exercício,
/// mostrando as mesmas opções que estão no WorkoutRecordViewModel
class WorkoutCategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const WorkoutCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modalidade de exercício',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Escolha uma modalidade da lista. Seus treinos desta modalidade atualizarão automaticamente esta meta.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        _buildCategoryList(),
      ],
    );
  }

  Widget _buildCategoryList() {
    // Lista exatamente igual ao WorkoutRecordViewModel
    final categories = GoalCategory.workoutTypes;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
      ),
      child: Column(
        children: categories.map((category) {
          final isSelected = selectedCategory == category;
          final isLast = categories.last == category;
          
          return _buildCategoryTile(
            category: category,
            isSelected: isSelected,
            isLast: isLast,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryTile({
    required String category,
    required bool isSelected,
    required bool isLast,
  }) {
    return GestureDetector(
      onTap: () => onCategorySelected(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          border: !isLast 
              ? Border(
                  bottom: BorderSide(
                    color: AppColors.outline.withOpacity(0.2),
                    width: 1,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            // Ícone da categoria
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(category),
                color: isSelected 
                    ? AppColors.onPrimary
                    : AppColors.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            
            // Nome da categoria
            Expanded(
              child: Text(
                category,
                style: AppTypography.bodyLarge.copyWith(
                  color: isSelected 
                      ? AppColors.primary
                      : AppColors.onSurface,
                  fontWeight: isSelected 
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            
            // Indicador de seleção
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  /// Retorna ícone específico para cada categoria
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Funcional':
        return Icons.sports_gymnastics;
      case 'Musculação':
        return Icons.fitness_center;
      case 'Pilates':
        return Icons.self_improvement;
      case 'Força':
        return Icons.sports_kabaddi;
      case 'Alongamento':
        return Icons.accessibility_new;
      case 'Corrida':
        return Icons.directions_run;
      case 'Fisioterapia':
        return Icons.healing;
      case 'Outro':
        return Icons.more_horiz;
      default:
        return Icons.fitness_center;
    }
  }
}

