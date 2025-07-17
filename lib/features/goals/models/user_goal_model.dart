// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Flutter imports:
import 'package:flutter/foundation.dart';

part 'user_goal_model.freezed.dart';
part 'user_goal_model.g.dart';

/// Tipo de meta que o usuário pode criar
enum GoalType {
  weight, // Meta de peso
  workout, // Meta de treino (número de treinos)
  steps, // Meta de passos
  nutrition, // Meta nutricional
  custom, // Meta personalizada
}

/// Modelo que representa uma meta de fitness do usuário
@freezed
class UserGoal with _$UserGoal {
  const factory UserGoal({
    /// Identificador único da meta
    required String id,
    
    /// Identificador do usuário
    required String userId,
    
    /// Nome/título da meta
    required String title,
    
    /// Descrição opcional da meta
    String? description,
    
    /// Tipo da meta
    required GoalType type,
    
    /// Valor alvo a ser alcançado
    required double target,
    
    /// Valor atual
    @Default(0.0) double progress,
    
    /// Unidade de medida (kg, min, etc)
    required String unit,
    
    /// Data de início
    required DateTime startDate,
    
    /// Data de término prevista
    DateTime? endDate,
    
    /// Data em que a meta foi concluída
    DateTime? completedAt,
    
    /// Data de criação
    required DateTime createdAt,
    
    /// Data da última atualização
    DateTime? updatedAt,
  }) = _UserGoal;

  /// Cria um UserGoal a partir de um mapa JSON
  factory UserGoal.fromJson(Map<String, dynamic> json) => _$UserGoalFromJson(json);
  
  const UserGoal._();
  
  /// Verifica se a meta já foi concluída
  bool get isCompleted => completedAt != null || progress >= target;
  
  /// Verifica se a meta usa valores numéricos (para exibição)
  bool get isNumeric => type != GoalType.custom;
  
  /// Retorna o percentual de conclusão da meta
  double get percentageCompleted => (progress / target).clamp(0.0, 1.0);
} 