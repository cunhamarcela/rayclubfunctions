import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'personalized_goal.freezed.dart';
part 'personalized_goal.g.dart';

/// Tipos de medição para metas personalizáveis
enum PersonalizedGoalMeasurementType {
  @JsonValue('check')
  check('check', 'check-ins', 'Check-ins', Icons.check_circle, Colors.orange),
  
  @JsonValue('minutes')
  minutes('minutes', 'min', 'Minutos', Icons.timer, Colors.blue),
  
  @JsonValue('weight')
  weight('weight', 'kg', 'Peso', Icons.monitor_weight, Colors.purple),
  
  @JsonValue('calories')
  calories('calories', 'kcal', 'Calorias', Icons.local_fire_department, Colors.red),
  
  @JsonValue('liters')
  liters('liters', 'L', 'Litros', Icons.opacity, Colors.cyan),
  
  @JsonValue('days')
  days('days', 'dias', 'Dias', Icons.calendar_today, Colors.green),
  
  @JsonValue('custom')
  custom('custom', 'unid', 'Personalizado', Icons.tune, Colors.grey);

  const PersonalizedGoalMeasurementType(
    this.value, 
    this.defaultUnit, 
    this.displayName, 
    this.icon, 
    this.color
  );
  
  final String value;
  final String defaultUnit;
  final String displayName;
  final IconData icon;
  final Color color;

  /// Verifica se é modalidade check (círculos clicáveis)
  bool get isCheckMode => this == PersonalizedGoalMeasurementType.check;
  
  /// Verifica se é modalidade unidade (barra de progresso + botão +)
  bool get isUnitMode => !isCheckMode;

  /// Obtém incremento sugerido baseado no tipo
  double get suggestedIncrement {
    switch (this) {
      case PersonalizedGoalMeasurementType.check:
        return 1;
      case PersonalizedGoalMeasurementType.minutes:
        return 10; // 10 minutos por vez
      case PersonalizedGoalMeasurementType.weight:
        return 0.5; // 0.5 kg por vez
      case PersonalizedGoalMeasurementType.calories:
        return 50; // 50 kcal por vez
      case PersonalizedGoalMeasurementType.liters:
        return 0.25; // 250ml por vez
      case PersonalizedGoalMeasurementType.days:
        return 1;
      case PersonalizedGoalMeasurementType.custom:
        return 1;
    }
  }

  static PersonalizedGoalMeasurementType fromString(String value) {
    return PersonalizedGoalMeasurementType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PersonalizedGoalMeasurementType.custom,
    );
  }
}

/// Tipos de metas pré-estabelecidas
enum PersonalizedGoalPresetType {
  @JsonValue('projeto_7_dias')
  projeto7Dias('projeto_7_dias', 'Projeto 7 Dias'),
  
  // Modalidades de Exercício
  @JsonValue('cardio_check')
  cardioCheck('cardio_check', 'Cardio'),
  
  @JsonValue('musculacao_check')
  musculacaoCheck('musculacao_check', 'Musculação'),
  
  @JsonValue('funcional_check')
  funcionalCheck('funcional_check', 'Funcional'),
  
  @JsonValue('yoga_check')
  yogaCheck('yoga_check', 'Yoga'),
  
  @JsonValue('pilates_check')
  pilatesCheck('pilates_check', 'Pilates'),
  
  @JsonValue('hiit_check')
  hiitCheck('hiit_check', 'HIIT'),
  
  @JsonValue('corrida_check')
  corridaCheck('corrida_check', 'Corrida'),
  
  @JsonValue('caminhada_check')
  caminhadaCheck('caminhada_check', 'Caminhada'),
  
  @JsonValue('natacao_check')
  natacaoCheck('natacao_check', 'Natação'),
  
  @JsonValue('ciclismo_check')
  ciclismoCheck('ciclismo_check', 'Ciclismo'),
  
  @JsonValue('alongamento_check')
  alongamentoCheck('alongamento_check', 'Alongamento'),
  
  @JsonValue('forca_check')
  forcaCheck('forca_check', 'Força'),
  
  @JsonValue('fisioterapia_check')
  fisioterapiaCheck('fisioterapia_check', 'Fisioterapia'),
  
