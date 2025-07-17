// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/widgets/app_bar_widget.dart';
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/features/goals/viewmodels/goals_view_model.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data_enhanced.dart';

/// Tela principal para gerenciar metas do usuário
@RoutePage()
class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega as metas ao entrar na tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(goalsViewModelProvider.notifier).loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalsState = ref.watch(goalsViewModelProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      appBar: AppBarWidget(
        title: 'Minhas Metas',
        showBackButton: true,
      ),
      body: goalsState.when(
        data: (goals) => _buildContent(context, goals),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFF38638),
          ),
        ),
        error: (error, _) => _buildErrorState(context, error),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateGoal(context),
        backgroundColor: const Color(0xFFF38638),
        icon: const Icon(Icons.add),
        label: const Text('Nova Meta'),
      ),
    );
  }
  
  Widget _buildContent(BuildContext context, List<GoalData> goals) {
    if (goals.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return RefreshIndicator(
      onRefresh: () => ref.read(goalsViewModelProvider.notifier).loadGoals(),
      color: const Color(0xFFF38638),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          return _buildGoalCard(context, goal);
        },
      ),
    );
  }
  
  Widget _buildGoalCard(BuildContext context, GoalData goal) {
    final progress = goal.targetValue > 0 
        ? (goal.currentValue / goal.targetValue).clamp(0.0, 1.0)
        : 0.0;
    final isCompleted = goal.isCompleted;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToEditGoal(context, goal),
          onLongPress: () => _showGoalOptions(context, goal),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getGoalColor(_getCategoryFromGoal(goal)).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getGoalIcon(_getCategoryFromGoal(goal)),
                        color: _getGoalColor(_getCategoryFromGoal(goal)),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D2D2D),
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Progress Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progresso',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getGoalColor(_getCategoryFromGoal(goal)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted 
                            ? Colors.green 
                            : _getGoalColor(_getCategoryFromGoal(goal)),
                      ),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${goal.currentValue.toStringAsFixed(0)} ${goal.unit}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                        Text(
                          'Meta: ${goal.targetValue.toStringAsFixed(0)} ${goal.unit}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Quick Update Buttons
                if (!isCompleted) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildQuickUpdateButton(
                        context,
                        icon: Icons.remove,
                        onPressed: goal.currentValue > 0
                            ? () => _updateGoalProgress(goal, goal.currentValue - 1)
                            : null,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          goal.currentValue.toStringAsFixed(0),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      _buildQuickUpdateButton(
                        context,
                        icon: Icons.add,
                        onPressed: () => _updateGoalProgress(goal, goal.currentValue + 1),
                        color: const Color(0xFF6B7FD7),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickUpdateButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: onPressed != null ? color : Colors.grey,
            size: 20,
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6B7FD7).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flag_outlined,
                color: Color(0xFF6B7FD7),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma meta criada',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Defina metas para acompanhar\nseu progresso e alcançar objetivos',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateGoal(context),
              icon: const Icon(Icons.add),
              label: const Text('Criar Primeira Meta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF38638),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context, dynamic error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar metas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(goalsViewModelProvider.notifier).loadGoals(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF38638),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToCreateGoal(BuildContext context) {
    context.router.push(GoalFormRoute());
  }
  
  void _navigateToEditGoal(BuildContext context, GoalData goal) {
    context.router.push(GoalFormRoute(existingGoal: goal));
  }
  
  void _updateGoalProgress(GoalData goal, double newValue) {
    ref.read(goalsViewModelProvider.notifier).updateGoalProgress(goal.id, newValue);
  }
  
  void _showGoalOptions(BuildContext context, GoalData goal) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar Meta'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditGoal(context, goal);
              },
            ),
            if (!goal.isCompleted)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Marcar como Concluída'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(goalsViewModelProvider.notifier).completeGoal(goal.id);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir Meta'),
              textColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteGoal(context, goal);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _confirmDeleteGoal(BuildContext context, GoalData goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Meta?'),
        content: Text('Tem certeza que deseja excluir "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(goalsViewModelProvider.notifier).deleteGoal(goal.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
  
  String _getCategoryFromGoal(GoalData goal) {
    final title = goal.title.toLowerCase();
    final unit = goal.unit.toLowerCase();
    
    // Determina categoria baseada no título e unidade
    if (title.contains('treino') || title.contains('exercício') || title.contains('fitness') || 
        unit.contains('treino') || unit.contains('exercício')) {
      return 'fitness';
    } else if (title.contains('água') || title.contains('nutrição') || title.contains('alimentação') ||
               title.contains('refeição') || unit.contains('litro') || unit.contains('copo')) {
      return 'nutrition';
    } else if (title.contains('peso') || title.contains('kg') || unit.contains('kg')) {
      return 'wellness';
    } else if (title.contains('passo') || unit.contains('passo') || unit.contains('km')) {
      return 'fitness';
    } else {
      return 'personal';
    }
  }
  
  Color _getGoalColor(String category) {
    switch (category.toLowerCase()) {
      case 'fitness':
        return const Color(0xFF6B7FD7);
      case 'nutrition':
        return Colors.green;
      case 'wellness':
        return const Color(0xFF4FC3F7);
      case 'personal':
        return const Color(0xFFF38638);
      default:
        return Colors.grey;
    }
  }
  
  IconData _getGoalIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fitness':
        return Icons.fitness_center;
      case 'nutrition':
        return Icons.restaurant;
      case 'wellness':
        return Icons.spa;
      case 'personal':
        return Icons.person;
      default:
        return Icons.flag;
    }
  }
} 