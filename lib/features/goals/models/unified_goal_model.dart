// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

// Project imports:

part 'unified_goal_model.freezed.dart';
part 'unified_goal_model.g.dart';

/// **MODELO UNIFICADO DE METAS RAY CLUB**
/// 
/// **Data:** 29 de Janeiro de 2025 às 15:30
/// **Objetivo:** Consolidar todas as estruturas de metas em uma única implementação
/// **Referência:** Sistema de metas unificado Ray Club
/// 
/// Este modelo substitui e unifica:
/// - UserGoal
/// - PersonalizedGoal  
/// - WeeklyGoal
/// - GoalData
/// - WorkoutCategoryGoal

/// Tipos de metas disponíveis no sistema
enum UnifiedGoalType {
  @JsonValue('workout_category')
  workoutCategory('workout_category', 'Modalidade de Exercício', Icons.fitness_center),
  
  @JsonValue('weekly_minutes')
  weeklyMinutes('weekly_minutes', 'Meta Semanal', Icons.calendar_today),
  
  @JsonValue('daily_habit')
  dailyHabit('daily_habit', 'Hábito Diário', Icons.check_circle),
  
  @JsonValue('custom')
  custom('custom', 'Personalizada', Icons.tune);

  const UnifiedGoalType(this.value, this.displayName, this.icon);
  
  final String value;
  final String displayName;
  final IconData icon;
}

/// **CATEGORIAS DE EXERCÍCIO PARA METAS**
/// ⚠️ ALINHADAS COM OS DADOS REAIS DO BANCO workout_records
/// Baseado no diagnóstico: Musculação(576), Cardio(318), Funcional(194), etc.
enum GoalCategory {
  @JsonValue('Musculação')
  musculacao('Musculação', '💪', Colors.red),
  
  @JsonValue('Cardio')
  cardio('Cardio', '❤️', Colors.red),
  
  @JsonValue('Funcional')
  funcional('Funcional', '🔥', Colors.orange),
  
  @JsonValue('Caminhada')
  caminhada('Caminhada', '🚶‍♀️', Colors.green),
  
  @JsonValue('Yoga')
  yoga('Yoga', '🧘‍♀️', Colors.purple),
  
  @JsonValue('Corrida')
  corrida('Corrida', '🏃‍♀️', Colors.cyan),
  
  @JsonValue('Pilates')
  pilates('Pilates', '🤸‍♀️', Colors.pink),
  
  @JsonValue('Dança')
  danca('Dança', '💃', Colors.yellow),
  
  @JsonValue('HIIT')
  hiit('HIIT', '⚡', Colors.deepOrange),
  
  @JsonValue('Outro')
  outro('Outro', '🎯', Colors.grey);

  const GoalCategory(this.displayName, this.emoji, this.color);
  final String displayName;
  final String emoji;
  final Color color;
  
  /// Getter para compatibilidade com código antigo
  String get value => displayName;

  /// Lista estática dos tipos de exercício (baseada nos dados reais do banco)
  static List<String> get workoutTypes => [
    'Musculação',    // 576 registros
    'Cardio',        // 318 registros  
    'Funcional',     // 194 registros
    'Caminhada',     // 96 registros
    'Yoga',          // 89 registros
    'Outro',         // 79 registros
    'Corrida',       // 69 registros
    'Pilates',       // 49 registros
    'Dança',         // 37 registros
    'HIIT',          // 29 registros
  ];

  /// Converte uma string para um enum GoalCategory
  static GoalCategory? fromString(String? value) {
    if (value == null) return null;
    try {
      return GoalCategory.values.firstWhere((e) => e.displayName == value);
    } catch (e) {
      return GoalCategory.outro;
    }
  }
  
  /// Converte um valor string para enum GoalCategory (alias para fromString)
  static GoalCategory? fromValue(String? value) {
    return fromString(value);
  }

  /// Verifica se um tipo de exercício é válido
  static bool isValidWorkoutType(String value) {
    return workoutTypes.contains(value);
  }
}

