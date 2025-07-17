import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/extensions/context_extensions.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/widgets/app_loading.dart';
import 'package:ray_club_app/core/widgets/ray_button.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/challenges/viewmodels/challenge_view_model.dart';
import 'package:ray_club_app/features/challenges/viewmodels/challenge_group_view_model.dart';

/// Widget para selecionar usuários do ranking para adicionar ao grupo
class SelectUsersFromRanking extends ConsumerStatefulWidget {
  final String groupId;
  final List<String> currentMemberIds;

  const SelectUsersFromRanking({
    Key? key,
    required this.groupId,
    required this.currentMemberIds,
  }) : super(key: key);

  @override
  ConsumerState<SelectUsersFromRanking> createState() => _SelectUsersFromRankingState();
}

class _SelectUsersFromRankingState extends ConsumerState<SelectUsersFromRanking> {
  final Set<String> _selectedUserIds = {};
  bool _isLoading = false;
  String? _errorMessage;
  Challenge? _selectedChallenge;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOfficialChallenge();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOfficialChallenge() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(challengeViewModelProvider.notifier).loadOfficialChallenge();
      final challengeState = ref.read(challengeViewModelProvider);
      setState(() {
        _selectedChallenge = challengeState.officialChallenge;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar desafio: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  Future<void> _inviteSelectedUsers() async {
    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um usuário')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final groupViewModel = ref.read(challengeGroupViewModelProvider.notifier);
      bool success = true;
      
      // Convidar cada usuário selecionado
      for (final userId in _selectedUserIds) {
        final result = await groupViewModel.inviteUserToGroup(
          groupId: widget.groupId,
          userId: userId,
        );
        
        if (!result) {
          success = false;
        }
      }

      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Recarregar os detalhes do grupo após os convites
        await groupViewModel.loadGroupDetails(widget.groupId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Convites enviados com sucesso!')),
          );
          Navigator.of(context).pop(true); // Retornar sucesso
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alguns convites não puderam ser enviados')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao enviar convites: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final challengeState = ref.watch(challengeViewModelProvider);
    final rankingList = challengeState.progressList;
    
    // Filtrar a lista de ranking baseado na pesquisa
    final filteredList = rankingList.where((progress) {
      if (_searchQuery.isEmpty) return true;
      return progress.userName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
    
    // ✅ USAR DADOS DIRETO DO BANCO (já vem ordenado por position)

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convidar do Ranking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : () {
              _inviteSelectedUsers();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: AppLoading())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      RayButton(
                        label: 'Tentar Novamente',
                        onPressed: () {
                          _loadOfficialChallenge();
                        },
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Pesquisar usuários...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    
                    // User list
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhum usuário encontrado no ranking',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredList.length,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemBuilder: (context, index) {
                                final progress = filteredList[index];
                                final userId = progress.userId;
                                final isCurrentMember = widget.currentMemberIds.contains(userId);
                                final isSelected = _selectedUserIds.contains(userId);
                                
                                // Skip current members from selection
                                if (isCurrentMember) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: progress.userPhotoUrl != null
                                          ? NetworkImage(progress.userPhotoUrl!)
                                          : null,
                                      child: progress.userPhotoUrl == null
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    title: Text(progress.userName),
                                    subtitle: Text('${progress.points} pontos'),
                                    trailing: const Chip(
                                      label: Text('Já é membro'),
                                      backgroundColor: Colors.grey,
                                      labelStyle: TextStyle(color: Colors.white),
                                    ),
                                    enabled: false,
                                  );
                                }
                                
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: progress.userPhotoUrl != null
                                        ? NetworkImage(progress.userPhotoUrl!)
                                        : null,
                                    child: progress.userPhotoUrl == null
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  title: Text(progress.userName),
                                  subtitle: Text('${progress.points} pontos'),
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                                      : const Icon(Icons.radio_button_unchecked),
                                  onTap: () => _toggleUserSelection(userId),
                                );
                              },
                            ),
                    ),
                    
                    // Bottom action bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '${_selectedUserIds.length} usuários selecionados',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            RayButton(
                              label: 'Enviar Convites',
                              isDisabled: _isLoading,
                              onPressed: () {
                                _inviteSelectedUsers();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
} 