  @JsonValue('flexibilidade_check')
  flexibilidadeCheck('flexibilidade_check', 'Flexibilidade'),
  
  @JsonValue('custom')
  custom('custom', 'Personalizada');

  const PersonalizedGoalPresetType(this.value, this.displayName);
  
  final String value;
  final String displayName;

  static PersonalizedGoalPresetType fromString(String value) {
    return PersonalizedGoalPresetType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PersonalizedGoalPresetType.custom,
    );
  }
}

/// Modelo principal de meta personalizada
@freezed
class PersonalizedGoal with _$PersonalizedGoal {
  const factory PersonalizedGoal({
    required String id,
    required String userId,
    required PersonalizedGoalPresetType presetType,
    required String title,
    String? description,
    required PersonalizedGoalMeasurementType measurementType,
    required double targetValue,
    @Default(0.0) double currentProgress,
    required String unitLabel,
    @Default(1.0) double incrementStep,
    required DateTime weekStartDate,
    required DateTime weekEndDate,
    @Default(true) bool isActive,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _PersonalizedGoal;

  factory PersonalizedGoal.fromJson(Map<String, dynamic> json) => 
      _$PersonalizedGoalFromJson(json);
  
  const PersonalizedGoal._();
  
  /// Percentual de conclusão (0-100)
  double get progressPercentage {
    if (targetValue <= 0) return 0.0;
    return ((currentProgress / targetValue) * 100).clamp(0.0, 100.0);
  }
  
  /// Valor de progresso para widgets (0-1)
  double get progressValue {
    if (targetValue <= 0) return 0.0;
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }
  
  /// Verifica se a meta foi atingida
  bool get isGoalAchieved => currentProgress >= targetValue;
  
  /// Quantidade restante para completar
  double get remainingValue => (targetValue - currentProgress).clamp(0.0, targetValue);
  
  /// Texto de progresso formatado
  String get progressText {
    if (measurementType.isCheckMode) {
      return '${currentProgress.toInt()}/${targetValue.toInt()} $unitLabel';
    } else {
      return '${currentProgress.toStringAsFixed(currentProgress.truncateToDouble() == currentProgress ? 0 : 1)}/${targetValue.toStringAsFixed(targetValue.truncateToDouble() == targetValue ? 0 : 1)} $unitLabel';
    }
  }
  
  /// Cor do progresso baseada no percentual
  Color get progressColor {
    if (progressPercentage >= 100) return Colors.green;
    if (progressPercentage >= 75) return Colors.blue;
    if (progressPercentage >= 50) return Colors.orange;
    return Colors.grey;
  }
  
  /// Mensagem motivacional baseada no progresso
  String get motivationalMessage {
    if (isCompleted) return 'Parabéns! Meta concluída! 🎉';
    if (progressPercentage >= 75) return 'Quase lá! Você consegue! 💪';
    if (progressPercentage >= 50) return 'Ótimo progresso! Continue assim! 🚀';
    if (progressPercentage >= 25) return 'Bom começo! Vamos em frente! ✨';
    return 'Vamos começar? Você é capaz! 🌟';
  }
}

/// Modelo de check-in individual
@freezed
class GoalCheckIn with _$GoalCheckIn {
  const factory GoalCheckIn({
    required String id,
    required String goalId,
    required String userId,
    required DateTime checkInDate,
    required DateTime checkInTime,
    String? notes,
    required DateTime createdAt,
  }) = _GoalCheckIn;

  factory GoalCheckIn.fromJson(Map<String, dynamic> json) => 
      _$GoalCheckInFromJson(json);
}

/// Modelo de entrada de progresso numérico
@freezed
class GoalProgressEntry with _$GoalProgressEntry {
  const factory GoalProgressEntry({
    required String id,
    required String goalId,
    required String userId,
    required double valueAdded,
    required DateTime entryDate,
    required DateTime entryTime,
    String? notes,
    @Default('manual') String source,
    required DateTime createdAt,
  }) = _GoalProgressEntry;

  factory GoalProgressEntry.fromJson(Map<String, dynamic> json) => 
      _$GoalProgressEntryFromJson(json);
}

/// Dados de criação de meta
@freezed
class CreateGoalData with _$CreateGoalData {
  const factory CreateGoalData({
    required String title,
    String? description,
    required PersonalizedGoalMeasurementType measurementType,
    required double targetValue,
    required String unitLabel,
    @Default(1.0) double incrementStep,
    @Default(PersonalizedGoalPresetType.custom) PersonalizedGoalPresetType presetType,
  }) = _CreateGoalData;

  factory CreateGoalData.fromJson(Map<String, dynamic> json) => 
      _$CreateGoalDataFromJson(json);
  
  const CreateGoalData._();
  
  /// Cria dados para meta pré-estabelecida "Projeto 7 Dias"
  static CreateGoalData projeto7Dias() => const CreateGoalData(
    title: 'Projeto 7 Dias',
    description: 'Complete 1 check-in por dia durante 7 dias',
    measurementType: PersonalizedGoalMeasurementType.check,
    targetValue: 7,
    unitLabel: 'dias',
    incrementStep: 1,
    presetType: PersonalizedGoalPresetType.projeto7Dias,
  );
  
  /// Cria dados para meta pré-estabelecida "Cardio Check"
  static CreateGoalData cardioCheck() => const CreateGoalData(
    title: 'Cardio Semanal',
    description: 'Faça cardio 4 vezes por semana',
    measurementType: PersonalizedGoalMeasurementType.check,
    targetValue: 4,
    unitLabel: 'sessões',
    incrementStep: 1,
    presetType: PersonalizedGoalPresetType.cardioCheck,
  );
  
  /// Cria dados para meta pré-estabelecida "Cardio Minutos"
  static CreateGoalData cardioMinutes() => const CreateGoalData(
    title: 'Cardio 100min',
    description: 'Acumule 100 minutos de cardio por semana',
    measurementType: PersonalizedGoalMeasurementType.minutes,
    targetValue: 100,
    unitLabel: 'min',
    incrementStep: 10,
    presetType: PersonalizedGoalPresetType.cardioCheck,
  );
  
  /// Cria dados para sugestão de hidratação
  static CreateGoalData hydrationSuggestion() => const CreateGoalData(
    title: 'Hidratação Diária',
    description: '2 litros de água por dia (14 check-ins na semana)',
    measurementType: PersonalizedGoalMeasurementType.check,
    targetValue: 14,
    unitLabel: 'copos',
    incrementStep: 1,
    presetType: PersonalizedGoalPresetType.custom,
  );
}

/// Resposta da API para operações
@freezed
class GoalApiResponse with _$GoalApiResponse {
  const factory GoalApiResponse({
    required bool success,
    String? message,
    String? error,
    Map<String, dynamic>? data,
  }) = _GoalApiResponse;

  factory GoalApiResponse.fromJson(Map<String, dynamic> json) => 
      _$GoalApiResponseFromJson(json);
}

/// Status da meta com dados extras
@freezed
class GoalStatus with _$GoalStatus {
  const factory GoalStatus({
    required PersonalizedGoal goal,
    @Default(0) int checkinsToday,
    @Default(0.0) double progressToday,
    @Default([]) List<GoalCheckIn> recentCheckIns,
    @Default([]) List<GoalProgressEntry> recentEntries,
  }) = _GoalStatus;

  factory GoalStatus.fromJson(Map<String, dynamic> json) => 
      _$GoalStatusFromJson(json);
  
  const GoalStatus._();
  
  /// Verifica se usuário já fez check-in hoje
  bool get hasCheckedInToday => checkinsToday > 0;
  
  /// Verifica se usuário adicionou progresso hoje
  bool get hasProgressToday => progressToday > 0;
}

/// Extensões úteis
extension PersonalizedGoalExtensions on PersonalizedGoal {
  /// Pode receber check-in hoje?
  bool canCheckInToday(List<GoalCheckIn> todayCheckIns) {
    if (!measurementType.isCheckMode) return false;
    return todayCheckIns.isEmpty;
  }
  
  /// Formata valor para exibição
  String formatValue(double value) {
    if (measurementType.isCheckMode || value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
} 