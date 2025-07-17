// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../core/router/app_navigator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/challenge.dart';
import '../viewmodels/challenge_view_model.dart';
import '../../../features/admin/screens/error_admin_screen.dart';

/// Tela de administração de desafios
@RoutePage()
class ChallengesAdminScreen extends ConsumerStatefulWidget {
  const ChallengesAdminScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChallengesAdminScreen> createState() => _ChallengesAdminScreenState();
}

class _ChallengesAdminScreenState extends ConsumerState<ChallengesAdminScreen> {
  bool _isAdmin = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadData();
  }
  
  /// Verifica se o usuário é admin
  Future<void> _checkAdminStatus() async {
    final isAdmin = await ref.read(challengeViewModelProvider.notifier).isAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
      });
    }
  }
  
  /// Carrega os dados iniciais
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await ref.read(challengeViewModelProvider.notifier).loadChallenges();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar desafios: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeViewModelProvider);
    final challenges = ChallengeStateHelper.getChallenges(state);
    
    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Administração'),
        ),
        body: const Center(
          child: Text('Você não tem permissão para acessar esta área.'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração de Desafios'),
        actions: [
          // Botão para alternar status de admin (para teste)
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Alternar status de admin',
            onPressed: () async {
              await ref.read(challengeViewModelProvider.notifier).toggleAdminStatus();
              await _checkAdminStatus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Status de admin: ${_isAdmin ? 'Ativado' : 'Desativado'}'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.error_outline),
            tooltip: 'Diagnóstico de Erros',
            onPressed: () => AppNavigator.navigateToAdminErrors(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Novo Desafio',
            onPressed: () => AppNavigator.navigateToChallengeForm(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildChallengesList(challenges),
    );
  }
  
  /// Constrói a lista de desafios
  Widget _buildChallengesList(List<Challenge> challenges) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_score, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Nenhum desafio encontrado',
              style: AppTypography.headingSmall.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => AppNavigator.navigateToChallengeForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Criar Novo Desafio'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (challenge.imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          challenge.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            challenge.description,
                            style: AppTypography.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _getStatusChip(challenge),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Início: ${DateFormat('dd/MM/yyyy').format(challenge.startDate)}',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Fim: ${DateFormat('dd/MM/yyyy').format(challenge.endDate)}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Participantes: ${challenge.participants.length}',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.emoji_events, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Pontos: ${challenge.points}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => AppNavigator.navigateToChallengeDetail(context, challenge.id),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Ver'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => AppNavigator.navigateToChallengeForm(context, id: challenge.id),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showDeleteConfirmationDialog(challenge),
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      label: Text('Excluir', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Retorna um chip com o status do desafio
  Widget _getStatusChip(Challenge challenge) {
    final now = DateTime.now();
    Color color;
    String label;
    
    if (now.isAfter(challenge.endDate)) {
      color = AppColors.error;
      label = 'Encerrado';
    } else if (now.isBefore(challenge.startDate)) {
      color = Colors.orange;
      label = 'Futuro';
    } else {
      color = AppColors.success;
      label = 'Ativo';
    }
    
    return Chip(
      backgroundColor: color.withOpacity(0.1),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
    );
  }
  
  /// Exibe diálogo de confirmação para exclusão
  void _showDeleteConfirmationDialog(Challenge challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o desafio "${challenge.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              setState(() {
                _isLoading = true;
              });
              
              try {
                final success = await ref.read(challengeViewModelProvider.notifier).deleteChallenge(challenge.id);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Desafio excluído com sucesso' : 'Erro ao excluir desafio',
                      ),
                      backgroundColor: success ? AppColors.success : AppColors.error,
                    ),
                  );
                  
                  if (success) {
                    await _loadData();
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao excluir desafio: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: const Text('Excluir', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
} 