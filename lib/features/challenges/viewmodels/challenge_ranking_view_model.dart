import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../models/challenge_group.dart';
import '../models/challenge_progress.dart';
import '../../../features/home/models/home_model.dart';
import '../repositories/challenge_repository.dart';
import '../services/realtime_service.dart';


// Implementação manual temporária para substituir o freezed
class ChallengeRankingState {
  final String? challengeId;
  final List<ChallengeProgress> progressList;
  final List<ChallengeGroup> userGroups;
  final String? selectedGroupIdForFilter;
  final bool isLoading;
  final String? errorMessage;
  final UserProgress? userProgress;
  final String searchQuery;

  const ChallengeRankingState({
    this.challengeId,
    this.progressList = const [],
    this.userGroups = const [],
    this.selectedGroupIdForFilter,
    this.isLoading = false,
    this.errorMessage,
    this.userProgress,
    this.searchQuery = '',
  });

  // Implementação manual do método copyWith
  ChallengeRankingState copyWith({
    String? challengeId,
    List<ChallengeProgress>? progressList,
    List<ChallengeGroup>? userGroups,
    String? selectedGroupIdForFilter,
    bool? isLoading,
    String? errorMessage,
    UserProgress? userProgress,
    String? searchQuery,
  }) {
    return ChallengeRankingState(
      challengeId: challengeId ?? this.challengeId,
      progressList: progressList ?? this.progressList,
      userGroups: userGroups ?? this.userGroups,
      selectedGroupIdForFilter: selectedGroupIdForFilter ?? this.selectedGroupIdForFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,  // Permitir definir null para errorMessage
      userProgress: userProgress ?? this.userProgress,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
  
  /// Retorna a lista filtrada baseada na pesquisa
  List<ChallengeProgress> get filteredProgressList {
    if (searchQuery.isEmpty) {
      return progressList;
    }
    
    return progressList.where((progress) {
      final userName = progress.userName.toLowerCase();
      final query = searchQuery.toLowerCase();
      return userName.contains(query);
    }).toList();
  }
}

class ChallengeRankingViewModel extends StateNotifier<ChallengeRankingState> {
  final ChallengeRepository _repository;
  final RealtimeService _realtimeService;
  StreamSubscription<List<ChallengeProgress>>? _rankingSubscription;

  ChallengeRankingViewModel(this._repository, this._realtimeService)
      : super(const ChallengeRankingState());

  @override
  void dispose() {
    _rankingSubscription?.cancel();
    super.dispose();
  }

  /// Inicializa o ViewModel com o ID do desafio e carrega os dados iniciais
  Future<void> init(String challengeId) async {
    state = state.copyWith(
      challengeId: challengeId,
      isLoading: true,
      errorMessage: null,
    );

    await loadChallengeRanking();
    await loadUserGroups();
  }

  /// Carrega o ranking do desafio
  Future<void> loadChallengeRanking() async {
    try {
      if (state.challengeId == null) {
        throw const AppException(message: 'ID do desafio não definido');
      }

      // Cancelar qualquer assinatura existente
      _rankingSubscription?.cancel();

      // Iniciar nova assinatura
      _rankingSubscription = _realtimeService
          .watchChallengeParticipants(state.challengeId!)
          .listen(_handleRankingUpdate);

      // Carregar dados iniciais
      final progressList = await _repository.getChallengeProgress(state.challengeId!);

      state = state.copyWith(
        progressList: progressList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: _getErrorMessage(e),
        isLoading: false,
      );
    }
  }

  /// Carrega os grupos do usuário para o desafio atual
  Future<void> loadUserGroups() async {
    try {
      if (state.challengeId == null) {
        return;
      }

      final groups = await _repository.getUserGroups(state.challengeId!);
      state = state.copyWith(userGroups: groups);
    } catch (e) {
      // Apenas log de erro, não afeta o fluxo principal
      debugPrint('Erro ao carregar grupos do usuário: $e');
    }
  }

  /// Filtra o ranking por um grupo específico
  Future<void> filterRankingByGroup(String? groupId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      if (state.challengeId == null) {
        throw const AppException(message: 'ID do desafio não definido');
      }
      
      // Cancelar qualquer assinatura existente
      _rankingSubscription?.cancel();
      
      List<ChallengeProgress> ranking;
      
      // Se groupId for null, mostra o ranking geral
      if (groupId == null) {
        // Configurar nova assinatura para ranking geral
        _rankingSubscription = _realtimeService
            .watchChallengeParticipants(state.challengeId!)
            .listen(_handleRankingUpdate);
            
        // Carregar dados iniciais
        ranking = await _repository.getChallengeProgress(state.challengeId!);
      } else {
        // Configurar nova assinatura para ranking do grupo
        _rankingSubscription = _realtimeService
            .watchGroupRanking(groupId)
            .listen(_handleRankingUpdate);
            
        // Carregar dados iniciais do grupo
        ranking = await _repository.getGroupRanking(groupId);
      }
      
      state = state.copyWith(
        progressList: ranking,
        selectedGroupIdForFilter: groupId,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: _getErrorMessage(e),
        isLoading: false,
      );
    }
  }

  /// Manipula atualizações em tempo real do ranking
  void _handleRankingUpdate(List<ChallengeProgress> updatedProgress) {
    state = state.copyWith(progressList: updatedProgress);
  }

  /// Atualiza a consulta de pesquisa
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Limpa a pesquisa
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  /// Obtém mensagem de erro formatada
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Ocorreu um erro: $error';
  }
} 