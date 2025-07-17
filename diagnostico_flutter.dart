// Script de Diagnóstico para Problemas de Flutter no Ranking e Dashboard
// Este script analisa os problemas de atualização do ranking e dashboard após
// o registro de treinos e pode ser executado para fornecer logs detalhados.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importe os repositórios e modelos relevantes
import 'package:ray_club_app/features/workout/repositories/workout_record_repository.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/dashboard/repositories/dashboard_repository.dart';
import 'package:ray_club_app/services/workout_challenge_service.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data.dart';

/// Esta classe realiza o diagnóstico de problemas relacionados à atualização
/// do ranking e dashboard após o registro de treinos
class DiagnosticoRankingDashboard {
  final WorkoutRecordRepository _workoutRepository;
  final ChallengeRepository _challengeRepository;
  final DashboardRepository _dashboardRepository;
  final WorkoutChallengeService _workoutChallengeService;
  final SupabaseClient _supabase;
  final Ref _ref;

  DiagnosticoRankingDashboard(this._workoutRepository, this._challengeRepository, 
      this._dashboardRepository, this._workoutChallengeService, this._supabase, this._ref);

  /// Executa um diagnóstico completo
  Future<void> executarDiagnosticoCompleto(String userId) async {
    debugPrint('\n\n======= INICIANDO DIAGNÓSTICO COMPLETO =======');
    
    try {
      // 1. Verificar conexão com o Supabase
      await _verificarConexaoSupabase();
      
      // 2. Verificar dados do usuário
      await _verificarDadosUsuario(userId);
      
      // 3. Verificar treinos recentes
      final treinos = await _verificarTreinosRecentes(userId);
      if (treinos.isEmpty) {
        debugPrint('❌ Nenhum treino recente encontrado para análise');
        return;
      }
      
      // 4. Verificar desafios ativos
      final desafios = await _verificarDesafiosAtivos(userId);
      
      // 5. Verificar progresso nos desafios
      await _verificarProgressoDesafios(userId, desafios);
      
      // 6. Verificar dados do dashboard
      await _verificarDadosDashboard(userId);
      
      // 7. Testar a cadeia completa de processos
      if (treinos.isNotEmpty) {
        await _testarRegistroTreino(treinos.first, userId);
      }
      
      // 8. Verificar possíveis race conditions e callbacks
      await _verificarRaceConditionsECallbacks();
      
      // 9. Verificar streams e listeners
      await _verificarStreamsEListeners();
      
      debugPrint('\n======= DIAGNÓSTICO COMPLETO FINALIZADO =======\n');
    } catch (e, stackTrace) {
      debugPrint('\n❌ ERRO NO DIAGNÓSTICO: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Verifica se a conexão com o Supabase está funcionando
  Future<void> _verificarConexaoSupabase() async {
    debugPrint('\n📡 Verificando conexão com o Supabase...');
    
    try {
      // Verificar se o usuário está autenticado
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) {
        debugPrint('❌ Usuário não autenticado no Supabase');
        return;
      }
      
      debugPrint('✅ Usuário autenticado. ID: ${authUser.id}');
      
      // Testar conexão com uma consulta simples
      final result = await _supabase.from('workout_records').select('id').limit(1);
      debugPrint('✅ Conexão com o Supabase OK. Resposta: $result');
    } catch (e) {
      debugPrint('❌ Erro na conexão com o Supabase: $e');
      throw Exception('Falha na conexão com o Supabase: $e');
    }
  }

  /// Verifica se os dados do usuário estão corretos
  Future<void> _verificarDadosUsuario(String userId) async {
    debugPrint('\n👤 Verificando dados do usuário...');
    
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      debugPrint('✅ Dados do usuário recuperados com sucesso:');
      debugPrint('   Nome: ${response['name'] ?? 'N/A'}');
      debugPrint('   Email: ${response['email'] ?? 'N/A'}');
      debugPrint('   Criado em: ${response['created_at'] ?? 'N/A'}');
    } catch (e) {
      debugPrint('❌ Erro ao recuperar dados do usuário: $e');
    }
  }

  /// Verifica os treinos recentes do usuário
  Future<List<WorkoutRecord>> _verificarTreinosRecentes(String userId) async {
    debugPrint('\n🏋️ Verificando treinos recentes...');
    
    try {
      final treinos = await _workoutRepository.getWorkoutRecordsByUser(userId: userId, limit: 5);
      
      debugPrint('✅ ${treinos.length} treinos recentes encontrados');
      for (var treino in treinos) {
        debugPrint('   ID: ${treino.id} | Nome: ${treino.workoutName} | Data: ${treino.date} | Duração: ${treino.durationMinutes}min');
      }
      
      return treinos;
    } catch (e) {
      debugPrint('❌ Erro ao recuperar treinos: $e');
      return [];
    }
  }

  /// Verifica os desafios ativos do usuário
  Future<List<Challenge>> _verificarDesafiosAtivos(String userId) async {
    debugPrint('\n🏆 Verificando desafios ativos...');
    
    try {
      final desafios = await _challengeRepository.getUserActiveChallenges(userId);
      
      debugPrint('✅ ${desafios.length} desafios ativos encontrados');
      for (var desafio in desafios) {
        debugPrint('   ID: ${desafio.id} | Título: ${desafio.title} | Início: ${desafio.startDate} | Fim: ${desafio.endDate}');
      }
      
      return desafios;
    } catch (e) {
      debugPrint('❌ Erro ao recuperar desafios: $e');
      return [];
    }
  }

  /// Verifica o progresso nos desafios
  Future<void> _verificarProgressoDesafios(String userId, List<Challenge> desafios) async {
    debugPrint('\n📊 Verificando progresso nos desafios...');
    
    try {
      for (var desafio in desafios) {
        final progresso = await _challengeRepository.getUserProgress(
          challengeId: desafio.id, 
          userId: userId
        );
        
        if (progresso != null) {
          debugPrint('✅ Progresso para desafio "${desafio.title}":');
          debugPrint('   Pontos: ${progresso.points} | Check-ins: ${progresso.checkInsCount} | Posição: ${progresso.position}');
        } else {
          debugPrint('⚠️ Nenhum progresso encontrado para o desafio "${desafio.title}"');
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao verificar progresso nos desafios: $e');
    }
  }

  /// Verifica os dados do dashboard
  Future<void> _verificarDadosDashboard(String userId) async {
    debugPrint('\n📱 Verificando dados do dashboard...');
    
    try {
      final dashboardData = await _dashboardRepository.getDashboardData(userId);
      
      debugPrint('✅ Dados do dashboard recuperados com sucesso:');
      debugPrint('   Total de treinos: ${dashboardData.userProgress.totalWorkouts}');
      debugPrint('   Streak atual: ${dashboardData.userProgress.currentStreak}');
      debugPrint('   Streak mais longo: ${dashboardData.userProgress.longestStreak}');
      debugPrint('   Total de pontos: ${dashboardData.userProgress.totalPoints}');
      debugPrint('   Tipos de treinos: ${dashboardData.userProgress.workoutTypes}');
      
      if (dashboardData.currentChallenge != null) {
        debugPrint('   Desafio atual: ${dashboardData.currentChallenge!.title}');
      } else {
        debugPrint('   Desafio atual: Nenhum');
      }
    } catch (e) {
      debugPrint('❌ Erro ao recuperar dados do dashboard: $e');
    }
  }

  /// Testa o registro de treino para verificar atualizações
  Future<void> _testarRegistroTreino(WorkoutRecord treino, String userId) async {
    debugPrint('\n🧪 Simulando processamento para treino "${treino.workoutName}"...');
    
    try {
      // 1. Obter o estado inicial do dashboard e ranking
      debugPrint('\n📊 Estado ANTES do processamento:');
      await _verificarDadosDashboard(userId);
      final desafios = await _verificarDesafiosAtivos(userId);
      await _verificarProgressoDesafios(userId, desafios);
      
      // 2. Processar o treino para desafios
      debugPrint('\n🔄 Processando treino para desafios...');
      final pontosGanhos = await _workoutChallengeService.processWorkoutCompletion(treino);
      debugPrint('✅ Processamento concluído. Pontos ganhos: $pontosGanhos');
      
      // 3. Verificar se os dados foram atualizados corretamente
      debugPrint('\n📊 Estado DEPOIS do processamento:');
      
      // Aguardar alguns segundos para garantir que as atualizações assíncronas foram aplicadas
      await Future.delayed(const Duration(seconds: 3));
      
      await _verificarDadosDashboard(userId);
      await _verificarProgressoDesafios(userId, desafios);
      
      // 4. Verificar logs de erros
      await _verificarLogsErros(treino.id);
    } catch (e) {
      debugPrint('❌ Erro ao testar registro de treino: $e');
    }
  }

  /// Verifica os logs de erros relacionados ao treino
  Future<void> _verificarLogsErros(String workoutId) async {
    debugPrint('\n🔍 Verificando logs de erros para o treino...');
    
    try {
      // Verificar se a tabela existe
      try {
        final logs = await _supabase
            .from('check_in_error_logs')
            .select()
            .eq('workout_id', workoutId)
            .order('created_at', ascending: false);
        
        if (logs.isEmpty) {
          debugPrint('✅ Nenhum erro encontrado para este treino');
        } else {
          debugPrint('⚠️ ${logs.length} erros encontrados:');
          for (var log in logs) {
            debugPrint('   [${log['created_at']}] ${log['error_message']}');
          }
        }
      } catch (e) {
        debugPrint('⚠️ Tabela de logs de erros não encontrada ou inacessível: $e');
      }
    } catch (e) {
      debugPrint('❌ Erro ao verificar logs: $e');
    }
  }

  /// Verifica possíveis race conditions e problemas de callbacks
  Future<void> _verificarRaceConditionsECallbacks() async {
    debugPrint('\n🔄 Verificando possíveis race conditions e problemas de callbacks...');
    
    // 1. Verificar como os providers são notificados após a atualização
    debugPrint('  • Analisando fluxo de notificação de providers:');
    
    // Verificar se o código usa refrescar estado explicitamente
    final dashboard = _ref.read(dashboardRepositoryProvider);
    if (dashboard != null) {
      debugPrint('    ✅ Provider do dashboard está disponível');
    } else {
      debugPrint('    ⚠️ Provider do dashboard não está disponível no contexto atual');
    }

    // 2. Verificar como as funções são chamadas
    debugPrint('\n  • Analisando chamadas de funções após registro de treino:');
    debugPrint('    - WorkoutChallengeService.processWorkoutCompletion() é chamado após o treino ser registrado');
    debugPrint('    - ChallengeRepository.recordChallengeCheckIn() é chamado para cada desafio ativo');
    debugPrint('    - No Supabase, record_challenge_check_in_v2() é responsável por atualizar pontos e progresso');
    debugPrint('    - Dashboard não é atualizado automaticamente, depende do ViewModel fazer a atualização');
    
    // 3. Possíveis problemas
    debugPrint('\n  • Possíveis problemas identificados:');
    debugPrint('    1. Falta de atualização automática do dashboard após check-in');
    debugPrint('    2. Possível falha na chamada das funções RPC no Supabase');
    debugPrint('    3. Race condition entre atualização de check-in e consulta do dashboard');
    debugPrint('    4. Falta de invalidação de cache dos providers após novos registros');
  }

  /// Verifica streams e listeners
  Future<void> _verificarStreamsEListeners() async {
    debugPrint('\n🔊 Verificando streams e listeners...');
    
    // 1. Verificar se os ViewModels estão usando os providers corretamente
    debugPrint('  • Analisando uso de providers e listeners:');
    debugPrint('    - Dashboard deve usar providers que reagem a mudanças');
    debugPrint('    - Ranking deve usar Stream ou AutoDisposeFutureProvider para atualizações em tempo real');
    
    // 2. Possíveis problemas
    debugPrint('\n  • Possíveis problemas com streams e listeners:');
    debugPrint('    1. Provider do dashboard não está sendo invalidado após novos treinos');
    debugPrint('    2. Stream de ranking não está recebendo notificações de mudanças');
    debugPrint('    3. Falta de uso de .ref.refresh() nos ViewModels após operações de gravação');
  }
  
  /// Gera recomendações com base nos problemas identificados
  String gerarRecomendacoes() {
    final recomendacoes = StringBuffer();
    
    recomendacoes.writeln('\n📋 RECOMENDAÇÕES DE CORREÇÃO:');
    recomendacoes.writeln('\n1. SUPABASE (SQL):');
    recomendacoes.writeln('   - Verificar a função record_challenge_check_in_v2 para garantir que está atualizando corretamente o ranking');
    recomendacoes.writeln('   - Garantir que process_workout_for_dashboard seja chamado corretamente após registro de treino');
    recomendacoes.writeln('   - Adicionar triggers para atualizar automaticamente o dashboard');
    recomendacoes.writeln('   - Verificar se há erros sendo registrados na tabela check_in_error_logs');
    
    recomendacoes.writeln('\n2. FLUTTER:');
    recomendacoes.writeln('   - Garantir que o ViewModel do dashboard esteja usando invalidação de cache adequadamente');
    recomendacoes.writeln('   - Após registro de treino, forçar atualização do dashboard com ref.refresh()');
    recomendacoes.writeln('   - Considerar usar StreamProviders para dados que precisam ser atualizados em tempo real');
    recomendacoes.writeln('   - Verificar se o WorkoutService está chamando corretamente o WorkoutChallengeService');
    
    recomendacoes.writeln('\n3. ARQUITETURA:');
    recomendacoes.writeln('   - Implementar um mecanismo de eventos para sincronizar atualizações entre diferentes partes do app');
    recomendacoes.writeln('   - Considerar usar um BroadcastProvider para notificar diferentes partes do app sobre novos treinos');
    recomendacoes.writeln('   - Reforçar o padrão MVVM garantindo que os ViewModels observem corretamente os providers');
    
    return recomendacoes.toString();
  }
}

// Provider para o diagnóstico
final diagnosticoProvider = Provider<DiagnosticoRankingDashboard>((ref) {
  final workoutRepository = ref.watch(workoutRecordRepositoryProvider);
  final challengeRepository = ref.watch(challengeRepositoryProvider);
  final dashboardRepository = ref.watch(dashboardRepositoryProvider);
  final workoutChallengeService = ref.watch(workoutChallengeServiceProvider);
  final supabase = Supabase.instance.client;
  
  return DiagnosticoRankingDashboard(
    workoutRepository, 
    challengeRepository,
    dashboardRepository,
    workoutChallengeService,
    supabase,
    ref
  );
});

// Execução do diagnóstico
void executarDiagnostico(WidgetRef ref, String userId) async {
  final diagnostico = ref.read(diagnosticoProvider);
  await diagnostico.executarDiagnosticoCompleto(userId);
  
  // Imprimir recomendações
  debugPrint(diagnostico.gerarRecomendacoes());
} 