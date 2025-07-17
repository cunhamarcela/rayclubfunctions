// Flutter imports:
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:ray_club_app/features/workout/models/workout_record.dart';

/// Widget que exibe um item de histórico de treino com indicação de status
class WorkoutHistoryItem extends StatelessWidget {
  /// Registro de treino a ser exibido
  final WorkoutRecord workout;
  
  /// Callback opcional para quando o item for pressionado
  final VoidCallback? onTap;
  
  /// DateFormat para formatação de data
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Construtor
  WorkoutHistoryItem({
    Key? key,
    required this.workout,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nome do treino
                  Expanded(
                    child: Text(
                      workout.workoutName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Status de processamento
                  _buildProcessingStatus(),
                ],
              ),
              const SizedBox(height: 8),
              // Tipo de treino e duração
              Row(
                children: [
                  Icon(
                    _getWorkoutIcon(workout.workoutType),
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    workout.workoutType,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${workout.durationMinutes} min',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Data do treino
              Text(
                _dateFormat.format(workout.date),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              // Mensagem de erro, quando aplicável
              if (workout.hasFailed) _buildErrorMessage(),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Constrói o widget de status de processamento
  Widget _buildProcessingStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: workout.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: workout.statusColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador visual de processamento
          if (!workout.isFullyProcessed)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: workout.statusColor,
              ),
            ),
          if (!workout.isFullyProcessed)
            const SizedBox(width: 4),
          Text(
            workout.statusText,
            style: TextStyle(
              fontSize: 12,
              color: workout.statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Constrói o widget de mensagem de erro
  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              workout.processingErrorMessage ?? 'Erro no processamento',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Obtém o ícone com base no tipo de treino
  IconData _getWorkoutIcon(String type) {
    switch (type.toLowerCase()) {
      case 'musculação':
      case 'bodybuilding':
        return Icons.fitness_center;
      case 'força':
      case 'strength':
        return Icons.sports_gymnastics;
      case 'funcional':
      case 'functional':
        return Icons.sports_martial_arts;
      case 'pilates':
        return Icons.spa;
      case 'corrida':
      case 'running':
        return Icons.directions_run;
      case 'alongamento':
      case 'flexibilidade':
        return Icons.accessibility_new;
      case 'fisioterapia':
        return Icons.healing;
      default:
        return Icons.fitness_center;
    }
  }
} 