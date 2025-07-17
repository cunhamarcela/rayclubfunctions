// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:flutter/foundation.dart'; // For ValueGetter if needed
import 'package:collection/collection.dart';
import 'dart:math' as math;
import 'package:ray_club_app/utils/log_utils.dart';
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/auth/models/user.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import '../models/challenge.dart';
import '../models/challenge_progress.dart';
import '../models/challenge_group.dart';
import '../models/challenge_state.dart'; // Usando o novo arquivo de estado
import '../repositories/challenge_repository.dart';
import '../providers/challenge_providers.dart'; // Adicionando import para o provider
import '../services/challenge_realtime_service.dart';
import 'package:ray_club_app/utils/text_sanitizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';


/// Provider para o ChallengeViewModel
final challengeViewModelProvider = StateNotifierProvider<ChallengeViewModel, ChallengeState>((ref) {
  final repository = ref.watch(challengeRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final realtimeService = ref.watch(challengeRealtimeServiceProvider);
  return ChallengeViewModel(
    repository: repository, 
    authRepository: authRepository,
    realtimeService: realtimeService,
    ref: ref,
  );
});

/// Helper class para extrair dados do estado atual de forma mais segura
class ChallengeStateHelper {
  /// Retorna desafios do estado, ou uma lista vazia se não existirem
  static List<Challenge> getChallenges(ChallengeState state) {
    return state.challenges;
  }
  
  /// Retorna desafios filtrados do estado, ou uma lista vazia se não existirem
  static List<Challenge> getFilteredChallenges(ChallengeState state) {
    return state.filteredChallenges;
  }
  
  /// Retorna o desafio selecionado, ou null se não existir
  static Challenge? getSelectedChallenge(ChallengeState state) {
    return state.selectedChallenge;
  }
  
  /// Retorna convites pendentes do estado, ou uma lista vazia se não existirem
  static List<ChallengeGroupInvite> getPendingInvites(ChallengeState state) {
    return state.pendingInvites;
  }
  
  /// Retorna a lista de progresso do estado, ou uma lista vazia se não existir
  static List<ChallengeProgress> getProgressList(ChallengeState state) {
    return state.progressList;
  }
  
  /// Retorna o progresso do usuário no desafio selecionado, ou null se não existir
  static ChallengeProgress? getUserProgress(ChallengeState state) {
    return state.userProgress;
  }
  
  /// Obtém a mensagem de sucesso do estado
  static String? getSuccessMessage(ChallengeState state) {
    return state.successMessage;
  }
  
  /// Obtém a mensagem de erro do estado
  static String? getErrorMessage(ChallengeState state) {
    return state.errorMessage;
  }
  
  /// Verifica se o estado está carregando
  static bool isLoading(ChallengeState state) {
    return state.isLoading;
  }
  
  /// Retorna o desafio oficial, ou null se não existir
  static Challenge? getOfficialChallenge(ChallengeState state) {
    return state.officialChallenge;
  }
}

/// ViewModel para gerenciar desafios
class ChallengeViewModel extends StateNotifier<ChallengeState> {
  final ChallengeRepository _repository;
  final IAuthRepository _authRepository;
  final ChallengeRealtimeService _realtimeService;
  final Ref ref;
  StreamSubscription? _rankingSubscription; // Single subscription for ranking

  // Rastrear se o componente foi descartado
  bool _isDisposed = false;

  ChallengeViewModel({
    required ChallengeRepository repository,
    required IAuthRepository authRepository,
    required ChallengeRealtimeService realtimeService,
    required this.ref,
  })  : _repository = repository,
        _authRepository = authRepository,
        _realtimeService = realtimeService,
        super(ChallengeState.initial()) {
    // Initial load can fetch the official challenge specifically
    loadOfficialChallenge();
    // Optionally load other challenges in the background or on demand
    // loadAllChallenges();
  }

  /// Extrai mensagem de erro de uma exceção
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    
    // Mapeamento de erros comuns para mensagens amigáveis ao usuário
    if (error is DatabaseException) {
      return 'Erro ao acessar banco de dados. Por favor, tente novamente mais tarde.';
    }
    
    if (error is NetworkException) {
      return 'Erro de conexão. Verifique sua internet e tente novamente.';
    }
    
    if (error is AppAuthException) {
      return 'Erro de autenticação. Faça login novamente.';
    }
    
    if (error is ValidationException) {
      return 'Dados inválidos. Verifique suas informações e tente novamente.';
    }
    
    // Para erros não mapeados, forneça uma mensagem genérica em vez de expor detalhes técnicos
    return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
  }

  /// Loads only the official challenge (e.g., Ray Challenge) and its ranking.
  Future<void> loadOfficialChallenge({String? filterByGroupId}) async {
    // Verificar se o componente não foi descartado
    if (!_isSafeToModifyState) {
      debugPrint('⚠️ ChallengeViewModel - tentativa de usar após dispose');
      return;
    }
    
    debugPrint('🔍 ChallengeViewModel - loadOfficialChallenge iniciado');
    
    // Preserve current state while loading official challenge
    state = ChallengeState.loading(
       challenges: state.challenges,
       // Keep other state fields as they are
       pendingInvites: state.pendingInvites,
       selectedGroupIdForFilter: filterByGroupId ?? state.selectedGroupIdForFilter,
    );
    
    try {
      final now = DateTime.now();
      debugPrint('🔍 ChallengeViewModel - Data atual: ${now.toIso8601String()}');
      
      final challenge = await _repository.getOfficialChallenge();
      
      // Verificar novamente se o componente não foi descartado após operação assíncrona
      if (!_isSafeToModifyState) {
        debugPrint('⚠️ ChallengeViewModel - componente descartado durante operação assíncrona');
        return;
      }
      
      debugPrint('🔍 ChallengeViewModel - Desafio oficial recebido: ${challenge?.title}, id: ${challenge?.id}');
      
      if (challenge != null) {
        debugPrint('🔍 ChallengeViewModel - Datas do desafio: início=${challenge.startDate.toIso8601String()}, fim=${challenge.endDate.toIso8601String()}');
        // Load ranking (potentially filtered)
        final progressList = await _loadRanking(challenge.id, filterByGroupId);
        debugPrint('🔍 ChallengeViewModel - Ranking carregado, ${progressList.length} participantes');
        
        // Load user's progress in this official challenge
        final userProgress = await _loadUserProgress(challenge.id);
        debugPrint('🔍 ChallengeViewModel - Progresso do usuário: ${userProgress != null ? 'encontrado' : 'não encontrado'}');

        state = state.copyWith(
          isLoading: false,
          officialChallenge: challenge,
          selectedChallenge: challenge, // Select the official one by default
          progressList: progressList,
          userProgress: userProgress,
          errorMessage: null, // Clear previous error
          selectedGroupIdForFilter: filterByGroupId, // Update filter state
        );
        debugPrint('🔍 ChallengeViewModel - Estado atualizado com desafio oficial');
        
        // Start watching for real-time updates (if not already watching)
        watchChallengeRanking(challenge.id, filterByGroupId: filterByGroupId);
      } else {
        debugPrint('❌ ChallengeViewModel - Nenhum desafio oficial encontrado');
        state = state.copyWith(
          isLoading: false,
          officialChallenge: null,
          selectedChallenge: null, // No challenge selected
          errorMessage: null,
          progressList: [], // Clear ranking
          userProgress: null,
        );
      }
    } catch (e, s) {
      debugPrint('❌ ChallengeViewModel - Erro ao carregar desafio oficial: $e');
      debugPrint(s.toString());
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Loads all non-official challenges.
  Future<void> loadOtherChallenges() async {
     // Use a different loading indicator or state if needed, or combine loading states
     state = state.copyWith(isLoading: true); // Consider a more specific loading state
     try {
        final allChallenges = await _repository.getChallenges();
        // Filter out the official challenge if it's already loaded separately
        final otherChallenges = allChallenges.where((c) => !c.isOfficial).toList();

        // Combine with potentially existing official challenge in the main list if desired
        // Or keep them separate in the state. For now, just update `challenges`.
        final currentOfficial = state.officialChallenge;
        final combinedChallenges = [
          if (currentOfficial != null) currentOfficial,
          ...otherChallenges,
        ];

        state = state.copyWith(
          isLoading: false,
          // Update the main challenges list, keeping officialChallenge separate
          challenges: combinedChallenges,
          // Decide how filteredChallenges should behave - initially show all?
          filteredChallenges: combinedChallenges,
          errorMessage: null,
        );
        debugPrint('✅ Loaded ${otherChallenges.length} other challenges.');
     } catch (e, s) {
        debugPrint('❌ Error loading other challenges: $e\\n$s');
        state = state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(e),
        );
     }
  }


  /// Loads details for a specific challenge (could be official or custom) and its ranking.
  Future<void> loadChallengeDetails(String challengeId, {
    String? filterByGroupId,
    bool skipRealtimeUpdates = false,
  }) async {
     debugPrint('🔄 ChallengeViewModel - Carregando detalhes do desafio com ID: $challengeId');
     state = ChallengeState.loading(
        // Preserve existing state while loading details
        challenges: state.challenges,
        officialChallenge: state.officialChallenge,
        pendingInvites: state.pendingInvites,
        selectedGroupIdForFilter: filterByGroupId ?? state.selectedGroupIdForFilter,
     );
    try {
      // Forçar atualização completa do desafio
      debugPrint('🔄 ChallengeViewModel - Buscando desafio atualizado');
      final challenge = await _repository.getChallengeById(challengeId);
      if (challenge == null) {
        throw Exception('Challenge with ID $challengeId not found.');
      }

      // Load ranking (potentially filtered) - forçando limpeza de cache
      debugPrint('🔄 ChallengeViewModel - Buscando ranking atualizado');
      final progressList = await _repository.getChallengeProgress(challenge.id);
      
      // Load user's progress in this specific challenge - forçando limpeza de cache
      debugPrint('🔄 ChallengeViewModel - Buscando progresso do usuário atualizado');
      final userProgress = await _loadUserProgress(challenge.id);
      
      debugPrint('✅ ChallengeViewModel - Dados carregados: ${progressList.length} participantes, usuário ${userProgress != null ? "encontrado" : "não encontrado"}');

      state = state.copyWith(
        isLoading: false,
        selectedChallenge: challenge,
        progressList: progressList,
        userProgress: userProgress,
        errorMessage: null,
        selectedGroupIdForFilter: filterByGroupId, // Update filter state
        // Keep officialChallenge as is
        officialChallenge: state.officialChallenge,
      );
      debugPrint('✅ Details loaded for challenge: ${challenge.title}');
      
      // Start watching for real-time updates, unless skipRealtimeUpdates is true
      if (!skipRealtimeUpdates) {
        watchChallengeRanking(challenge.id, filterByGroupId: filterByGroupId);
      } else {
        debugPrint('ℹ️ Skipping real-time updates as requested');
      }
    } catch (e, s) {
      debugPrint('❌ Error loading challenge details for $challengeId: $e\\n$s');
      state = state.copyWith(
        isLoading: false,
        selectedChallenge: null, // Clear selection on error
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Filters the ranking of the currently selected challenge by a group ID.
  void filterRankingByGroup(String? groupId) async {
    if (state.selectedChallenge == null) {
      debugPrint('⚠️ Cannot filter ranking: No challenge selected.');
      return;
    }
    
    // Set loading state and keep the new filter selection
    state = state.copyWith(
      isLoading: true,
      selectedGroupIdForFilter: groupId,
    );

    try {
      // Verificar se existe um desafio selecionado
      final selectedChallenge = state.selectedChallenge;
      if (selectedChallenge == null) {
        throw AppException(message: 'Nenhum desafio selecionado para filtrar');
      }
      
      // Load filtered ranking data
      final progressList = await _loadRanking(selectedChallenge.id, groupId);
      
      // Update state with new filtered data
      state = state.copyWith(
        isLoading: false, 
        progressList: progressList,
        errorMessage: null, // Clear any previous errors
      );
      
      // Update the subscription to watch the correct stream
      watchChallengeRanking(selectedChallenge.id, filterByGroupId: groupId);
      
      debugPrint('✅ Ranking filtered by groupId: $groupId');
    } catch (e) {
      debugPrint('❌ Error filtering ranking by group: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Setup a real-time subscription to watch challenge ranking updates
  void watchChallengeRanking(String challengeId, {String? filterByGroupId}) {
    debugPrint('🔍 ChallengeViewModel - watchChallengeRanking iniciado para desafio: $challengeId, filtro: $filterByGroupId');
    
    // Cancel any existing subscription first
    if (_rankingSubscription != null) {
      debugPrint('🔍 ChallengeViewModel - Cancelando subscription anterior');
      _rankingSubscription?.cancel();
      _rankingSubscription = null;
    }
    
    // Different stream setup based on whether we're filtering by group or not
    if (filterByGroupId != null) {
      debugPrint('🔄 ChallengeRealtimeService - Iniciando observação para grupo: $filterByGroupId no desafio: $challengeId');
      _rankingSubscription = _realtimeService.watchGroupRanking(challengeId, filterByGroupId)
        .listen(_handleRankingUpdate);
    } else {
      debugPrint('🔄 ChallengeRealtimeService - Iniciando observação para ranking geral do desafio: $challengeId');
      _rankingSubscription = _realtimeService.watchChallengeParticipants(challengeId)
        .listen(_handleRankingUpdate);
    }
    
    debugPrint('🔍 ChallengeViewModel - Stream configurado com o serviço realtime');
    
    // Initial fetch to ensure we have data while waiting for real-time events
    _refreshRankingData(challengeId, filterByGroupId);
  }
  
  /// Handle incoming real-time updates to ranking
  void _handleRankingUpdate(List<ChallengeProgress> newRanking) async {
    debugPrint('🔄 Atualizando ranking com ${newRanking.length} registros...');
    
    // ✅ USAR DADOS DIRETO DO BANCO (já vem ordenado e com posições corretas)
    try {
      final userId = await _authRepository.getCurrentUserId();
      final userProgress = newRanking.firstWhereOrNull((p) => p.userId == userId);
      
      // Update state with new ranking data (sem modificar as posições)
      state = state.copyWith(
        progressList: newRanking, // ✅ Usar dados direto do banco
        userProgress: userProgress,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      debugPrint('❌ Erro ao obter ID do usuário: $e');
      // Update state without user progress
      state = state.copyWith(
        progressList: newRanking, // ✅ Usar dados direto do banco
        isLoading: false,
        errorMessage: null,
      );
    }
  }
  
  /// Refresh ranking data manually (used for initial load or after error)
  Future<void> _refreshRankingData(String challengeId, String? groupIdFilter) async {
    debugPrint('🔍 Iniciando refresh forçado do ranking do desafio: $challengeId');
    try {
      // Buscar os dados do usuário atual
      final userId = await _authRepository.getCurrentUserId();
      if (userId == null) {
        debugPrint('⚠️ Não foi possível obter o ID do usuário atual');
        return;
      }

      // Forçar limpeza do cache diretamente
      await _repository.clearCache(challengeId);
      
      // Aguardar um momento para garantir que o banco processou as atualizações
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Buscar o ranking completo (com update de cache)
      debugPrint('🔄 Forçando atualização do ranking completo...');
      final ranking = await _repository.getChallengeProgress(challengeId);
      
      // Buscar também o progresso do usuário atual
      debugPrint('🔄 Forçando atualização do progresso do usuário: $userId');
      final userProgress = await _repository.getUserProgress(
        challengeId: challengeId,
        userId: userId,
      );
      
      // Atualizar o estado com os dados mais recentes
      if (ranking.isNotEmpty) {
        debugPrint('✅ Dados atualizados: ${ranking.length} participantes, usuário ${userProgress != null ? "encontrado" : "não encontrado"}');
        
        state = state.copyWith(
          progressList: ranking,
          userProgress: userProgress,
          isLoading: false,
        );
      } else {
        debugPrint('⚠️ Nenhum dado de ranking recebido');
      }
    } catch (e) {
      debugPrint('❌ Erro ao atualizar ranking: $e');
    }
  }

  /// Load ranking (and potentially filter it)
  Future<List<ChallengeProgress>> _loadRanking(String challengeId, String? filterByGroupId) async {
    try {
      return await _repository.getChallengeProgress(challengeId);
    } catch (e) {
      debugPrint('❌ Erro ao carregar ranking: $e');
      // Return empty list on error, but don't update state yet
      return [];
    }
  }

  /// Loads and watches user progress in the specified challenge
  Future<ChallengeProgress?> _loadUserProgress(String challengeId) async {
    try {
      final user = await _authRepository.getCurrentUser();
      final userId = user?.id;
      if (userId == null) {
        debugPrint('⚠️ Cannot load user progress: No authenticated user.');
        return null;
      }
      
      // Verificar se o usuário está participando do desafio
      final progress = await _repository.getUserProgress(
        challengeId: challengeId,
        userId: userId,
      );
      
      if (progress == null) {
        debugPrint('🔍 _loadUserProgress: Usuário não tem progresso no desafio, verificando se é participante');
        
        // Verificar se o usuário está na tabela de participantes
        final isParticipant = await _repository.isUserParticipatingInChallenge(
          challengeId: challengeId,
          userId: userId,
        );
        
        if (isParticipant) {
          debugPrint('🔍 _loadUserProgress: Usuário é participante mas não tem progresso, criando progresso inicial');
          
          try {
            // Se o usuário é participante mas não tem progresso, criar um progresso inicial
            final userInfo = await _authRepository.getUserProfile();
            final userName = userInfo?.userMetadata?['name'] as String? ?? "Usuário";
            final photoUrl = userInfo?.userMetadata?['avatar_url'] as String?;
            
            // Criar progresso inicial
            await _repository.createUserProgress(
              challengeId: challengeId,
              userId: userId,
              userName: userName,
              userPhotoUrl: photoUrl,
              points: 0,
              completionPercentage: 0,
            );
            
            // Buscar o progresso novamente após criar
            return await _repository.getUserProgress(
              challengeId: challengeId,
              userId: userId,
            );
          } catch (e) {
            // Se ocorrer erro de chave duplicada (code 23505), tente buscar o progresso novamente
            if (e.toString().contains('23505') || e.toString().contains('duplicate key')) {
              debugPrint('⚠️ _loadUserProgress: Conflito de chave duplicada, tentando recuperar progresso existente');
              // Aguarde um momento para garantir consistência
              await Future.delayed(const Duration(milliseconds: 500));
              return await _repository.getUserProgress(
                challengeId: challengeId,
                userId: userId,
              );
            } else {
              // Relançar o erro para outros casos
              rethrow;
            }
          }
        }
      }
      
      return progress;
    } catch (e) {
      debugPrint('❌ Error loading user progress: $e');
      return null;
    }
  }

  /// Carrega o ranking de um desafio com opção de filtro por grupo
  Future<void> loadChallengeRanking(String challengeId, {String? groupId}) async {
    try {
      state = state.copyWith(isLoading: true);
      
      List<ChallengeProgress> ranking;
      if (groupId != null) {
        // Usar função RPC específica para filtro de grupo
        final client = Supabase.instance.client;
        final response = await client.rpc(
          'get_group_challenge_ranking', 
          params: {
            '_challenge_id': challengeId,
            '_group_id': groupId
          }
        );
            
        if (response == null) {
          throw AppException(message: 'Erro ao carregar ranking por grupo: Resposta nula');
        }
        
        ranking = (response as List).map((item) => ChallengeProgress.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        // Usar ranking padrão
        ranking = await _repository.getChallengeProgress(challengeId);
      }
      
      state = state.copyWith(
        progressList: ranking,
        selectedGroupIdForFilter: groupId,
        isLoading: false
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: _getErrorMessage(e),
        isLoading: false
      );
    }
  }

  /// Carrega todos os desafios, mas garante que o desafio oficial da Ray está incluído
  Future<void> loadAllChallengesWithOfficial() async {
    try {
      state = ChallengeState.loading();
      
      // Carrega todos os desafios
      final challenges = await _repository.getChallenges();
      
      // Verifica se há um desafio oficial
      final officialChallenge = await _repository.getOfficialChallenge();
      
      // Garante que o desafio oficial está na lista se existir
      final allChallenges = List<Challenge>.from(challenges);
      if (officialChallenge != null) {
        // Remove versões duplicadas do desafio oficial se existirem
        allChallenges.removeWhere((challenge) => challenge.id == officialChallenge.id);
        // Adiciona o desafio oficial
        allChallenges.add(officialChallenge);
      }
      
      // Carrega os convites pendentes para o usuário atual
      final currentUser = await _authRepository.getCurrentUser();
      final userId = currentUser?.id ?? '';
      
      if (userId.isEmpty) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }
      
      final pendingInvites = await _repository.getPendingInvites(userId);
      
      state = ChallengeState.success(
        challenges: allChallenges,
        filteredChallenges: allChallenges,
        pendingInvites: pendingInvites,
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }

  /// Carrega todos os desafios do repositório
  Future<void> loadChallenges() async {
    try {
      state = ChallengeState.loading(
        // Preservar dados existentes para evitar flickering
        officialChallenge: state.officialChallenge,
        selectedChallenge: state.selectedChallenge,
        pendingInvites: state.pendingInvites,
        progressList: state.progressList,
        userProgress: state.userProgress,
      );
      
      final challenges = await _repository.getChallenges();
      
      state = state.copyWith(
        challenges: challenges,
        filteredChallenges: challenges,
        isLoading: false,
        errorMessage: null, // Clear any previous error
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Verifica se o usuário atual é um administrador
  Future<bool> isAdmin() async {
    try {
      return await _repository.isCurrentUserAdmin();
    } catch (e) {
      return false;
    }
  }
  
  /// Alterna o status de administrador (apenas para testes)
  Future<void> toggleAdminStatus() async {
    try {
      await _repository.toggleAdminStatus();
    } catch (e) {
      state = ChallengeState(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        progressList: ChallengeStateHelper.getProgressList(state),
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Método para filtrar desafios ativos na UI sem fazer nova requisição
  void filtrarDesafiosAtivos() {
    try {
      // Verificar se há desafios carregados
      if (state.challenges.isEmpty) {
        throw AppException(message: 'Nenhum desafio carregado para filtrar');
      }
      
      final now = DateTime.now();
      
      // Filtrar desafios já carregados que estão ativos
      final desafiosAtivos = state.challenges.where((challenge) => 
        challenge.startDate.isBefore(now) && challenge.endDate.isAfter(now)
      ).toList();
      
      // Atualizar apenas o filtro, mantendo a lista completa
      state = state.copyWith(
        filteredChallenges: desafiosAtivos,
        isLoading: false,
        errorMessage: null,
        successMessage: desafiosAtivos.isEmpty ? 'Não há desafios ativos no momento' : null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Cria um novo desafio com validação aprimorada
  Future<void> createChallenge(Challenge challenge) async {
    try {
      // Validações antes de começar
      if (challenge.title.trim().isEmpty) {
        throw ValidationException(message: 'O título do desafio não pode estar vazio');
      }
      
      if (challenge.description.trim().isEmpty) {
        throw ValidationException(message: 'A descrição do desafio não pode estar vazia');
      }
      
      if (challenge.startDate.isAfter(challenge.endDate)) {
        throw ValidationException(message: 'A data de início deve ser anterior à data de término');
      }
      
      // Iniciar estado de carregamento preservando dados existentes
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );
      
      // Criar o desafio
      final newChallenge = await _repository.createChallenge(challenge);
      
      // Atualizar a lista de desafios incluindo o novo
      final updatedChallenges = [...state.challenges, newChallenge];
      
      // Atualizar estado
      state = state.copyWith(
        challenges: updatedChallenges,
        filteredChallenges: updatedChallenges,
        selectedChallenge: newChallenge,
        isLoading: false,
        successMessage: 'Desafio criado com sucesso!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Atualiza um desafio existente com validações e tratamento de estado aprimorados
  Future<void> updateChallenge(Challenge challenge) async {
    try {
      // Validações antes de começar
      if (challenge.title.trim().isEmpty) {
        throw ValidationException(message: 'O título do desafio não pode estar vazio');
      }
      
      if (challenge.description.trim().isEmpty) {
        throw ValidationException(message: 'A descrição do desafio não pode estar vazia');
      }
      
      if (challenge.startDate.isAfter(challenge.endDate)) {
        throw ValidationException(message: 'A data de início deve ser anterior à data de término');
      }
      
      // Iniciar estado de carregamento preservando dados existentes
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );
      
      // Atualizar o desafio
      await _repository.updateChallenge(challenge);
      
      // Atualizar as listas no estado mantendo referência ao progresso atual
      final updatedChallenges = state.challenges.map((c) {
        return c.id == challenge.id ? challenge : c;
      }).toList();
      
      final updatedFilteredChallenges = state.filteredChallenges.map((c) {
        return c.id == challenge.id ? challenge : c;
      }).toList();
      
      // Se o desafio atualizado for o desafio oficial, atualizar também a referência
      final updatedOfficialChallenge = state.officialChallenge?.id == challenge.id
        ? challenge
        : state.officialChallenge;
      
      // Atualizar estado
      state = state.copyWith(
        challenges: updatedChallenges,
        filteredChallenges: updatedFilteredChallenges,
        selectedChallenge: challenge,
        officialChallenge: updatedOfficialChallenge,
        isLoading: false,
        successMessage: 'Desafio atualizado com sucesso!',
      );
      
      // Se o desafio atualizado for o selecionado atualmente, atualizar também o ranking
      if (state.selectedChallenge?.id == challenge.id) {
        // Recarregar o ranking do desafio selecionado
        loadChallengeDetails(challenge.id, skipRealtimeUpdates: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Participa de um desafio com melhor tratamento de estado
  Future<void> joinChallenge({required String challengeId, required String userId}) async {
    try {
      // Mostrar progresso mantendo o estado atual
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );
      
      // Verificações adicionais
      if (challengeId.isEmpty || userId.isEmpty) {
        throw ValidationException(message: 'ID do desafio ou do usuário inválido');
      }
      
      // Tentar entrar no desafio
      await _repository.joinChallenge(
        challengeId: challengeId,
        userId: userId,
      );
      
      // Aguardar um momento para garantir que o banco de dados processou a entrada
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Buscar o progresso do usuário atualizado - força a recarga completa
      final userProgress = await _repository.getUserProgress(
        challengeId: challengeId, 
        userId: userId
      );
      
      debugPrint('🔍 joinChallenge: Progresso obtido após entrar no desafio: ${userProgress != null ? 'encontrado' : 'não encontrado'}');
      
      // Recarregar também o ranking completo
      final progressList = await _repository.getChallengeProgress(challengeId);
      debugPrint('🔍 joinChallenge: Ranking recarregado com ${progressList.length} participantes');
      
      // Atualizar o estado com todas as informações
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Você entrou no desafio com sucesso!',
        userProgress: userProgress, // Atualizar com o novo progresso
        progressList: progressList, // Atualizar o ranking
      );
      
      // Garantir que as atualizações em tempo real estão funcionando
      watchChallengeRanking(challengeId, filterByGroupId: state.selectedGroupIdForFilter);
    } catch (e) {
      // Tratar exceções específicas
      String errorMessage = _getErrorMessage(e);
      
      // Mensagens mais amigáveis para erros específicos 
      if (errorMessage.contains('já é membro') || errorMessage.contains('already joined')) {
        errorMessage = 'Você já participa deste desafio';
      } else if (errorMessage.contains('desafio encerrado') || 
                errorMessage.contains('challenge ended')) {
        errorMessage = 'Este desafio já foi encerrado';
      }
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
    }
  }
  
  /// Sai de um desafio com melhor tratamento de estado
  Future<void> leaveChallenge({required String challengeId, required String userId}) async {
    try {
      // Mostrar progresso mantendo o estado atual
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );
      
      // Verificações adicionais
      if (challengeId.isEmpty || userId.isEmpty) {
        throw ValidationException(message: 'ID do desafio ou do usuário inválido');
      }
      
      // Tentar sair do desafio
      await _repository.leaveChallenge(
        challengeId: challengeId,
        userId: userId,
      );
      
      // Se bem-sucedido, notificar e recarregar os detalhes
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Você saiu do desafio',
        userProgress: null, // Limpar o progresso do usuário
      );
      
      // Recarregar os detalhes do desafio para atualizar a lista de participantes
      await loadChallengeDetails(challengeId);
    } catch (e) {
      // Tratar exceções específicas
      String errorMessage = _getErrorMessage(e);
      
      // Mensagens mais amigáveis para erros específicos
      if (errorMessage.contains('não é membro') || errorMessage.contains('not a member')) {
        errorMessage = 'Você não participa deste desafio';
      } else if (errorMessage.contains('criador não pode sair') || 
                errorMessage.contains('creator cannot leave')) {
        errorMessage = 'Como criador do desafio, você não pode sair';
      }
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
    }
  }
  
  /// Registra um check-in manual em um desafio
  Future<bool> recordCheckIn({required String challengeId, required String userId, String? workoutId}) async {
    try {
      // Mostrar progresso mantendo o estado atual
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );
      
      // Verificações adicionais
      if (challengeId.isEmpty || userId.isEmpty) {
        throw ValidationException(message: 'ID do desafio ou do usuário inválido');
      }
      
      // Verificar se já existe check-in hoje diretamente no banco de dados
      final now = DateTime.now();
      debugPrint('🔍 DATA ATUAL: ${now.toIso8601String()}');
      
      final today = DateTime(now.year, now.month, now.day);
      debugPrint('🔍 DATA NORMALIZADA: ${today.toIso8601String()}');
      
      final hasCheckedIn = await _repository.hasCheckedInOnDate(userId, challengeId, today);
      
      debugPrint('🔍 Verificando se já existe check-in hoje para o desafio $challengeId');
      if (hasCheckedIn) {
        debugPrint('⚠️ Já existe check-in registrado para hoje. Atualizando UI mesmo assim.');
        
        // Força atualização dos dados mesmo quando o check-in já existe
        await _refreshRankingData(challengeId, state.selectedGroupIdForFilter);
        
        // Atualizar o estado para mostrar um feedback amigável
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Você já registrou um treino hoje! 🎉',
        );
        
        // Atualizar o dashboard para refletir as alterações imediatamente
        try {
          final dashboardViewModel = ref.read(dashboardViewModelProvider.notifier);
          await dashboardViewModel.refreshData();
          debugPrint('✅ Dashboard atualizado após check-in');
        } catch (e) {
          debugPrint('⚠️ Não foi possível atualizar o dashboard: $e');
        }
        
        return true;
      }
      
      debugPrint('🔍 Registrando check-in para desafio específico: $challengeId');
      
      // Verificar se temos um ID de workout para registrar
      final workoutResult = await _repository.recordChallengeCheckIn(
        userId: userId,
        challengeId: challengeId,
        workoutId: workoutId,
        workoutName: 'Check-in manual',
        workoutType: 'Manual',
        date: today,
        durationMinutes: 60, // Padrão para check-ins manuais
      );
      
      // Se o check-in retornou 0 pontos, pode indicar que já foi feito hoje
      if (workoutResult.points == 0 && workoutResult.message.contains('já')) {
        debugPrint('⚠️ Já existe check-in para hoje, forçando atualização da UI');
        
        // Força atualização dos dados
        await _refreshRankingData(challengeId, state.selectedGroupIdForFilter);
        
        // Atualizar o estado para mostrar um feedback amigável
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Você já registrou um treino hoje! 🎉',
        );
        
        // Atualizar o dashboard para refletir as alterações imediatamente
        try {
          final dashboardViewModel = ref.read(dashboardViewModelProvider.notifier);
          await dashboardViewModel.refreshData();
          debugPrint('✅ Dashboard atualizado após check-in');
        } catch (e) {
          debugPrint('⚠️ Não foi possível atualizar o dashboard: $e');
        }
        
        return true;
      } else if (workoutResult.points == 0) {
        // Se retornou 0 pontos mas não é por já ter feito check-in
        throw Exception(workoutResult.message);
      }
      
      // Aguardar um momento para garantir que o banco de dados atualizou
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Força atualização completa do ranking
      await _refreshRankingData(challengeId, state.selectedGroupIdForFilter);
      
      // Atualizar o estado
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Check-in registrado com sucesso! +${workoutResult.points} pontos',
      );
      
      // Mostrar estatísticas na tela
      debugPrint('✅ Check-in bem sucedido! Pontos: ${workoutResult.points}, Streak: ${workoutResult.streak}');
      
      // Carregar detalhes atualizados do desafio
      await loadChallengeDetails(challengeId);
      
      // Atualizar o dashboard para refletir as alterações imediatamente
      try {
        final dashboardViewModel = ref.read(dashboardViewModelProvider.notifier);
        await dashboardViewModel.refreshData();
        debugPrint('✅ Dashboard atualizado após check-in');
      } catch (e) {
        debugPrint('⚠️ Não foi possível atualizar o dashboard: $e');
      }
      
      return true;
    } catch (e, stackTrace) {
      // Log error
      debugPrint('❌ Erro ao registrar check-in: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao registrar check-in: ${e.toString()}',
      );
      
      return false;
    }
  }
  
  /// Carrega os convites pendentes para um usuário
  Future<void> loadPendingInvites([String? userId]) async {
    try {
      state = ChallengeState.loading();
      
      // Se userId não for fornecido, obter do usuário atual
      String userIdToUse;
      if (userId != null) {
        userIdToUse = userId;
      } else {
        final currentUser = await _authRepository.getCurrentUser();
        if (currentUser == null) {
          throw AppAuthException(message: 'Usuário não autenticado');
        }
        userIdToUse = currentUser.id;
      }
      
      final invites = await _repository.getPendingInvites(userIdToUse);
      
      // Mantém a lista atual de desafios
      final currentChallenges = ChallengeStateHelper.getChallenges(state);
      
      state = ChallengeState.success(
        challenges: currentChallenges,
        filteredChallenges: currentChallenges,
        pendingInvites: invites,
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }
  
  /// Updates the user's progress data for a specific challenge
  /// Returns true if the operation succeeded, false otherwise
  Future<bool> updateUserProgress(String challengeId, UserProgressUpdateData updateData) async {
    try {
      // Primeiro, obtenha o usuário atual
      final currentUser = await _authRepository.getCurrentUser();
      // Verifique se há um usuário logado
      if (currentUser == null) {
        state = state.copyWith(
          errorMessage: 'Usuário não autenticado',
        );
        return false;
      }

      // Valide os IDs
      _validateIds('updateUserProgress', challengeId: challengeId, userId: currentUser.id);
      
      debugPrint('🔍 ChallengeViewModel - updateUserProgress para desafio: $challengeId, dados: ${updateData.toString()}');
    
      // Verifique se o desafio está ativo
      final challenge = _getChallengeById(challengeId);
      if (challenge == null) {
        state = state.copyWith(
          errorMessage: 'Desafio não encontrado. Tente recarregar a página.',
        );
        return false;
      }
      
      if (!challenge.isActive()) {
        state = state.copyWith(
          errorMessage: 'Esse desafio não está mais ativo.',
        );
        return false;
      }
      
      // Atualize o estado para mostrar carregamento
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );
      
      // Use o serviço em tempo real para a atualização
      final updatedProgress = await _realtimeService.updateProgress(
        challengeId: challengeId,
        updateData: updateData.toJson(),
        onOptimisticUpdate: (optimisticProgress) {
          // Atualiza a UI imediatamente com update otimista
          _updateProgressLocally(optimisticProgress);
        },
      );
      
      if (updatedProgress != null) {
        // Servidor confirmou a atualização
        _updateProgressLocally(updatedProgress);
        
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Progresso atualizado com sucesso!',
        );
        return true;
      } else {
        // A atualização foi rejeitada (tratada pelo serviço)
        state = state.copyWith(
          isLoading: false,
        );
        return false;
      }
    } on AppException catch (e) {
      debugPrint('❌ ChallengeViewModel - Erro ao atualizar progresso: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      debugPrint('❌ ChallengeViewModel - Erro desconhecido: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Não foi possível atualizar seu progresso. Tente novamente mais tarde.',
      );
      return false;
    }
  }
  
  // Helper to update the progress list locally for immediate UI feedback
  void _updateProgressLocally(ChallengeProgress updatedProgress) {
    final currentList = List<ChallengeProgress>.from(state.progressList);
    final index = currentList.indexWhere((p) => 
        p.userId == updatedProgress.userId && 
        p.challengeId == updatedProgress.challengeId);
    
    if (index >= 0) {
      // Replace existing progress
      currentList[index] = updatedProgress;
    } else {
      // Add new progress
      currentList.add(updatedProgress);
    }
    
    state = state.copyWith(progressList: currentList);
  }

  /// Carrega o progresso do usuário em um desafio específico
  Future<void> loadUserChallengeProgress({
    required String userId,
    required String challengeId,
  }) async {
    try {
      // Validações básicas
      if (challengeId.trim().isEmpty) {
        throw ValidationException(message: 'ID do desafio não pode estar vazio');
      }
      
      if (userId.trim().isEmpty) {
        throw ValidationException(message: 'ID do usuário não pode estar vazio');
      }
      
      // Define estado de carregamento
      state = ChallengeState.loading(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
      );
      
      // Busca o progresso do usuário
      final userProgress = await _repository.getUserProgress(
        challengeId: challengeId,
        userId: userId,
      );
      
      // Se não houver progresso, atualiza estado sem progresso
      if (userProgress == null) {
        state = ChallengeState(
          challenges: ChallengeStateHelper.getChallenges(state),
          filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
          selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
          pendingInvites: ChallengeStateHelper.getPendingInvites(state),
          userProgress: null,
        );
        return;
      }
      
      // Verifica dias consecutivos para exibir streak atual
      final consecutiveDays = await _repository.getConsecutiveDaysCount(userId, challengeId);
      
      // Registra a informação de dias consecutivos no objeto de progresso
      final updatedProgress = userProgress.copyWith(
        consecutiveDays: consecutiveDays,
      );
      
      // Atualiza o estado com o progresso do usuário
      state = ChallengeState(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        userProgress: updatedProgress,
      );
    } catch (e) {
      state = ChallengeState.error(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        message: _getErrorMessage(e),
      );
    }
  }
  
  /// Carrega um desafio com seu ranking completo 
  Future<Challenge> _loadChallengeWithRanking(Challenge challenge) async {
    try {
      // Carrega o ranking para o desafio
      final progressList = await _repository.getChallengeProgress(challenge.id);
      
      // Como não podemos modificar o objeto challenge diretamente com o ranking,
      // retornamos o desafio original - o ranking é armazenado separadamente no estado
      if (progressList.isNotEmpty) {
        debugPrint('✅ Ranking carregado para desafio ${challenge.title}: ${progressList.length} participantes');
      }
      
      return challenge;
    } catch (e) {
      debugPrint('❌ Erro ao carregar ranking para desafio ${challenge.title}: $e');
      // Retorna o desafio original em caso de erro
      return challenge;
    }
  }

  /// Carrega as estatísticas do desafio para o usuário
  Future<void> loadChallengeStats({
    required String userId,
    required String challengeId,
  }) async {
    try {
      // Validações básicas
      if (challengeId.trim().isEmpty) {
        throw ValidationException(message: 'ID do desafio não pode estar vazio');
      }
      
      if (userId.trim().isEmpty) {
        throw ValidationException(message: 'ID do usuário não pode estar vazio');
      }
      
      // Define estado de carregamento
      state = ChallengeState.loading(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        progressList: ChallengeStateHelper.getProgressList(state),
        userProgress: ChallengeStateHelper.getUserProgress(state),
      );
      
      // Busca o progresso do usuário
      final userProgress = await _repository.getUserProgress(
        challengeId: challengeId,
        userId: userId,
      );
      
      // Verifica dias consecutivos atuais
      final consecutiveDays = await _repository.getConsecutiveDaysCount(userId, challengeId);
      
      // Verifica a última data de check-in e check-in de hoje
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);
      final hasCheckedInToday = await _repository.hasCheckedInOnDate(userId, challengeId, normalizedToday);
      
      // Obtém o desafio atual para calcular informações
      final challenge = ChallengeStateHelper.getSelectedChallenge(state);
      
      // Prepara o estado atualizado
      final updatedState = ChallengeState(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: challenge,
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        progressList: ChallengeStateHelper.getProgressList(state),
        userProgress: userProgress?.copyWith(
          consecutiveDays: consecutiveDays,
        ),
        successMessage: _formatChallengeStatsMessage(consecutiveDays, hasCheckedInToday),
      );
      
      state = updatedState;
    } catch (e) {
      state = ChallengeState.error(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        progressList: ChallengeStateHelper.getProgressList(state),
        userProgress: ChallengeStateHelper.getUserProgress(state),
        message: _getErrorMessage(e),
      );
    }
  }
  
  /// Formata a mensagem de estatísticas do desafio baseado nos dias consecutivos
  String _formatChallengeStatsMessage(int consecutiveDays, bool hasCheckedInToday) {
    String message = '';
    
    if (consecutiveDays > 0) {
      message = 'Você está com $consecutiveDays ${consecutiveDays == 1 ? 'dia' : 'dias'} consecutivos!';
      
      // Adiciona informação sobre streak/bônus futuros
      if (consecutiveDays % 5 == 4 && !hasCheckedInToday) {
        message += ' Faça check-in hoje para ganhar bônus de sequência!';
      }
    }
    
    if (hasCheckedInToday) {
      if (message.isNotEmpty) {
        message += ' Você já fez check-in hoje!';
      } else {
        message = 'Você já fez check-in hoje!';
      }
    }
    
    return message;
  }

  /// Exclui um desafio
  Future<bool> deleteChallenge(String id) async {
    try {
      await _repository.deleteChallenge(id);
      // Após excluir, atualiza a lista de desafios
      final challenges = await _repository.getChallenges();
      state = state.copyWith(
        challenges: challenges,
        filteredChallenges: challenges,
        successMessage: 'Desafio excluído com sucesso',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Atualiza o estado imediatamente (útil para atualizações otimistas da UI)
  void updateStateImmediately({
    ChallengeProgress? userProgress,
    List<ChallengeProgress>? progressList,
    String? successMessage,
    String? errorMessage,
  }) {
    state = state.copyWith(
      userProgress: userProgress ?? state.userProgress,
      progressList: progressList ?? state.progressList,
      successMessage: successMessage,
      errorMessage: errorMessage,
      isLoading: false,
    );
    
    debugPrint('✅ ChallengeViewModel - Estado atualizado imediatamente');
  }

  /// Sobrescrever o mu00e9todo dispose para marcar quando foi descartado
  @override
  void dispose() {
    _isDisposed = true;
    _rankingSubscription?.cancel();
    super.dispose();
  }

  /// Helper para verificar se u00e9 seguro modificar o estado
  bool get _isSafeToModifyState => !_isDisposed;

  /// Valida IDs para operações que exigem identificadores
  void _validateIds(String operation, {String? challengeId, String? userId}) {
    if (challengeId != null && challengeId.trim().isEmpty) {
      throw ValidationException(message: 'ID do desafio não pode estar vazio');
    }
    
    if (userId != null && userId.trim().isEmpty) {
      throw ValidationException(message: 'ID do usuário não pode estar vazio');
    }
    
    debugPrint('✅ ChallengeViewModel - IDs validados para operação: $operation');
  }
  
  /// Busca um desafio pelo ID na lista de desafios carregados
  Challenge? _getChallengeById(String challengeId) {
    // Primeiro verifica se é o desafio selecionado (caso mais comum)
    if (state.selectedChallenge?.id == challengeId) {
      return state.selectedChallenge;
    }
    
    // Depois verifica se é o desafio oficial
    if (state.officialChallenge?.id == challengeId) {
      return state.officialChallenge;
    }
    
    // Por último, procura na lista completa de desafios
    return state.challenges.firstWhere(
      (challenge) => challenge.id == challengeId,
      orElse: () => throw ResourceNotFoundException(
        message: 'Desafio não encontrado',
        code: 'challenge_not_found',
      ),
    );
  }

  /// Registra um workout como check-in nos desafios ativos do usuário
  Future<void> registerWorkoutInActiveChallenges({
    required String userId,
    required String workoutId,
    required String workoutName,
    required DateTime workoutDate,
    required int durationMinutes,
  }) async {
    try {
      debugPrint('🔄 ChallengeViewModel - Registrando workout em desafios ativos');
      // Em vez de buscar desafios ativos específicos, vamos pegar o desafio oficial
      // que é o mais comumente usado e verificar se o usuário está participando
      final officialChallenge = await _repository.getOfficialChallenge();
      
      if (officialChallenge == null) {
        debugPrint('ℹ️ Nenhum desafio oficial encontrado para registrar workout');
        return;
      }
      
      // Verificar se o usuário está participando neste desafio
      final isParticipating = await _repository.isUserParticipatingInChallenge(
        challengeId: officialChallenge.id,
        userId: userId,
      );
      
      if (!isParticipating) {
        debugPrint('ℹ️ Usuário não está participando do desafio oficial');
        return;
      }
      
      debugPrint('🔍 Registrando workout no desafio oficial: ${officialChallenge.title}');
      
      try {
        final result = await _repository.recordChallengeCheckIn(
          challengeId: officialChallenge.id,
          userId: userId,
          workoutId: workoutId,
          workoutName: workoutName,
          workoutType: 'workout',
          date: workoutDate,
          durationMinutes: durationMinutes,
        );
        
        // Sempre forçar uma atualização completa da UI, independente do resultado
        debugPrint('🔄 Forçando atualização completa da interface após tentativa de check-in');
        
        // Primeiro forçar uma pausa para garantir consistência dos dados
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Forçar atualização completa, ignorando cache
        await loadChallengeDetails(officialChallenge.id);
        
        // Atualizar o estado para notificar o usuário sobre o resultado
        if (result.points > 0) {
          debugPrint('✅ Workout registrado com sucesso no desafio: ${officialChallenge.title}');
          state = state.copyWith(
            successMessage: 'Treino registrado com sucesso no desafio!',
          );
        } else if (result.points == 0 && result.message.contains('já')) {
          debugPrint('ℹ️ Já existe check-in hoje para o desafio: ${officialChallenge.title}');
          state = state.copyWith(
            successMessage: 'Treino registrado! Você já havia feito check-in no desafio hoje.',
          );
        } else {
          debugPrint('⚠️ Falha ao registrar workout no desafio: ${result.message}');
          state = state.copyWith(
            errorMessage: result.message,
          );
        }
      } catch (e) {
        debugPrint('❌ Erro ao registrar workout no desafio ${officialChallenge.title}: $e');
        // Mesmo em caso de erro, forçar atualização da UI
        await Future.delayed(const Duration(milliseconds: 500));
        await loadChallengeDetails(officialChallenge.id);
        state = state.copyWith(
          errorMessage: 'Erro ao registrar treino no desafio: $e',
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao registrar workout em desafios: $e');
      // Não propagar o erro para não interromper o fluxo principal
    }
  }
}

/// Helper para inicialização de convites
void loadInvitesCallback(Function callback) {
  // Executa o callback diretamente no próximo frame  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
} 
