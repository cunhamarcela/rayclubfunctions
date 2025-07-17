// Flutter imports:
import 'package:flutter/material.dart';
import 'dart:math' as math;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/providers/dashboard_providers.dart';

/// Widget melhorado que exibe o progresso do desafio atual
class ChallengeProgressWidgetImproved extends ConsumerStatefulWidget {
  /// Construtor
  const ChallengeProgressWidgetImproved({Key? key}) : super(key: key);

  @override
  ConsumerState<ChallengeProgressWidgetImproved> createState() => _ChallengeProgressWidgetImprovedState();
}

class _ChallengeProgressWidgetImprovedState extends ConsumerState<ChallengeProgressWidgetImproved> 
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
    // Se não há desafio ativo
    if (challengeProgress.challengeId == null) {
      return _buildNoChallengeState(context);
    }
    
    // Calcula o progresso percentual
    final progressPercent = challengeProgress.totalDays > 0 
        ? (challengeProgress.checkIns / challengeProgress.totalDays).clamp(0.0, 1.0)
        : 0.0;
    
    // Calcula dias restantes
    final daysRemaining = challengeProgress.endDate != null
        ? () {
            final now = DateTime.now();
            final brazilNow = DateTime(now.year, now.month, now.day);
            final brazilEndDate = DateTime(
              challengeProgress.endDate!.year, 
              challengeProgress.endDate!.month, 
              challengeProgress.endDate!.day
            );
            final difference = brazilEndDate.difference(brazilNow).inDays + 1;
            return difference >= 0 ? difference : 0;
          }()
        : 0;
    
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
                        if (challengeProgress.challengeName != null)
                          Text(
                            challengeProgress.challengeName!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFF38638),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (daysRemaining > 0 && daysRemaining <= 7)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$daysRemaining dias',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'CenturyGothic',
                              color: Colors.red.shade700,
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
                      icon: Icons.calendar_today_rounded,
                      label: 'Check-ins',
                      value: '${challengeProgress.checkIns}',
                      maxValue: '/${challengeProgress.totalDays}',
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
                      value: '${challengeProgress.checkIns * 10}',
                      maxValue: '',
                      color: const Color(0xFFFFD700),
                      progress: _progressAnimation.value,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Barra de progresso visual
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progresso Geral',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D2D2D),
                        ),
                      ),
                      Text(
                        '${(progressPercent * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'CenturyGothic',
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF38638),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progressPercent * _progressAnimation.value,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF38638),
                                Color(0xFFFF8A65),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF38638).withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Ranking preview
              if (challengeProgress.ranking != null && challengeProgress.ranking! <= 10)
                _buildRankingPreview(context, challengeProgress.ranking!),
              
              // Mensagem motivacional
              if (progressPercent > 0)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF38638).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF38638).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getMotivationalIcon(progressPercent),
                        color: const Color(0xFFF38638),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getMotivationalMessage(progressPercent),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFF38638),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
    required String maxValue,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
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
                      fontFamily: 'CenturyGothic',
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D2D2D),
                    ),
                  );
                },
              ),
              if (maxValue.isNotEmpty)
                Text(
                  maxValue,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'StingerTrial',
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRankingPreview(BuildContext context, int ranking) {
    IconData rankingIcon;
    Color rankingColor;
    String rankingText;
    
    if (ranking == 1) {
      rankingIcon = Icons.looks_one_rounded;
      rankingColor = const Color(0xFFFFD700);
      rankingText = '🏆 1º Lugar!';
    } else if (ranking == 2) {
      rankingIcon = Icons.looks_two_rounded;
      rankingColor = const Color(0xFFC0C0C0);
      rankingText = '🥈 2º Lugar!';
    } else if (ranking == 3) {
      rankingIcon = Icons.looks_3_rounded;
      rankingColor = const Color(0xFFCD7F32);
      rankingText = '🥉 3º Lugar!';
    } else {
      rankingIcon = Icons.leaderboard_rounded;
      rankingColor = const Color(0xFF6B7FD7);
      rankingText = '📊 ${ranking}º Lugar';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            rankingColor.withOpacity(0.1),
            rankingColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rankingColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            rankingIcon,
            color: rankingColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            rankingText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontFamily: 'StingerTrial',
              fontWeight: FontWeight.bold,
              color: rankingColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'no ranking geral',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
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
            'Participe de um desafio para começar\na competir e ganhar pontos!',
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
  
  IconData _getMotivationalIcon(double progress) {
    if (progress >= 0.8) return Icons.local_fire_department_rounded;
    if (progress >= 0.6) return Icons.trending_up_rounded;
    if (progress >= 0.4) return Icons.thumb_up_rounded;
    if (progress >= 0.2) return Icons.sentiment_satisfied_rounded;
    return Icons.sports_handball_rounded;
  }
  
  String _getMotivationalMessage(double progress) {
    if (progress >= 0.8) return 'Incrível! Você está quase lá! 🔥';
    if (progress >= 0.6) return 'Ótimo progresso! Continue assim! 💪';
    if (progress >= 0.4) return 'Você está no caminho certo! 👏';
    if (progress >= 0.2) return 'Bom começo! Não desista! 🌟';
    return 'Vamos começar com tudo! 🚀';
  }
} 