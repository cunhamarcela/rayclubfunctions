import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/router/app_navigator.dart';
import 'package:ray_club_app/features/goals/models/weekly_goal.dart';
import 'package:ray_club_app/features/goals/viewmodels/weekly_goal_view_model.dart';
import 'package:ray_club_app/features/goals/widgets/weekly_goal_selector_widget.dart';
import 'package:ray_club_app/features/progress/view_models/progress_view_model.dart';

/// Dashboard de progresso semanal com meta dinâmica
class WeeklyProgressDashboard extends ConsumerWidget {
  const WeeklyProgressDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalState = ref.watch(weeklyGoalViewModelProvider);
    final progressState = ref.watch(progressViewModelProvider);
    
    // Lista de dias da semana abreviados
    final dayLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    
    // Dia atual (0 = segunda, 6 = domingo)
    final now = DateTime.now();
    final currentDay = now.weekday - 1;
    
    // Obter dias da semana atual
    final List<DateTime> weekDays = [];
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    for (int i = 0; i < 7; i++) {
      weekDays.add(startOfWeek.add(Duration(days: i)));
    }
    
    // Dados de treinos por dia
    final monthlyWorkouts = progressState.userProgress?.monthlyWorkouts ?? {};
    
    // Verifica quais dias da semana têm treinos registrados
    final List<bool> trainedDays = List.generate(7, (index) {
      final day = weekDays[index];
      final monthKey = '${day.year}-${day.month.toString().padLeft(2, '0')}';
      return monthlyWorkouts[monthKey] != null && monthlyWorkouts[monthKey]! > 0;
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE78639),
            Color(0xFFFFB176),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com meta semanal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título e meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meta Semanal',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (goalState.currentGoal != null) ...[
                      Text(
                        _formatGoalText(goalState.currentGoal!),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Barra de progresso
                      _buildProgressBar(goalState.currentGoal!),
                    ] else
                      const Text(
                        'Defina sua meta semanal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Botão de editar meta
              IconButton(
                onPressed: () => _showGoalSelector(context),
                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Calendário semanal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final bool isToday = index == currentDay;
              final bool hasTrained = trainedDays[index];
              final day = weekDays[index];
              
              return InkWell(
                onTap: () {
                  ref.read(progressViewModelProvider.notifier).selectDate(day);
                  AppNavigator.navigateToDashboard(context);
                },
                child: Column(
                  children: [
                    Text(
                      dayLabels[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasTrained 
                            ? (isToday ? Colors.white : Colors.white.withOpacity(0.8))
                            : (isToday ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.15)),
                        border: isToday 
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                        boxShadow: isToday ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Center(
                        child: hasTrained
                            ? const Icon(
                                Icons.check,
                                color: Color(0xFFE78639),
                                size: 18,
                              )
                            : Text(
                                day.day.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isToday ? AppColors.brown : Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          
          const SizedBox(height: 20),
          
          // Estatísticas de progresso
          if (goalState.currentGoal != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressStat(
                  'Tempo atual',
                  _formatMinutes(goalState.currentGoal!.currentMinutes),
                  Icons.timer,
                  Colors.white,
                ),
                _buildProgressStat(
                  'Meta',
                  _formatMinutes(goalState.currentGoal!.goalMinutes),
                  Icons.flag,
                  Colors.white,
                ),
                _buildProgressStat(
                  'Progresso',
                  '${goalState.currentGoal!.percentageCompleted.toStringAsFixed(0)}%',
                  Icons.trending_up,
                  Colors.white,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(WeeklyGoal goal) {
    final percentage = goal.percentageCompleted / 100;
    final isCompleted = goal.completed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // Barra de fundo
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Barra de progresso
            LayoutBuilder(
              builder: (context, constraints) => AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 8,
                width: (constraints.maxWidth * 0.8) * percentage.clamp(0.0, 1.0),
                              decoration: BoxDecoration(
                  color: isCompleted ? Colors.greenAccent : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isCompleted 
              ? '🎉 Meta atingida!' 
              : '${goal.currentMinutes} de ${goal.goalMinutes} minutos',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatGoalText(WeeklyGoal goal) {
    final option = WeeklyGoalOption.fromMinutes(goal.goalMinutes);
    if (option != WeeklyGoalOption.custom) {
      return '${option.label} - ${option.description}';
    }
    return 'Meta personalizada - ${_formatMinutes(goal.goalMinutes)} por semana';
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours h';
    }
    return '$hours h $mins min';
  }

  void _showGoalSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle do modal
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Widget de seleção
              WeeklyGoalSelectorWidget(
                onGoalUpdated: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }


} 