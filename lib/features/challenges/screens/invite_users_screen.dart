// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/providers/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../../../features/profile/models/profile_model.dart';
import '../models/challenge.dart';
import '../viewmodels/challenge_view_model.dart';
import '../viewmodels/challenge_group_view_model.dart';
import '../viewmodels/invite_form_view_model.dart';
import '../viewmodels/invite_form_state.dart';

/// Tela para convidar usuários para um desafio
@RoutePage()
class InviteUsersScreen extends ConsumerStatefulWidget {
  final String challengeId;
  final String challengeTitle;
  final String? currentUserId;
  final String? currentUserName;

  const InviteUsersScreen({
    Key? key,
    this.challengeId = 'temp-id',
    this.challengeTitle = 'Novo Desafio',
    this.currentUserId,
    this.currentUserName,
  }) : super(key: key);

  @override
  ConsumerState<InviteUsersScreen> createState() => _InviteUsersScreenState();
}

class _InviteUsersScreenState extends ConsumerState<InviteUsersScreen> {
  /// Controlador para o campo de busca
  final TextEditingController _searchController = TextEditingController();
  
  /// ScrollController para detectar quando chegou ao final da lista
  final ScrollController _scrollController = ScrollController();

  String? _userId;
  String? _userName;
  
  @override
  void initState() {
    super.initState();
    // Inicializa o ScrollController
    _initScrollController();
    
    // Carrega perfis quando a tela é construída pela primeira vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inviteFormViewModelProvider.notifier).loadProfiles();
      _loadUserData();
    });
  }

  /// Carrega os dados do usuário atual
  Future<void> _loadUserData() async {
    final authRepo = ref.read(authRepositoryProvider);
    try {
      final user = await authRepo.getCurrentUser();
      if (user != null) {
        setState(() {
          _userId = widget.currentUserId ?? user.id;
          _userName = widget.currentUserName ?? user.userMetadata?['name'] ?? 'Usuário';
        });
      } else {
        // Falha ao obter usuário
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha ao carregar dados do usuário'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtém o estado do formulário de convites
    final inviteFormState = ref.watch(inviteFormViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convidar Usuários'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildSelectedUsersList(inviteFormState.selectedUsers),
          Expanded(
            child: _buildUsersList(context, inviteFormState),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, inviteFormState.selectedUsers),
    );
  }

  /// Inicializa o controlador de scroll
  void _initScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        // Quando estamos próximos do final da lista, carrega mais dados
        ref.read(inviteFormViewModelProvider.notifier).loadMoreProfiles();
      }
    });
  }

  /// Constrói o campo de busca
  Widget _buildSearchField() {
    final inviteFormNotifier = ref.read(inviteFormViewModelProvider.notifier);
    final searchQuery = ref.watch(inviteFormViewModelProvider).searchQuery;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar usuários...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchQuery.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    inviteFormNotifier.clearSearchQuery();
                  },
                ) 
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          fillColor: Colors.grey[100],
          filled: true,
        ),
        onChanged: (value) {
          inviteFormNotifier.updateSearchQuery(value);
        },
      ),
    );
  }

  /// Constrói a lista de usuários selecionados
  Widget _buildSelectedUsersList(List<Profile> selectedUsers) {
    if (selectedUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usuários selecionados (${selectedUsers.length})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedUsers.map((user) {
              return Chip(
                avatar: CircleAvatar(
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(user.name?[0] ?? 'U')
                      : null,
                ),
                label: Text(user.name ?? 'Usuário'),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _onUserSelected(user),
              );
            }).toList(),
          ),
          const Divider(),
        ],
      ),
    );
  }

  /// Constrói a lista de usuários
  Widget _buildUsersList(BuildContext context, InviteFormState state) {
    if (state.errorMessage != null) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(inviteFormViewModelProvider.notifier).loadProfiles(),
      );
    }

    if (state.paginatedProfiles.isEmpty && state.allProfiles.isEmpty) {
      return const Center(child: AppLoading());
    }

    if (state.paginatedProfiles.isEmpty) {
      return const AppEmptyState(
        message: 'Nenhum usuário encontrado para este termo',
        icon: Icons.search_off,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.paginatedProfiles.length + (state.hasMoreData ? 1 : 0),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        // Se for o último item e temos mais dados, mostrar o loader
        if (index == state.paginatedProfiles.length && state.hasMoreData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Se for um item normal, mostrar o perfil
        if (index < state.paginatedProfiles.length) {
          final profile = state.paginatedProfiles[index];
          final isSelected = state.selectedUsers.any((u) => u.id == profile.id);
          return _buildUserItem(profile, isSelected);
        }
        
        return null;
      },
    );
  }

  /// Constrói um item de usuário
  Widget _buildUserItem(Profile profile, bool isSelected) {
    // Não mostrar o usuário atual na lista
    if (profile.id == _userId) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _onUserSelected(profile),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: profile.photoUrl != null
                    ? NetworkImage(profile.photoUrl!)
                    : null,
                radius: 24,
                child: profile.photoUrl == null
                    ? Text(profile.name?[0] ?? 'U',
                        style: const TextStyle(fontSize: 18))
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name ?? 'Usuário',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (profile.email != null)
                      Text(
                        profile.email!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              Checkbox(
                value: isSelected,
                activeColor: AppTheme.primaryColor,
                onChanged: (_) => _onUserSelected(profile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói a barra inferior com botões de ação
  Widget _buildBottomBar(BuildContext context, List<Profile> selectedUsers) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: selectedUsers.isEmpty
                  ? null
                  : () => _sendInvites(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Convidar ${selectedUsers.length} ${selectedUsers.length == 1 ? 'Usuário' : 'Usuários'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Envia convites para os usuários selecionados
  void _sendInvites() async {
    final selectedUsers = ref.read(inviteFormViewModelProvider).selectedUsers;
    
    if (selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um usuário para convidar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final challengeGroupViewModel = ref.read(challengeGroupViewModelProvider.notifier);
    
    // Mostrar diálogo de progresso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Enviando convites...'),
          ],
        ),
      ),
    );
    
    try {
      // Enviar convites para cada usuário selecionado
      for (final user in selectedUsers) {
        await challengeGroupViewModel.inviteUserToGroup(
          groupId: widget.challengeId,
          userId: user.id,
        );
      }
      
      // Fechar diálogo de progresso
      Navigator.of(context).pop();
      
      // Mostrar confirmação
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selectedUsers.length} convites enviados com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Limpar seleção
      ref.read(inviteFormViewModelProvider.notifier).clearSelectedUsers();
      
      // Voltar para tela anterior
      Navigator.of(context).pop();
    } catch (e) {
      // Fechar diálogo de progresso
      Navigator.of(context).pop();
      
      // Mostrar erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar convites: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Trata a seleção/desseleção de um usuário
  void _onUserSelected(Profile profile) {
    ref.read(inviteFormViewModelProvider.notifier).toggleUserSelection(profile);
  }
} 
