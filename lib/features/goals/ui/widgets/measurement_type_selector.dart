// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../create_goal_screen.dart';

/// **SELETOR DE TIPO DE MEDIÇÃO**
/// 
/// Widget que permite escolher entre:
/// 1. Minutos (progresso numérico contínuo)
/// 2. Dias (check-ins, bolinhas de marcar)
class MeasurementTypeSelector extends StatelessWidget {
  final MeasurementType selectedType;
  final ValueChanged<MeasurementType> onTypeChanged;

  const MeasurementTypeSelector({
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
          'Como medir o progresso',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMeasurementOption(
                type: MeasurementType.minutes,
                icon: Icons.timer,
                title: 'Por Minutos',
                subtitle: 'Ex: 150 min/semana',
                description: 'Progresso contínuo em minutos',
                isSelected: selectedType == MeasurementType.minutes,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMeasurementOption(
                type: MeasurementType.days,
                icon: Icons.check_circle_outline,
                title: 'Por Dias',
                subtitle: 'Ex: 5 dias/semana',
                description: 'Check-ins diários (bolinhas)',
                isSelected: selectedType == MeasurementType.days,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeasurementOption({
    required MeasurementType type,
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone e título
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected 
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? AppColors.primary
                          : AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            
            // Description
            Text(
              description,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            
            // Visual indicator
            const SizedBox(height: 12),
            _buildVisualIndicator(type, isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualIndicator(MeasurementType type, bool isSelected) {
    if (type == MeasurementType.minutes) {
      // Barra de progresso para minutos
      return Container(
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.outline.withOpacity(0.2),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: 0.6,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isSelected 
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
        ),
      );
    } else {
      // Bolinhas para dias
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (index) {
          final isCompleted = index < 3; // Exemplo: 3 de 5 dias
          return Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted 
                  ? (isSelected 
                      ? AppColors.primary 
                      : AppColors.onSurfaceVariant.withOpacity(0.5))
                  : AppColors.outline.withOpacity(0.2),
              border: !isCompleted ? Border.all(
                color: isSelected 
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.outline.withOpacity(0.3),
              ) : null,
            ),
            child: isCompleted 
                ? Icon(
                    Icons.check,
                    size: 10,
                    color: AppColors.onPrimary,
                  )
                : null,
          );
        }),
      );
    }
  }
}

