// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_category_goal.freezed.dart';
part 'workout_category_goal.g.dart';

/// Modelo que representa uma meta semanal por categoria de treino
/// Exemplo: "120 minutos de Corrida por semana"
@freezed
class WorkoutCategoryGoal with _$WorkoutCategoryGoal {
  const factory WorkoutCategoryGoal({
    /// Identificador único da meta
    required String id,
    
    /// Identificador do usuário
    required String userId,
    
    /// Categoria do treino (corrida, yoga, funcional, etc.)
    required String category,
    
    /// Meta em minutos para a semana
    required int goalMinutes,
    
    /// Minutos acumulados na semana atual
    @Default(0) int currentMinutes,
    
    /// Data de início da semana
    required DateTime weekStartDate,
    
    /// Data de fim da semana
    required DateTime weekEndDate,
    
    /// Se a meta está ativa
    @Default(true) bool isActive,
    
    /// Se a meta foi completada
    @Default(false) bool completed,
    
    /// Data de criação
    required DateTime createdAt,
    
    /// Data da última atualização
    DateTime? updatedAt,
  }) = _WorkoutCategoryGoal;

  /// Cria um WorkoutCategoryGoal a partir de um mapa JSON
  factory WorkoutCategoryGoal.fromJson(Map<String, dynamic> json) => 
      _$WorkoutCategoryGoalFromJson(json);
  
  const WorkoutCategoryGoal._();
  
  /// Retorna o percentual de conclusão da meta (0-100)
  double get percentageCompleted {
    if (goalMinutes <= 0) return 0.0;
    return (currentMinutes / goalMinutes * 100).clamp(0.0, 100.0);
  }
  
  /// Retorna a porcentagem como valor de 0 a 1 para widgets de progresso
  double get progressValue {
    if (goalMinutes <= 0) return 0.0;
    return (currentMinutes / goalMinutes).clamp(0.0, 1.0);
  }
  
  /// Verifica se a meta foi atingida
  bool get isCompleted => currentMinutes >= goalMinutes;
  
  /// Retorna quantos minutos ainda faltam para completar a meta
  int get remainingMinutes {
    final remaining = goalMinutes - currentMinutes;
    return remaining > 0 ? remaining : 0;
  }
  
  /// Converte categoria para formato de exibição amigável
  String get categoryDisplayName {
    switch (category.toLowerCase()) {
      case 'corrida':
        return 'Corrida 🏃‍♀️';
      case 'caminhada':
        return 'Caminhada 🚶‍♀️';
      case 'yoga':
        return 'Yoga 🧘‍♀️';
      case 'alongamento':
        return 'Alongamento 🤸‍♀️';
      case 'funcional':
        return 'Funcional 💪';
      case 'crossfit':
        return 'CrossFit 🏋️‍♀️';
      case 'natacao':
        return 'Natação 🏊‍♀️';
      case 'ciclismo':
        return 'Ciclismo 🚴‍♀️';
      case 'musculacao':
        return 'Musculação 🏋️‍♂️';
      case 'pilates':
        return 'Pilates 🤸‍♀️';
      default:
        return category.substring(0, 1).toUpperCase() + 
               category.substring(1).toLowerCase();
    }
  }
  
  /// Retorna cor temática baseada na categoria
  String get categoryColor {
    switch (category.toLowerCase()) {
      case 'corrida':
      case 'caminhada':
        return '#FF6B6B'; // Vermelho
      case 'yoga':
      case 'alongamento':
        return '#A8E6CF'; // Verde claro
      case 'funcional':
      case 'crossfit':
      case 'musculacao':
        return '#FF8E53'; // Laranja
      case 'natacao':
        return '#4ECDC4'; // Azul turquesa
      case 'ciclismo':
        return '#45B7D1'; // Azul
      case 'pilates':
        return '#DDA0DD'; // Roxo claro
      default:
        return '#95A5A6'; // Cinza
    }
  }
  
  /// Retorna mensagem motivacional baseada no progresso
  String get motivationalMessage {
    final percentage = percentageCompleted;
    
    if (isCompleted) {
      return 'Parabéns! Meta atingida! 🎉';
    } else if (percentage >= 80) {
      return 'Quase lá! Você consegue! 💪';
    } else if (percentage >= 50) {
      return 'Metade do caminho feito! 🔥';
    } else if (percentage >= 25) {
      return 'Bom começo! Continue assim! ✨';
    } else if (currentMinutes > 0) {
      return 'Todo progresso conta! 🌱';
    } else {
      return 'Vamos começar? 🚀';
    }
  }
  
  /// Converte minutos para formato de exibição (ex: "1h 30min")
  String get currentMinutesDisplay => _formatMinutes(currentMinutes);
  String get goalMinutesDisplay => _formatMinutes(goalMinutes);
  String get remainingMinutesDisplay => _formatMinutes(remainingMinutes);
  
  String _formatMinutes(int minutes) {
    if (minutes == 0) return '0min';
    
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (hours == 0) {
      return '${mins}min';
    } else if (mins == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${mins}min';
    }
  }
}

/// Modelo para evolução semanal de uma categoria
@freezed
class WeeklyEvolution with _$WeeklyEvolution {
  const factory WeeklyEvolution({
    /// Data de início da semana
    required DateTime weekStartDate,
    
    /// Meta em minutos para a semana
    required int goalMinutes,
    
    /// Minutos realizados na semana
    required int currentMinutes,
    
    /// Percentual completado
    required double percentageCompleted,
    
    /// Se a meta foi completada
    required bool completed,
  }) = _WeeklyEvolution;

  /// Cria um WeeklyEvolution a partir de um mapa JSON
  factory WeeklyEvolution.fromJson(Map<String, dynamic> json) => 
      _$WeeklyEvolutionFromJson(json);
      
  const WeeklyEvolution._();
  
  /// Data de fim da semana (calculada)
  DateTime get weekEndDate => weekStartDate.add(const Duration(days: 6));
  
  /// Descrição da semana (ex: "12-18 Jan")
  String get weekDescription {
    final start = weekStartDate;
    final end = weekEndDate;
    
    // Se for a semana atual
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    
    if (start.difference(currentWeekStart).inDays.abs() < 1) {
      return 'Esta semana';
    }
    
    // Se for na semana passada
    final lastWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    if (start.difference(lastWeekStart).inDays.abs() < 1) {
      return 'Semana passada';
    }
    
    // Formato geral
    final months = [
      '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    
    if (start.month == end.month) {
      return '${start.day}-${end.day} ${months[start.month]}';
    } else {
      return '${start.day} ${months[start.month]} - ${end.day} ${months[end.month]}';
    }
  }
} 