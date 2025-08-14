import 'package:supabase_flutter/supabase_flutter.dart';
import 'cardio_ranking_entry.dart';
import 'participant_workout.dart';

class RankingService {
  final SupabaseClient supabase;
  RankingService({SupabaseClient? client}) : supabase = client ?? Supabase.instance.client;

  /// Obtém ranking de cardio com janela [from, to) interpretada em BRT no backend.
  /// Paginação opcional via [limit]/[offset].
  Future<List<CardioRankingEntry>> getCardioRanking({
    DateTime? from,
    DateTime? to,
    int? limit,
    int? offset,
  }) async {
    final params = <String, dynamic>{
      if (from != null) 'date_from': from.toUtc().toIso8601String(),
      if (to != null) 'date_to': to.toUtc().toIso8601String(),
      if (limit != null) '_limit': limit,
      if (offset != null) '_offset': offset,
    };

    print('DEBUG: Chamando get_cardio_ranking com params: $params');
    
    try {
      final response = await supabase.rpc('get_cardio_ranking', params: params);
      print('DEBUG: Resposta get_cardio_ranking: $response');
      print('DEBUG: Tipo da resposta: ${response.runtimeType}');
      
      final data = (response as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
      print('DEBUG: Dados convertidos: ${data.length} entradas');
      
      final entries = data.map(CardioRankingEntry.fromMap).toList();
      print('DEBUG: Ranking entries criados: ${entries.length}');
      for (var entry in entries) {
        print('DEBUG: - ${entry.fullName}: ${entry.totalCardioMinutes} min');
      }
      
      return entries;
    } catch (e, stackTrace) {
      print('ERROR: get_cardio_ranking falhou: $e');
      print('ERROR: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> joinCardioChallenge({String? userId}) async {
    print('DEBUG: Chamando join_cardio_challenge com userId: $userId');
    try {
      final result = await supabase.rpc('join_cardio_challenge', params: {
        if (userId != null) 'p_user_id': userId,
      });
      print('DEBUG: Resultado join_cardio_challenge: $result');
    } catch (e) {
      print('ERROR: Falha ao entrar no desafio: $e');
      rethrow;
    }
  }

  Future<void> leaveCardioChallenge({String? userId}) async {
    await supabase.rpc('leave_cardio_challenge', params: {
      if (userId != null) 'p_user_id': userId,
    });
  }

  /// Obtém o status de participação do usuário no desafio de cardio.
  Future<bool> getCardioParticipationStatus() async {
    print('DEBUG: Verificando status de participação...');
    try {
      final response = await supabase.rpc('get_cardio_participation');
      print('DEBUG: Resposta get_cardio_participation: $response');
      if (response is List && response.isNotEmpty) {
        final data = response.first as Map<String, dynamic>;
        // A função retorna 'is_participant', não 'active'
        final isParticipant = data['is_participant'] as bool? ?? false;
        print('DEBUG: Status participante no banco: $isParticipant');
        return isParticipant;
      }
      print('DEBUG: Resposta vazia ou inválida, retornando false');
      return false;
    } catch (e) {
      print('ERROR: Falha ao verificar status: $e');
      return false;
    }
  }

  /// Obtém os treinos de cardio de um participante específico.
  /// Aplica filtros de período se especificados (from/to) para consistência com o ranking.
  Future<List<ParticipantWorkout>> getParticipantCardioWorkouts({
    required String participantId,
    DateTime? from,
    DateTime? to,
    int? limit,
    int? offset,
  }) async {
    print('DEBUG: getParticipantCardioWorkouts - participantId: $participantId');
    print('DEBUG: Filtros - from: $from, to: $to, limit: $limit, offset: $offset');
    
    try {
      // REMOVIDA A VERIFICAÇÃO DE PARTICIPAÇÃO - já é filtrada no ranking
      // Se o usuário aparece no ranking, significa que é participante ativo
      
      // Buscar TODOS os treinos de cardio do usuário
      print('DEBUG: Construindo query para user_id: $participantId');
      print('DEBUG: Parâmetros - from: $from, to: $to, limit: $limit, offset: $offset');
      
      // TESTE RLS: Verificar se o problema é Row Level Security
      final currentUserId = supabase.auth.currentUser?.id;
      final isOwnUser = participantId == currentUserId;
      
      print('DEBUG: 🔐 TESTE RLS:');
      print('DEBUG: Current User ID: $currentUserId');
      print('DEBUG: Participant ID: $participantId');
      print('DEBUG: É próprio usuário: $isOwnUser');
      
      // Teste 1: Count simples
      try {
        final test1 = await supabase
            .from('workout_records')
            .select('id')
            .eq('user_id', participantId)
            .eq('workout_type', 'Cardio')
            .limit(1000);
        print('DEBUG: Test1 (Count com limit 1000) - Encontrados: ${test1.length}');
      } catch (e) {
        print('DEBUG: ❌ ERRO Test1: $e');
      }
      
          // Teste 2: Verificar treinos recentes (últimos 3 meses para maior abrangência)
    try {
      final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
      final test2 = await supabase
          .from('workout_records')
          .select('id, date, workout_name')
          .eq('user_id', participantId)
          .eq('workout_type', 'Cardio')
          .gt('duration_minutes', 0)
          .gte('date', threeMonthsAgo.toUtc().toIso8601String())
          .order('date', ascending: false)
          .limit(50);
      print('DEBUG: Test2 (Últimos 3 meses) - Encontrados: ${test2.length}');
      if (test2.isNotEmpty) {
        print('DEBUG: Primeiro treino recente: ${test2.first}');
        print('DEBUG: Último treino: ${test2.last}');
      }
      
      // Teste 3: DIRETO - treinos em agosto especificamente
      final augustTest = await supabase
          .from('workout_records')
          .select('id, date, workout_name')
          .eq('user_id', participantId)
          .eq('workout_type', 'Cardio')
          .gte('date', '2025-08-01T00:00:00.000Z')
          .lt('date', '2025-09-01T00:00:00.000Z')
          .order('date', ascending: false);
      print('DEBUG: Test3 (Agosto 2025) - Encontrados: ${augustTest.length}');
      
    } catch (e) {
      print('DEBUG: ❌ ERRO Test2: $e');
    }
      
      var query = supabase
          .from('workout_records')
          .select('id, workout_name, workout_type, date, duration_minutes, notes, is_completed, image_urls')
          .eq('user_id', participantId)
          .eq('workout_type', 'Cardio')
          .gt('duration_minutes', 0);
      
      print('DEBUG: Query básica construída - antes dos filtros de período');

      // Aplicar filtros de período se especificados (para consistência com ranking)
      if (from != null) {
        query = query.gte('date', from.toUtc().toIso8601String());
        print('DEBUG: Aplicando filtro from: ${from.toUtc().toIso8601String()}');
      }
      
      if (to != null) {
        query = query.lt('date', to.toUtc().toIso8601String());
        print('DEBUG: Aplicando filtro to: ${to.toUtc().toIso8601String()}');
      }
      
      print('DEBUG: Filtros de período aplicados. From: ${from != null}, To: ${to != null}');

      // 🚀 SOLUÇÃO FINAL: Usar RPC que bypassa limitações do Flutter client
      print('DEBUG: 🚀 SOLUÇÃO FINAL: Usando RPC get_participant_cardio_workouts...');
      
      try {
        final rpcResult = await supabase.rpc('get_participant_cardio_workouts', params: {
          'participant_user_id': participantId,
          'date_from': from?.toUtc().toIso8601String(),
          'date_to': to?.toUtc().toIso8601String(),
          'workout_limit': limit,
          'workout_offset': offset,
        });
        
        if (rpcResult != null && rpcResult is List) {
          final result = (rpcResult as List).cast<Map<String, dynamic>>();
          
          print('DEBUG: ===============================================');
          print('DEBUG: 🎉 RESULTADO RPC DIRETO:');
          print('DEBUG: RPC retornou: ${result.length} treinos');
          print('DEBUG: ✅ BYPASS do Flutter client funcionou!');
          print('DEBUG: ===============================================');
          
          if (result.isNotEmpty) {
            print('DEBUG: PRIMEIROS 5 TREINOS RPC:');
            for (int i = 0; i < result.length && i < 5; i++) {
              final workout = result[i];
              print('DEBUG: $i. ${workout['workout_name']} - ${workout['date']} - ${workout['duration_minutes']}min');
            }
          }
          
          return result.map((item) => ParticipantWorkout.fromMap(item)).toList();
          
        } else {
          print('DEBUG: ❌ RPC retornou dados inválidos: $rpcResult');
        }
      } catch (e) {
        print('DEBUG: ❌ ERRO no RPC: $e');
        print('DEBUG: 🔄 Voltando para método de períodos como fallback...');
      }
      
      // FALLBACK: Buscar por períodos como antes (caso RPC falhe)
      List<Map<String, dynamic>> allResults = [];
      
      print('DEBUG: 🔄 FALLBACK: Buscar por períodos de tempo...');
      
      // Definir períodos para buscar
      final periods = [
        {'from': '2025-08-01', 'to': '2025-09-01', 'name': 'Agosto 2025'},
        {'from': '2025-07-01', 'to': '2025-08-01', 'name': 'Julho 2025'},
        {'from': '2025-06-01', 'to': '2025-07-01', 'name': 'Junho 2025'},
        {'from': '2025-05-01', 'to': '2025-06-01', 'name': 'Maio 2025'},
        {'from': '2025-04-01', 'to': '2025-05-01', 'name': 'Abril 2025'},
        {'from': '2025-01-01', 'to': '2025-04-01', 'name': 'Jan-Mar 2025'},
      ];
      
      for (final period in periods) {
        try {
          final periodQuery = supabase
              .from('workout_records')
              .select('id, workout_name, workout_type, date, duration_minutes, notes, is_completed, image_urls')
              .eq('user_id', participantId)
              .eq('workout_type', 'Cardio')
              .gt('duration_minutes', 0)
              .gte('date', period['from']!)
              .lt('date', period['to']!)
              .order('date', ascending: false);
          
          final periodResult = await periodQuery;
          print('DEBUG: 📅 ${period['name']}: ${periodResult.length} treinos');
          
          if (periodResult.isNotEmpty) {
            allResults.addAll((periodResult as List).cast<Map<String, dynamic>>());
          }
        } catch (e) {
          print('DEBUG: ❌ ERRO no período ${period['name']}: $e');
        }
      }
      
      // Remover duplicatas e ordenar
      final uniqueResults = <String, Map<String, dynamic>>{};
      for (final item in allResults) {
        uniqueResults[item['id']] = item;
      }
      
      final result = uniqueResults.values.toList()
        ..sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
          
      print('DEBUG: ===============================================');
      print('DEBUG: 🚨 RESULTADO FALLBACK:');
      print('DEBUG: Supabase retornou: ${result.length} treinos');
      print('DEBUG: Esperado no banco: 22 treinos');
      print('DEBUG: Diferença: ${22 - result.length} treinos PERDIDOS');
      print('DEBUG: ===============================================');
      
      // Log dos primeiros 5 treinos para verificar quais chegaram
      print('DEBUG: PRIMEIROS 5 TREINOS RETORNADOS:');
      for (int i = 0; i < (result.length > 5 ? 5 : result.length); i++) {
        final item = result[i];
        print('DEBUG: $i. ${item['workout_name']} - ${item['date']} - ${item['duration_minutes']}min');
      }
      
      if (result.length < 22) {
        print('DEBUG: ⚠️ PROBLEMA CONFIRMADO: Supabase Flutter client não retornou todos os registros!');
      }

      final data = (result as List).cast<Map<String, dynamic>>();
      final workouts = data.map(ParticipantWorkout.fromMap).toList();
      
      // Log dos treinos encontrados
      for (var workout in workouts) {
        print('DEBUG: - ${workout.workoutName}: ${workout.durationMinutes}min em ${workout.date}');
      }
      
      return workouts;
      
    } catch (e, stackTrace) {
      print('ERROR: getParticipantCardioWorkouts falhou: $e');
      print('ERROR: Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Obtém as estatísticas totais de cardio de um participante.
  /// Tenta usar função RPC específica para contagem exata, com fallback para estimativa.
  Future<Map<String, int>> getParticipantCardioStats({
    required String participantId,
    DateTime? from,
    DateTime? to,
  }) async {
    print('DEBUG: getParticipantCardioStats - participantId: $participantId');
    print('DEBUG: Filtros stats - from: $from, to: $to');
    
    try {
      // 🎯 TENTATIVA 1: Usar função RPC específica para contagem exata (se disponível)
      print('DEBUG: 🎯 Tentando get_participant_cardio_count para contagem exata...');
      
      try {
        final countResult = await supabase.rpc('get_participant_cardio_count', params: {
          'participant_user_id': participantId,
          'date_from': from?.toUtc().toIso8601String(),
          'date_to': to?.toUtc().toIso8601String(),
        });

        print('DEBUG: Resposta get_participant_cardio_count: $countResult');

        if (countResult != null && countResult is List && countResult.isNotEmpty) {
          final stats = countResult.first;
          final totalMinutes = stats['total_minutes'] as int? ?? 0;
          final totalWorkouts = stats['total_workouts'] as int? ?? 0;
          
          print('DEBUG: ✅ Stats EXATAS via RPC - totalMinutes: $totalMinutes, totalWorkouts: $totalWorkouts');

          return {
            'totalMinutes': totalMinutes,
            'totalWorkouts': totalWorkouts,
          };
        }
      } catch (e) {
        print('DEBUG: ❌ Função RPC específica não disponível: $e');
      }
      
      // 🔄 FALLBACK: Usar método original (get_cardio_ranking + estimativa)
      print('DEBUG: 🔄 FALLBACK: Usando get_cardio_ranking + estimativa...');
      
      final response = await supabase.rpc('get_cardio_ranking', params: {
        'date_from': from?.toUtc().toIso8601String(),
        'date_to': to?.toUtc().toIso8601String(),
        '_limit': 1000, // Limite alto para pegar todos os participantes
        '_offset': 0,
      });

      print('DEBUG: Resposta get_cardio_ranking para stats: $response');

      if (response == null || response is! List || response.isEmpty) {
        print('DEBUG: Nenhum dado encontrado no ranking para stats');
        return {'totalMinutes': 0, 'totalWorkouts': 0};
      }

      // Buscar especificamente este participante no ranking
      final participantData = (response as List).firstWhere(
        (entry) => entry['user_id'] == participantId,
        orElse: () => null,
      );

      if (participantData == null) {
        print('DEBUG: Participante não encontrado no ranking');
        return {'totalMinutes': 0, 'totalWorkouts': 0};
      }

      final totalMinutes = participantData['total_cardio_minutes'] as int? ?? 0;
      
      // ⚠️ FALLBACK: Usar estimativa de treinos baseada nos minutos totais
      // Isso é usado quando a função RPC específica não está disponível
      final estimatedWorkouts = totalMinutes > 0 ? (totalMinutes / 50).round() : 0; // ~50min por treino
      final totalWorkouts = estimatedWorkouts;

      print('DEBUG: ⚠️ Stats estimadas (fallback) - totalMinutes: $totalMinutes, totalWorkouts: $totalWorkouts');

      return {
        'totalMinutes': totalMinutes,
        'totalWorkouts': totalWorkouts,
      };
    } catch (e) {
      print('ERROR: Falha ao buscar estatísticas: $e');
      return {'totalMinutes': 0, 'totalWorkouts': 0};
    }
  }
}


