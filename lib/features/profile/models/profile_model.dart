// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

/// Modelo para armazenar dados do perfil do usuário
@freezed
class Profile with _$Profile {
  const factory Profile({
    /// ID do usuário
    required String id,
    
    /// Nome do usuário
    String? name,
    
    /// E-mail do usuário
    String? email,
    
    /// URL da foto de perfil
    String? photoUrl,
    
    /// Número de treinos completados
    @Default(0) int completedWorkouts,
    
    /// Número de dias em sequência de treino
    @Default(0) int streak,
    
    /// Pontos acumulados pelo usuário
    @Default(0) int points,
    
    /// Data de criação do perfil
    DateTime? createdAt,
    
    /// Data da última atualização do perfil
    DateTime? updatedAt,
    
    /// Biografia ou descrição do usuário
    String? bio,
    
    /// Objetivos de fitness do usuário (ex: "Perder peso", "Ganhar massa muscular")
    @Default([]) List<String> goals,
    
    /// IDs dos treinos favoritos do usuário
    @Default([]) List<String> favoriteWorkoutIds,
    
    /// Número de telefone do usuário
    String? phone,
    
    /// Gênero do usuário
    String? gender,
    
    /// Data de nascimento do usuário
    DateTime? birthDate,
    
    /// Instagram do usuário
    String? instagram,
    
    /// Meta de copos de água diários
    @Default(8) int dailyWaterGoal,
    
    /// Meta de treinos diários
    @Default(1) int dailyWorkoutGoal,
    
    /// Meta de treinos semanais
    @Default(5) int weeklyWorkoutGoal,
    
    /// Meta de peso (kg)
    double? weightGoal,
    
    /// Altura do usuário (cm)
    double? height,
    
    /// Peso atual do usuário (kg)
    double? currentWeight,
    
    /// Tipos de treinos preferidos
    @Default([]) List<String> preferredWorkoutTypes,
    
    /// Tipo de conta do usuário (basic/expert)
    @Default('basic') String accountType,
    
    /// Estatísticas do usuário
    @Default({
      'total_workouts': 0,
      'total_challenges': 0,
      'total_checkins': 0,
      'longest_streak': 0,
      'points_earned': 0,
      'completed_challenges': 0,
      'water_intake_average': 0
    }) Map<String, dynamic> stats,
  }) = _Profile;
  
  /// Cria uma instância de Profile a partir de JSON
  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
} 
