import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/features/goals/widgets/preset_goals_modal.dart';
import 'package:ray_club_app/features/goals/widgets/goal_period_filter_widget.dart';
import 'package:ray_club_app/features/goals/viewmodels/weekly_goal_expanded_view_model.dart';
import 'package:ray_club_app/features/goals/models/weekly_goal_expanded.dart';

/// Seção do dashboard que exibe metas personalizáveis
/// Conectada com o sistema antigo que funciona (WeeklyGoalExpandedSystem)
class PersonalizedGoalsDashboardSection extends ConsumerStatefulWidget {
  final bool isCompact;
  
  const PersonalizedGoalsDashboardSection({
    super.key,
    this.isCompact = false,
  });

  @override
  ConsumerState<PersonalizedGoalsDashboardSection> createState() => 
      _PersonalizedGoalsDashboardSectionState();
}

class _PersonalizedGoalsDashboardSectionState 
    extends ConsumerState<PersonalizedGoalsDashboardSection> {
  
  @override
  void initState() {
    super.initState();
    // Carregar meta ativa do sistema antigo que funciona
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weeklyGoalExpandedViewModelProvider.notifier).loadCurrentGoal();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usar o sistema antigo que funciona
    final weeklyGoalState = ref.watch(weeklyGoalExpandedViewModelProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 16),
        _buildGoalContent(weeklyGoalState),
      ],
    );
  }

  Widget _buildGoalContent(WeeklyGoalExpandedState state) {
    if (state.isLoading) {
      return _buildLoadingState();
    }
    
    // 🗓️ Obter metas baseado no filtro atual
    final displayGoals = _getDisplayGoals(state);
    
    return Column(
      children: [
        // 🗓️ FILTRO DE PERÍODO
        const GoalPeriodFilterWidget(),
        const SizedBox(height: 16),
        
        // METAS ENCONTRADAS
        if (displayGoals.isEmpty)
          _buildNoGoalState()
        else ...[
          for (int i = 0; i < displayGoals.length; i++) ...[
            _buildActiveGoalCard(displayGoals[i]),
            if (i < displayGoals.length - 1) const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),
          // 🆕 BOTÃO PARA ADICIONAR MAIS METAS (só na semana atual)
          if (state.currentFilter.value == 'current_week')
            _buildAddNewGoalButton(),
        ],
      ],
    );
  }

  /// 🗓️ Obter metas para exibição baseado no filtro
  List<WeeklyGoalExpanded> _getDisplayGoals(WeeklyGoalExpandedState state) {
    switch (state.currentFilter.value) {
      case 'current_week':
        return state.currentWeekGoals;
      default:
        return state.filteredGoals;
    }
  }

  Widget _buildActiveGoalCard(WeeklyGoalExpanded goal) {
    final progressPercentage = goal.currentValue / goal.targetValue;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com título, valores e botões de ação
          Row(
            children: [
              Icon(
                Icons.flag,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.goalTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4D4D4D),
                      ),
                    ),
                    Text(
                      '${goal.currentValue.toStringAsFixed(goal.measurementType == GoalMeasurementType.days ? 0 : 1)}/${goal.targetValue.toStringAsFixed(goal.measurementType == GoalMeasurementType.days ? 0 : 1)} ${goal.unitLabel}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Botões de ação
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showEditGoalDialog(goal),
                    icon: Icon(Icons.edit_outlined, size: 18, color: Colors.grey[600]),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.all(8),
                      minimumSize: Size(32, 32),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(goal),
                    icon: Icon(Icons.delete_outline, size: 18, color: Colors.grey[600]),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.all(8),
                      minimumSize: Size(32, 32),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 🎯 INTERFACE INTELIGENTE: Bolinhas para check-ins/dias, barra para outros tipos
          _buildProgressInterface(goal, progressPercentage),
        ],
      ),
    );
  }

  /// 🎯 INTERFACE INTELIGENTE: Decide entre bolinhas ou barra de progresso
  Widget _buildProgressInterface(WeeklyGoalExpanded goal, double progressPercentage) {
    // Para metas de check-ins ou dias, mostrar bolinhas clicáveis
    final isCheckInType = goal.measurementType == GoalMeasurementType.days || 
                         goal.unitLabel.toLowerCase().contains('check');
    
    if (isCheckInType) {
      return _buildCheckCirclesInterface(goal, progressPercentage);
    } else {
      return _buildProgressBarInterface(goal, progressPercentage);
    }
  }

  /// 🔴 INTERFACE DE BOLINHAS: Para check-ins e dias
  Widget _buildCheckCirclesInterface(WeeklyGoalExpanded goal, double progressPercentage) {
    final totalChecks = goal.targetValue.toInt();
    final completedChecks = goal.currentValue.toInt();
    final isCompleted = progressPercentage >= 1.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso da semana',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '$completedChecks/$totalChecks ${goal.unitLabel}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 🎯 BOLINHAS CLICÁVEIS - COM QUEBRA DE LINHA AUTOMÁTICA
        Wrap(
          spacing: 8, // Espaçamento horizontal entre bolinhas
          runSpacing: 8, // Espaçamento vertical entre linhas
          children: List.generate(totalChecks, (index) {
            final isChecked = index < completedChecks;
            final canCheck = !isChecked && !isCompleted;
            
            return GestureDetector(
              onTap: canCheck ? () => _onCheckCircleTap(goal, index + 1) : null,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isChecked ? AppColors.primary : Colors.grey[100],
                  border: Border.all(
                    color: isChecked ? AppColors.primary : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: isChecked 
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
            );
          }),
        ),
        
        if (isCompleted) ...[
          const SizedBox(height: 12),
          Text(
            'Meta Concluída ✅',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green[600],
            ),
          ),
        ],
      ],
    );
  }

  /// 📊 INTERFACE DE BARRA: Para reps, minutos, peso, etc.
  Widget _buildProgressBarInterface(WeeklyGoalExpanded goal, double progressPercentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso da semana',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${(progressPercentage * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progressPercentage.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 8,
        ),
        const SizedBox(height: 16),
        
        // Botão de ação para valores numéricos
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: progressPercentage >= 1.0 ? null : () {
              _showAddProgressDialog(goal);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: progressPercentage >= 1.0 ? Colors.green : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              progressPercentage >= 1.0 
                  ? 'Meta Concluída ✅' 
                  : 'Adicionar Progresso',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 🎯 AÇÃO: Quando usuário clica em uma bolinha
  void _onCheckCircleTap(WeeklyGoalExpanded goal, int newValue) {
    print('🔥 CLIQUE DETECTADO! Bolinha ${newValue} da meta: ${goal.goalTitle}');
    
    // 🔧 VERSÃO SIMPLES: Atualizar diretamente no banco sem função complexa
    _updateGoalDirectly(goal, newValue.toDouble());
  }
  
  /// 🔧 MÉTODO SIMPLES: Atualizar meta diretamente
  Future<void> _updateGoalDirectly(WeeklyGoalExpanded goal, double newValue) async {
    try {
      print('🔥 Atualizando meta ${goal.goalTitle} para valor $newValue');
      
      // Usar o repository diretamente para atualizar a meta
      final repository = ref.read(weeklyGoalExpandedRepositoryProvider);
      
      // Atualizar diretamente na tabela
      await repository.updateGoalCurrentValue(goal.id, newValue);
      
      // Recarregar as metas
      await ref.read(weeklyGoalExpandedViewModelProvider.notifier).loadCurrentGoal();
      
      print('🔥 ✅ Meta atualizada com sucesso!');
    } catch (e) {
      print('🚨 ERRO ao atualizar meta: $e');
    }
  }

  void _showAddProgressDialog(WeeklyGoalExpanded goal) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Progresso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Quanto você quer adicionar à sua meta "${goal.goalTitle}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Valor (${goal.unitLabel})',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                ref.read(weeklyGoalExpandedViewModelProvider.notifier)
                    .addProgress(value: value, measurementType: goal.measurementType);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progresso adicionado com sucesso! 🎉'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  /// 📝 Mostra dialog para editar meta
  void _showEditGoalDialog(WeeklyGoalExpanded goal) {
    final titleController = TextEditingController(text: goal.goalTitle);
    final targetController = TextEditingController(text: goal.targetValue.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Nome da Meta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Meta (${goal.unitLabel})',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = titleController.text.trim();
              final newTarget = double.tryParse(targetController.text);
              
              if (newTitle.isNotEmpty && newTarget != null && newTarget > 0) {
                _updateGoal(goal, newTitle, newTarget);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Meta editada com sucesso! ✨'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  /// 🗑️ Mostra confirmação para deletar meta
  void _showDeleteConfirmation(WeeklyGoalExpanded goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Meta'),
        content: Text('Tem certeza que deseja remover a meta "${goal.goalTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteGoal(goal);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Meta removida com sucesso! 🗑️'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 🔧 Atualiza meta existente
  Future<void> _updateGoal(WeeklyGoalExpanded goal, String newTitle, double newTarget) async {
    try {
      final repository = ref.read(weeklyGoalExpandedRepositoryProvider);
      // Usar o método específico que criamos para editar título e meta
      await repository.updateGoal(
        goalId: goal.id,
        goalTitle: newTitle,
        targetValue: newTarget,
      );
      await ref.read(weeklyGoalExpandedViewModelProvider.notifier).loadCurrentGoal();
    } catch (e) {
      print('🚨 ERRO ao atualizar meta: $e');
    }
  }

  /// 🗑️ Remove meta
  Future<void> _deleteGoal(WeeklyGoalExpanded goal) async {
    try {
      final repository = ref.read(weeklyGoalExpandedRepositoryProvider);
      await repository.deleteGoal(goal.id);
      await ref.read(weeklyGoalExpandedViewModelProvider.notifier).loadCurrentGoal();
    } catch (e) {
      print('🚨 ERRO ao deletar meta: $e');
    }
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildNoGoalState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 48,
            color: AppColors.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Defina sua meta semanal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha entre metas pré-estabelecidas ou\ncrie a sua própria',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showGoalCreationModal();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Criar Meta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGoalCreationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: PresetGoalsModal(
          onGoalCreated: () {
            Navigator.pop(context);
            // Atualizar o estado após criar meta
            ref.read(weeklyGoalExpandedViewModelProvider.notifier).refresh();
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Icon(
          Icons.emoji_events,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(weeklyGoalExpandedViewModelProvider);
            final displayGoals = _getDisplayGoals(state);
            final goalCount = displayGoals.length;
            
            // 🗓️ Título dinâmico baseado no filtro
            String title;
            if (state.currentFilter.value == 'current_week') {
              title = goalCount <= 1 ? 'Meta da Semana' : 'Metas da Semana ($goalCount)';
            } else {
              title = '${state.currentFilter.displayName} ($goalCount)';
            }
            
            return Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4D4D4D),
              ),
            );
          },
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            ref.read(weeklyGoalExpandedViewModelProvider.notifier).refresh();
          },
          icon: const Icon(
            Icons.refresh,
            color: Colors.grey,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildAddNewGoalButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showGoalSelector(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '✨ Adicionar Nova Meta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          minHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16, 
            16, 
            16, 
            MediaQuery.of(context).viewInsets.bottom + 16
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Criar Nova Meta Semanal ✨',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4D4D4D),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Widget de seleção com scroll flexível
              Flexible(
                child: PresetGoalsModal(
                  onGoalCreated: () {
                    Navigator.pop(context);
                    // Força o refresh do provider após criar uma meta
                    ref.read(weeklyGoalExpandedViewModelProvider.notifier).refresh();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 