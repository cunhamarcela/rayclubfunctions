import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/unified_goal_model.dart';
import '../providers/unified_goal_providers.dart';
import 'preset_goal_creator.dart';

/// **WIDGET UNIFICADO DE METAS PARA O DASHBOARD**
/// 
/// **Data:** 29 de Janeiro de 2025 às 17:00
/// **Objetivo:** Exibir e gerenciar metas no dashboard principal
/// **Referência:** Sistema de metas unificado Ray Club

class UnifiedGoalsDashboardWidget extends ConsumerWidget {
  const UnifiedGoalsDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGoalsAsync = ref.watch(activeGoalsProvider);
    final goalStatsAsync = ref.watch(goalStatsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com estatísticas
          _buildHeader(goalStatsAsync),
          
          const SizedBox(height: 20),
          
          // Lista de metas ativas
          activeGoalsAsync.when(
            data: (goals) => _buildGoalsList(context, ref, goals),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(error),
          ),
          
          const SizedBox(height: 16),
          
          // Botão para criar nova meta
          _buildCreateGoalSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(AsyncValue<Map<String, dynamic>> statsAsync) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.track_changes,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suas Metas ✨',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              
              statsAsync.when(
                data: (stats) => Text(
                  '${stats['active']} ativas • ${(stats['completion_rate'] * 100).toInt()}% concluídas',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                loading: () => Text(
                  'Carregando estatísticas...',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                error: (_, __) => Text(
                  'Suas metas pessoais',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsList(BuildContext context, WidgetRef ref, List<UnifiedGoal> goals) {
    if (goals.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: goals.take(3).map((goal) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildGoalCard(context, ref, goal),
      )).toList(),
    );
  }

  Widget _buildGoalCard(BuildContext context, WidgetRef ref, UnifiedGoal goal) {
    final progress = goal.progressPercentage;
    final isCompleted = goal.isCompleted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: goal.displayColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: goal.displayColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do card
          Row(
            children: [
              Text(
                goal.displayEmoji,
                style: const TextStyle(fontSize: 20),
              ),
              
              const SizedBox(width: 8),
              
              Expanded(
                child: Text(
                  goal.title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: goal.displayColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Concluída!',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Progresso
          Row(
            children: [
              Expanded(
                child: Text(
                  '${goal.currentValue.toInt()}/${goal.targetValue.toInt()} ${goal.unit.shortLabel}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTypography.bodySmall.copyWith(
                  color: goal.displayColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Barra de progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: goal.displayColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(goal.displayColor),
              minHeight: 6,
            ),
          ),
          
          // Botões de ação (se necessário)
          if (!isCompleted && goal.type == UnifiedGoalType.dailyHabit)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildGoalActions(ref, goal),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalActions(WidgetRef ref, UnifiedGoal goal) {
    return Row(
      children: [
        const Spacer(),
        TextButton.icon(
          onPressed: () => _incrementGoalProgress(ref, goal),
          icon: Icon(Icons.add_circle_outline, size: 16, color: goal.displayColor),
          label: Text(
            'Marcar Progresso',
            style: AppTypography.labelSmall.copyWith(
              color: goal.displayColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Future<void> _incrementGoalProgress(WidgetRef ref, UnifiedGoal goal) async {
    try {
      final incrementProgress = ref.read(incrementGoalProgressProvider);
      await incrementProgress(goal.id, 1.0);
    } catch (e) {
      // Error handling seria feito aqui
      debugPrint('Erro ao incrementar progresso: $e');
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.track_changes,
            size: 32,
            color: AppColors.onSurfaceVariant,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Nenhuma meta ativa',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            'Que tal criar sua primeira meta?',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(2, (index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Erro ao carregar metas',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateGoalSection(BuildContext context) {
    return Column(
      children: [
        Divider(color: AppColors.outline.withOpacity(0.2)),
        const SizedBox(height: 16),
        
        // Botão principal para criar meta
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showCreateGoalModal(context),
            icon: Icon(Icons.add, color: AppColors.primary),
            label: Text(
              'Criar Nova Meta',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateGoalModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: PresetGoalCreator(),
        ),
      ),
    );
  }
} 