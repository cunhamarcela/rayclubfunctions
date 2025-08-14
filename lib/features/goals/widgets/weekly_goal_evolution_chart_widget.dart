import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/features/goals/viewmodels/weekly_goal_expanded_view_model.dart';

/// Widget para mostrar gráfico de evolução das metas semanais
class WeeklyGoalEvolutionChartWidget extends ConsumerWidget {
  const WeeklyGoalEvolutionChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalState = ref.watch(weeklyGoalExpandedViewModelProvider);
    
    if (goalState.allGoals.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Pegar as últimas 4 semanas
    final recentGoals = goalState.allGoals.take(4).toList();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Evolução das Metas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              Icon(
                Icons.trending_up,
                size: 20,
                color: Colors.grey[600],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Gráfico simples com barras
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: recentGoals.map((goal) => _buildBar(goal)).toList(),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Legenda
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: recentGoals.map((goal) => _buildLegend(goal)).toList(),
          ),
          
          const SizedBox(height: 8),
          
          // Resumo
          _buildSummary(recentGoals),
        ],
      ),
    );
  }

  Widget _buildBar(goal) {
    final height = (goal.percentageCompleted / 100 * 70).clamp(8.0, 70.0);
    final color = goal.percentageCompleted >= 100 
        ? Colors.green 
        : goal.percentageCompleted >= 70
            ? Colors.orange
            : Colors.grey;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${goal.percentageCompleted.round()}%',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                color,
                color.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(goal) {
    final weekNumber = _getWeekNumber(goal.weekStartDate);
    
    return Column(
      children: [
        Text(
          'Sem $weekNumber',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: goal.percentageCompleted >= 100 
                ? Colors.green 
                : goal.percentageCompleted >= 70
                    ? Colors.orange
                    : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(List recentGoals) {
    final completedGoals = recentGoals.where((g) => g.percentageCompleted >= 100).length;
    final averageProgress = recentGoals.fold(0.0, (sum, g) => sum + g.percentageCompleted) / recentGoals.length;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Concluídas',
            '$completedGoals/${recentGoals.length}',
            Icons.check_circle,
            Colors.green,
          ),
          _buildSummaryItem(
            'Média',
            '${averageProgress.round()}%',
            Icons.trending_up,
            Colors.blue,
          ),
          _buildSummaryItem(
            'Sequência',
            _calculateStreak(recentGoals).toString(),
            Icons.local_fire_department,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  int _getWeekNumber(DateTime date) {
    final currentWeek = DateTime.now();
    final difference = currentWeek.difference(date).inDays;
    final weeksAgo = (difference / 7).round();
    
    if (weeksAgo == 0) return 1; // Semana atual
    return weeksAgo + 1;
  }

  int _calculateStreak(List goals) {
    int streak = 0;
    for (final goal in goals.reversed) {
      if (goal.percentageCompleted >= 100) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}

/// Widget mini para mostrar apenas tendência
class WeeklyGoalTrendWidget extends ConsumerWidget {
  const WeeklyGoalTrendWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalState = ref.watch(weeklyGoalExpandedViewModelProvider);
    
    if (goalState.allGoals.length < 2) {
      return const SizedBox.shrink();
    }
    
    final currentGoal = goalState.allGoals.first;
    final previousGoal = goalState.allGoals[1];
    
    final trend = currentGoal.percentageCompleted - previousGoal.percentageCompleted;
    final isImproving = trend > 0;
    final isStable = trend.abs() < 5;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isImproving 
            ? Colors.green.withOpacity(0.1)
            : isStable
                ? Colors.blue.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isImproving 
                ? Icons.trending_up
                : isStable
                    ? Icons.trending_flat
                    : Icons.trending_down,
            size: 14,
            color: isImproving 
                ? Colors.green
                : isStable
                    ? Colors.blue
                    : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            isStable 
                ? 'Estável'
                : '${trend.abs().round()}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isImproving 
                  ? Colors.green
                  : isStable
                      ? Colors.blue
                      : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
} 