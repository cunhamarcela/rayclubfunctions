import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'weekly_goal_expanded.freezed.dart';
part 'weekly_goal_expanded.g.dart';

/// Tipos de medição para metas semanais
enum GoalMeasurementType {
  @JsonValue('minutes')
  minutes('minutes', 'min', 'Minutos'),
  
  @JsonValue('days')
  days('days', 'dias', 'Dias'),
  
  @JsonValue('checkins')
  checkins('checkins', 'check-ins', 'Check-ins'),
  
  @JsonValue('weight')
  weight('weight', 'kg', 'Peso'),
  
  @JsonValue('repetitions')
  repetitions('repetitions', 'reps', 'Repetições'),
  
  @JsonValue('distance')
  distance('distance', 'km', 'Distância'),
  
  @JsonValue('custom')
  custom('custom', 'unid', 'Personalizado');

  const GoalMeasurementType(this.value, this.defaultUnit, this.displayName);
  
  final String value;
  final String defaultUnit;
  final String displayName;

  /// Obtém ícone apropriado para o tipo de medição
  IconData get icon {
    switch (this) {
      case GoalMeasurementType.minutes:
        return Icons.timer;
      case GoalMeasurementType.days:
        return Icons.calendar_today;
      case GoalMeasurementType.checkins:
        return Icons.check_circle;
      case GoalMeasurementType.weight:
        return Icons.monitor_weight;
      case GoalMeasurementType.repetitions:
        return Icons.repeat;
      case GoalMeasurementType.distance:
        return Icons.straighten;
      case GoalMeasurementType.custom:
        return Icons.tune;
    }
  }

  /// Obtém cor apropriada para o tipo de medição
  Color get color {
    switch (this) {
      case GoalMeasurementType.minutes:
        return Colors.blue;
      case GoalMeasurementType.days:
        return Colors.green;
      case GoalMeasurementType.checkins:
        return Colors.orange;
      case GoalMeasurementType.weight:
        return Colors.purple;
      case GoalMeasurementType.repetitions:
        return Colors.red;
      case GoalMeasurementType.distance:
        return Colors.teal;
      case GoalMeasurementType.custom:
        return Colors.grey;
    }
  }

  static GoalMeasurementType fromString(String value) {
    return GoalMeasurementType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => GoalMeasurementType.custom,
    );
  }
}

/// Tipos de metas pré-estabelecidas
enum GoalPresetType {
  @JsonValue('projeto_bruna_braga')
  projetoBrunaBraga('projeto_bruna_braga', 'Projeto 7 dias', '7 dias seguindo o programa especial! 💪'),
  
  @JsonValue('cardio')
  cardio('cardio', 'Meta de Cardio', 'Exercícios cardiovasculares'),
  
  @JsonValue('musculacao')
  musculacao('musculacao', 'Meta de Musculação', 'Treinos de força e resistência'),
  
  @JsonValue('custom')
  custom('custom', 'Meta Personalizada', 'Defina sua própria meta');

  const GoalPresetType(this.value, this.displayName, this.description);
  
  final String value;
  final String displayName;
  final String description;

  /// Obtém ícone apropriado para o tipo de preset
  IconData get icon {
    switch (this) {
      case GoalPresetType.projetoBrunaBraga:
        return Icons.fitness_center;
      case GoalPresetType.cardio:
        return Icons.favorite;
      case GoalPresetType.musculacao:
        return Icons.sports_gymnastics;
      case GoalPresetType.custom:
        return Icons.edit;
    }
  }

  /// Obtém cor apropriada para o tipo de preset
  Color get color {
    switch (this) {
      case GoalPresetType.projetoBrunaBraga:
        return const Color(0xFFE91E63); // Pink para Bruna Braga
      case GoalPresetType.cardio:
        return const Color(0xFFF44336); // Vermelho para cardio
      case GoalPresetType.musculacao:
        return const Color(0xFF2196F3); // Azul para musculação
      case GoalPresetType.custom:
        return const Color(0xFF9E9E9E); // Cinza para personalizado
    }
  }

