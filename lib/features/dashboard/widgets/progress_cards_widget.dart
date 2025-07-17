// Flutter imports:
import 'package:flutter/material.dart';
import 'dart:math' as math;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/models/dashboard_fitness_data.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_fitness_view_model.dart';
import 'package:ray_club_app/features/dashboard/widgets/animated_progress_ring.dart';

/// Widget com cards de progresso, ranking e streak
class ProgressCardsWidget extends ConsumerWidget {
  const ProgressCardsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardFitnessViewModelProvider);

    return dashboardState.when(
      data: (data) => _buildProgressCards(context, data),
      loading: () => _buildLoadingCards(),
      error: (error, _) => _buildErrorCards(context, error),
    );
  }

  /// Constrói os cards de progresso
  Widget _buildProgressCards(BuildContext context, DashboardFitnessData data) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progresso da semana
          _buildWeekProgressCard(data.progress.week),
          
          const SizedBox(height: 16),
          
          // Row com Streak e Estatísticas
          Row(
            children: [
              // Streak
              Expanded(
                child: _buildStreakCard(data.progress.streak),
              ),
              
              const SizedBox(width: 16),
              
              // Estatísticas totais
              Expanded(
                child: _buildTotalStatsCard(data.progress.total),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progresso do mês
          _buildMonthProgressCard(data.progress.month),
        ],
      ),
    );
  }

  /// Card de progresso da semana
  Widget _buildWeekProgressCard(WeekProgress week) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progresso da Semana',
            style: TextStyle(
              color: Color(0xFF4D4D4D),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Progresso de treinos
          _buildProgressItem(
            label: 'Treinos',
            current: week.workouts,
            target: 7, // Meta de 7 treinos por semana
            color: const Color(0xFFF38C38),
            icon: Icons.fitness_center,
          ),
          
          const SizedBox(height: 12),
          
          // Progresso de minutos
          _buildProgressItem(
            label: 'Minutos',
            current: week.minutes,
            target: 300, // Meta de 300 minutos por semana
            color: const Color(0xFFCDA8F0),
            icon: Icons.timer,
          ),
          
          const SizedBox(height: 16),
          
          // Informações adicionais
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.calendar_today,
                label: '${week.days} dias',
                color: const Color(0xFFEE583F),
              ),
              
              const SizedBox(width: 12),
              
              _buildInfoChip(
                icon: Icons.category,
                label: '${week.types} tipos',
                color: const Color(0xFFF1EDC9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Item de progresso com barra
  Widget _buildProgressItem({
    required String label,
    required int current,
    required int target,
    required Color color,
    required IconData icon,
  }) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            
            const SizedBox(width: 8),
            
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4D4D4D),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            
            const Spacer(),
            
            Text(
              '$current de $target',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Barra de progresso animada
        AnimatedProgressBar(
          progress: progress,
          color: color,
          height: 8,
          duration: const Duration(milliseconds: 1000),
        ),
      ],
    );
  }

  /// Card de streak
  Widget _buildStreakCard(StreakData streak) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _getStreakEmoji(streak.current),
            style: const TextStyle(fontSize: 32),
          ),
          
          const SizedBox(height: 8),
          
          AnimatedCounter(
            value: streak.current,
            textStyle: const TextStyle(
              color: Color(0xFFEE583F),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
            duration: const Duration(milliseconds: 800),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            streak.current == 1 ? 'dia seguido' : 'dias seguidos',
            style: TextStyle(
              color: const Color(0xFF4D4D4D).withOpacity(0.7),
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            _getStreakMessage(streak.current),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF4D4D4D),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  /// Card de estatísticas totais
  Widget _buildTotalStatsCard(TotalProgress total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estatísticas Totais',
            style: TextStyle(
              color: Color(0xFF4D4D4D),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          
          const SizedBox(height: 16),
          
                     _buildMonthStat(
             icon: Icons.fitness_center,
             label: 'Treinos',
             value: '${total.workoutsCompleted}',
             color: const Color(0xFFF38C38),
           ),
           
           const SizedBox(height: 12),
           
           _buildMonthStat(
             icon: Icons.timer,
             label: 'Minutos',
             value: '${total.duration}',
             color: const Color(0xFFCDA8F0),
           ),
           
           const SizedBox(height: 12),
           
           _buildMonthStat(
             icon: Icons.calendar_today,
             label: 'Dias',
             value: '${total.daysTrainedThisMonth}',
             color: const Color(0xFFEE583F),
           ),
        ],
      ),
    );
  }



  /// Card de progresso do mês
  Widget _buildMonthProgressCard(MonthProgress month) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo do Mês',
            style: TextStyle(
              color: Color(0xFF4D4D4D),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Estatísticas do mês
          Row(
            children: [
              _buildMonthStat(
                icon: Icons.fitness_center,
                label: 'Treinos',
                value: '${month.workouts}',
                color: const Color(0xFFF38C38),
              ),
              
              const SizedBox(width: 20),
              
              _buildMonthStat(
                icon: Icons.timer,
                label: 'Minutos',
                value: '${month.minutes}',
                color: const Color(0xFFCDA8F0),
              ),
              
              const SizedBox(width: 20),
              
              _buildMonthStat(
                icon: Icons.calendar_today,
                label: 'Dias',
                value: '${month.days}',
                color: const Color(0xFFEE583F),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Frequência do mês
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                size: 16,
                color: Color(0xFF4D4D4D),
              ),
              
              const SizedBox(width: 8),
              
              Text(
                'Frequência: ${((month.days / 30) * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Barra de frequência animada
          AnimatedProgressBar(
            progress: (month.days / 30).clamp(0.0, 1.0),
            color: const Color(0xFF4D4D4D),
            height: 6,
            duration: const Duration(milliseconds: 1200),
          ),
          
          // Tipos de treino
          if (month.typesDistribution.isNotEmpty) ...[
            const SizedBox(height: 16),
            
            const Text(
              'Tipos de Treino',
              style: TextStyle(
                color: Color(0xFF4D4D4D),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: month.typesDistribution.entries.map((entry) {
                final minutes = entry.value is int ? entry.value : 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F1E7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$minutes min de ${entry.key}',
                    style: const TextStyle(
                      color: Color(0xFF4D4D4D),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// Estatística do mês
  Widget _buildMonthStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF4D4D4D).withOpacity(0.7),
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  /// Chip de informação
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          
          const SizedBox(width: 4),
          
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  /// Cards de carregamento
  Widget _buildLoadingCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLoadingCard(height: 160),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildLoadingCard(height: 140)),
              const SizedBox(width: 16),
              Expanded(child: _buildLoadingCard(height: 140)),
            ],
          ),
          const SizedBox(height: 16),
          _buildLoadingCard(height: 100),
          const SizedBox(height: 16),
          _buildLoadingCard(height: 200),
        ],
      ),
    );
  }

  /// Card de carregamento
  Widget _buildLoadingCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF38C38),
        ),
      ),
    );
  }

  /// Cards de erro
  Widget _buildErrorCards(BuildContext context, Object error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFEE583F),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Erro ao carregar progresso',
              style: TextStyle(
                color: Color(0xFF4D4D4D),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Tente novamente mais tarde',
              style: TextStyle(
                color: const Color(0xFF4D4D4D).withOpacity(0.7),
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Obtém o emoji do streak baseado no número de dias
  String _getStreakEmoji(int streakDays) {
    if (streakDays == 0) return '😴';
    if (streakDays == 1) return '🌱';
    if (streakDays <= 3) return '🔥';
    if (streakDays <= 7) return '🚀';
    if (streakDays <= 14) return '⚡';
    if (streakDays <= 30) return '💪';
    return '🏆';
  }

  /// Obtém a mensagem do streak baseado no número de dias
  String _getStreakMessage(int streakDays) {
    if (streakDays == 0) return 'Vamos começar hoje! ✨';
    if (streakDays == 1) return 'Primeiro dia! Continue assim! 🌱';
    if (streakDays <= 3) return 'Pegando o ritmo! 🔥';
    if (streakDays <= 7) return 'Na primeira semana! 🚀';
    if (streakDays <= 14) return 'Duas semanas incríveis! ⚡';
    if (streakDays <= 30) return 'Um mês de dedicação! 💪';
    return 'Você é incrível! 🏆';
  }
} 