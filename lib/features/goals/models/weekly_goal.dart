import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekly_goal.freezed.dart';
part 'weekly_goal.g.dart';

/// Modelo de meta semanal de treinos
@freezed
class WeeklyGoal with _$WeeklyGoal {
  const factory WeeklyGoal({
    required String id,
    required String userId,
    required int goalMinutes,
    @Default(0) int currentMinutes,
    required DateTime weekStartDate,
    required DateTime weekEndDate,
    @Default(false) bool completed,
    @Default(0.0) double percentageCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WeeklyGoal;

  factory WeeklyGoal.fromJson(Map<String, dynamic> json) =>
      _$WeeklyGoalFromJson(json);
}

/// Opções predefinidas de metas semanais
enum WeeklyGoalOption {
  beginner(60, 'Iniciante', '1 hora por semana'),
  light(120, 'Leve', '2 horas por semana'),
  moderate(180, 'Moderado', '3 horas por semana'),
  active(300, 'Ativo', '5 horas por semana'),
  intense(420, 'Intenso', '7 horas por semana'),
  athlete(600, 'Atleta', '10 horas por semana'),
  custom(0, 'Personalizado', 'Defina sua própria meta');

  final int minutes;
  final String label;
  final String description;

  const WeeklyGoalOption(this.minutes, this.label, this.description);

  /// Converte minutos para formato legível
  String get formattedTime {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '$hours h';
      } else {
        return '$hours h $mins min';
      }
    }
  }

  /// Obtém opção baseada em minutos
  static WeeklyGoalOption fromMinutes(int minutes) {
    return WeeklyGoalOption.values.firstWhere(
      (option) => option.minutes == minutes,
      orElse: () => WeeklyGoalOption.custom,
    );
  }
} 