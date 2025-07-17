// Dart imports:
import 'dart:async';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import '../models/challenge_progress.dart';

abstract class RealtimeService {
  /// Observa as atualizações de progresso de um desafio específico
  Stream<List<ChallengeProgress>> watchChallengeParticipants(String challengeId);
  
  /// Observa as atualizações do ranking de um grupo específico
  Stream<List<ChallengeProgress>> watchGroupRanking(String groupId);
}

class SupabaseRealtimeService implements RealtimeService {
  final SupabaseClient _client;
  
  SupabaseRealtimeService(this._client);
  
  @override
  Stream<List<ChallengeProgress>> watchChallengeParticipants(String challengeId) {
    return _client
        .from('challenge_progress')
        .stream(primaryKey: ['id'])
        .eq('challenge_id', challengeId)
        .order('position', ascending: true)
        .map((data) => data
            .map<ChallengeProgress>((json) => ChallengeProgress.fromJson(json))
            .toList());
  }
  
  @override
  Stream<List<ChallengeProgress>> watchGroupRanking(String groupId) {
    // Usar a função RPC get_group_ranking para obter o ranking inicial
    final Stream<List<ChallengeProgress>> initialStream = _client
        .rpc('get_group_ranking', params: {'group_id_param': groupId})
        .then((data) => 
            (data as List<dynamic>)
                .map<ChallengeProgress>((json) => ChallengeProgress.fromJson(json))
                .toList())
        .asStream();
    
    // Buscar o challenge_id associado ao grupo
    final Future<String> challengeIdFuture = _client
        .from('challenge_groups')
        .select('challenge_id')
        .eq('id', groupId)
        .single()
        .then((data) => data['challenge_id'] as String);
    
    // Quando tivermos o challenge_id, criar um stream para observar todas 
    // as mudanças no challenge_progress para esse desafio
    final Future<Stream<List<ChallengeProgress>>> updatesStreamFuture = challengeIdFuture.then((challengeId) {
      // Obter IDs dos membros do grupo
      return _client
          .from('challenge_group_members')
          .select('user_id')
          .eq('group_id', groupId)
          .then((data) {
            final List<String> memberIds = data
                .map<String>((item) => item['user_id'] as String)
                .toList();
            
            // API atualizada do Supabase não suporta mais .filter() diretamente no stream
            // Como alternativa, vamos usar uma solução semelhante sem filtragem específica de membros
            return _client
                .from('challenge_progress')
                .stream(primaryKey: ['id'])
                .eq('challenge_id', challengeId)
                .order('position', ascending: true)
                .map((data) {
                  // Filtragem manual dos membros
                  final filteredData = data
                      .where((json) => memberIds.contains(json['user_id'] as String))
                      .toList();
                  
                  final List<ChallengeProgress> progressList = filteredData
                      .map<ChallengeProgress>((json) => ChallengeProgress.fromJson(json))
                      .toList();
                  
                  // ✅ USAR DADOS DIRETO DO BANCO (já vem ordenado e com posições corretas)
                  return progressList;
                });
          });
    });
    
    // Combinar o stream inicial com o stream de atualizações usando RxDart
    // Usamos asStream().take(1) para garantir tipo correto
    return initialStream.concatWith([
      Stream<List<ChallengeProgress>>.fromFuture(
        updatesStreamFuture
            .then((stream) => stream.first)
      ).concatWith([
        updatesStreamFuture
            .asStream()
            .switchMap((stream) => stream)
      ])
    ]);
  }
} 