import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/extensions/context_extensions.dart';
import 'package:ray_club_app/core/services/auth_service.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/widgets/app_bar_widget.dart';
import 'package:ray_club_app/core/widgets/app_loading.dart';
import 'package:ray_club_app/core/widgets/ray_button.dart';
import 'package:ray_club_app/features/challenges/models/challenge_group.dart';
import 'package:ray_club_app/features/challenges/models/group_member.dart';
import 'package:ray_club_app/features/challenges/viewmodels/challenge_group_view_model.dart';
import 'package:ray_club_app/features/challenges/widgets/select_users_from_ranking.dart';
import 'package:share_plus/share_plus.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class ChallengeGroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;

  const ChallengeGroupDetailScreen({
    Key? key,
    @PathParam('groupId') required this.groupId,
  }) : super(key: key);

  @override
  ConsumerState<ChallengeGroupDetailScreen> createState() => _ChallengeGroupDetailScreenState();
}

class _ChallengeGroupDetailScreenState extends ConsumerState<ChallengeGroupDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroupDetails();
    });
  }

  Future<void> _loadGroupDetails() async {
    await ref.read(challengeGroupViewModelProvider.notifier).loadGroupDetails(widget.groupId);
  }

  Future<void> _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do grupo'),
        content: const Text('Tem certeza que deseja sair deste grupo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(challengeGroupViewModelProvider.notifier).leaveGroup(widget.groupId);
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _shareGroupInvite(ChallengeGroup group) {
    final shareText = "Junte-se ao meu grupo '${group.name}' no Ray Club! ID do grupo: ${group.id}";
    Share.share(shareText);
  }

  void _copyGroupId(String groupId) {
    Clipboard.setData(ClipboardData(text: groupId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID do grupo copiado para a área de transferência')),
    );
  }

  Future<void> _showEditGroupDialog(ChallengeGroup group) async {
    final nameController = TextEditingController(text: group.name);
    final descriptionController = TextEditingController(text: group.description);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Grupo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Grupo',
                  hintText: 'Digite o nome do grupo',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Digite a descrição do grupo',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final updatedGroup = group.copyWith(
                name: nameController.text.trim(),
                description: descriptionController.text.trim(),
              );
              
              ref.read(challengeGroupViewModelProvider.notifier).updateGroup(updatedGroup);
              Navigator.of(context).pop(true);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadGroupDetails();
    }
  }

  Future<void> _showDeleteGroupDialog(String groupId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Grupo'),
        content: const Text('Tem certeza que deseja excluir este grupo? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(challengeGroupViewModelProvider.notifier).deleteGroup(groupId);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeGroupViewModelProvider);
    final currentUserId = ref.watch(authServiceProvider).currentUser?.id;
    
    if (state.isLoading) {
      return Scaffold(
        appBar: AppBarWidget(title: 'Detalhes do Grupo'),
        body: const Center(child: AppLoading()),
      );
    }

    final group = state.selectedGroup;
    if (group == null) {
      return Scaffold(
        appBar: AppBarWidget(title: 'Detalhes do Grupo'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Grupo não encontrado',
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              RayButton(
                label: 'Voltar',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    }

    final isCreator = currentUserId != null && group.isCreator(currentUserId);
    final members = <GroupMember>[]; // Usando uma lista vazia temporariamente

    return Scaffold(
      appBar: AppBarWidget(
        title: group.name,
        actions: [
          if (isCreator)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditGroupDialog(group);
                } else if (value == 'delete') {
                  _showDeleteGroupDialog(group.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Editar Grupo'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Excluir Grupo', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          if (!isCreator)
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: _leaveGroup,
              tooltip: 'Sair do grupo',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGroupDetails,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupHeader(group, isCreator),
                const SizedBox(height: 24),
                _buildMembersList(members, currentUserId, isCreator),
                const SizedBox(height: 24),
                if (!isCreator) ...[
                  RayButton(
                    label: 'Sair do Grupo',
                    onPressed: _leaveGroup,
                    backgroundColor: Colors.red,
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupHeader(ChallengeGroup group, bool isCreator) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isCreator)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Criador',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            if (group.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Descrição',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                group.description,
                style: context.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.people, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${group.memberCount} ${group.memberCount == 1 ? 'membro' : 'membros'}',
                        style: context.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _shareGroupInvite(group),
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _copyGroupId(group.id),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID do Grupo',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            group.id,
                            style: context.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.copy,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList(List<GroupMember> members, String? currentUserId, bool isCreator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Membros',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isCreator)
              ElevatedButton.icon(
                onPressed: _showSelectUsersFromRanking,
                icon: const Icon(Icons.people_alt, size: 16),
                label: const Text('Convidar do Ranking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        members.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Nenhum membro encontrado',
                    style: context.textTheme.bodyMedium,
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: members.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final member = members[index];
                  final isCurrentUser = currentUserId != null && member.userId == currentUserId;
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        member.userDisplayName.isNotEmpty
                            ? member.userDisplayName[0].toUpperCase()
                            : '?',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            member.userDisplayName.isNotEmpty
                                ? member.userDisplayName
                                : 'Usuário #${member.userId.substring(0, 8)}',
                          ),
                        ),
                        if (isCurrentUser)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Você',
                              style: context.textTheme.bodySmall,
                            ),
                          ),
                        if (member.isCreator)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Criador',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: member.joinedAt != null
                        ? Text(
                            'Entrou em ${_formatJoinDate(member.joinedAt!)}',
                            style: context.textTheme.bodySmall,
                          )
                        : null,
                    trailing: isCreator && !member.isCreator
                        ? IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              // Implementar remoção de membro
                            },
                            tooltip: 'Remover membro',
                          )
                        : null,
                  );
                },
              ),
      ],
    );
  }

  String _formatJoinDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Método para abrir a tela de seleção de usuários do ranking
  void _showSelectUsersFromRanking() async {
    final group = ref.watch(challengeGroupViewModelProvider).selectedGroup;
    if (group == null) return;
    
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectUsersFromRanking(
          groupId: group.id,
          currentMemberIds: group.memberIds,
        ),
      ),
    );
    
    // Se retornou com sucesso, recarregar os detalhes do grupo
    if (result == true) {
      _loadGroupDetails();
    }
  }
} 