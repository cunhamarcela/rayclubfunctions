// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/repositories/workout_record_repository.dart';

/// Provider para o ViewModel do histórico de treinos
final workoutHistoryViewModelProvider = 
    StateNotifierProvider<WorkoutHistoryViewModel, WorkoutHistoryState>((ref) {
  final repository = ref.watch(workoutRecordRepositoryProvider);
  return WorkoutHistoryViewModel(repository);
});

/// Estados possíveis do histórico de treinos
sealed class WorkoutHistoryState {
  const WorkoutHistoryState();
}

class WorkoutHistoryLoading extends WorkoutHistoryState {
  const WorkoutHistoryLoading();
}

class WorkoutHistoryLoaded extends WorkoutHistoryState {
  final List<WorkoutRecord> allRecords;
  final DateTime? selectedDate;
  final List<WorkoutRecord>? selectedDateRecords;
  
  const WorkoutHistoryLoaded({
    required this.allRecords,
    this.selectedDate,
    this.selectedDateRecords,
  });
}

class WorkoutHistoryEmpty extends WorkoutHistoryState {
  const WorkoutHistoryEmpty();
}

class WorkoutHistoryError extends WorkoutHistoryState {
  final String message;
  
  const WorkoutHistoryError(this.message);
}

/// ViewModel para gerenciar o histórico de treinos
class WorkoutHistoryViewModel extends StateNotifier<WorkoutHistoryState> {
  final WorkoutRecordRepository _repository;
  
  WorkoutHistoryViewModel(this._repository) : super(const WorkoutHistoryLoading()) {
    loadWorkoutHistory();
  }
  
  /// Carrega o histórico de treinos do usuário atual
  Future<void> loadWorkoutHistory() async {
    try {
      state = const WorkoutHistoryLoading();
      
      final records = await _repository.getUserWorkoutRecords();
      
      if (records.isEmpty) {
        state = const WorkoutHistoryEmpty();
      } else {
        state = WorkoutHistoryLoaded(
          allRecords: records,
          selectedDate: null,
          selectedDateRecords: null,
        );
      }
    } catch (e) {
      state = WorkoutHistoryError('Erro ao carregar histórico: ${e.toString()}');
    }
  }
  
  /// Obtém os dias que têm treinos registrados
  List<DateTime> getDaysWithWorkouts() {
    final currentState = state;
    if (currentState is! WorkoutHistoryLoaded) return [];
    
    return currentState.allRecords
        .map((record) => DateTime(
              record.date.year,
              record.date.month,
              record.date.day,
            ))
        .toSet()
        .toList()
      ..sort();
  }
  
  /// Seleciona uma data específica e filtra os treinos
  void selectDate(DateTime date) {
    final currentState = state;
    if (currentState is! WorkoutHistoryLoaded) return;
    
    final selectedDay = DateTime(date.year, date.month, date.day);
    final dayRecords = currentState.allRecords
        .where((record) {
          final recordDay = DateTime(
            record.date.year,
            record.date.month,
            record.date.day,
          );
          return recordDay == selectedDay;
        })
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    
    state = WorkoutHistoryLoaded(
      allRecords: currentState.allRecords,
      selectedDate: date,
      selectedDateRecords: dayRecords,
    );
  }
  
  /// Força o recarregamento dos dados
  Future<void> refresh() async {
    await loadWorkoutHistory();
  }

  /// Obtém os treinos agrupados por data
  Map<DateTime, List<WorkoutRecord>> getWorkoutsByDay() {
    final currentState = state;
    if (currentState is! WorkoutHistoryLoaded) return {};
    
    final workoutsByDay = <DateTime, List<WorkoutRecord>>{};
    
    for (final record in currentState.allRecords) {
      final normalizedDate = DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
      );
      
      workoutsByDay.putIfAbsent(normalizedDate, () => []).add(record);
    }
    
    return workoutsByDay;
  }

  /// Limpa a seleção de data
  void clearSelectedDate() {
    final currentState = state;
    if (currentState is! WorkoutHistoryLoaded) return;
    
    state = WorkoutHistoryLoaded(
      allRecords: currentState.allRecords,
      selectedDate: null,
      selectedDateRecords: null,
    );
  }
} 