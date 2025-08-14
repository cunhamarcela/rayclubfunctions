// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../providers/unified_goal_providers.dart';
import 'widgets/goal_progress_card.dart';
import 'create_goal_screen.dart';

/// **TELA DE LISTA DE METAS - RAY CLUB**
/// 
/// **Data:** 30 de Janeiro de 2025 às 17:00
/// **Objetivo:** Visualizar todas as metas do usuário com progresso
/// **Funcionalidades:**
/// 1. Lista de metas ativas e concluídas
/// 2. Progresso visual (bolinhas para dias, barra para minutos)
/// 3. Check-ins manuais para metas de dias
/// 4. Navegação para criação de nova meta
class GoalsListScreen extends ConsumerWidget {
  const GoalsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGoalsAsync = ref.watch(userGoalsProvider);
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Minhas Metas',
        actions: [
          IconButton(
            onPressed: () => _navigateToCreateGoal(context),
            icon: Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
            ),
            tooltip: 'Nova Meta',
          ),
        ],
      ),
      body: userGoalsAsync.when(
        data: (goals) => _buildGoalsList(context, goals),
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateGoal(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nova Meta'),
      ),
    );
  }

  Widget _buildGoalsList(BuildContext context, List<dynamic> goals) {
    if (goals.isEmpty) {
      return _buildEmptyState(context);
    }

    // Separar metas ativas das concluídas
    final activeGoals = goals.where((g) => !g.isCompleted).toList();
    final completedGoals = goals.where((g) => g.isCompleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com estatísticas
          _buildStatsHeader(activeGoals.length, completedGoals.length),
          
          const SizedBox(height: 24),
          
          // Metas ativas
          if (activeGoals.isNotEmpty) ...[
            _buildSectionTitle('Metas Ativas', activeGoals.length),
            const SizedBox(height: 16),
            ...activeGoals.map((goal) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GoalProgressCard(goal: goal),
            )),
            const SizedBox(height: 24),
          ],
          
          // Metas concluídas
          if (completedGoals.isNotEmpty) ...[
            _buildSectionTitle('Metas Concluídas', completedGoals.length),
            const SizedBox(height: 16),
            ...completedGoals.map((goal) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GoalProgressCard(goal: goal),
            )),
          ],
          
          // Espaço extra para o FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(int activeCount, int completedCount) {
    final totalGoals = activeCount + completedCount;
    final completionRate = totalGoals > 0 
        ? ((completedCount / totalGoals) * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Ativas',
              activeCount.toString(),
              Icons.trending_up,
              AppColors.primary,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.outline.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              'Concluídas',
              completedCount.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.outline.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              'Taxa',
              '$completionRate%',
              Icons.insights,
              AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.headingH3.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      children: [
        Icon(
          title.contains('Ativas') ? Icons.play_circle : Icons.check_circle,
          color: title.contains('Ativas') ? AppColors.primary : Colors.green,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.headingH4.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 80,
              color: AppColors.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma meta criada ainda',
              style: AppTypography.headingH3.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Que tal criar sua primeira meta? ✨\n'
              'Você pode escolher exercícios da lista ou criar uma meta personalizada.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateGoal(context),
              icon: const Icon(Icons.add),
              label: const Text('Criar Primeira Meta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando suas metas...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Ops! Algo deu errado',
              style: AppTypography.headingH3.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Não conseguimos carregar suas metas no momento.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateGoal(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateGoal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateGoalScreen(),
      ),
    );
  }
}

