// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/providers/challenge_providers.dart';
import 'package:ray_club_app/features/challenges/providers/challenge_provider.dart' as cp;
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';

/// Widget que exibe o progresso do desafio atual no dashboard
class ChallengeProgressWidget extends ConsumerWidget {
  /// Construtor
  const ChallengeProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar dados do dashboard para obter o desafio atual
    final dashboardAsync = ref.watch(dashboardDataProvider);
    
    return dashboardAsync.when(
      data: (dashboardData) {
        // Verificar se há um desafio ativo
        if (dashboardData.challengeProgress.checkIns <= 0 && 
            dashboardData.challengeProgress.totalPoints <= 0) {
          return const SizedBox.shrink();
        }
        
        // Buscar dados do desafio atual
        return _buildChallengeInfo(context, ref);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
  
  /// Constrói a visualização com informações do desafio
  Widget _buildChallengeInfo(BuildContext context, WidgetRef ref) {
    // Buscar desafios ativos do usuário usando o provider correto
    final userChallengesAsync = ref.watch(userChallengesProvider);
    
    return userChallengesAsync.when(
      data: (challenges) {
        // Pegar o primeiro desafio ativo (geralmente o oficial)
        if (challenges.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final activeChallenge = challenges.firstWhere(
          (c) => c.isActive(),
          orElse: () => challenges.first,
        );
        
        // Buscar o ranking do desafio para obter total de participantes
        final rankingAsync = ref.watch(challengeRankingProvider(activeChallenge.id));
        
        return rankingAsync.when(
          data: (ranking) => _buildChallengeProgress(
            context, 
            ref,
            activeChallenge,
            ranking.length, // Total de participantes
          ),
          loading: () => _buildChallengeProgress(context, ref, activeChallenge, 0),
          error: (_, __) => _buildChallengeProgress(context, ref, activeChallenge, 0),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
  
  /// Constrói a visualização do progresso do desafio
  Widget _buildChallengeProgress(
    BuildContext context, 
    WidgetRef ref,
    Challenge challenge,
    int totalParticipants,
  ) {
    // Buscar o usuário atual através do auth state
    final authState = ref.watch(authViewModelProvider);
    
    return authState.maybeWhen(
      authenticated: (user) {
        // Buscar progresso do usuário especificamente para este desafio
        final userProgressAsync = ref.watch(cp.userProgressProvider(cp.UserProgressParams(
          challengeId: challenge.id,
          userId: user.id,
        )));
        
        return userProgressAsync.when(
          data: (userProgress) {
            // Usar os pontos do usuário ou 0 se não houver progresso
            final userPoints = userProgress?.points ?? 0;
            
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Color(0xFFF38638)),
                        const SizedBox(width: 8),
                        Text(
                          'Desafio Atual',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontFamily: 'StingerTrial',
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4D4D4D),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Participantes e pontos do usuário no desafio
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context, 
                            icon: Icons.people,
                            label: 'Participantes',
                            value: '$totalParticipants',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatItem(
                            context, 
                            icon: Icons.star,
                            label: 'Pontos',
                            value: '$userPoints', // Agora mostra os pontos do usuário
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => _buildLoadingCard(context, challenge, totalParticipants),
          error: (_, __) => _buildErrorCard(context, challenge, totalParticipants),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  /// Constrói um card de carregamento
  Widget _buildLoadingCard(BuildContext context, Challenge challenge, int totalParticipants) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFF38638)),
                const SizedBox(width: 8),
                Text(
                  'Desafio Atual',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Century',
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4D4D4D),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Participantes e pontos carregando
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context, 
                    icon: Icons.people,
                    label: 'Participantes',
                    value: '$totalParticipants',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    context, 
                    icon: Icons.star,
                    label: 'Pontos',
                    value: '...',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói um card de erro (mostra 0 pontos)
  Widget _buildErrorCard(BuildContext context, Challenge challenge, int totalParticipants) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFF38638)),
                const SizedBox(width: 8),
                Text(
                  'Desafio Atual',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'StingerTrial',
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4D4D4D),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Participantes e pontos (0 em caso de erro)
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context, 
                    icon: Icons.people,
                    label: 'Participantes',
                    value: '$totalParticipants',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    context, 
                    icon: Icons.star,
                    label: 'Pontos',
                    value: '0',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói um item de estatística para o desafio
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECDD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFF38638),
            size: 24,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4D4D4D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 