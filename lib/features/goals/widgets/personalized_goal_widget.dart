import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/features/goals/models/personalized_goal.dart';
import 'package:ray_club_app/features/goals/viewmodels/personalized_goal_viewmodel.dart';
import 'package:ray_club_app/features/goals/widgets/goal_creation_modal.dart';

/// Widget principal inteligente para metas personalizáveis
/// Detecta automaticamente a modalidade (check vs unidade) e mostra UI apropriada
class PersonalizedGoalWidget extends ConsumerWidget {
  final bool isCompact;
  final VoidCallback? onTap;

  const PersonalizedGoalWidget({
    super.key,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(personalizedGoalViewModelProvider);

    if (state.isLoading) {
      return _buildLoadingState();
    }

    if (!state.hasActiveGoal) {
      return _buildNoGoalState(context, ref);
    }

    final goal = state.currentGoal!.goal;

    // Interface inteligente: detecta modalidade e mostra UI apropriada
    return goal.measurementType.isCheckMode
        ? _buildCheckModeInterface(context, ref, goal, state)
        : _buildUnitModeInterface(context, ref, goal, state);
  }

  /// Interface para modalidade CHECK (círculos clicáveis)
  Widget _buildCheckModeInterface(
    BuildContext context,
    WidgetRef ref,
    PersonalizedGoal goal,
    PersonalizedGoalState state,
  ) {
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
          // Header da meta
          _buildGoalHeader(goal),
          
          const SizedBox(height: 16),
          
          // Progresso atual
          _buildCheckProgress(goal),
          
          const SizedBox(height: 20),
          
          // Círculos de check-in clicáveis
          _buildCheckCircles(context, ref, goal, state),
          
          const SizedBox(height: 16),
          
          // Mensagem motivacional
          _buildMotivationalMessage(goal),
          
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            _buildErrorMessage(state.errorMessage!),
          ],
        ],
      ),
    );
  }

  /// Interface para modalidade UNIDADE (barra de progresso + botão +)
  Widget _buildUnitModeInterface(
    BuildContext context,
    WidgetRef ref,
    PersonalizedGoal goal,
    PersonalizedGoalState state,
  ) {
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
          // Header da meta
          _buildGoalHeader(goal),
          
          const SizedBox(height: 16),
          
          // Barra de progresso
          _buildProgressBar(goal),
          
          const SizedBox(height: 20),
          
          // Controles de incremento
          _buildIncrementControls(context, ref, goal, state),
          
          const SizedBox(height: 16),
          
          // Mensagem motivacional
          _buildMotivationalMessage(goal),
          
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            _buildErrorMessage(state.errorMessage!),
          ],
        ],
      ),
    );
  }

  /// Header comum com título e descrição
  Widget _buildGoalHeader(PersonalizedGoal goal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              goal.measurementType.icon,
              color: goal.measurementType.color,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                goal.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (goal.isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Concluída! 🎉',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        if (goal.description != null) ...[
          const SizedBox(height: 4),
          Text(
            goal.description!,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  /// Progresso para modalidade check
  Widget _buildCheckProgress(PersonalizedGoal goal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          goal.progressText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          '${goal.progressPercentage.toInt()}%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: goal.progressColor,
          ),
        ),
      ],
    );
  }

  /// Círculos clicáveis para check-ins
  Widget _buildCheckCircles(
    BuildContext context,
    WidgetRef ref,
    PersonalizedGoal goal,
    PersonalizedGoalState state,
  ) {
    final totalChecks = goal.targetValue.toInt();
    final completedChecks = goal.currentProgress.toInt();
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(totalChecks, (index) {
        final isCompleted = index < completedChecks;
        final isNext = index == completedChecks && !goal.isCompleted;
        final canCheck = isNext && state.canCheckInToday && !state.isRegistering;
        
        return GestureDetector(
          onTap: canCheck ? () => _handleCheckIn(ref) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted 
                  ? goal.measurementType.color
                  : canCheck 
                      ? goal.measurementType.color.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
              border: Border.all(
                color: canCheck 
                    ? goal.measurementType.color
                    : Colors.grey.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: canCheck ? [
                BoxShadow(
                  color: goal.measurementType.color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    )
                  : canCheck
                      ? Icon(
                          Icons.add,
                          color: goal.measurementType.color,
                          size: 24,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
            ),
          ),
        );
      }),
    );
  }

  /// Barra de progresso para modalidade unidade
  Widget _buildProgressBar(PersonalizedGoal goal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              goal.progressText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${goal.progressPercentage.toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: goal.progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: goal.progressValue,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(goal.progressColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  /// Controles de incremento para modalidade unidade
  Widget _buildIncrementControls(
    BuildContext context,
    WidgetRef ref,
    PersonalizedGoal goal,
    PersonalizedGoalState state,
  ) {
    return Row(
      children: [
        // Botão de incremento rápido
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.isRegistering ? null : () => _handleQuickIncrement(ref, goal),
            icon: Icon(Icons.add),
            label: Text('+${goal.formatValue(goal.incrementStep)} ${goal.unitLabel}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: goal.measurementType.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Botão de incremento personalizado
        OutlinedButton(
          onPressed: state.isRegistering ? null : () => _showCustomIncrementDialog(context, ref, goal),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: goal.measurementType.color),
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Icon(
            Icons.edit,
            color: goal.measurementType.color,
          ),
        ),
      ],
    );
  }

  /// Mensagem motivacional
  Widget _buildMotivationalMessage(PersonalizedGoal goal) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: goal.measurementType.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb,
            color: goal.measurementType.color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              goal.motivationalMessage,
              style: TextStyle(
                color: goal.measurementType.color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Estado de loading
  Widget _buildLoadingState() {
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
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Carregando sua meta... ✨'),
          ],
        ),
      ),
    );
  }

  /// Estado quando não há meta ativa
  Widget _buildNoGoalState(BuildContext context, WidgetRef ref) {
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
        children: [
          Icon(
            Icons.flag_outlined,
            size: 48,
            color: AppColors.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          const Text(
            'Defina sua meta semanal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha entre metas pré-estabelecidas ou crie a sua própria',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showGoalCreationModal(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Criar Meta'),
          ),
        ],
      ),
    );
  }

  /// Mensagem de erro
  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ações
  void _handleCheckIn(WidgetRef ref) async {
    final success = await ref
        .read(personalizedGoalViewModelProvider.notifier)
        .registerCheckIn();
    
    if (success) {
      // Feedback visual de sucesso pode ser adicionado aqui
    }
  }

  void _handleQuickIncrement(WidgetRef ref, PersonalizedGoal goal) async {
    final success = await ref
        .read(personalizedGoalViewModelProvider.notifier)
        .addIncrementalProgress();
    
    if (success) {
      // Feedback visual de sucesso pode ser adicionado aqui
    }
  }

  void _showCustomIncrementDialog(
    BuildContext context,
    WidgetRef ref,
    PersonalizedGoal goal,
  ) {
    showDialog(
      context: context,
      builder: (context) => CustomIncrementDialog(
        goal: goal,
        onIncrement: (value) async {
          final success = await ref
              .read(personalizedGoalViewModelProvider.notifier)
              .addProgress(value);
          
          if (success) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _showGoalCreationModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GoalCreationModal(),
    );
  }
}

/// Dialog para incremento personalizado
class CustomIncrementDialog extends StatefulWidget {
  final PersonalizedGoal goal;
  final Function(double) onIncrement;

  const CustomIncrementDialog({
    super.key,
    required this.goal,
    required this.onIncrement,
  });

  @override
  State<CustomIncrementDialog> createState() => _CustomIncrementDialogState();
}

class _CustomIncrementDialogState extends State<CustomIncrementDialog> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.goal.incrementStep.toString(),
    );
    _focusNode = FocusNode();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adicionar ${widget.goal.unitLabel}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Valor',
              suffixText: widget.goal.unitLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final value = double.tryParse(_controller.text);
            if (value != null && value > 0) {
              widget.onIncrement(value);
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
} 