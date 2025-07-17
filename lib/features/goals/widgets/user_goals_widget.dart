// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/features/goals/models/user_goal_model.dart';
import 'package:ray_club_app/features/goals/viewmodels/user_goals_view_model.dart';

/// Widget que exibe as metas do usuário
/// PATCH: Corrigir bug 5 - Criar um componente separado para exibir as metas do usuário
class UserGoalsWidget extends ConsumerWidget {
  /// Construtor
  const UserGoalsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsState = ref.watch(userGoalsViewModelProvider);
    
    if (goalsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (goalsState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 48),
            const SizedBox(height: 8),
            Text(
              'Erro ao carregar metas:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              goalsState.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(userGoalsViewModelProvider.notifier).loadUserGoals(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    
    if (goalsState.goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, color: Colors.grey, size: 48),
            const SizedBox(height: 8),
            Text(
              'Nenhuma meta definida',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Defina metas para acompanhar seu progresso',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                // PATCH: Adicionar botão para criar metas quando não há metas
                final result = await AppNavigator.navigateToGoalForm(context, existingGoal: null);
                if (result == true) {
                  // Recarregar as metas quando voltar do formulário
                  ref.read(userGoalsViewModelProvider.notifier).loadUserGoals();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Meta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        // Cabeçalho com título e botão para adicionar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Suas Metas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () async {
                // PATCH: Adicionar botão para criar novas metas
                final result = await AppNavigator.navigateToGoalForm(context, existingGoal: null);
                if (result == true) {
                  // Recarregar as metas quando voltar do formulário
                  ref.read(userGoalsViewModelProvider.notifier).loadUserGoals();
                }
              },
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Adicionar Meta',
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Lista de metas
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: goalsState.goals.length,
          itemBuilder: (context, index) {
            final goal = goalsState.goals[index];
            return _buildGoalItem(context, ref, goal);
          },
        ),
      ],
    );
  }
  
  /// Constrói o item de uma meta
  Widget _buildGoalItem(BuildContext context, WidgetRef ref, UserGoal goal) {
    final progressPercentage = goal.percentageCompleted;
    final goalColor = _getGoalColor(goal.type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(progressPercentage * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: goalColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(goalColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goal.isNumeric
                    ? '${goal.progress.toInt()} de ${goal.target.toInt()} ${goal.unit}'
                    : '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              if (goal.endDate != null)
                Text(
                  _formatRemainingDays(goal.endDate!),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          // Adicionar controles para atualizar progresso
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Botão para diminuir
              IconButton(
                onPressed: () {
                  // Decrementar o valor da meta
                  ref.read(userGoalsViewModelProvider.notifier).updateGoalProgress(
                    goal.id, 
                    goal.progress - 1 <= 0 ? 0 : goal.progress - 1,
                  );
                },
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.red,
              ),
              const SizedBox(width: 16),
              
              // Botão para aumentar
              IconButton(
                onPressed: () {
                  // Incrementar o valor da meta
                  ref.read(userGoalsViewModelProvider.notifier).updateGoalProgress(
                    goal.id, 
                    goal.progress + 1 >= goal.target ? goal.target : goal.progress + 1,
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Retorna a cor baseada no tipo de meta
  Color _getGoalColor(GoalType type) {
    switch (type) {
      case GoalType.weight:
        return Colors.red;
      case GoalType.workout:
        return Colors.orange;
      case GoalType.steps:
        return Colors.green;
      case GoalType.nutrition:
        return Colors.blue;
      case GoalType.custom:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  /// Formata os dias restantes para o fim da meta
  String _formatRemainingDays(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;
    
    if (difference < 0) {
      return 'Expirado';
    } else if (difference == 0) {
      return 'Último dia';
    } else if (difference == 1) {
      return 'Falta 1 dia';
    } else {
      return 'Faltam $difference dias';
    }
  }
} 