  /// Retorna valores padrão para cada tipo de preset
  WeeklyGoalExpandedPreset get defaultValues {
    switch (this) {
      case GoalPresetType.projetoBrunaBraga:
        return WeeklyGoalExpandedPreset(
          goalType: this,
          measurementType: GoalMeasurementType.days,
          targetValue: 7,
          unitLabel: 'dias',
          title: 'Projeto 7 dias',
          description: 'Complete 7 dias consecutivos de treino seguindo o programa da Bruna Braga',
        );
      case GoalPresetType.cardio:
        return WeeklyGoalExpandedPreset(
          goalType: this,
          measurementType: GoalMeasurementType.minutes,
          targetValue: 150,
          unitLabel: 'min',
          title: 'Meta de Cardio',
          description: 'Meta de exercícios cardiovasculares para a semana',
        );
      case GoalPresetType.musculacao:
        return WeeklyGoalExpandedPreset(
          goalType: this,
          measurementType: GoalMeasurementType.minutes,
          targetValue: 180,
          unitLabel: 'min',
          title: 'Meta de Musculação',
          description: 'Meta de treinos de musculação para a semana',
        );
      case GoalPresetType.custom:
        return WeeklyGoalExpandedPreset(
          goalType: this,
          measurementType: GoalMeasurementType.minutes,
          targetValue: 180,
          unitLabel: 'min',
          title: 'Meta Personalizada',
          description: 'Meta personalizada definida pelo usuário',
        );
    }
  }

  static GoalPresetType fromString(String value) {
    return GoalPresetType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => GoalPresetType.custom,
    );
  }
}

/// Classe para valores padrão de presets
@freezed
class WeeklyGoalExpandedPreset with _$WeeklyGoalExpandedPreset {
  const factory WeeklyGoalExpandedPreset({
    required GoalPresetType goalType,
    required GoalMeasurementType measurementType,
    required double targetValue,
    required String unitLabel,
    required String title,
    required String description,
  }) = _WeeklyGoalExpandedPreset;
}

