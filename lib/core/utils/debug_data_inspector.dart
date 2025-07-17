import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Utilitário para inspecionar dados recebidos do Supabase
/// e verificar sua estrutura
class DebugDataInspector {
  /// Registra detalhes sobre os dados recebidos
  static void logResponse(String tag, dynamic response) {
    if (!kDebugMode) return;
    
    try {
      debugPrint('🔍 VERIFICAÇÃO DE DADOS DO SUPABASE - $tag');
      debugPrint('Tipo da resposta: ${response.runtimeType}');
      
      if (response == null) {
        debugPrint('❌ Resposta nula!');
        return;
      }
      
      if (response is List) {
        debugPrint('📋 Resposta é uma lista de ${response.length} itens');
        if (response.isNotEmpty) {
          final firstItem = response.first;
          debugPrint('📝 Primeiro item tipo: ${firstItem.runtimeType}');
          _inspectItem(firstItem);
        }
      } else if (response is Map) {
        debugPrint('📋 Resposta é um mapa');
        _inspectItem(response);
      } else {
        debugPrint('📝 Valor: $response');
      }
    } catch (e) {
      debugPrint('❌ Erro ao inspecionar resposta: $e');
    }
  }
  
  /// Examina um item específico (objeto ou mapa)
  static void _inspectItem(dynamic item) {
    try {
      if (item is Map) {
        debugPrint('🔑 Chaves disponíveis: ${item.keys.join(', ')}');
        
        // Tenta detectar e mostrar campos aninhados
        for (var key in item.keys) {
          final value = item[key];
          if (value is Map || value is List) {
            debugPrint('🔄 Campo aninhado encontrado: $key (tipo: ${value.runtimeType})');
            if (value is Map) {
              debugPrint('  → Sub-chaves: ${value.keys.join(', ')}');
            } else if (value is List && value.isNotEmpty) {
              debugPrint('  → Lista com ${value.length} itens (primeiro item tipo: ${value.first.runtimeType})');
            }
          }
        }
        
        // Tenta fazer pretty-print do JSON
        try {
          final encoder = JsonEncoder.withIndent('  ');
          final prettyJson = encoder.convert(item);
          debugPrint('📊 ESTRUTURA JSON:\n$prettyJson');
        } catch (e) {
          debugPrint('⚠️ Não foi possível serializar objeto para JSON: $e');
        }
      } else {
        debugPrint('📝 Valor: $item');
      }
    } catch (e) {
      debugPrint('❌ Erro ao inspecionar item: $e');
    }
  }
} 