// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/providers/cardio_challenge_providers.dart';
import 'package:ray_club_app/features/dashboard/models/cardio_challenge_progress.dart';

/// Widget que exibe o progresso do usuário no desafio de cardio
class CardioChallengeProgressWidget extends ConsumerWidget {
  const CardioChallengeProgressWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeProgressAsync = ref.watch(cardioChallengeProgressWithRefreshProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: challengeProgressAsync.when(
          data: (progress) => _buildProgressContent(context, progress),
          loading: () => _buildLoadingContent(),
          error: (error, _) => _buildErrorContent(context, error),
        ),
      ),
    );
  }

  /// Constrói o conteúdo principal do widget com os dados do progresso
  Widget _buildProgressContent(BuildContext context, CardioChallengeProgress progress) {
    if (!progress.isParticipating) {
      return _buildNotParticipatingContent(context);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF38C38).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFFF38C38),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Desafio Cardio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Century',
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    Text(
                      progress.motivationalMessage,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Century',
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Estatísticas principais
          Row(
            children: [
              // Posição
              Expanded(
                child: _buildStatCard(
                  icon: Icons.emoji_events,
                  iconColor: _getPositionColor(progress.position),
                  title: 'Posição',
                  value: progress.formattedPosition,
                  subtitle: 'de ${progress.totalParticipants}',
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Minutos totais
              Expanded(
                child: _buildStatCard(
                  icon: Icons.timer,
                  iconColor: const Color(0xFF4CAF50),
                  title: 'Minutos',
                  value: '${progress.totalMinutes}',
                  subtitle: 'total',
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Melhoria percentual
              Expanded(
                child: _buildStatCard(
                  icon: _getImprovementIcon(progress.improvementPercentage),
                  iconColor: _getImprovementColor(progress.improvementPercentage),
                  title: 'Melhoria',
                  value: progress.formattedImprovementPercentage,
                  subtitle: 'vs ontem',
                ),
              ),
            ],
          ),
          
          // Barra de progresso visual (opcional)
          if (progress.hasSignificantImprovement) ...[
            const SizedBox(height: 16),
            _buildImprovementBar(progress),
          ],
        ],
      ),
    );
  }

  /// Constrói um card de estatística
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F1E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF38C38).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Century',
              color: Color(0xFF2D2D2D),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'Century',
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 9,
              fontFamily: 'Century',
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a barra de melhoria quando há progresso significativo
  Widget _buildImprovementBar(CardioChallengeProgress progress) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.trending_up,
            color: Color(0xFF4CAF50),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Excelente! Você melhorou ${progress.formattedImprovementPercentage} em relação a ontem! 🎉',
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Century',
                color: Color(0xFF2D2D2D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o conteúdo quando o usuário não está participando
  Widget _buildNotParticipatingContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9E9E9E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_fire_department_outlined,
                  color: Color(0xFF9E9E9E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Desafio Cardio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Century',
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    Text(
                      'Entre no desafio para competir!',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Century',
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F1E7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF38C38).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.sports_gymnastics,
                  color: Color(0xFFF38C38),
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  'Participe do desafio e compete com outros usuários em minutos de cardio!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Century',
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o conteúdo de loading
  Widget _buildLoadingContent() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              CircularProgressIndicator(
                color: Color(0xFFF38C38),
                strokeWidth: 2,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Desafio Cardio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Century',
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    Text(
                      'Carregando seu progresso...',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Century',
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói o conteúdo de erro
  Widget _buildErrorContent(BuildContext context, Object error) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF44336).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Color(0xFFF44336),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Desafio Cardio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Century',
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    Text(
                      'Erro ao carregar dados',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Century',
                        color: Color(0xFFF44336),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Retorna a cor baseada na posição do usuário
  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // Ouro
      case 2:
        return const Color(0xFFC0C0C0); // Prata
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF2196F3); // Azul padrão
    }
  }

  /// Retorna o ícone baseado na melhoria percentual
  IconData _getImprovementIcon(double improvement) {
    if (improvement > 0) return Icons.trending_up;
    if (improvement < 0) return Icons.trending_down;
    return Icons.trending_flat;
  }

  /// Retorna a cor baseada na melhoria percentual
  Color _getImprovementColor(double improvement) {
    if (improvement > 0) return const Color(0xFF4CAF50); // Verde
    if (improvement < 0) return const Color(0xFFF44336); // Vermelho
    return const Color(0xFF9E9E9E); // Cinza
  }
}
