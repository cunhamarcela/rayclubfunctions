import 'package:ray_club_app/features/goals/models/user_goal_model.dart';
import 'package:flutter/material.dart';

/// Mapper para converter entre objetos UserGoal e representações JSON do Supabase
class UserGoalMapper {
  /// Converte um JSON do Supabase para um objeto UserGoal
  static UserGoal fromSupabaseJson(Map<String, dynamic> json) {
    debugPrint('🔍 UserGoalMapper: Convertendo JSON do Supabase para modelo');
    debugPrint('📊 JSON recebido: $json');
    
    // Mapear campos do Supabase (estrutura real) para o modelo Flutter (camelCase)
    final mappedJson = <String, dynamic>{};
    
    // Campos obrigatórios
    mappedJson['id'] = json['id']?.toString() ?? '';
    mappedJson['userId'] = json['user_id']?.toString() ?? '';
    mappedJson['title'] = json['title']?.toString() ?? '';
    mappedJson['unit'] = json['unit']?.toString() ?? '';
    
    // Campos opcionais - a estrutura real não tem description
    mappedJson['description'] = null;
    
    // Tipo da meta - usar goal_type da estrutura real
    String goalType = json['goal_type']?.toString() ?? 'custom';
    mappedJson['type'] = goalType;
    
    // Valores numéricos - usar target_value e current_value da estrutura real
    mappedJson['target'] = _parseDouble(json['target_value'] ?? 0);
    mappedJson['progress'] = _parseDouble(json['current_value'] ?? 0);
    
    // Datas - mapear corretamente
    mappedJson['startDate'] = _parseDate(json['start_date']);
    mappedJson['endDate'] = _parseDate(json['target_date']); // target_date → endDate
    mappedJson['completedAt'] = json['is_completed'] == true ? _parseDate(json['updated_at']) : null;
    mappedJson['createdAt'] = _parseDate(json['created_at']);
    mappedJson['updatedAt'] = _parseDate(json['updated_at']);
    
    debugPrint('📊 JSON mapeado: $mappedJson');
    
    try {
      return UserGoal.fromJson(mappedJson);
    } catch (e) {
      debugPrint('❌ Erro ao converter JSON para UserGoal: $e');
      debugPrint('📊 JSON que causou erro: $mappedJson');
      rethrow;
    }
  }

  /// Converte um objeto UserGoal para JSON do Supabase
  static Map<String, dynamic> toSupabaseJson(UserGoal userGoal) {
    debugPrint('🔍 UserGoalMapper: Convertendo modelo para JSON do Supabase');
    
    return {
      'id': userGoal.id,
      'user_id': userGoal.userId,
      'title': userGoal.title,
      // description não existe na estrutura real, então omitimos
      'goal_type': userGoal.type.name,
      'target_value': userGoal.target,
      'current_value': userGoal.progress,
      'unit': userGoal.unit,
      'start_date': userGoal.startDate.toIso8601String(),
      'target_date': userGoal.endDate?.toIso8601String(),
      'is_completed': userGoal.isCompleted,
      'created_at': userGoal.createdAt.toIso8601String(),
      'updated_at': userGoal.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      // progress_percentage pode ser calculado automaticamente no banco
      'progress_percentage': userGoal.target > 0 ? (userGoal.progress / userGoal.target * 100) : 0,
    };
  }
  
  /// Converte valor para double, tratando diferentes tipos
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
  
  /// Converte valor para DateTime, tratando diferentes tipos
  static String _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now().toIso8601String();
    }
    
    if (value is String) {
      // Se já é uma string ISO, retornar como está
      try {
        DateTime.parse(value);
        return value;
      } catch (e) {
        return DateTime.now().toIso8601String();
      }
    }
    
    if (value is DateTime) {
      return value.toIso8601String();
    }
    
    return DateTime.now().toIso8601String();
  }
} 