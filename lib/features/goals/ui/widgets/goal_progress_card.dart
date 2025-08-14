// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../models/unified_goal_model.dart';
import '../../services/goal_checkin_service.dart';
import '../../providers/unified_goal_providers.dart';

/// **CARD DE PROGRESSO DE META**
/// 
/// Widget que mostra o progresso de uma meta e permite check-ins manuais
/// para metas medidas em dias
class GoalProgressCard extends ConsumerWidget {
  final UnifiedGoal goal;

  const GoalProgressCard({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkinService = ref.watch(goalCheckinServiceProvider);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com título e tipo
            _buildHeader(),
            
            const SizedBox(height: 16),
            
            // Progresso visual
            _buildProgress(),
            
            const SizedBox(height: 16),
            
            // Ações (check-in manual para metas de dias)
            if (goal.measurementType == 'days' && !goal.isCompleted)
              _buildCheckinButton(context, ref, checkinService),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Ícone da categoria ou tipo
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getGoalColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getGoalIcon(),
            color: _getGoalColor(),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        
        // Título e subtítulo
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.title,
                style: AppTypography.headingH4.copyWith(
                  color: AppColors.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _getSubtitle(),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        
        // Status badge
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildProgress() {
    if (goal.measurementType == 'days') {
      return _buildDayProgress();
    } else {
      return _buildMinuteProgress();
    }
  }

  Widget _buildDayProgress() {
    final totalDays = goal.targetValue.toInt();
    final completedDays = goal.currentValue.toInt();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso dos dias',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              '$completedDays/$totalDays dias',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: _getGoalColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Grid de bolinhas
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(totalDays, (index) {
            final isCompleted = index < completedDays;
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted 
                    ? _getGoalColor()
                    : AppColors.outline.withOpacity(0.2),
                border: !isCompleted ? Border.all(
                  color: AppColors.outline.withOpacity(0.3),
                ) : null,
              ),
              child: isCompleted 
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.onPrimary,
                    )
                  : null,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMinuteProgress() {
    final progress = goal.progressPercentage;
    final currentMinutes = goal.currentValue.toInt();
    final targetMinutes = goal.targetValue.toInt();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso em minutos',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              '$currentMinutes/$targetMinutes min',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: _getGoalColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Barra de progresso
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: AppColors.outline.withOpacity(0.2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: _getGoalColor(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}% concluído',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckinButton(BuildContext context, WidgetRef ref, GoalCheckinService checkinService) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleCheckin(context, ref, checkinService),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Marcar hoje ✨'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getGoalColor(),
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final String status;
    final Color color;
    
    if (goal.isCompleted) {
      status = 'Concluída';
      color = Colors.green;
    } else if (goal.progressPercentage > 0.7) {
      status = 'Quase lá';
      color = Colors.orange;
    } else {
      status = 'Em andamento';
      color = AppColors.primary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _handleCheckin(BuildContext context, WidgetRef ref, GoalCheckinService checkinService) async {
    try {
      final success = await checkinService.registerCheckin(
        goalId: goal.id,
        userId: goal.userId,
      );
      
      if (success) {
        // Atualizar lista de metas
        ref.invalidate(userGoalsProvider);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Check-in registrado! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível registrar o check-in'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getSubtitle() {
    if (goal.category != null) {
      return '${goal.category!.displayName} • Progresso automático';
    } else {
      return 'Meta personalizada • Progresso manual';
    }
  }

  Color _getGoalColor() {
    if (goal.isCompleted) return Colors.green;
    if (goal.category != null) return AppColors.primary;
    return AppColors.secondary;
  }

  IconData _getGoalIcon() {
    if (goal.isCompleted) return Icons.check_circle;
    if (goal.measurementType == 'days') return Icons.calendar_today;
    return Icons.timer;
  }
}

/// **PROVIDER DO SERVIÇO DE CHECK-IN**
final goalCheckinServiceProvider = Provider<GoalCheckinService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return GoalCheckinService(supabase);
});

