// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../features/profile/models/profile_model.dart';
import '../../../features/profile/repositories/profile_repository.dart';
import '../../../features/profile/viewmodels/profile_view_model.dart';
import 'invite_form_state.dart';

/// Provider para o ViewModel do formulário de convites
final inviteFormViewModelProvider = StateNotifierProvider.autoDispose<InviteFormViewModel, InviteFormState>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return InviteFormViewModel(profileRepository: profileRepository);
});

/// Tamanho da página para paginação
const int _pageSize = 15;

/// ViewModel para gerenciar o formulário de convites
class InviteFormViewModel extends StateNotifier<InviteFormState> {
  final ProfileRepository _profileRepository;

  /// Construtor
  InviteFormViewModel({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(const InviteFormState());

  /// Carrega todos os perfis disponíveis
  Future<void> loadProfiles() async {
    try {
      final profiles = await _profileRepository.getAllProfiles();
      
      state = state.copyWith(
        allProfiles: profiles,
        errorMessage: null,
      );
      
      // Inicializa a primeira página
      updatePaginatedProfiles();
    } catch (e) {
      state = state.copyWith(
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Atualiza o termo de busca
  void updateSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query.toLowerCase(),
      currentPage: 0,
      paginatedProfiles: [],
      hasMoreData: true,
    );
    
    updatePaginatedProfiles();
  }

  /// Limpa o termo de busca
  void clearSearchQuery() {
    state = state.copyWith(
      searchQuery: '',
      currentPage: 0,
      paginatedProfiles: [],
      hasMoreData: true,
    );
    
    updatePaginatedProfiles();
  }

  /// Atualiza a lista de perfis paginados com base no filtro atual
  void updatePaginatedProfiles() {
    if (state.isLoadingMore) return;
    
    final filteredProfiles = state.allProfiles
        .where((profile) =>
            profile.name?.toLowerCase().contains(state.searchQuery) == true || 
            profile.email?.toLowerCase().contains(state.searchQuery) == true)
        .toList();
    
    final int startIndex = state.currentPage * _pageSize;
    
    if (startIndex >= filteredProfiles.length) {
      state = state.copyWith(
        hasMoreData: false,
        isLoadingMore: false,
      );
      return;
    }
    
    // Calcular o índice final (não exceder o tamanho da lista)
    final int endIndex = (startIndex + _pageSize < filteredProfiles.length) 
        ? startIndex + _pageSize 
        : filteredProfiles.length;
    
    if (state.currentPage == 0) {
      // Se é a primeira página, substitui a lista
      state = state.copyWith(
        paginatedProfiles: filteredProfiles.sublist(startIndex, endIndex),
        hasMoreData: endIndex < filteredProfiles.length,
        isLoadingMore: false,
      );
    } else {
      // Senão, adiciona à lista existente
      state = state.copyWith(
        paginatedProfiles: [...state.paginatedProfiles, ...filteredProfiles.sublist(startIndex, endIndex)],
        hasMoreData: endIndex < filteredProfiles.length,
        isLoadingMore: false,
      );
    }
  }

  /// Carrega a próxima página de perfis
  void loadMoreProfiles() {
    if (!state.hasMoreData || state.isLoadingMore) return;
    
    state = state.copyWith(
      currentPage: state.currentPage + 1,
      isLoadingMore: true,
    );
    
    updatePaginatedProfiles();
  }

  /// Adiciona um usuário à lista de selecionados
  void toggleUserSelection(Profile profile) {
    final isAlreadySelected = state.selectedUsers.any((u) => u.id == profile.id);
    
    if (isAlreadySelected) {
      // Remove o usuário da lista de selecionados
      state = state.copyWith(
        selectedUsers: state.selectedUsers.where((u) => u.id != profile.id).toList(),
      );
    } else {
      // Adiciona o usuário à lista de selecionados
      state = state.copyWith(
        selectedUsers: [...state.selectedUsers, profile],
      );
    }
  }

  /// Verifica se um usuário está selecionado
  bool isUserSelected(String userId) {
    return state.selectedUsers.any((user) => user.id == userId);
  }

  /// Limpa a lista de usuários selecionados
  void clearSelectedUsers() {
    state = state.copyWith(
      selectedUsers: [],
    );
  }

  /// Obtém a mensagem de erro formatada
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString();
  }
} 
