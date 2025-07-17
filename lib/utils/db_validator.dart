import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Classe utilitária para verificar a integridade e estrutura das tabelas do Supabase
class DbValidator {
  final SupabaseClient _client;
  
  DbValidator(this._client);

  /// Verifica se todas as tabelas necessárias para o módulo de desafios existem
  /// e possuem a estrutura correta
  Future<Map<String, bool>> validateChallengesTables() async {
    debugPrint('🔎 DbValidator: Iniciando validação das tabelas de desafios...');
    
    final results = <String, bool>{};
    
    try {
      // Lista de tabelas a verificar
      final tablesToCheck = [
        'challenges',
        'challenge_progress',
        'challenge_groups',
        'challenge_group_members',
        'user_progress',
        'profile',
      ];
      
      for (final table in tablesToCheck) {
        try {
          debugPrint('🔎 DbValidator: Verificando tabela $table...');
          
          // Verificar se a tabela existe, tentando buscar registros
          final data = await _client
              .from(table)
              .select('*')
              .limit(1);
          
          final exists = data != null;
          results[table] = exists;
          
          if (exists) {
            debugPrint('✅ DbValidator: Tabela $table existe');
          } else {
            debugPrint('❌ DbValidator: Tabela $table não encontrada');
          }
          
          // Verificar colunas específicas de acordo com a tabela
          await _validateTableColumns(table);
          
        } catch (e) {
          debugPrint('❌ DbValidator: Erro ao verificar tabela $table: $e');
          results[table] = false;
        }
      }
      
      // Verificar relacionamentos críticos
      await _validateRelationships();
      
      return results;
    } catch (e) {
      debugPrint('❌ DbValidator: Erro geral na validação: $e');
      return {'error': false};
    }
  }
  
  /// Verifica se as colunas esperadas existem para cada tabela
  Future<void> _validateTableColumns(String table) async {
    try {
      switch (table) {
        case 'challenges':
          await _checkColumns(table, [
            'id', 'title', 'description', 'image_url', 'start_date', 
            'end_date', 'type', 'points', 'requirements', 'active',
            'creator_id', 'is_official'
          ]);
          break;
          
        case 'challenge_progress':
          await _checkColumns(table, [
            'id', 'user_id', 'challenge_id', 'points', 'check_ins_count',
            'created_at', 'updated_at'
          ]);
          break;
          
        case 'challenge_groups':
          await _checkColumns(table, [
            'id', 'name', 'description', 'creator_id', 'created_at'
          ]);
          break;
          
        case 'challenge_group_members':
          await _checkColumns(table, [
            'id', 'group_id', 'user_id', 'created_at'
          ]);
          break;
          
        case 'user_progress':
          await _checkColumns(table, [
            'id', 'user_id', 'total_points', 'total_workouts',
            'streaks', 'achievements'
          ]);
          break;
          
        case 'profile':
          await _checkColumns(table, [
            'id', 'username', 'avatar_url', 'updated_at'
          ]);
          break;
      }
    } catch (e) {
      debugPrint('⚠️ DbValidator: Erro ao verificar colunas da tabela $table: $e');
    }
  }
  
  /// Verifica se as colunas esperadas existem em uma tabela
  Future<Map<String, bool>> _checkColumns(String table, List<String> expectedColumns) async {
    final results = <String, bool>{};
    
    try {
      // Verificar a primeira linha para obter as colunas
      final response = await _client
          .from(table)
          .select('*')
          .limit(1);
      
      if (response != null && response.isNotEmpty) {
        final Map<String, dynamic> row = response[0];
        final existingColumns = row.keys.toList();
        
        for (final column in expectedColumns) {
          final exists = existingColumns.contains(column);
          results[column] = exists;
          
          if (!exists) {
            debugPrint('⚠️ DbValidator: Coluna "$column" não encontrada na tabela "$table"');
          }
        }
        
        debugPrint('🔎 DbValidator: Tabela "$table" tem ${existingColumns.length} colunas, verificadas ${expectedColumns.length}');
      } else {
        debugPrint('⚠️ DbValidator: Tabela "$table" existe mas não tem dados para verificar colunas');
      }
    } catch (e) {
      debugPrint('❌ DbValidator: Erro ao verificar colunas da tabela "$table": $e');
    }
    
    return results;
  }
  
  /// Verifica relacionamentos críticos entre tabelas
  Future<void> _validateRelationships() async {
    debugPrint('🔎 DbValidator: Verificando relacionamentos entre tabelas...');
    
    try {
      // Verificar relacionamento entre challenges e challenge_progress
      final challengesResponse = await _client
          .from('challenges')
          .select('id')
          .limit(1);
          
      if (challengesResponse != null && challengesResponse.isNotEmpty) {
        final challengeId = challengesResponse[0]['id'];
        
        try {
          final progressResponse = await _client
              .from('challenge_progress')
              .select('*')
              .eq('challenge_id', challengeId)
              .limit(1);
              
          debugPrint('🔎 DbValidator: Verificado relacionamento challenge_progress -> challenges (OK)');
        } catch (e) {
          debugPrint('⚠️ DbValidator: Erro no relacionamento challenge_progress -> challenges: $e');
        }
      }
      
      // Verificar relacionamento entre challenge_groups e challenge_group_members
      final groupsResponse = await _client
          .from('challenge_groups')
          .select('id')
          .limit(1);
          
      if (groupsResponse != null && groupsResponse.isNotEmpty) {
        final groupId = groupsResponse[0]['id'];
        
        try {
          final membersResponse = await _client
              .from('challenge_group_members')
              .select('*')
              .eq('group_id', groupId)
              .limit(1);
              
          debugPrint('🔎 DbValidator: Verificado relacionamento challenge_group_members -> challenge_groups (OK)');
        } catch (e) {
          debugPrint('⚠️ DbValidator: Erro no relacionamento challenge_group_members -> challenge_groups: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ DbValidator: Erro ao verificar relacionamentos: $e');
    }
  }
}

/// Provider para o DbValidator
final dbValidatorProvider = Provider<DbValidator>((ref) {
  final client = Supabase.instance.client;
  return DbValidator(client);
});

/// Provider para executar a validação das tabelas de desafios
final challengesTablesValidationProvider = FutureProvider<Map<String, bool>>((ref) async {
  final validator = ref.watch(dbValidatorProvider);
  return validator.validateChallengesTables();
}); 