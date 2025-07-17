// Flutter imports:
import 'package:flutter/material.dart';
import 'dart:math' as math;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';

/// Widget melhorado que exibe o progresso do usuário no dashboard
class ProgressDashboardWidgetImproved extends ConsumerStatefulWidget {
  /// Construtor
  const ProgressDashboardWidgetImproved({Key? key}) : super(key: key);

  @override
  ConsumerState<ProgressDashboardWidgetImproved> createState() => _ProgressDashboardWidgetImprovedState();
}

class _ProgressDashboardWidgetImprovedState extends ConsumerState<ProgressDashboardWidgetImproved> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
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
      data: (dashboardData) => AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: _buildProgressDashboard(context, dashboardData),
            ),
          );
        },
      ),
      loading: () => _buildLoadingState(),
      error: (error, stackTrace) => _buildErrorState(context),
    );
  }
  
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 48),
          const SizedBox(height: 12),
          Text(
            'Ops! Algo deu errado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => ref.refresh(dashboardViewModelProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFF38638),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressDashboard(BuildContext context, dashboardData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF38638).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF38638).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFFF38638),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Seu Progresso',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'StingerTrial',
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D),
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  // Adicionar tooltip ou informações adicionais
                },
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Grid com animações escalonadas
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 1.4,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            padding: EdgeInsets.zero,
            children: [
              _buildAnimatedStatCard(
                context,
                icon: Icons.fitness_center_rounded,
                title: 'Treinos',
                value: '${dashboardData.totalWorkouts}',
                color: const Color(0xFF6B7FD7),
                delay: 0,
                subtitle: _getMotivationalText(dashboardData.totalWorkouts, 'treinos'),
              ),
              
              _buildAnimatedStatCard(
                context,
                icon: Icons.calendar_month_rounded,
                title: 'Dias no Mês',
                value: '${dashboardData.daysTrainedThisMonth}',
                color: const Color(0xFFF38638),
                delay: 100,
                subtitle: '${30 - dashboardData.daysTrainedThisMonth} dias restantes',
              ),
              
              _buildAnimatedStatCard(
                context,
                icon: Icons.timer_rounded,
                title: 'Minutos',
                value: _formatMinutes(dashboardData.totalDuration),
                color: const Color(0xFFB88FE8),
                delay: 200,
                subtitle: _getTimeEquivalent(dashboardData.totalDuration),
              ),
              
              _buildAnimatedStatCard(
                context,
                icon: Icons.workspace_premium_rounded,
                title: 'Check-ins',
                value: '${dashboardData.challengeProgress.checkIns}',
                color: const Color(0xFF5DBB88),
                delay: 300,
                subtitle: 'Pontos: ${dashboardData.challengeProgress.checkIns * 10}',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Distribuição de treinos melhorada
          _buildEnhancedWorkoutDistribution(context, dashboardData.workoutsByType),
          
          const SizedBox(height: 20),
          
          // Adicionar seção de conquistas recentes
          _buildRecentAchievements(context, dashboardData),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required int delay,
    String? subtitle,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                    Icon(
                      Icons.trending_up_rounded,
                      color: color.withOpacity(0.5),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontFamily: 'StingerTrial',
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D2D2D),
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEnhancedWorkoutDistribution(BuildContext context, Map<String, dynamic> workoutsByType) {
    if (workoutsByType.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Comece a treinar para ver suas estatísticas aqui!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Calcular total para porcentagens
    int totalWorkouts = 0;
    workoutsByType.values.forEach((value) {
      totalWorkouts += (value as int);
    });
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF6B7FD7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.pie_chart_rounded,
                color: Color(0xFF6B7FD7),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Distribuição dos Treinos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFamily: 'StingerTrial',
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        ...workoutsByType.entries.map((entry) {
          final workoutType = entry.key;
          final count = entry.value is int ? entry.value : 0;
          final percentage = totalWorkouts > 0 ? (count / totalWorkouts * 100) : 0;
          final color = _getColorForWorkoutType(workoutType);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          workoutType.length > 15 
                              ? '${workoutType.substring(0, 12)}...'
                              : workoutType,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '$count',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${percentage.toStringAsFixed(0)}%)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: _calculateProgressValue(count, workoutsByType)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  color,
                                  color.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
  
  Widget _buildRecentAchievements(BuildContext context, dashboardData) {
    // Calcula conquistas baseadas nos dados existentes
    List<Map<String, dynamic>> achievements = [];
    
    if (dashboardData.totalWorkouts >= 50) {
      achievements.add({
        'icon': Icons.emoji_events_rounded,
        'title': 'Veterano',
        'description': '50+ treinos realizados!',
        'color': const Color(0xFFFFD700),
      });
    }
    
    if (dashboardData.daysTrainedThisMonth >= 15) {
      achievements.add({
        'icon': Icons.local_fire_department_rounded,
        'title': 'Em Chamas',
        'description': '15+ dias neste mês!',
        'color': const Color(0xFFFF6B6B),
      });
    }
    
    if (dashboardData.totalDuration >= 1000) {
      achievements.add({
        'icon': Icons.access_time_filled_rounded,
        'title': 'Maratonista',
        'description': '1000+ minutos!',
        'color': const Color(0xFF4ECDC4),
      });
    }
    
    if (achievements.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFD700),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Conquistas Recentes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFamily: 'StingerTrial',
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: achievements.map((achievement) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (achievement['color'] as Color).withOpacity(0.1),
                      (achievement['color'] as Color).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (achievement['color'] as Color).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      achievement['icon'] as IconData,
                      color: achievement['color'] as Color,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement['title'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                        Text(
                          achievement['description'] as String,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  // Funções auxiliares
  String _formatMinutes(int minutes) {
    if (minutes < 60) return '$minutes';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h${mins}m' : '${hours}h';
  }
  
  String _getTimeEquivalent(int minutes) {
    if (minutes < 60) return '$minutes minutos';
    final hours = minutes / 60;
    return '${hours.toStringAsFixed(1)} horas';
  }
  
  String _getMotivationalText(int count, String type) {
    if (count == 0) return 'Comece hoje!';
    if (count < 10) return 'Ótimo início!';
    if (count < 50) return 'Continue assim!';
    if (count < 100) return 'Impressionante!';
    return 'Lendário!';
  }
  
  double _calculateProgressValue(int count, Map<String, dynamic> allTypes) {
    int maxCount = 0;
    for (final value in allTypes.values) {
      final valueAsInt = value is int ? value : 0;
      if (valueAsInt > maxCount) {
        maxCount = valueAsInt;
      }
    }
    
    if (maxCount == 0) return 0;
    return (count / maxCount).clamp(0.1, 1.0);
  }
  
  Color _getColorForWorkoutType(String type) {
    final normalizedType = type.toLowerCase();
    
    if (normalizedType.contains('funcional')) {
      return const Color(0xFF6B7FD7);
    } else if (normalizedType.contains('musculação') || normalizedType.contains('força')) {
      return const Color(0xFFF38638);
    } else if (normalizedType.contains('yoga') || normalizedType.contains('flexibilidade')) {
      return const Color(0xFFB88FE8);
    } else if (normalizedType.contains('cardio') || normalizedType.contains('corrida')) {
      return const Color(0xFF5DBB88);
    } else if (normalizedType.contains('hiit')) {
      return const Color(0xFFFF6B6B);
    } else {
      return const Color(0xFF9E9E9E);
    }
  }
} 