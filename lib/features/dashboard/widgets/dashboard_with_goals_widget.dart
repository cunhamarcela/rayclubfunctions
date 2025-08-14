import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/features/goals/widgets/weekly_goal_progress_summary_widget.dart';

/// Exemplo de dashboard integrado com widgets de metas semanais
class DashboardWithGoalsWidget extends ConsumerWidget {
  const DashboardWithGoalsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do dashboard
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá! 👋',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Como está seu progresso hoje?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Widget principal de meta semanal
          const WeeklyGoalProgressSummaryWidget(),
          
          // Estatísticas rápidas
          const WeeklyGoalStatsWidget(),
          
          // Espaço para outros widgets do dashboard
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Atividades Recentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                // Aqui você pode adicionar outros widgets do dashboard
                _buildPlaceholderContent('Últimos treinos'),
                const SizedBox(height: 12),
                _buildPlaceholderContent('Conquistas'),
                const SizedBox(height: 12),
                _buildPlaceholderContent('Desafios ativos'),
              ],
            ),
          ),
          
          // Widget mini na parte inferior (opcional)
          const Text(
            '  Progresso Rápido',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const WeeklyGoalProgressMiniWidget(),
          
          const SizedBox(height: 80), // Espaço para bottom navigation
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent(String title) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.fitness_center, color: Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
        ],
      ),
    );
  }
}

/// Versão compacta para integrar em dashboards existentes
class CompactGoalProgressWidget extends ConsumerWidget {
  const CompactGoalProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const WeeklyGoalProgressSummaryWidget(),
        const WeeklyGoalStatsWidget(),
      ],
    );
  }
}

/// Versão apenas com estatísticas para headers de dashboard
class QuickGoalStatsWidget extends ConsumerWidget {
  const QuickGoalStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const WeeklyGoalStatsWidget();
  }
} 