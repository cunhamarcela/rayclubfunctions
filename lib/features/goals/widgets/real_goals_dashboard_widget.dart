import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/real_goals_providers.dart';
import '../models/real_backend_goal_models.dart';

/// **WIDGET REAL DO DASHBOARD DE METAS - RAY CLUB**
/// 
/// **Data:** 29 de Janeiro de 2025 às 18:50
/// **Objetivo:** Usar as estruturas REAIS que já existem no backend
/// **Referência:** Sistema com 8 tabelas e 26 funções SQL funcionais
/// 
/// IMPORTANTE: Este widget substitui implementações conflitantes e usa apenas o que FUNCIONA

class RealGoalsDashboardWidget extends ConsumerWidget {
  const RealGoalsDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header com estatísticas gerais
        _buildGoalsHeader(context, ref),
        
        const SizedBox(height: 16),
        
        // Metas por categoria (sistema que já funciona!)
        _buildCategoryGoalsSection(context, ref),
        
        const SizedBox(height: 16),
        
        // Metas semanais expandidas
        _buildWeeklyGoalsSection(context, ref),
        
        const SizedBox(height: 16),
        
        // Meta personalizada ativa
        _buildActiveGoalSection(context, ref),
        
        const SizedBox(height: 16),
        
        // Botões de ação
        _buildActionButtons(context, ref),
      ],
    );
  }

  /// Header com estatísticas gerais das metas
  Widget _buildGoalsHeader(BuildContext context, WidgetRef ref) {
    final categoryStatsAsync = ref.watch(categoryGoalsStatsProvider);
    final weeklyStatsAsync = ref.watch(weeklyGoalsStatsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.8), AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🎯 Suas Metas',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Semana Atual',
                  style: AppTypography.bodySmall.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              // Estatísticas de categoria
              Expanded(
                child: categoryStatsAsync.when(
                  data: (stats) => _buildStatCard(
                    '💪 Por Categoria',
                    '${stats.completedGoals}/${stats.totalGoals}',
                    '${stats.progressPercentage.toStringAsFixed(1)}%',
                    Colors.white,
                  ),
                  loading: () => _buildStatCardLoading(),
                  error: (_, __) => _buildStatCard('💪 Categoria', '0/0', '0%', Colors.white),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Estatísticas semanais
              Expanded(
                child: weeklyStatsAsync.when(
                  data: (stats) => _buildStatCard(
                    '📅 Semanais',
                    '${stats.completedGoals}/${stats.totalGoals}',
                    '${stats.overallProgress.toStringAsFixed(1)}%',
                    Colors.white,
                  ),
                  loading: () => _buildStatCardLoading(),
                  error: (_, __) => _buildStatCard('📅 Semanais', '0/0', '0%', Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Seção de metas por categoria (workout_category_goals)
  /// Esta é a tabela que JÁ FAZ a integração automática treino→meta!
  Widget _buildCategoryGoalsSection(BuildContext context, WidgetRef ref) {
    final categoryGoalsAsync = ref.watch(userCategoryGoalsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '💪 Metas por Categoria',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              'Atualização automática! ✨',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.success,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        categoryGoalsAsync.when(
          data: (goals) {
            if (goals.isEmpty) {
              return _buildEmptyState(
                '🎯 Nenhuma meta de categoria ainda',
                'Registre um treino e uma meta será criada automaticamente!',
              );
            }
            
            return Column(
              children: goals.map((goal) => _buildCategoryGoalCard(goal)).toList(),
            );
          },
          loading: () => _buildLoadingCard(),
          error: (error, _) => _buildErrorCard('Erro ao carregar metas de categoria: $error'),
        ),
      ],
    );
  }

  /// Card de meta de categoria
  Widget _buildCategoryGoalCard(WorkoutCategoryGoal goal) {
    final progress = goal.goalMinutes > 0 
        ? (goal.currentMinutes / goal.goalMinutes).clamp(0.0, 1.0)
        : 0.0;
    
    final categoryIcon = _getCategoryIcon(goal.category);
    final isCompleted = goal.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.success.withOpacity(0.1) : Colors.white,
        border: Border.all(
          color: isCompleted ? AppColors.success : AppColors.neutral200,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                categoryIcon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.category.toUpperCase(),
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? AppColors.success : null,
                      ),
                    ),
                    Text(
                      '${goal.currentMinutes}/${goal.goalMinutes} min',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                )
              else
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? AppColors.success : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Seção de metas semanais (weekly_goals_expanded)
  Widget _buildWeeklyGoalsSection(BuildContext context, WidgetRef ref) {
    final weeklyGoalsAsync = ref.watch(userWeeklyGoalsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📅 Metas Semanais',
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        weeklyGoalsAsync.when(
          data: (goals) {
            if (goals.isEmpty) {
              return _buildEmptyState(
                '📅 Nenhuma meta semanal criada',
                'Crie suas metas para a semana!',
              );
            }
            
            return Column(
              children: goals.map((goal) => _buildWeeklyGoalCard(goal)).toList(),
            );
          },
          loading: () => _buildLoadingCard(),
          error: (error, _) => _buildErrorCard('Erro ao carregar metas semanais: $error'),
        ),
      ],
    );
  }

  /// Card de meta semanal
  Widget _buildWeeklyGoalCard(WeeklyGoalExpanded goal) {
    final progress = goal.targetValue > 0 
        ? (goal.currentValue / goal.targetValue).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: goal.completed ? AppColors.success.withOpacity(0.1) : Colors.white,
        border: Border.all(
          color: goal.completed ? AppColors.success : AppColors.neutral200,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.goalTitle,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: goal.completed ? AppColors.success : null,
                  ),
                ),
              ),
              if (goal.completed)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                )
              else
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Text(
            '${goal.currentValue.toStringAsFixed(0)}/${goal.targetValue.toStringAsFixed(0)} ${goal.unitLabel}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(
              goal.completed ? AppColors.success : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Seção de meta personalizada ativa
  Widget _buildActiveGoalSection(BuildContext context, WidgetRef ref) {
    final activeGoalAsync = ref.watch(userActiveGoalProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⭐ Meta Personalizada',
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        activeGoalAsync.when(
          data: (goal) {
            if (goal == null) {
              return _buildEmptyState(
                '⭐ Nenhuma meta personalizada ativa',
                'Crie uma meta personalizada com check-ins!',
              );
            }
            
            return _buildPersonalizedGoalCard(goal);
          },
          loading: () => _buildLoadingCard(),
          error: (error, _) => _buildErrorCard('Erro ao carregar meta personalizada: $error'),
        ),
      ],
    );
  }

  /// Card de meta personalizada
  Widget _buildPersonalizedGoalCard(PersonalizedWeeklyGoal goal) {
    final progress = goal.targetValue > 0 
        ? (goal.currentProgress / goal.targetValue).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: goal.isCompleted ? AppColors.success.withOpacity(0.1) : Colors.white,
        border: Border.all(
          color: goal.isCompleted ? AppColors.success : AppColors.primary,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.goalTitle,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: goal.isCompleted ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
              if (goal.isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                )
              else
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          
          if (goal.goalDescription != null) ...[
            const SizedBox(height: 4),
            Text(
              goal.goalDescription!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
          
          const SizedBox(height: 4),
          
          Text(
            '${goal.currentProgress.toStringAsFixed(0)}/${goal.targetValue.toStringAsFixed(0)} ${goal.unitLabel}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(
              goal.isCompleted ? AppColors.success : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Botões de ação
  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showCreateCategoryGoalDialog(context, ref),
            icon: const Icon(Icons.add_circle),
            label: const Text('Meta por Categoria'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showCreateWeeklyGoalDialog(context, ref),
            icon: const Icon(Icons.calendar_today),
            label: const Text('Meta Semanal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Widgets auxiliares
  Widget _buildStatCard(String title, String value, String subtitle, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodySmall.copyWith(color: textColor.withOpacity(0.8)),
        ),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(color: textColor.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildStatCardLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        border: Border.all(color: AppColors.error),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        error,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.error,
        ),
      ),
    );
  }

  /// Helpers
  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cardio': return '🏃';
      case 'musculacao': return '💪';
      case 'funcional': return '⚡';
      case 'yoga': return '🧘';
      case 'pilates': return '🤸';
      case 'corrida': return '🏃‍♀️';
      case 'natacao': return '🏊';
      case 'ciclismo': return '🚴';
      case 'crossfit': return '🏋️';
      case 'danca': return '💃';
      case 'caminhada': return '🚶';
      case 'alongamento': return '🤏';
      default: return '🎯';
    }
  }

  /// Dialogs para criar metas
  void _showCreateCategoryGoalDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implementar dialog para criar meta de categoria
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Em breve: Criar meta por categoria')),
    );
  }

  void _showCreateWeeklyGoalDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implementar dialog para criar meta semanal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Em breve: Criar meta semanal')),
    );
  }
} 