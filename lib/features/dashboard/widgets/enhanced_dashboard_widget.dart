// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/widgets/charts/weekly_evolution_chart.dart';
import 'package:ray_club_app/features/goals/models/workout_category_goal.dart';
import 'package:ray_club_app/features/goals/repositories/workout_category_goals_repository.dart';
import 'package:ray_club_app/features/goals/widgets/set_category_goal_modal.dart';

/// Provider para as metas por categoria do usuário
final workoutCategoryGoalsProvider = FutureProvider<List<WorkoutCategoryGoal>>((ref) async {
  final repository = ref.watch(workoutCategoryGoalsRepositoryProvider);
  return repository.getUserCategoryGoals();
});

/// Widget principal que exibe o dashboard aprimorado com gráficos e metas
class EnhancedDashboardWidget extends ConsumerWidget {
  const EnhancedDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildCategoryGoalsSection(context, ref),
          const SizedBox(height: 24),
          _buildChartsSection(context, ref),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metas e Evolução',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4D4D4D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Acompanhe suas metas semanais e veja sua evolução! 📈',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGoalsSection(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(workoutCategoryGoalsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Metas da Semana',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4D4D4D),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showSetGoalModal(context),
              icon: const Icon(
                Icons.add,
                size: 18,
                color: Color(0xFF2196F3),
              ),
              label: const Text(
                'Nova Meta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        goalsAsync.when(
          data: (goals) => _buildGoalsList(context, goals),
          loading: () => _buildGoalsLoading(),
          error: (error, stackTrace) => _buildGoalsError(context, error),
        ),
      ],
    );
  }

  Widget _buildGoalsList(BuildContext context, List<WorkoutCategoryGoal> goals) {
    if (goals.isEmpty) {
      return _buildEmptyGoalsState(context);
    }

    return Column(
      children: goals.map((goal) => _buildGoalCard(context, goal)).toList(),
    );
  }

  Widget _buildGoalCard(BuildContext context, WorkoutCategoryGoal goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goal.isCompleted 
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : Colors.grey.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                goal.categoryDisplayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4D4D4D),
                ),
              ),
              const Spacer(),
              if (goal.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Atingida! 🎉',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
              IconButton(
                onPressed: () => _showSetGoalModal(context, goal: goal),
                icon: const Icon(
                  Icons.edit,
                  size: 20,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de progresso
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: goal.progressValue,
              child: Container(
                decoration: BoxDecoration(
                  color: goal.isCompleted 
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${goal.currentMinutesDisplay} / ${goal.goalMinutesDisplay}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4D4D4D),
                ),
              ),
              Text(
                '${goal.percentageCompleted.toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: goal.isCompleted 
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            goal.motivationalMessage,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGoalsState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma meta definida',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Defina metas semanais para acompanhar seu progresso!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showSetGoalModal(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Criar Primeira Meta',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsLoading() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2196F3),
        ),
      ),
    );
  }

  Widget _buildGoalsError(BuildContext context, Object error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Erro ao carregar metas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.red[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(workoutCategoryGoalsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evolução Semanal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4D4D4D),
          ),
        ),
        const SizedBox(height: 16),
        goalsAsync.when(
          data: (goals) => _buildChartsForGoals(context, ref, goals),
          loading: () => _buildChartsLoading(),
          error: (error, stackTrace) => _buildChartsEmpty(),
        ),
      ],
    );
  }

  Widget _buildChartsForGoals(BuildContext context, WidgetRef ref, List<WorkoutCategoryGoal> goals) {
    if (goals.isEmpty) {
      return _buildChartsEmpty();
    }

    // Mostrar gráfico da primeira categoria ou da mais ativa
    final primaryGoal = goals.first;
    
    return FutureBuilder<List<WeeklyEvolution>>(
      future: ref.read(workoutCategoryGoalsRepositoryProvider)
          .getWeeklyEvolution(primaryGoal.category),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return WeeklyEvolutionChart(
            evolutionData: snapshot.data!,
            category: primaryGoal.category,
            height: 280,
          );
        } else if (snapshot.hasError) {
          return _buildChartsError();
        } else {
          return _buildChartsLoading();
        }
      },
    );
  }

  Widget _buildChartsLoading() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2196F3),
        ),
      ),
    );
  }

  Widget _buildChartsEmpty() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum dado disponível',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Defina metas e faça treinos para ver sua evolução!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsError() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar gráfico',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4D4D4D),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.flag,
                title: 'Nova Meta',
                subtitle: 'Definir meta por categoria',
                color: const Color(0xFF2196F3),
                onTap: () => _showSetGoalModal(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.timeline,
                title: 'Ver Gráficos',
                subtitle: 'Analisar evolução',
                color: const Color(0xFF4CAF50),
                onTap: () => _showFullChartsView(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSetGoalModal(BuildContext context, {WorkoutCategoryGoal? goal}) async {
    final result = await SetCategoryGoalModal.show(
      context,
      existingGoal: goal,
    );
    
    if (result == true && context.mounted) {
      // Recarregar metas após definir/editar
      final container = ProviderScope.containerOf(context);
      container.refresh(workoutCategoryGoalsProvider);
    }
  }

  void _showFullChartsView(BuildContext context) {
    // TODO: Navegar para tela de gráficos completa
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade em desenvolvimento! 🚧'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 