/// Unidades de medida para metas
enum GoalUnit {
  @JsonValue('sessoes')
  sessoes('sessoes', 'sessões', 'check-ins'),
  
  @JsonValue('minutos')
  minutos('minutos', 'min', 'minutos'),
  
  @JsonValue('horas')
  horas('horas', 'h', 'horas'),
  
  @JsonValue('dias')
  dias('dias', 'dias', 'dias'),
  
  @JsonValue('vezes')
  vezes('vezes', 'x', 'vezes'),
  
  @JsonValue('quilometros')
  quilometros('quilometros', 'km', 'quilômetros'),
  
  @JsonValue('calorias')
  calorias('calorias', 'kcal', 'calorias'),
  
  @JsonValue('unidade')
  unidade('unidade', 'unid', 'unidades');

  const GoalUnit(this.value, this.shortLabel, this.fullLabel);
  
  final String value;
  final String shortLabel;
  final String fullLabel;
}

/// **MODELO PRINCIPAL - META UNIFICADA**
@freezed
class UnifiedGoal with _$UnifiedGoal {
  const factory UnifiedGoal({
    /// Identificadores
    required String id,
    required String userId,
    
    /// Informações básicas
    required String title,
    String? description,
    
    /// Tipo e categoria
    required UnifiedGoalType type,
    GoalCategory? category,  // Apenas para workout_category
    
    /// Valores de progresso
    required double targetValue,
    @Default(0.0) double currentValue,
    required GoalUnit unit,
    @Default('minutes') String measurementType, // 'minutes' ou 'days'
    
    /// Período da meta
    required DateTime startDate,
    DateTime? endDate,
    
    /// Status
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    
    /// Auto-incremento
    @Default(true) bool autoIncrement, // Se deve ser atualizada automaticamente por treinos
    
    /// Timestamps
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _UnifiedGoal;

  factory UnifiedGoal.fromJson(Map<String, dynamic> json) => _$UnifiedGoalFromJson(json);
  
  const UnifiedGoal._();
  
  /// Calcula o percentual de conclusão
  double get progressPercentage => (currentValue / targetValue).clamp(0.0, 1.0);
  
  /// Verifica se a meta está ativa
  bool get isActive => !isCompleted && (endDate == null || endDate!.isAfter(DateTime.now()));

  /// **CONVERSÃO DO BANCO DE DADOS**
  /// Cria UnifiedGoal a partir de dados do Supabase
  /// ⚠️ IMPORTANTE: Usar nomes reais das colunas do banco
  factory UnifiedGoal.fromDatabaseMap(Map<String, dynamic> data) {
    return UnifiedGoal(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      type: _parseGoalType(data['goal_type'] as String), // ← CORREÇÃO: goal_type
      category: GoalCategory.fromString(data['category'] as String?),
      targetValue: (data['target_value'] as num).toDouble(), // ← CORREÇÃO: target_value
      currentValue: (data['current_value'] as num?)?.toDouble() ?? 0.0, // ← CORREÇÃO: current_value
      unit: _parseGoalUnit(data['unit'] as String),
      measurementType: data['measurement_type'] as String? ?? 'minutes',
      startDate: DateTime.parse(data['start_date'] as String),
      endDate: data['target_date'] != null ? DateTime.parse(data['target_date'] as String) : null, // ← CORREÇÃO: target_date
      isCompleted: data['completed_at'] != null,
      completedAt: data['completed_at'] != null ? DateTime.parse(data['completed_at'] as String) : null,
      autoIncrement: true, // Default para true
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at'] as String) : null,
    );
  }

  /// **CONVERSÃO PARA BANCO DE DADOS**
  /// Converte UnifiedGoal para formato do Supabase
  /// ⚠️ IMPORTANTE: Usar nomes reais das colunas do banco
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'goal_type': type.value, // ← CORREÇÃO: goal_type
      'category': category?.displayName,
      'target_value': targetValue, // ← CORREÇÃO: target_value
      'current_value': currentValue, // ← CORREÇÃO: current_value
      'unit': unit.value,
      'measurement_type': measurementType,
      'start_date': startDate.toIso8601String(),
      'target_date': endDate?.toIso8601String(), // ← CORREÇÃO: target_date
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Parse do tipo de meta a partir de string
  static UnifiedGoalType _parseGoalType(String type) {
    switch (type) {
      case 'workout_category':
        return UnifiedGoalType.workoutCategory;
      case 'weekly_minutes':
        return UnifiedGoalType.weeklyMinutes;
      case 'daily_habit':
        return UnifiedGoalType.dailyHabit;
      case 'custom':
        return UnifiedGoalType.custom;
      default:
        return UnifiedGoalType.custom;
    }
  }

  /// Parse da unidade a partir de string
  static GoalUnit _parseGoalUnit(String unit) {
    return GoalUnit.values.firstWhere(
      (u) => u.value == unit,
      orElse: () => GoalUnit.unidade,
    );
  }
  
  /// Verifica se a meta deve ser auto-incrementada pelo treino
  bool get shouldAutoIncrement => autoIncrement && isActive;
  
  /// Retorna cor baseada na categoria ou tipo
  Color get displayColor {
    if (category != null) {
      return category!.color;
    }
    
    switch (type) {
      case UnifiedGoalType.workoutCategory:
        return Colors.blue;
      case UnifiedGoalType.weeklyMinutes:
        return Colors.green;
      case UnifiedGoalType.dailyHabit:
        return Colors.orange;
      case UnifiedGoalType.custom:
        return Colors.grey;
    }
  }
  
  /// Retorna emoji baseado na categoria ou tipo
  String get displayEmoji {
    if (category != null) {
      return category!.emoji;
    }
    
    switch (type) {
      case UnifiedGoalType.workoutCategory:
        return '🏋️‍♀️';
      case UnifiedGoalType.weeklyMinutes:
        return '📅';
      case UnifiedGoalType.dailyHabit:
        return '✅';
      case UnifiedGoalType.custom:
        return '🎯';
    }
  }
  

}

/// **FACTORY METHODS PARA CRIAR METAS PRÉ-DEFINIDAS**
extension UnifiedGoalFactory on UnifiedGoal {
  /// Cria uma meta de modalidade de exercício
  static UnifiedGoal createWorkoutCategoryGoal({
    required String userId,
    required GoalCategory category,
    required int targetSessions,
    DateTime? endDate,
  }) {
    return UnifiedGoal(
      id: '', // Será definido pelo banco
      userId: userId,
      title: 'Meta de ${category.displayName}',
      description: 'Complete $targetSessions sessões de ${category.displayName}',
      type: UnifiedGoalType.workoutCategory,
      category: category,
      targetValue: targetSessions.toDouble(),
      unit: GoalUnit.sessoes,
      startDate: DateTime.now(),
      endDate: endDate,
      autoIncrement: true,
      createdAt: DateTime.now(),
    );
  }
  
  /// Cria uma meta semanal de minutos
  static UnifiedGoal createWeeklyMinutesGoal({
    required String userId,
    required int targetMinutes,
  }) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return UnifiedGoal(
      id: '',
      userId: userId,
      title: 'Meta Semanal',
      description: 'Complete $targetMinutes minutos de exercício esta semana',
      type: UnifiedGoalType.weeklyMinutes,
      targetValue: targetMinutes.toDouble(),
      unit: GoalUnit.minutos,
      startDate: weekStart,
      endDate: weekEnd,
      autoIncrement: true,
      createdAt: DateTime.now(),
    );
  }
  
  /// Cria uma meta de hábito diário
  static UnifiedGoal createDailyHabitGoal({
    required String userId,
    required String title,
    required String description,
    required int targetDays,
  }) {
    return UnifiedGoal(
      id: '',
      userId: userId,
      title: title,
      description: description,
      type: UnifiedGoalType.dailyHabit,
      targetValue: targetDays.toDouble(),
      unit: GoalUnit.dias,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: targetDays + 7)), // 1 semana extra
      autoIncrement: false, // Hábitos são marcados manualmente
      createdAt: DateTime.now(),
    );
  }
} 