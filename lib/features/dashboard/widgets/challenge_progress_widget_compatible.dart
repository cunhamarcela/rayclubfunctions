// Flutter imports:
import 'package:flutter/material.dart';
import 'dart:math' as math;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/providers/dashboard_providers.dart';

/// Widget melhorado que exibe o progresso do desafio atual
/// Versão compatível com a estrutura atual do banco de dados
class ChallengeProgressWidgetCompatible extends ConsumerStatefulWidget {
  /// Construtor
  const ChallengeProgressWidgetCompatible({Key? key}) : super(key: key);

  @override
  ConsumerState<ChallengeProgressWidgetCompatible> createState() => _ChallengeProgressWidgetCompatibleState();
}

class _ChallengeProgressWidgetCompatibleState extends ConsumerState<ChallengeProgressWidgetCompatible> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    
    return dashboardAsync.when(
      data: (dashboardData) => _buildChallengeProgress(context, dashboardData.challengeProgress),
      loading: () => _buildLoadingState(),
      error: (error, stackTrace) => _buildErrorState(context),
    );
  }
  
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF38638),
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          'Erro ao carregar desafio',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.red.shade700,
          ),
        ),
      ),
    );
  }
  
  Widget _buildChallengeProgress(BuildContext context, challengeProgress) {
    // Se não há check-ins, assume que não há desafio ativo
    if (challengeProgress.checkIns == 0) {
      return _buildNoChallengeState(context);
    }
    
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFF38638).withOpacity(0.08),
                const Color(0xFFFFE0B2).withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF38638).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF38638),
                                Color(0xFFFF8A65),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF38638).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Desafio Atual',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontFamily: 'StingerTrial',
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D2D2D),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Participando ativamente',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFF38638),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge de atividade
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5DBB88).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF5DBB88).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5DBB88),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ativo',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF5DBB88),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Cards de estatísticas com animação
              Row(
                children: [
                  Expanded(
                    child: _buildStatisticCard(
                      context,
                      icon: Icons.calendar_check_rounded,
                      label: 'Check-ins',
                      value: '${challengeProgress.checkIns}',
                      color: const Color(0xFF6B7FD7),
                      progress: _progressAnimation.value,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatisticCard(
                      context,
                      icon: Icons.star_rounded,
                      label: 'Pontos',
                      value: '${challengeProgress.totalPoints}',
                      color: const Color(0xFFFFD700),
                      progress: _progressAnimation.value,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Estatísticas adicionais baseadas nos check-ins
              _buildProgressStats(context, challengeProgress),
              
              const SizedBox(height: 20),
              
              // Mensagem motivacional baseada no número de check-ins
              _buildMotivationalMessage(context, challengeProgress.checkIns),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStatisticCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<int>(
            duration: const Duration(milliseconds: 800),
            tween: IntTween(
              begin: 0,
              end: int.tryParse(value) ?? 0,
            ),
            builder: (context, animatedValue, child) {
              return Text(
                '$animatedValue',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressStats(BuildContext context, challengeProgress) {
    // Calcula estatísticas baseadas nos check-ins
    final avgCheckInsPerWeek = challengeProgress.checkIns > 0 
        ? (challengeProgress.checkIns / 4).toStringAsFixed(1) // Assumindo 4 semanas
        : '0';
    
    final level = _getLevel(challengeProgress.checkIns);
    final nextLevelCheckIns = _getNextLevelRequirement(challengeProgress.checkIns);
    final progressToNextLevel = _getProgressToNextLevel(challengeProgress.checkIns);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF38638).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nível atual
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.military_tech_rounded,
                    color: Color(0xFFF38638),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nível $level',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF38638),
                    ),
                  ),
                ],
              ),
              Text(
                '$nextLevelCheckIns check-ins para o próximo',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Barra de progresso para próximo nível
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressToNextLevel,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFFF38638),
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          // Média semanal
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: Colors.grey.shade600,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Média: $avgCheckInsPerWeek check-ins por semana',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMotivationalMessage(BuildContext context, int checkIns) {
    final message = _getMotivationalMessageForCheckIns(checkIns);
    final icon = _getMotivationalIcon(checkIns);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF38638).withOpacity(0.1),
            const Color(0xFFFFE0B2).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF38638).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFF38638),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFF38638),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoChallengeState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade100,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              color: Colors.grey.shade400,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum desafio ativo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comece a treinar com um desafio\npara ganhar pontos e competir!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Navegar para a tela de desafios
            },
            icon: const Icon(Icons.search_rounded),
            label: const Text('Explorar Desafios'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF38638),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  // Funções auxiliares
  int _getLevel(int checkIns) {
    if (checkIns >= 100) return 5;
    if (checkIns >= 50) return 4;
    if (checkIns >= 25) return 3;
    if (checkIns >= 10) return 2;
    return 1;
  }
  
  int _getNextLevelRequirement(int checkIns) {
    if (checkIns < 10) return 10 - checkIns;
    if (checkIns < 25) return 25 - checkIns;
    if (checkIns < 50) return 50 - checkIns;
    if (checkIns < 100) return 100 - checkIns;
    return 0;
  }
  
  double _getProgressToNextLevel(int checkIns) {
    if (checkIns < 10) return checkIns / 10;
    if (checkIns < 25) return (checkIns - 10) / 15;
    if (checkIns < 50) return (checkIns - 25) / 25;
    if (checkIns < 100) return (checkIns - 50) / 50;
    return 1.0;
  }
  
  IconData _getMotivationalIcon(int checkIns) {
    if (checkIns >= 50) return Icons.local_fire_department_rounded;
    if (checkIns >= 25) return Icons.trending_up_rounded;
    if (checkIns >= 10) return Icons.thumb_up_rounded;
    if (checkIns >= 5) return Icons.sentiment_satisfied_rounded;
    return Icons.sports_handball_rounded;
  }
  
  String _getMotivationalMessageForCheckIns(int checkIns) {
    if (checkIns >= 100) return 'Lendário! Você é uma inspiração! 🏆';
    if (checkIns >= 50) return 'Incrível! Você está em chamas! 🔥';
    if (checkIns >= 25) return 'Fantástico! Continue assim! 💪';
    if (checkIns >= 10) return 'Muito bem! Você está evoluindo! 🌟';
    if (checkIns >= 5) return 'Bom trabalho! Mantenha o ritmo! 👏';
    return 'Ótimo começo! Vamos em frente! 🚀';
  }
} 