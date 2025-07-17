import 'package:flutter/foundation.dart';
import 'dart:convert';

/// Utilitário para verificar a compatibilidade entre modelos e dados do Supabase
class ModelCompatibilityChecker {
  /// Verifica e registra problemas na conversão de dados do Supabase
  /// para um modelo específico
  static void checkModelCompatibility<T>({
    required String modelName,
    required Map<String, dynamic> supabaseData,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
  }) {
    if (!kDebugMode) return;
    
    try {
      debugPrint('📋 VERIFICANDO COMPATIBILIDADE - $modelName');
      
      // 1. Listar campos presentes nos dados do Supabase
      final supabaseFields = supabaseData.keys.toList();
      debugPrint('📥 Campos do Supabase (${supabaseFields.length}): ${supabaseFields.join(', ')}');
      
      // 2. Converter para o modelo
      final model = fromJson(supabaseData);
      debugPrint('✅ Conversão para $modelName bem-sucedida');
      
      // 3. Converter de volta para JSON
      final modelJson = toJson(model);
      final modelFields = modelJson.keys.toList();
      debugPrint('📤 Campos do modelo (${modelFields.length}): ${modelFields.join(', ')}');
      
      // 4. Verificar campos ausentes ou extras
      final missingFields = supabaseFields.where((field) => !modelFields.contains(field)).toList();
      final extraFields = modelFields.where((field) => !supabaseFields.contains(field)).toList();
      
      if (missingFields.isNotEmpty) {
        debugPrint('⚠️ Campos do Supabase não presentes no modelo: ${missingFields.join(', ')}');
      }
      
      if (extraFields.isNotEmpty) {
        debugPrint('⚠️ Campos no modelo não presentes no Supabase: ${extraFields.join(', ')}');
      }
      
      // 5. Verificar campos com formato diferente
      for (final field in supabaseFields.where((field) => modelFields.contains(field))) {
        final supabaseValue = supabaseData[field];
        final modelValue = modelJson[field];
        
        if (supabaseValue != null && modelValue != null && 
            supabaseValue.runtimeType != modelValue.runtimeType) {
          debugPrint('⚠️ Possível incompatibilidade de tipo no campo "$field":');
          debugPrint('   - Tipo no Supabase: ${supabaseValue.runtimeType}');
          debugPrint('   - Tipo no modelo: ${modelValue.runtimeType}');
          debugPrint('   - Valores: "${supabaseValue}" vs "${modelValue}"');
        }
      }
      
      // 6. Verificar campos aninhados
      _checkNestedFields(supabaseData, modelJson);
      
    } catch (e) {
      debugPrint('❌ Erro na verificação de compatibilidade: $e');
    }
  }
  
  /// Verifica campos aninhados (objetos ou listas)
  static void _checkNestedFields(Map<String, dynamic> supabaseData, Map<String, dynamic> modelJson) {
    for (final field in supabaseData.keys) {
      final supabaseValue = supabaseData[field];
      final modelValue = modelJson[field];
      
      if (supabaseValue is Map && modelValue is Map) {
        debugPrint('🔍 Verificando campo aninhado (objeto): $field');
        
        // Comparar chaves de objetos aninhados
        final supabaseNestedKeys = (supabaseValue as Map).keys.toList();
        final modelNestedKeys = (modelValue as Map).keys.toList();
        
        final missingNestedKeys = supabaseNestedKeys.where(
          (key) => !modelNestedKeys.contains(key)
        ).toList();
        
        if (missingNestedKeys.isNotEmpty) {
          debugPrint('⚠️ Sub-campos não presentes no modelo: ${missingNestedKeys.join(', ')}');
        }
      } 
      else if (supabaseValue is List && modelValue is List && 
               supabaseValue.isNotEmpty && modelValue.isNotEmpty) {
        debugPrint('🔍 Verificando campo aninhado (lista): $field');
        
        // Comparar o tipo do primeiro item da lista
        final supabaseItemType = supabaseValue.first.runtimeType;
        final modelItemType = modelValue.first.runtimeType;
        
        if (supabaseItemType != modelItemType) {
          debugPrint('⚠️ Possível incompatibilidade no tipo dos itens da lista:');
          debugPrint('   - Tipo no Supabase: $supabaseItemType');
          debugPrint('   - Tipo no modelo: $modelItemType');
        }
      }
    }
  }
} 