import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/features/challenges/viewmodels/challenge_group_view_model.dart';

/// Widget modal para criar ou entrar em um grupo de desafio
class CreateJoinGroupModal extends ConsumerStatefulWidget {
  const CreateJoinGroupModal({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateJoinGroupModal> createState() => _CreateJoinGroupModalState();
}

class _CreateJoinGroupModalState extends ConsumerState<CreateJoinGroupModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _joinGroupIdController = TextEditingController();
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _joinGroupIdController.dispose();
    super.dispose();
  }

  Future<void> _joinGroup() async {
    final groupId = _joinGroupIdController.text.trim();
    if (groupId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o ID do grupo')),
      );
      return;
    }

    setState(() {
      _isJoining = true;
    });

    try {
      final success = await ref.read(challengeGroupViewModelProvider.notifier).joinGroup(groupId);
      
      if (mounted) {
        setState(() {
          _isJoining = false;
        });

        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Você entrou no grupo com sucesso!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Grupo não encontrado ou você já é membro')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao entrar no grupo: $e')),
        );
      }
    }
  }

  void _navigateToCreateGroup() {
    Navigator.of(context).pop();
    context.router.push(const CreateChallengeGroupRoute());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Criar Grupo'),
              Tab(text: 'Entrar em Grupo'),
            ],
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Criar Grupo Tab
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.group_add,
                      size: 64,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Crie um novo grupo para acompanhar o ranking com seus amigos',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _navigateToCreateGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Criar Novo Grupo'),
                    ),
                  ],
                ),
                
                // Entrar em Grupo Tab
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        controller: _joinGroupIdController,
                        decoration: const InputDecoration(
                          labelText: 'ID do Grupo',
                          hintText: 'Cole aqui o ID do grupo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isJoining ? null : _joinGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: _isJoining
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Entrar no Grupo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 