import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'challenge.dart';
import 'challenge_progress.dart';
import 'challenge_group.dart';

part 'challenge_state.freezed.dart';

/// Estado da feature de desafios, usando Freezed para imutabilidade
@freezed
class ChallengeState with _$ChallengeState {
  const ChallengeState._(); // Construtor privado para métodos de extensão

  /// Construtor principal com todos os campos
  const factory ChallengeState({
    /// Lista de todos os desafios carregados
    @Default([]) List<Challenge> challenges,

    /// Lista de desafios filtrados por critérios da UI
    @Default([]) List<Challenge> filteredChallenges,

    /// Desafio atualmente selecionado para visualização de detalhes
    Challenge? selectedChallenge,

    /// Lista de convites pendentes de grupo para o usuário atual
    @Default([]) List<ChallengeGroupInvite> pendingInvites,

    /// Lista de ranking/progresso para o desafio selecionado
    @Default([]) List<ChallengeProgress> progressList,

    /// Progresso do usuário atual no desafio selecionado
    ChallengeProgress? userProgress,

    /// Indica se os dados estão sendo carregados
    @Default(false) bool isLoading,

    /// Mensagem de erro, se alguma operação falhou
    String? errorMessage,

    /// Mensagem de sucesso após operações bem-sucedidas
    String? successMessage,

    /// O desafio oficial principal (ex.: Desafio da Ray)
    Challenge? officialChallenge,

    /// ID do grupo selecionado para filtrar o ranking
    String? selectedGroupIdForFilter,
  }) = _ChallengeState;

  /// Estado inicial vazio
  factory ChallengeState.initial() => const ChallengeState();

  /// Estado de carregamento, preservando dados existentes
  factory ChallengeState.loading({
    List<Challenge> challenges = const [],
    List<Challenge> filteredChallenges = const [],
    Challenge? selectedChallenge,
    List<ChallengeGroupInvite> pendingInvites = const [],
    List<ChallengeProgress> progressList = const [],
    ChallengeProgress? userProgress,
    Challenge? officialChallenge,
    String? selectedGroupIdForFilter,
  }) => ChallengeState(
    challenges: challenges,
    filteredChallenges: filteredChallenges,
    selectedChallenge: selectedChallenge,
    pendingInvites: pendingInvites,
    progressList: progressList,
    userProgress: userProgress,
    isLoading: true,
    officialChallenge: officialChallenge,
    selectedGroupIdForFilter: selectedGroupIdForFilter,
  );

  /// Estado de sucesso após operação bem-sucedida
  factory ChallengeState.success({
    required List<Challenge> challenges,
    required List<Challenge> filteredChallenges,
    Challenge? selectedChallenge,
    List<ChallengeGroupInvite> pendingInvites = const [],
    List<ChallengeProgress> progressList = const [],
    ChallengeProgress? userProgress,
    Challenge? officialChallenge,
    String? selectedGroupIdForFilter,
    String? message,
  }) => ChallengeState(
    challenges: challenges,
    filteredChallenges: filteredChallenges,
    selectedChallenge: selectedChallenge,
    pendingInvites: pendingInvites,
    progressList: progressList,
    userProgress: userProgress,
    isLoading: false,
    successMessage: message,
    officialChallenge: officialChallenge,
    selectedGroupIdForFilter: selectedGroupIdForFilter,
  );

  /// Estado de erro após falha em operação
  factory ChallengeState.error({
    List<Challenge> challenges = const [],
    List<Challenge> filteredChallenges = const [],
    Challenge? selectedChallenge,
    List<ChallengeGroupInvite> pendingInvites = const [],
    List<ChallengeProgress> progressList = const [],
    ChallengeProgress? userProgress,
    Challenge? officialChallenge,
    String? selectedGroupIdForFilter,
    required String message,
  }) => ChallengeState(
    challenges: challenges,
    filteredChallenges: filteredChallenges,
    selectedChallenge: selectedChallenge,
    pendingInvites: pendingInvites,
    progressList: progressList,
    userProgress: userProgress,
    isLoading: false,
    errorMessage: message,
    officialChallenge: officialChallenge,
    selectedGroupIdForFilter: selectedGroupIdForFilter,
  );
} 