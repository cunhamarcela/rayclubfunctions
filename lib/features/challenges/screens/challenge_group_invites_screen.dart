import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_textures.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/providers/auth_provider.dart';
import '../viewmodels/challenge_group_view_model.dart';
import '../models/challenge_group.dart';

@RoutePage()
class ChallengeGroupInvitesScreen extends ConsumerStatefulWidget {
  const ChallengeGroupInvitesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChallengeGroupInvitesScreen> createState() => _ChallengeGroupInvitesScreenState();
}

class _ChallengeGroupInvitesScreenState extends ConsumerState<ChallengeGroupInvitesScreen> {
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    
    // Iniciar carregamento dos convites
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPendingInvites();
    });
  }

  Future<void> _loadPendingInvites() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      await ref.read(challengeGroupViewModelProvider.notifier).loadPendingInvites(currentUser.id);
    }
  }

  Future<void> _respondToInvite(String inviteId, bool accept) async {
    await ref.read(challengeGroupViewModelProvider.notifier).respondToInvite(inviteId, accept);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeGroupViewModelProvider);
    
    // Mostrar mensagem de sucesso, se houver
    if (state.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.successMessage!)),
        );
        ref.read(challengeGroupViewModelProvider.notifier).clearMessages();
      });
    }
    
    // Mostrar mensagem de erro, se houver
    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(challengeGroupViewModelProvider.notifier).clearMessages();
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Convites de Grupos',
          style: AppTypography.headingMedium.copyWith(
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingInvites,
          ),
        ],
      ),
      body: AppTextures.addWaveTexture(
        state.isLoading
            ? const Center(child: LoadingIndicator())
            : state.pendingInvites.isEmpty
                ? EmptyState(
                    message: 'Você não tem convites pendentes',
                    icon: Icons.mail_outline,
                    actionLabel: 'Verificar novamente',
                    onAction: _loadPendingInvites,
                  )
                : RefreshIndicator(
                    onRefresh: _loadPendingInvites,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.pendingInvites.length,
                      itemBuilder: (context, index) {
                        final invite = state.pendingInvites[index];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.group,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        invite.groupName,
                                        style: AppTypography.titleMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Você foi convidado(a) por ${invite.inviterName}',
                                  style: AppTypography.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Convite recebido em ${dateFormat.format(invite.createdAt)}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => _respondToInvite(invite.id, false),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                      child: const Text('Recusar'),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      onPressed: () => _respondToInvite(invite.id, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.secondary,
                                      ),
                                      child: const Text('Aceitar'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
} 