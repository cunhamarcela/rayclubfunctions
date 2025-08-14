import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/preset_category_goals.dart';
import '../models/real_backend_goal_models.dart';
import '../providers/real_goals_providers.dart';
import 'preset_goals_modal.dart';
import '../../dashboard/widgets/enhanced_dashboard_widget.dart';

export 'preset_goals_dashboard.dart';
export 'preset_goals_modal.dart';

/// Dashboard principal para exibir e gerenciar metas por categoria
class PresetGoalsDashboard extends ConsumerWidget {
  const PresetGoalsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(userCategoryGoalsProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.track_changes,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Metas Semanais ✨',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Progresso atualizado automaticamente',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showCreateGoalModal(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Content
            goalsAsync.when(
              data: (goals) => _buildGoalsContent(context, goals),
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(context, error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsContent(BuildContext context, List<WorkoutCategoryGoal> goals) {
    if (goals.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Metas ativas
        ...goals.map((goal) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildGoalCard(context, goal),
        )),
        
        // Botão para adicionar mais metas
        const SizedBox(height: 8),
        _buildAddMoreButton(context),
      ],
    );
  }

  Widget _buildGoalCard(BuildContext context, WorkoutCategoryGoal goal) {
    final preset = PresetCategoryGoal.getByCategory(goal.category);
    final progress = goal.percentageCompleted / 100;
    final isCompleted = goal.completed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: preset?.lightColor ?? Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: preset?.color.withOpacity(0.3) ?? Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          // Header do card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: preset?.color ?? AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  preset?.emoji ?? '⭐',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset?.displayName ?? goal.category,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: preset?.color ?? AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${goal.currentMinutes} / ${goal.goalMinutes} min',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge de completado
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Completa! 🎉',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Barra de progresso
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}% completo',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: preset?.color ?? AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    preset?.formatMinutes(goal.goalMinutes - goal.currentMinutes) ?? '',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    preset?.color ?? AppColors.primary,
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
          
          // Mensagem motivacional
          if (preset != null) ...[
            const SizedBox(height: 12),
            Text(
              _getMotivationalMessage(progress, preset),
              style: AppTypography.bodySmall.copyWith(
                color: preset.color,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.track_changes,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Comece definindo suas metas! 🎯',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha atividades que você gosta e defina objetivos semanais realistas.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCreateGoalModal(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Criar Primeira Meta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildPresetPreview(),
      ],
    );
  }

  Widget _buildPresetPreview() {
    final presets = PresetCategoryGoal.allPresets.take(6).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metas Disponíveis:',
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((preset) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: preset.lightColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: preset.color.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(preset.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  preset.displayName,
                  style: AppTypography.bodySmall.copyWith(
                    color: preset.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildAddMoreButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          style: BorderStyle.solid,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton.icon(
        onPressed: () => _showCreateGoalModal(context),
        icon: Icon(
          Icons.add,
          color: AppColors.primary,
          size: 20,
        ),
        label: Text(
          'Adicionar Nova Meta',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Erro ao carregar metas',
            style: AppTypography.titleSmall.copyWith(
              color: Colors.red.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error.toString(),
            style: AppTypography.bodySmall.copyWith(
              color: Colors.red.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _showCreateGoalModal(context),
            child: Text(
              'Tentar Novamente',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage(double progress, PresetCategoryGoal preset) {
    if (progress >= 1.0) {
      return 'Parabéns! Meta atingida! 🎉';
    } else if (progress >= 0.8) {
      return 'Quase lá! Você consegue! 💪';
    } else if (progress >= 0.5) {
      return 'Metade do caminho feito! 🔥';
    } else if (progress >= 0.25) {
      return 'Bom começo! Continue assim! ✨';
    } else {
      return preset.motivationalText;
    }
  }

  Future<void> _showCreateGoalModal(BuildContext context) async {
    final result = await PresetGoalsModal.show(context);
    if (result == true) {
      // Meta criada com sucesso - o provider será atualizado automaticamente
    }
  }
} 