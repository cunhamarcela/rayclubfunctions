// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/models/dashboard_fitness_data.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_fitness_view_model.dart';

/// Modal para exibir detalhes de um dia específico
class DayDetailsModal extends ConsumerWidget {
  final DateTime date;

  const DayDetailsModal({
    Key? key,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayDetailsState = ref.watch(dayDetailsProvider(date));

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F1E7), // Fundo bege claro
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle do modal
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF4D4D4D).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          _buildHeader(context),
          
          // Conteúdo
          Expanded(
            child: dayDetailsState.when(
              data: (data) => _buildContent(context, data),
              loading: () => _buildLoading(),
              error: (error, _) => _buildError(context, error),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o header do modal
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE', 'pt_BR').format(date),
                style: const TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                DateFormat('d \'de\' MMMM', 'pt_BR').format(date),
                style: const TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: Color(0xFF4D4D4D),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o conteúdo do modal
  Widget _buildContent(BuildContext context, DayDetailsData data) {
    if (data.workouts.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumo do dia
          _buildDaySummary(data),
          
          const SizedBox(height: 24),
          
          // Lista de treinos
          _buildWorkoutsList(data.workouts),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Constrói o resumo do dia
  Widget _buildDaySummary(DayDetailsData data) {
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
            'Resumo do Dia',
            style: TextStyle(
              color: Color(0xFF4D4D4D),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildSummaryItem(
                icon: Icons.fitness_center,
                label: 'Treinos',
                value: '${data.totalWorkouts}',
                color: const Color(0xFFF38C38),
              ),
              
              const SizedBox(width: 20),
              
              _buildSummaryItem(
                icon: Icons.timer,
                label: 'Minutos',
                value: '${data.totalMinutes}',
                color: const Color(0xFFCDA8F0),
              ),
              
              const SizedBox(width: 20),
              
              _buildSummaryItem(
                icon: Icons.star,
                label: 'Pontos',
                value: '${data.totalPoints}',
                color: const Color(0xFFEE583F),
              ),
            ],
          ),
          
          if (data.workouts.isNotEmpty) ...[
            const SizedBox(height: 16),
            
            Text(
              'Tipos: ${data.workouts.map((w) => w.type).toSet().join(', ')}',
              style: TextStyle(
                color: const Color(0xFF4D4D4D).withOpacity(0.7),
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Constrói um item do resumo
  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
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

  /// Constrói a lista de treinos
  Widget _buildWorkoutsList(List<WorkoutSummary> workouts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Treinos Realizados',
          style: TextStyle(
            color: Color(0xFF4D4D4D),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        
        const SizedBox(height: 16),
        
        ...workouts.map((workout) => _buildWorkoutItem(workout)),
      ],
    );
  }

  /// Constrói um item de treino
  Widget _buildWorkoutItem(WorkoutSummary workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone do tipo de treino
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getWorkoutTypeColor(workout.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getWorkoutTypeIcon(workout.type),
              color: _getWorkoutTypeColor(workout.type),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Informações do treino
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: const TextStyle(
                    color: Color(0xFF4D4D4D),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Text(
                      workout.type,
                      style: TextStyle(
                        color: const Color(0xFF4D4D4D).withOpacity(0.7),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    Text(
                      '•',
                      style: TextStyle(
                        color: const Color(0xFF4D4D4D).withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    Text(
                      '${workout.duration} min',
                      style: TextStyle(
                        color: const Color(0xFF4D4D4D).withOpacity(0.7),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Pontos e status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (workout.points > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EDC9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${workout.points} pts',
                    style: const TextStyle(
                      color: Color(0xFF4D4D4D),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                
                const SizedBox(height: 4),
              ],
              
              if (workout.isChallengeValid) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEE583F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Desafio ✓',
                    style: TextStyle(
                      color: Color(0xFFEE583F),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói o estado vazio
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE6E6E6),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.fitness_center,
              size: 40,
              color: Color(0xFF4D4D4D),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Nenhum treino registrado',
            style: TextStyle(
              color: Color(0xFF4D4D4D),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Que tal começar um treino hoje?',
            style: TextStyle(
              color: const Color(0xFF4D4D4D).withOpacity(0.7),
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o estado de carregamento
  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFFF38C38),
      ),
    );
  }

  /// Constrói o estado de erro
  Widget _buildError(BuildContext context, Object error) {
    return Center(
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
            'Erro ao carregar detalhes',
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
    );
  }

  /// Obtém a cor do tipo de treino
  Color _getWorkoutTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'cardio':
        return const Color(0xFFEE583F);
      case 'força':
      case 'musculação':
        return const Color(0xFFF38C38);
      case 'funcional':
        return const Color(0xFFCDA8F0);
      case 'yoga':
        return const Color(0xFFF1EDC9);
      default:
        return const Color(0xFF4D4D4D);
    }
  }

  /// Obtém o ícone do tipo de treino
  IconData _getWorkoutTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cardio':
        return Icons.directions_run;
      case 'força':
      case 'musculação':
        return Icons.fitness_center;
      case 'funcional':
        return Icons.sports_gymnastics;
      case 'yoga':
        return Icons.self_improvement;
      default:
        return Icons.sports;
    }
  }
} 