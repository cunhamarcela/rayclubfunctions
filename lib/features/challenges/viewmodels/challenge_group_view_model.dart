// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:ray_club_app/core/services/supabase_service.dart';
import 'package:ray_club_app/core/services/auth_service.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../models/challenge_group.dart';
import '../models/challenge_progress.dart';
import '../repositories/challenge_repository.dart';

/// Estado para gerenciamento de grupos de desafio
class ChallengeGroupState {
  final List<ChallengeGroup> groups;
  final ChallengeGroup? selectedGroup;
  final List<ChallengeGroupInvite> pendingInvites;
  final List<ChallengeProgress> groupRanking;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  ChallengeGroupState({
    this.groups = const [],
    this.selectedGroup,
    this.pendingInvites = const [],
    this.groupRanking = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  /// Cria estado inicial
  factory ChallengeGroupState.initial() => ChallengeGroupState();

  /// Cria estado de carregamento
  factory ChallengeGroupState.loading({
    List<ChallengeGroup> groups = const [],
    ChallengeGroup? selectedGroup,
    List<ChallengeGroupInvite> pendingInvites = const [],
    List<ChallengeProgress> groupRanking = const [],
  }) => ChallengeGroupState(
    groups: groups,
    selectedGroup: selectedGroup,
    pendingInvites: pendingInvites,
    groupRanking: groupRanking,
    isLoading: true,
  );

  /// Cria estado de sucesso
  factory ChallengeGroupState.success({
    required List<ChallengeGroup> groups,
    ChallengeGroup? selectedGroup,
    List<ChallengeGroupInvite> pendingInvites = const [],
    List<ChallengeProgress> groupRanking = const [],
    String? message,
  }) => ChallengeGroupState(
    groups: groups,
    selectedGroup: selectedGroup,
    pendingInvites: pendingInvites,
    groupRanking: groupRanking,
    successMessage: message,
  );

  /// Cria estado de erro
  factory ChallengeGroupState.error({
    List<ChallengeGroup> groups = const [],
    ChallengeGroup? selectedGroup,
    List<ChallengeGroupInvite> pendingInvites = const [],
    List<ChallengeProgress> groupRanking = const [],
    required String message,
  }) => ChallengeGroupState(
    groups: groups,
    selectedGroup: selectedGroup,
    pendingInvites: pendingInvites,
    groupRanking: groupRanking,
    errorMessage: message,
  );

  /// Cria uma cópia do estado com campos opcionalmente modificados
  ChallengeGroupState copyWith({
    List<ChallengeGroup>? groups,
    ChallengeGroup? selectedGroup,
    List<ChallengeGroupInvite>? pendingInvites,
    List<ChallengeProgress>? groupRanking,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ChallengeGroupState(
      groups: groups ?? this.groups,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      pendingInvites: pendingInvites ?? this.pendingInvites,
      groupRanking: groupRanking ?? this.groupRanking,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

/// Provider para o ViewModel de grupos de desafio
final challengeGroupViewModelProvider = StateNotifierProvider<ChallengeGroupViewModel, ChallengeGroupState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return ChallengeGroupViewModel(supabaseService, authService);
});

/// ViewModel para gerenciar grupos de desafio
class ChallengeGroupViewModel extends StateNotifier<ChallengeGroupState> {
  final SupabaseService _supabaseService;
  final AuthService _authService;

  ChallengeGroupViewModel(this._supabaseService, this._authService)
      : super(ChallengeGroupState.initial());

  /// Obtém mensagem de erro formatada
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Ocorreu um erro: $error';
  }

  /// Carrega grupos dos quais o usuário é membro
  Future<void> loadUserGroups() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final userId = _authService.currentUser?.id;
      
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        );
        return;
      }

      // Buscar grupos criados pelo usuário
      final createdGroups = await _supabaseService.supabase
          .from('challenge_groups')
          .select()
          .eq('creator_id', userId);

      // Buscar grupos dos quais o usuário é membro
      final memberGroups = await _supabaseService.supabase
          .from('challenge_group_members')
          .select('group_id, groups:challenge_groups(*)')
          .eq('user_id', userId);

      // Processar resultados
      final List<ChallengeGroup> groups = [];
      
      if (createdGroups != null) {
        for (final group in createdGroups) {
          // Buscar membros do grupo
          final membersData = await _supabaseService.supabase
              .from('challenge_group_members')
              .select('user_id, id, joined_at')
              .eq('group_id', group['id']);

          final List<ChallengeGroupMember> groupMembers = membersData != null
              ? membersData.map<ChallengeGroupMember>((m) => ChallengeGroupMember(
                  id: m['id'] ?? 'unknown',
                  groupId: group['id'],
                  userId: m['user_id'],
                  joinedAt: m['joined_at'] != null ? DateTime.parse(m['joined_at']) : DateTime.now(),
                )).toList()
              : [];

          groups.add(ChallengeGroup(
            id: group['id'],
            name: group['name'],
            description: group['description'] ?? '',
            creatorId: group['creator_id'],
            createdAt: DateTime.parse(group['created_at']),
            members: groupMembers,
          ));
        }
      }

      if (memberGroups != null) {
        for (final item in memberGroups) {
          final group = item['groups'];
          if (group != null && !groups.any((g) => g.id == group['id'])) {
            // Buscar membros do grupo
            final membersData = await _supabaseService.supabase
                .from('challenge_group_members')
                .select('user_id, id, joined_at')
                .eq('group_id', group['id']);

            final List<ChallengeGroupMember> groupMembers = membersData != null
                ? membersData.map<ChallengeGroupMember>((m) => ChallengeGroupMember(
                    id: m['id'] ?? 'unknown',
                    groupId: group['id'],
                    userId: m['user_id'],
                    joinedAt: m['joined_at'] != null ? DateTime.parse(m['joined_at']) : DateTime.now(),
                  )).toList()
                : [];

            groups.add(ChallengeGroup(
              id: group['id'],
              name: group['name'],
              description: group['description'] ?? '',
              creatorId: group['creator_id'],
              createdAt: DateTime.parse(group['created_at']),
              members: groupMembers,
            ));
          }
        }
      }

      state = state.copyWith(
        groups: groups,
        isLoading: false,
      );
      
      debugPrint('Grupos carregados: ${groups.length}');
    } catch (e) {
      debugPrint('Erro ao carregar grupos: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar grupos: $e',
      );
    }
  }

  /// Carrega convites pendentes para o usuário
  Future<void> loadPendingInvites(String userId) async {
    try {
      state = ChallengeGroupState.loading(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
      );

      final pendingInvitesData = await _supabaseService.supabase
          .from('challenge_group_invites')
          .select()
          .eq('invitee_id', userId);

      // Converter dados JSON em objetos ChallengeGroupInvite
      final List<ChallengeGroupInvite> pendingInvites = pendingInvitesData
          .map<ChallengeGroupInvite>((data) {
            // Mapear campos do banco de dados para campos da classe
            final mappedData = {
              'id': data['id'],
              'groupId': data['group_id'],
              'groupName': data['group_name'],
              'inviterId': data['inviter_id'],
              'inviterName': data['inviter_name'],
              'inviteeId': data['invitee_id'],
              'status': data['status'] == 0 ? 'pending' : (data['status'] == 1 ? 'accepted' : 'rejected'),
              'createdAt': data['created_at'],
              'respondedAt': data['responded_at'],
            };
            return ChallengeGroupInvite.fromJson(mappedData);
          })
          .toList();

      state = ChallengeGroupState.success(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: pendingInvites,
        groupRanking: state.groupRanking,
      );
    } catch (e) {
      state = ChallengeGroupState.error(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: _getErrorMessage(e),
      );
    }
  }

  /// Carrega detalhes de um grupo específico e seu ranking
  Future<void> loadGroupDetails(String groupId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Buscar dados do grupo
      final groupData = await _supabaseService.supabase
          .from('challenge_groups')
          .select()
          .eq('id', groupId)
          .single();

      if (groupData == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Grupo não encontrado',
        );
        return;
      }

      // Buscar membros do grupo
      final membersData = await _supabaseService.supabase
          .from('challenge_group_members')
          .select('user_id, id, joined_at')
          .eq('group_id', groupId);

      final List<ChallengeGroupMember> groupMembers = membersData != null
          ? membersData.map<ChallengeGroupMember>((m) => ChallengeGroupMember(
              id: m['id'] ?? 'unknown',
              groupId: groupId,
              userId: m['user_id'],
              joinedAt: m['joined_at'] != null ? DateTime.parse(m['joined_at']) : DateTime.now(),
            )).toList()
          : [];

      final selectedGroup = ChallengeGroup(
        id: groupData['id'],
        name: groupData['name'],
        description: groupData['description'] ?? '',
        creatorId: groupData['creator_id'],
        createdAt: DateTime.parse(groupData['created_at']),
        members: groupMembers,
      );

      state = state.copyWith(
        selectedGroup: selectedGroup,
        isLoading: false,
      );
      
      debugPrint('Detalhes do grupo carregados: ${selectedGroup.name}');
    } catch (e) {
      debugPrint('Erro ao carregar detalhes do grupo: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar detalhes do grupo: $e',
      );
    }
  }

  /// Cria um novo grupo para o desafio principal
  Future<bool> createGroup({
    required String name,
    required String description,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final userId = _authService.currentUser?.id;
      
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        );
        return false;
      }

      final groupId = const Uuid().v4();
      
      // Inserir o grupo
      await _supabaseService.supabase.from('challenge_groups').insert({
        'id': groupId,
        'name': name,
        'description': description,
        'creator_id': userId,
      });

      // Adicionar o criador como membro
      await _supabaseService.supabase.from('challenge_group_members').insert({
        'group_id': groupId,
        'user_id': userId,
      });

      // Recarregar grupos
      await loadUserGroups();
      
      return true;
    } catch (e) {
      debugPrint('Erro ao criar grupo: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao criar grupo: $e',
      );
      return false;
    }
  }

  /// Atualiza um grupo existente
  Future<void> updateGroup(ChallengeGroup group) async {
    try {
      state = ChallengeGroupState.loading(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
      );

      await _supabaseService.supabase
          .from('challenge_groups')
          .update({
            'name': group.name,
            'description': group.description,
          })
          .eq('id', group.id);

      // Atualizar o grupo na lista
      final updatedGroups = state.groups.map((g) {
        return g.id == group.id ? group : g;
      }).toList();

      state = ChallengeGroupState.success(
        groups: updatedGroups,
        selectedGroup: group,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: 'Grupo atualizado com sucesso!',
      );
    } catch (e) {
      state = ChallengeGroupState.error(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: _getErrorMessage(e),
      );
    }
  }

  /// Exclui um grupo
  Future<void> deleteGroup(String groupId) async {
    try {
      state = ChallengeGroupState.loading(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
      );

      await _supabaseService.supabase
          .from('challenge_groups')
          .delete()
          .eq('id', groupId);

      // Remover o grupo da lista
      final updatedGroups = state.groups.where((g) => g.id != groupId).toList();

      state = ChallengeGroupState.success(
        groups: updatedGroups,
        selectedGroup: state.selectedGroup?.id == groupId ? null : state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: 'Grupo excluído com sucesso!',
      );
    } catch (e) {
      state = ChallengeGroupState.error(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: _getErrorMessage(e),
      );
    }
  }

  /// Convida um usuário para o grupo
  Future<bool> inviteUserToGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Obter informações do grupo para incluir no convite
      final groupData = await _supabaseService.supabase
          .from('challenge_groups')
          .select()
          .eq('id', groupId)
          .single();
      
      if (groupData == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Grupo não encontrado',
        );
        return false;
      }

      final groupName = groupData['name'] ?? 'Grupo sem nome';
      
      // Obter informações do convidador (usuário atual)
      final inviterId = _authService.currentUser?.id;
      
      // Se não tiver ID do convidador, não pode continuar
      if (inviterId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        );
        return false;
      }
      
      final inviterData = await _supabaseService.supabase
          .from('profiles')
          .select('display_name, name')
          .eq('id', inviterId)
          .single();
      
      if (inviterData == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não encontrado',
        );
        return false;
      }

      // Usar o nome de exibição ou nome completo como nome do convidador
      final inviterName = inviterData['display_name'] ?? 
                         inviterData['name'] ?? 
                         'Usuário';
      
      // Verificar se o usuário já é membro do grupo
      final existingMember = await _supabaseService.supabase
          .from('challenge_group_members')
          .select()
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .maybeSingle();
      
      if (existingMember != null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário já é membro deste grupo',
        );
        return false;
      }
      
      // Verificar se já existe um convite pendente
      final existingInvite = await _supabaseService.supabase
          .from('challenge_group_invites')
          .select()
          .eq('group_id', groupId)
          .eq('invitee_id', userId)
          .eq('status', 0) // status 0 = pendente
          .maybeSingle();
      
      if (existingInvite != null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Já existe um convite pendente para este usuário',
        );
        return false;
      }

      // Inserir o convite
      await _supabaseService.supabase
          .from('challenge_group_invites')
          .insert({
            'group_id': groupId,
            'group_name': groupName,
            'inviter_id': inviterId, // Agora temos certeza que não é nulo
            'inviter_name': inviterName,
            'invitee_id': userId,
            'status': 0, // 0 = pendente
          });

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Convite enviado com sucesso!',
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Responde a um convite de grupo
  Future<void> respondToInvite(String inviteId, bool accept) async {
    try {
      state = ChallengeGroupState.loading(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
      );

      await _supabaseService.supabase
          .from('challenge_group_invites')
          .delete()
          .eq('id', inviteId);

      // Se aceitou, atualizar a lista de grupos
      List<ChallengeGroup> updatedGroups = state.groups;
      if (accept) {
        // Buscar o ID do usuário atual
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          await loadUserGroups();
        }
      }

      state = ChallengeGroupState.success(
        groups: updatedGroups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: accept ? 'Convite aceito com sucesso!' : 'Convite recusado.',
      );
    } catch (e) {
      state = ChallengeGroupState.error(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: _getErrorMessage(e),
      );
    }
  }

  /// Remove um usuário do grupo
  Future<void> removeUserFromGroup(String groupId, String userId) async {
    try {
      state = ChallengeGroupState.loading(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
      );

      await _supabaseService.supabase
          .from('challenge_group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);

      // Atualizar o grupo selecionado, se for o mesmo
      ChallengeGroup? updatedSelectedGroup = state.selectedGroup;
      if (state.selectedGroup?.id == groupId) {
        final groupData = await _supabaseService.supabase
            .from('challenge_groups')
            .select('*, members:challenge_group_members(user_id)')
            .eq('id', groupId)
            .single();
            
        if (groupData != null) {
          updatedSelectedGroup = ChallengeGroup.fromJson(groupData);
        }
      }

      // Recarregar o ranking se necessário
      List<ChallengeProgress> updatedRanking = state.groupRanking;
      if (state.selectedGroup?.id == groupId) {
        final memberData = await _supabaseService.supabase
            .from('challenge_group_members')
            .select()
            .eq('group_id', groupId);
            
        if (memberData != null) {
          updatedRanking = memberData.map<ChallengeProgress>((data) => ChallengeProgress(
            id: data['id'] ?? const Uuid().v4(),
            userId: data['user_id'],
            challengeId: data['challenge_id'] ?? groupId,
            userName: data['user_name'] ?? 'Participante',
            points: data['points'] ?? 0,
            position: data['position'] ?? 0,
            createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
          )).toList();
        }
      }

      state = ChallengeGroupState.success(
        groups: state.groups,
        selectedGroup: updatedSelectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: updatedRanking,
        message: 'Usuário removido com sucesso!',
      );
    } catch (e) {
      state = ChallengeGroupState.error(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: _getErrorMessage(e),
      );
    }
  }

  /// Atualiza o ranking do grupo
  Future<void> refreshGroupRanking(String groupId) async {
    try {
      state = ChallengeGroupState.loading(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
      );

      final memberData = await _supabaseService.supabase
          .from('challenge_group_members')
          .select()
          .eq('group_id', groupId);
          
      List<ChallengeProgress> updatedRanking = [];
      if (memberData != null) {
        updatedRanking = memberData.map<ChallengeProgress>((data) => ChallengeProgress(
          id: data['id'] ?? const Uuid().v4(),
          userId: data['user_id'],
          challengeId: data['challenge_id'] ?? groupId,
          userName: data['user_name'] ?? 'Participante',
          points: data['points'] ?? 0,
          position: data['position'] ?? 0,
          createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
        )).toList();
      }

      state = ChallengeGroupState.success(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: updatedRanking,
      );
    } catch (e) {
      state = ChallengeGroupState.error(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: _getErrorMessage(e),
      );
    }
  }

  /// Limpa erros e mensagens de sucesso
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  Future<bool> joinGroup(String groupId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final userId = _authService.currentUser?.id;
      
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        );
        return false;
      }

      // Verificar se o usuário já é membro
      final existing = await _supabaseService.supabase
          .from('challenge_group_members')
          .select()
          .eq('group_id', groupId)
          .eq('user_id', userId);

      if (existing != null && existing.isNotEmpty) {
        state = state.copyWith(isLoading: false);
        return true; // Já é membro
      }

      // Adicionar como membro
      await _supabaseService.supabase.from('challenge_group_members').insert({
        'group_id': groupId,
        'user_id': userId,
      });

      // Recarregar grupos
      await loadUserGroups();
      
      return true;
    } catch (e) {
      debugPrint('Erro ao entrar no grupo: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao entrar no grupo: $e',
      );
      return false;
    }
  }

  Future<bool> leaveGroup(String groupId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final userId = _authService.currentUser?.id;
      
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        );
        return false;
      }

      // Remover do grupo
      await _supabaseService.supabase
          .from('challenge_group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);

      // Recarregar grupos
      await loadUserGroups();
      
      return true;
    } catch (e) {
      debugPrint('Erro ao sair do grupo: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao sair do grupo: $e',
      );
      return false;
    }
  }
} 