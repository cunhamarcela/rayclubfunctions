// Project imports:
import '../../../features/profile/models/profile_model.dart';
import '../models/challenge.dart';

/// Estado para o formulário de convite de usuários
class InviteFormState {
  /// Lista completa de perfis disponíveis
  final List<Profile> allProfiles;
  
  /// Lista de perfis filtrados e paginados para exibição
  final List<Profile> paginatedProfiles;
  
  /// Lista de usuários selecionados para convite
  final List<Profile> selectedUsers;
  
  /// Termo de busca atual
  final String searchQuery;
  
  /// Página atual na paginação
  final int currentPage;
  
  /// Indica se há mais dados para carregar
  final bool hasMoreData;
  
  /// Indica se está carregando mais dados
  final bool isLoadingMore;
  
  /// Mensagem de erro, se houver
  final String? errorMessage;

  /// Construtor
  const InviteFormState({
    this.allProfiles = const [],
    this.paginatedProfiles = const [],
    this.selectedUsers = const [],
    this.searchQuery = '',
    this.currentPage = 0,
    this.hasMoreData = true,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  /// Cria uma cópia deste estado com os campos especificados atualizados
  InviteFormState copyWith({
    List<Profile>? allProfiles,
    List<Profile>? paginatedProfiles,
    List<Profile>? selectedUsers,
    String? searchQuery,
    int? currentPage,
    bool? hasMoreData,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return InviteFormState(
      allProfiles: allProfiles ?? this.allProfiles,
      paginatedProfiles: paginatedProfiles ?? this.paginatedProfiles,
      selectedUsers: selectedUsers ?? this.selectedUsers,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
} 
