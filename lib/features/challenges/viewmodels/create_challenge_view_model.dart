// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../services/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../models/challenge.dart';
import '../repositories/challenge_repository.dart';
import '../providers/challenge_providers.dart';
import 'create_challenge_state.dart';

final createChallengeViewModelProvider = StateNotifierProvider.autoDispose<CreateChallengeViewModel, CreateChallengeState>((ref) {
  final repository = ref.watch(challengeRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  return CreateChallengeViewModel(repository, authService);
});

class CreateChallengeViewModel extends StateNotifier<CreateChallengeState> {
  final ChallengeRepository _repository;
  final AuthService _authService;

  CreateChallengeViewModel(this._repository, this._authService) : super(CreateChallengeState.initial());

  // Atualiza o título do desafio
  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  // Atualiza as regras do desafio
  void updateRules(String rules) {
    state = state.copyWith(rules: rules);
  }

  // Atualiza a recompensa do desafio
  void updateReward(String reward) {
    state = state.copyWith(reward: reward);
  }

  // Atualiza a data de início do desafio
  void updateStartDate(DateTime startDate) {
    DateTime endDate = state.endDate;
    
    // Se a data de início for posterior à data de término, atualiza a data de término
    if (startDate.isAfter(endDate)) {
      endDate = startDate.add(const Duration(days: 7));
    }
    
    state = state.copyWith(startDate: startDate, endDate: endDate);
  }

  // Atualiza a data de término do desafio
  void updateEndDate(DateTime endDate) {
    // Certifica-se de que a data de término não é anterior à data de início
    if (endDate.isBefore(state.startDate)) {
      throw ValidationException(
        message: 'A data de término não pode ser anterior à data de início',
      );
    }
    
    state = state.copyWith(endDate: endDate);
  }
  
  // Atualiza a lista de usuários convidados
  void updateInvitedUsers(List<String> invitedUsers) {
    state = state.copyWith(invitedUsers: invitedUsers);
  }
  
  // Remove um usuário da lista de convidados
  void removeInvitedUser(String userId) {
    final updatedInvitedUsers = List<String>.from(state.invitedUsers)
      ..remove(userId);
    state = state.copyWith(invitedUsers: updatedInvitedUsers);
  }

  /// Salva o desafio
  Future<void> saveChallenge() async {
    if (state.isSaving) return;
    
    state = state.copyWith(isSaving: true, error: null);
    
    try {
      // Obtém o ID do criador
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      // Cria um novo desafio
      final newChallenge = state.toChallenge(currentUser.id);
      
      // Salva o desafio no repositório
      final savedChallenge = await _repository.createChallenge(newChallenge);
      
      // Não enviamos mais convites para desafios individuais, apenas para grupos
      
      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Erro ao salvar desafio: ${e.toString()}',
      );
    }
  }
} 