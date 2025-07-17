import 'package:flutter/foundation.dart';

/// Utilitário para mapeamento seguro entre dados do Supabase/API e modelos locais
class ModelMapper {
  /// Obtém um valor de um campo com segurança, retornando um valor padrão se nulo ou do tipo incorreto
  static T getValue<T>(Map<String, dynamic> json, String key, T defaultValue) {
    try {
      final value = json[key];
      
      if (value == null) {
        return defaultValue;
      }
      
      // Se o tipo esperado e o tipo real são compatíveis
      if (value is T) {
        return value;
      }
      
      // Conversões específicas para tipos comuns
      if (T == String) {
        if (value != null) {
          return value.toString() as T;
        }
      }
      
      if (T == int) {
        if (value is String) {
          return (int.tryParse(value) ?? defaultValue) as T;
        } else if (value is double) {
          return value.toInt() as T;
        }
      }
      
      if (T == double) {
        if (value is int) {
          return value.toDouble() as T;
        } else if (value is String) {
          return (double.tryParse(value) ?? defaultValue) as T;
        }
      }
      
      if (T == bool) {
        if (value is String) {
          return (value.toLowerCase() == 'true') as T;
        } else if (value is int) {
          return (value != 0) as T;
        }
      }
      
      if (T == DateTime) {
        if (value is String) {
          try {
            return DateTime.parse(value) as T;
          } catch (e) {
            return defaultValue;
          }
        }
      }
      
      // Arrays
      if (T == List<String>) {
        if (value is List) {
          return value.map((e) => e.toString()).toList() as T;
        }
      }
      
      // Se chegamos aqui, não conseguimos converter - usar valor padrão
      debugPrint('⚠️ ModelMapper: Não foi possível converter $value para $T, usando padrão: $defaultValue');
      return defaultValue;
      
    } catch (e) {
      debugPrint('⚠️ ModelMapper: Erro ao obter $key: $e');
      return defaultValue;
    }
  }
  
  /// Obtém uma lista de valores com segurança, retornando uma lista vazia se nulo ou do tipo incorreto
  static List<T> getList<T>(Map<String, dynamic> json, String key, T Function(dynamic) converter) {
    try {
      final value = json[key];
      
      if (value == null) {
        return <T>[];
      }
      
      if (value is List) {
        return value.map((item) {
          try {
            return converter(item);
          } catch (e) {
            debugPrint('⚠️ ModelMapper: Erro ao converter item da lista $key: $e');
            return null;
          }
        }).whereType<T>().toList();
      }
      
      return <T>[];
    } catch (e) {
      debugPrint('⚠️ ModelMapper: Erro ao obter lista $key: $e');
      return <T>[];
    }
  }
  
  /// Obtém um valor DateTime de um campo, tratando diferentes formatos possíveis
  static DateTime? getDateTime(Map<String, dynamic> json, String key) {
    try {
      final value = json[key];
      
      if (value == null) {
        return null;
      }
      
      if (value is DateTime) {
        return value;
      }
      
      if (value is String) {
        return DateTime.parse(value);
      }
      
      if (value is int) {
        // Timestamp em segundos ou milissegundos
        if (value > 100000000000) {
          return DateTime.fromMillisecondsSinceEpoch(value);
        } else {
          return DateTime.fromMillisecondsSinceEpoch(value * 1000);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('⚠️ ModelMapper: Erro ao converter DateTime para $key: $e');
      return null;
    }
  }
  
  /// Log detalhado de falhas de mapeamento para diagnóstico
  static void logMappingIssue(
    String modelName, 
    String fieldName, 
    dynamic value, 
    Type expectedType,
    [dynamic error]
  ) {
    debugPrint('🔴 Erro de mapeamento: $modelName.$fieldName');
    debugPrint('  Esperado: $expectedType, Recebido: ${value?.runtimeType}');
    debugPrint('  Valor: $value');
    if (error != null) {
      debugPrint('  Erro: $error');
    }
  }
} 