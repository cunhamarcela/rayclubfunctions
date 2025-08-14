import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/unified_goal_model.dart';
import '../providers/unified_goal_providers.dart';

/// **WIDGET CRIADOR DE METAS PRÉ-ESTABELECIDAS**
/// 
/// **Data:** 29 de Janeiro de 2025 às 16:45
/// **Objetivo:** Interface para criar metas baseadas em modalidades de exercício
/// **Referência:** Sistema de metas unificado Ray Club

class PresetGoalCreator extends ConsumerStatefulWidget {
  const PresetGoalCreator({super.key});

  @override
  ConsumerState<PresetGoalCreator> createState() => _PresetGoalCreatorState();
}

class _PresetGoalCreatorState extends ConsumerState<PresetGoalCreator> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_task,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Criar Nova Meta ✨',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Escolha uma modalidade para criar sua meta automática:',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Grid de categorias
          _buildCategoryGrid(),
          
          const SizedBox(height: 16),
          
          // Metas semanais rápidas
          _buildQuickWeeklyGoals(),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    // Categorias mais populares para o dashboard
    final popularCategories = [
      GoalCategory.corrida,
      GoalCategory.musculacao,
      GoalCategory.yoga,
      GoalCategory.funcional,
      GoalCategory.cardio,
      GoalCategory.pilates,
      GoalCategory.caminhada,
      GoalCategory.hiit,
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: popularCategories.length,
      itemBuilder: (context, index) {
        final category = popularCategories[index];
        return _buildCategoryItem(category);
      },
    );
  }

  Widget _buildCategoryItem(GoalCategory category) {
    return GestureDetector(
      onTap: () => _showCategoryGoalDialog(category),
      child: Container(
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: category.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              category.displayName,
              style: AppTypography.labelSmall.copyWith(
                color: category.color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickWeeklyGoals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metas Semanais Rápidas:',
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickGoalChip('150 min/semana', 150, Icons.timer),
            _buildQuickGoalChip('300 min/semana', 300, Icons.fitness_center),
            _buildQuickGoalChip('5 treinos/semana', null, Icons.calendar_today, customAction: _showCustomWeeklyGoal),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickGoalChip(String label, int? minutes, IconData icon, {VoidCallback? customAction}) {
    return ActionChip(
      onPressed: customAction ?? () => _createWeeklyMinutesGoal(minutes!),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
    );
  }

  void _showCategoryGoalDialog(GoalCategory category) {
    showDialog(
      context: context,
      builder: (context) => _CategoryGoalDialog(category: category),
    );
  }

  void _showCustomWeeklyGoal() {
    showDialog(
      context: context,
      builder: (context) => const _CustomWeeklyGoalDialog(),
    );
  }

  Future<void> _createWeeklyMinutesGoal(int targetMinutes) async {
    try {
      final createPresetGoal = ref.read(createPresetGoalProvider);
      
      await createPresetGoal(
        presetType: 'weekly_minutes',
        params: {'target_minutes': targetMinutes},
      );
      
      _showSuccessSnackbar('Meta semanal de $targetMinutes minutos criada! 🎯');
    } catch (e) {
      _showErrorSnackbar('Erro ao criar meta: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

/// **DIALOG PARA CRIAR META DE CATEGORIA**
class _CategoryGoalDialog extends ConsumerStatefulWidget {
  final GoalCategory category;

  const _CategoryGoalDialog({required this.category});

  @override
  ConsumerState<_CategoryGoalDialog> createState() => _CategoryGoalDialogState();
}

class _CategoryGoalDialogState extends ConsumerState<_CategoryGoalDialog> {
  int targetSessions = 3;
  bool isCreating = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text(widget.category.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Meta de ${widget.category.displayName}',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Quantas sessões você quer fazer esta semana?',
            style: AppTypography.bodyMedium,
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: targetSessions > 1 ? () => setState(() => targetSessions--) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.primary,
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: widget.category.color.withOpacity(0.3)),
                ),
                child: Text(
                  '$targetSessions sessões',
                  style: AppTypography.titleLarge.copyWith(
                    color: widget.category.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              IconButton(
                onPressed: targetSessions < 7 ? () => setState(() => targetSessions++) : null,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Quando você registrar treinos de ${widget.category.displayName}, esta meta será atualizada automaticamente! ✨',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isCreating ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ),
        ElevatedButton(
          onPressed: isCreating ? null : _createCategoryGoal,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.category.color,
            foregroundColor: Colors.white,
          ),
          child: isCreating 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('Criar Meta'),
        ),
      ],
    );
  }

  Future<void> _createCategoryGoal() async {
    setState(() => isCreating = true);
    
    try {
      final createPresetGoal = ref.read(createPresetGoalProvider);
      
      final weekEnd = DateTime.now().add(const Duration(days: 7));
      
      await createPresetGoal(
        presetType: 'workout_category',
        params: {
          'category': widget.category.value,
          'target_sessions': targetSessions,
          'end_date': weekEnd.toIso8601String(),
        },
      );
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meta de ${widget.category.displayName} criada! 🎯'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar meta: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isCreating = false);
    }
  }
}

/// **DIALOG PARA META SEMANAL CUSTOMIZADA**
class _CustomWeeklyGoalDialog extends ConsumerStatefulWidget {
  const _CustomWeeklyGoalDialog();

  @override
  ConsumerState<_CustomWeeklyGoalDialog> createState() => _CustomWeeklyGoalDialogState();
}

class _CustomWeeklyGoalDialogState extends ConsumerState<_CustomWeeklyGoalDialog> {
  int targetMinutes = 150;
  bool isCreating = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Text('📅', style: TextStyle(fontSize: 24)),
          SizedBox(width: 8),
          Text('Meta Semanal Personalizada'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Quantos minutos você quer treinar esta semana?',
            style: AppTypography.bodyMedium,
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: targetMinutes > 30 ? () => setState(() => targetMinutes -= 30) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.primary,
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  '$targetMinutes min',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              IconButton(
                onPressed: targetMinutes < 600 ? () => setState(() => targetMinutes += 30) : null,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Equivale a ${(targetMinutes / 60).toStringAsFixed(1)} horas de exercício',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isCreating ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ),
        ElevatedButton(
          onPressed: isCreating ? null : _createWeeklyGoal,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: isCreating 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('Criar Meta'),
        ),
      ],
    );
  }

  Future<void> _createWeeklyGoal() async {
    setState(() => isCreating = true);
    
    try {
      final createPresetGoal = ref.read(createPresetGoalProvider);
      
      await createPresetGoal(
        presetType: 'weekly_minutes',
        params: {'target_minutes': targetMinutes},
      );
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meta semanal de $targetMinutes minutos criada! 🎯'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar meta: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isCreating = false);
    }
  }
} 