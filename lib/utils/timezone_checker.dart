import 'package:flutter/foundation.dart';

import 'datetime_extensions.dart';

/// Classe utilitária para verificar e testar manipulação de timezone
class TimezoneChecker {
  /// Realiza testes com datas/horário para verificar se o timezone de Brasília
  /// está sendo aplicado corretamente
  static Future<void> testTimezone() async {
    try {
      // Data atual local
      final now = DateTime.now();
      
      // Data para Supabase com timezone de Brasília via extensão
      final nowForSupabase = now.toSupabaseString();
      
      // Data normalizada via extensão
      final startOfDay = now.toStartOfDayWithTimezone();
      final endOfDay = now.toEndOfDayWithTimezone();
      
      // Log de informações
      debugPrint('=== TIMEZONE CHECKER ===');
      debugPrint('Data local: ${now.toIso8601String()}');
      debugPrint('Data para Supabase: $nowForSupabase');
      debugPrint('Início do dia com timezone: ${startOfDay.toIso8601String()}');
      debugPrint('Fim do dia com timezone: ${endOfDay.toIso8601String()}');
      debugPrint('=======================');
    } catch (e) {
      debugPrint('❌ Erro no teste de timezone: $e');
    }
  }
  
  /// Verifica e retorna informações sobre timezone do dispositivo
  static Map<String, dynamic> getTimezoneInfo() {
    final now = DateTime.now();
    final utcNow = DateTime.now().toUtc();
    final offset = now.timeZoneOffset;
    
    return {
      'local_time': now.toIso8601String(),
      'utc_time': utcNow.toIso8601String(),
      'timezone_offset_hours': offset.inHours,
      'timezone_offset_minutes': offset.inMinutes,
      'is_brasilia_timezone': offset.inHours == -3,
    };
  }
} 