// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'water_intake_model.freezed.dart';
part 'water_intake_model.g.dart';

/// Modelo que representa o registro de ingestão de água diária do usuário
@freezed
class WaterIntake with _$WaterIntake {
  const factory WaterIntake({
    /// Identificador único do registro
    required String id,
    
    /// Identificador do usuário
    required String userId,
    
    /// Data do registro
    required DateTime date,
    
    /// Número de copos de água ingeridos
    @Default(0) int currentGlasses,
    
    /// Meta diária de copos de água
    @Default(8) int dailyGoal,
    
    /// Volume em ml por copo (padrão 250ml)
    @Default(250) int glassSize,
    
    /// Data de criação do registro
    required DateTime createdAt,
    
    /// Data da última atualização do registro
    DateTime? updatedAt,
  }) = _WaterIntake;

  /// Cria um WaterIntake a partir de um mapa JSON
  factory WaterIntake.fromJson(Map<String, dynamic> json) => _$WaterIntakeFromJson(json);
  
  const WaterIntake._();
  
  /// Verifica se a meta diária foi atingida
  bool get isGoalReached => currentGlasses >= dailyGoal;
  
  /// Calcula o volume total em ml consumido
  int get totalMilliliters => currentGlasses * glassSize;
  
  /// Calcula o progresso como percentual (0.0 a 1.0)
  double get progress => dailyGoal > 0 ? (currentGlasses / dailyGoal).clamp(0.0, 1.0) : 0.0;
  
  /// Progresso formatado como porcentagem
  String get progressPercentage => '${(progress * 100).toInt()}%';
  
  /// Total de ml a ser consumido para atingir a meta
  int get targetMilliliters => dailyGoal * glassSize;
  
  /// Quantidade restante de copos para atingir a meta
  int get remainingGlasses => (dailyGoal - currentGlasses).clamp(0, dailyGoal);
} 