// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../create_goal_screen.dart';

/// **SELETOR DE TIPO DE META**
/// 
/// Widget que permite ao usuário escolher entre:
/// 1. Meta pré-definida (da lista de exercícios)
/// 2. Meta personalizada (título livre)
class GoalTypeSelector extends StatelessWidget {
  final GoalCreationType selectedType;
  final ValueChanged<GoalCreationType> onTypeChanged;

  const GoalTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de meta',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                type: GoalCreationType.predefined,
                icon: Icons.fitness_center,
                title: 'Lista de Exercícios',
                subtitle: 'Escolha da lista existente',
                isSelected: selectedType == GoalCreationType.predefined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeOption(
                type: GoalCreationType.custom,
                icon: Icons.edit,
                title: 'Meta Personalizada',
                subtitle: 'Escreva seu próprio título',
                isSelected: selectedType == GoalCreationType.custom,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeOption({
    required GoalCreationType type,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary
                : AppColors.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected 
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? AppColors.primary
                    : AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

