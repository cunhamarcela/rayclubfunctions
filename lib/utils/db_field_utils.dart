import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Utilitário para acessar campos de tabelas com segurança
class DbFieldUtils {
  static final SupabaseClient _client = Supabase.instance.client;
  static final Map<String, Map<String, String>> _fieldMappings = {};
  
  /// Inicializa os mapeamentos de campo com base na estrutura atual do banco
  static Future<void> initialize() async {
    try {
      // Definir mapeamentos padrão para evitar chamadas à função problemática
      _fieldMappings['user_progress'] = {
        'points': 'points',
        'workouts': 'workouts'
      };
      
      // Nota: Desativando o código que verifica as colunas total_points e total_workouts
      // porque essas colunas não existem mais no banco de dados
      
      // Em vez de tentar acessar colunas que podem não existir, usamos os nomes corretos
      // diretamente conforme a estrutura atual do banco
      
      debugPrint('✅ DbFieldUtils inicializado: $_fieldMappings');
    } catch (e) {
      debugPrint('❌ Erro inicializando DbFieldUtils: $e');
    }
  }
  
  /// Obtém o valor de um campo usando o mapeamento correto
  static dynamic getFieldValue(
    Map<String, dynamic> data, 
    String tableName, 
    String fieldName, 
    {dynamic defaultValue}
  ) {
    if (!_fieldMappings.containsKey(tableName)) {
      return data[fieldName] ?? defaultValue;
    }
    
    final mapping = _fieldMappings[tableName];
    if (!mapping!.containsKey(fieldName)) {
      return data[fieldName] ?? defaultValue;
    }
    
    final actualFieldName = mapping[fieldName]!;
    return data[actualFieldName] ?? defaultValue;
  }
  
  /// Obtém pontos com segurança
  static int getPoints(Map<String, dynamic> data) {
    return getFieldValue(data, 'user_progress', 'points', defaultValue: 0);
  }
  
  /// Obtém total de treinos com segurança
  static int getWorkouts(Map<String, dynamic> data) {
    return getFieldValue(data, 'user_progress', 'workouts', defaultValue: 0);
  }
} 