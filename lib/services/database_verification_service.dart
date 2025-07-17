// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider para o serviço de verificação de banco de dados
final databaseVerificationServiceProvider = Provider<DatabaseVerificationService>((ref) {
  final client = Supabase.instance.client;
  return DatabaseVerificationService(client);
});

/// Serviço responsável por verificar a integridade do banco de dados
class DatabaseVerificationService {
  final SupabaseClient _client;
  
  // Lista de tabelas essenciais que devem existir
  final List<String> _requiredTables = [
    'workouts',
    'workout_records',
    'banners',
    'challenges',
    'challenge_progress',
    'profiles',
    'user_progress',
    'water_intake',
  ];
  
  DatabaseVerificationService(this._client);
  
  /// Verifica se todas as tabelas essenciais existem
  Future<Map<String, bool>> verifyRequiredTables() async {
    final results = <String, bool>{};
    
    for (final table in _requiredTables) {
      try {
        await _client.from(table).select('id').limit(1);
        results[table] = true;
        debugPrint('✅ Tabela $table verificada com sucesso');
      } catch (e) {
        results[table] = false;
        debugPrint('❌ Erro ao verificar tabela $table: $e');
      }
    }
    
    return results;
  }
  
  /// Verifica a integridade do banco de dados e retorna um relatório
  Future<DatabaseIntegrityReport> checkDatabaseIntegrity() async {
    final tableResults = await verifyRequiredTables();
    final missingTables = tableResults.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
    
    final isValid = missingTables.isEmpty;
    
    return DatabaseIntegrityReport(
      isValid: isValid,
      verifiedTables: tableResults,
      missingTables: missingTables,
      timestamp: DateTime.now(),
    );
  }
  
  /// Exibe um relatório de diagnóstico no console
  Future<void> printDiagnostics() async {
    debugPrint('📊 Iniciando diagnóstico do banco de dados...');
    
    try {
      final report = await checkDatabaseIntegrity();
      
      debugPrint('🔍 Relatório de integridade do banco de dados:');
      debugPrint('  Timestamp: ${report.timestamp}');
      debugPrint('  Integridade: ${report.isValid ? '✅ OK' : '❌ Problemas encontrados'}');
      
      if (report.missingTables.isNotEmpty) {
        debugPrint('  ⚠️ Tabelas ausentes:');
        for (final table in report.missingTables) {
          debugPrint('    - $table');
        }
        debugPrint('  ⚠️ Verifique a configuração do Supabase ou execute as migrações necessárias.');
      }
      
      debugPrint('📊 Diagnóstico concluído.');
    } catch (e) {
      debugPrint('❌ Erro durante o diagnóstico: $e');
    }
  }
}

/// Classe para representar o relatório de integridade do banco de dados
class DatabaseIntegrityReport {
  final bool isValid;
  final Map<String, bool> verifiedTables;
  final List<String> missingTables;
  final DateTime timestamp;
  
  DatabaseIntegrityReport({
    required this.isValid,
    required this.verifiedTables,
    required this.missingTables,
    required this.timestamp,
  });
} 