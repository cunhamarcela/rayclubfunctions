import 'package:ray_club_app/core/utils/model_mapper.dart';
import 'package:ray_club_app/features/goals/models/water_intake_model.dart';
import 'package:flutter/material.dart';

/// Mapper para converter entre objetos WaterIntake e representações JSON
class WaterIntakeMapper {
  /// Converte um JSON para um objeto WaterIntake
  static WaterIntake fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 WaterIntakeMapper: Convertendo JSON para modelo');
    return WaterIntake(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      currentGlasses: json['cups'] ?? 0,
      dailyGoal: json['goal'] ?? 8,
      // Sempre usar o valor padrão de 250ml, não tentar ler do banco
      glassSize: 250, 
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  /// Converte um objeto WaterIntake para JSON
  static Map<String, dynamic> toJson(WaterIntake waterIntake) {
    debugPrint('🔍 WaterIntakeMapper: Convertendo modelo para JSON');
    return {
      'id': waterIntake.id,
      'user_id': waterIntake.userId,
      'date': waterIntake.date.toIso8601String().split('T')[0],
      'cups': waterIntake.currentGlasses,
      'goal': waterIntake.dailyGoal,
      // Não incluir glass_size no JSON para evitar erros no banco
      'created_at': waterIntake.createdAt.toIso8601String(),
      'updated_at': waterIntake.updatedAt?.toIso8601String(),
    };
  }
} 