// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_typography.dart';
import 'package:ray_club_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:ray_club_app/features/workout/providers/workout_providers.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_view_model.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_history_view_model.dart';

/// Widget que exibe um calendário de treinos no dashboard
class WorkoutCalendarWidget extends ConsumerStatefulWidget {
  /// Construtor
  const WorkoutCalendarWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<WorkoutCalendarWidget> createState() => _WorkoutCalendarWidgetState();
}

class _WorkoutCalendarWidgetState extends ConsumerState<WorkoutCalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    // Obter dados de treinos do repositório de workout
    final workoutsData = ref.watch(userWorkoutsProvider);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Calendário de Treinos',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Estado do calendário
            workoutsData.when(
              data: (workouts) {
                // Log the workouts for debugging
                debugPrint('📅 Calendário: Recebido ${workouts.length} treinos para exibição');
                
                if (workouts.isEmpty) {
                  debugPrint('⚠️ Calendário: Nenhum treino encontrado no histórico');
                } else {
                  for (var i = 0; i < workouts.length && i < 3; i++) {
                    final workout = workouts[i];
                    debugPrint('📊 Treino #$i: ${workout.workoutName} em ${DateFormat('dd/MM/yyyy').format(workout.date)}');
                  }
                }
                
                // Criar mapa com marcações de treinos por dia
                final workoutMarkers = <DateTime, List<dynamic>>{};
                
                for (final workout in workouts) {
                  // Normaliza a data removendo horas/minutos/segundos para comparar apenas a data
                  final workoutDate = DateTime(
                    workout.date.year,
                    workout.date.month,
                    workout.date.day,
                  );
                  
                  if (workoutMarkers.containsKey(workoutDate)) {
                    workoutMarkers[workoutDate]!.add(workout);
                  } else {
                    workoutMarkers[workoutDate] = [workout];
                  }
                }
                
                return TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 30)),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) {
                    final normalizedDay = DateTime(day.year, day.month, day.day);
                    return workoutMarkers[normalizedDay] ?? [];
                  },
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    
                    // Log the selected day and its workouts
                    final normalizedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                    final dayWorkouts = workoutMarkers[normalizedDay] ?? [];
                    debugPrint('🔍 Dia selecionado: ${DateFormat('dd/MM/yyyy').format(selectedDay)}');
                    debugPrint('🔍 Treinos neste dia: ${dayWorkouts.length}');
                    
                    // Show workout details when a day is selected
                    if (dayWorkouts.isNotEmpty) {
                      _showWorkoutDetails(context, dayWorkouts, selectedDay);
                    }
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  // Estilização do calendário
                  calendarStyle: CalendarStyle(
                    markersMaxCount: 3,
                    markerDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: const Icon(
                      Icons.chevron_left,
                      color: AppColors.primary,
                    ),
                    rightChevronIcon: const Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) {
                // Log the error for debugging
                debugPrint('❌ Erro ao carregar calendário: $error');
                debugPrint('Stack trace: $stackTrace');
                
                return SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Erro ao carregar o calendário de treinos',
                          style: AppTypography.bodyMedium.copyWith(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Usar o provider correto para carregar histórico de treinos
                            ref.read(workoutHistoryViewModelProvider.notifier).loadWorkoutHistory();
                          },
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Legenda
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Dias com treino',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Exibe um diálogo com os detalhes dos treinos para um dia específico
  void _showWorkoutDetails(BuildContext context, List<dynamic> workouts, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Treinos em ${DateFormat('dd/MM/yyyy').format(date)}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return ListTile(
                title: Text(workout.workoutName),
                subtitle: Text('${workout.durationMinutes} minutos'),
                leading: const Icon(Icons.fitness_center, color: AppColors.primary),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
} 