/// Modelo expandido de meta semanal
@freezed
class WeeklyGoalExpanded with _$WeeklyGoalExpanded {
  const factory WeeklyGoalExpanded({
    required String id,
    required String userId,
    @Default(GoalPresetType.custom) GoalPresetType goalType,
    @Default(GoalMeasurementType.minutes) GoalMeasurementType measurementType,
    @Default('Meta Semanal') String goalTitle,
    String? goalDescription,
    @Default(180.0) double targetValue,
    @Default(0.0) double currentValue,
    @Default('min') String unitLabel,
    required DateTime weekStartDate,
    required DateTime weekEndDate,
    @Default(false) bool completed,
    @Default(true) bool active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WeeklyGoalExpanded;

  factory WeeklyGoalExpanded.fromJson(Map<String, dynamic> json) =>
      _$WeeklyGoalExpandedFromJson(json);

  const WeeklyGoalExpanded._();

  /// Calcula a porcentagem de conclusão
  double get percentageCompleted {
    if (targetValue <= 0) return 0.0;
    final percentage = (currentValue / targetValue) * 100;
    return percentage.clamp(0.0, 100.0);
  }

  /// Verifica se a meta foi atingida
  bool get isAchieved => currentValue >= targetValue;

  /// Retorna o valor restante para atingir a meta
  double get remainingValue {
    final remaining = targetValue - currentValue;
    return remaining > 0 ? remaining : 0.0;
  }

  /// Formata o progresso atual para exibição
  String get formattedProgress {
    return '${_formatValue(currentValue)} / ${_formatValue(targetValue)} $unitLabel';
  }

  /// Formata o valor restante para exibição
  String get formattedRemaining {
    if (isAchieved) return 'Meta atingida! 🎉';
    return 'Faltam ${_formatValue(remainingValue)} $unitLabel';
  }

  /// Retorna mensagem motivacional baseada no progresso
  String get motivationalMessage {
    final progress = percentageCompleted;
    
    if (progress >= 100) {
      return 'Parabéns! Meta conquistada! ✨';
    } else if (progress >= 80) {
      return 'Quase lá! Você consegue! 💪';
    } else if (progress >= 50) {
      return 'Metade do caminho! Continue assim! 🌟';
    } else if (progress >= 25) {
      return 'Bom começo! Vamos em frente! 🚀';
    } else {
      return 'Vamos começar juntos! 🌱';
    }
  }

  /// Retorna cor apropriada baseada no progresso
  Color get progressColor {
    final progress = percentageCompleted;
    
    if (progress >= 100) {
      return Colors.green;
    } else if (progress >= 80) {
      return Colors.lightGreen;
    } else if (progress >= 50) {
      return Colors.orange;
    } else {
      return goalType.color;
    }
  }

  /// Verifica se está na semana atual
  bool get isCurrentWeek {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final currentWeekStartDate = DateTime(
      currentWeekStart.year,
      currentWeekStart.month,
      currentWeekStart.day,
    );
    
    return weekStartDate.isAtSameMomentAs(currentWeekStartDate);
  }

  /// Retorna número de dias restantes na semana
  int get daysRemainingInWeek {
    final now = DateTime.now();
    final difference = weekEndDate.difference(now).inDays;
    return difference > 0 ? difference + 1 : 0;
  }

  /// Formata valores para exibição
  String _formatValue(double value) {
    // Para dias e check-ins, mostrar apenas inteiros
    if (measurementType == GoalMeasurementType.days || 
        measurementType == GoalMeasurementType.checkins ||
        measurementType == GoalMeasurementType.repetitions) {
      return value.round().toString();
    }
    
    // Para outros tipos, mostrar com uma casa decimal se necessário
    return value % 1 == 0 ? value.round().toString() : value.toStringAsFixed(1);
  }

  /// Cria uma cópia com valores atualizados
  WeeklyGoalExpanded copyWithProgress(double addedValue) {
    return copyWith(
      currentValue: currentValue + addedValue,
      completed: (currentValue + addedValue) >= targetValue,
      updatedAt: DateTime.now(),
    );
  }

  /// Cria meta a partir de preset
  static WeeklyGoalExpanded fromPreset({
    required String id,
    required String userId,
    required GoalPresetType presetType,
    DateTime? weekStartDate,
    DateTime? weekEndDate,
  }) {
    final preset = presetType.defaultValues;
    final now = DateTime.now();
    final startDate = weekStartDate ?? now.subtract(Duration(days: now.weekday - 1));
    final endDate = weekEndDate ?? startDate.add(const Duration(days: 6));

    return WeeklyGoalExpanded(
      id: id,
      userId: userId,
      goalType: preset.goalType,
      measurementType: preset.measurementType,
      goalTitle: preset.title,
      goalDescription: preset.description,
      targetValue: preset.targetValue,
      unitLabel: preset.unitLabel,
      weekStartDate: startDate,
      weekEndDate: endDate,
      createdAt: now,
      updatedAt: now,
    );
  }
}

/// Opções rápidas para criação de metas
class WeeklyGoalQuickOptions {
  static const List<WeeklyGoalExpandedPreset> popularPresets = [
    // Projeto 7 dias
    WeeklyGoalExpandedPreset(
      goalType: GoalPresetType.projetoBrunaBraga,
      measurementType: GoalMeasurementType.days,
      targetValue: 7,
      unitLabel: 'dias',
      title: 'Projeto 7 dias',
      description: '7 dias seguindo o programa especial! 💪',
    ),
    
    // Cardio - opções variadas
    WeeklyGoalExpandedPreset(
      goalType: GoalPresetType.cardio,
      measurementType: GoalMeasurementType.minutes,
      targetValue: 150,
      unitLabel: 'min',
      title: 'Cardio - 150min',
      description: '150 minutos de cardio por semana',
    ),
    
    WeeklyGoalExpandedPreset(
      goalType: GoalPresetType.cardio,
      measurementType: GoalMeasurementType.days,
      targetValue: 3,
      unitLabel: 'dias',
      title: 'Cardio - 3 dias',
      description: '3 dias de cardio por semana',
    ),
    
    // Musculação - opções variadas
    WeeklyGoalExpandedPreset(
      goalType: GoalPresetType.musculacao,
      measurementType: GoalMeasurementType.minutes,
      targetValue: 180,
      unitLabel: 'min',
      title: 'Musculação - 180min',
      description: '3 horas de musculação por semana',
    ),
    
    WeeklyGoalExpandedPreset(
      goalType: GoalPresetType.musculacao,
      measurementType: GoalMeasurementType.days,
      targetValue: 4,
      unitLabel: 'dias',
      title: 'Musculação - 4 dias',
      description: '4 dias de musculação por semana',
    ),
  ];

  /// Retorna presets por categoria
  static List<WeeklyGoalExpandedPreset> getPresetsByType(GoalPresetType type) {
    return popularPresets.where((preset) => preset.goalType == type).toList();
  }

  /// Retorna todos os tipos de medição disponíveis para o usuário
  static List<GoalMeasurementType> get availableMeasurementTypes => [
    GoalMeasurementType.minutes,
    GoalMeasurementType.days,
    GoalMeasurementType.checkins,
    GoalMeasurementType.weight,
    GoalMeasurementType.repetitions,
    GoalMeasurementType.distance,
  ];
} 