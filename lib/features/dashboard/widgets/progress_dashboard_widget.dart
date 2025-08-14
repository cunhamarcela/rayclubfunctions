// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:ray_club_app/core/router/app_router.dart';

/// Widget que exibe o progresso do usuário no dashboard
class ProgressDashboardWidget extends ConsumerWidget {
  /// Construtor
  const ProgressDashboardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar os dados do dashboard
    final dashboardAsync = ref.watch(dashboardDataProvider);
    
    return dashboardAsync.when(
      data: (dashboardData) => _buildProgressDashboard(context, dashboardData),
      loading: () => const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                'Erro ao carregar progresso',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () => ref.refresh(dashboardViewModelProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Constrói o dashboard com os dados de progresso
  Widget _buildProgressDashboard(BuildContext context, dashboardData) {
    return InkWell(
      onTap: () => _navigateToWorkoutsList(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seu Progresso',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'StingerTrial',
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4D4D4D),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Ver todos',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFF38638),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: const Color(0xFFF38638),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Grid com os principais indicadores - ajustados para evitar overflow
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 1.5,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            padding: EdgeInsets.zero,
            children: [
              // Treinos realizados
              _buildStatCard(
                context,
                icon: Icons.fitness_center,
                title: 'Treinos',
                value: '${dashboardData.totalWorkouts}',
                color: const Color(0xFF8CA9D3),
              ),
              
              // Dias treinados este mês
              _buildStatCard(
                context,
                icon: Icons.calendar_today,
                title: 'Dias no Mês',
                value: '${dashboardData.daysTrainedThisMonth}',
                color: const Color(0xFFF38638),
              ),
              
              // Tempo total de treino (em minutos)
              _buildStatCard(
                context,
                icon: Icons.timer,
                title: 'Minutos',
                value: '${dashboardData.totalDuration}',
                color: const Color(0xFFCDA8F0),
              ),
              
              // Check-ins em desafios
              _buildStatCard(
                context,
                icon: Icons.emoji_events,
                title: 'Check-ins',
                value: '${dashboardData.challengeProgress.checkIns}',
                color: const Color(0xFF85D1AE),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Distribuição de treinos por tipo
          _buildWorkoutTypeDistribution(context, dashboardData.workoutsByType),
        ],
        ),
      ),
    );
  }
  
  /// Navega para a tela de listagem de treinos
  void _navigateToWorkoutsList(BuildContext context) {
    context.pushRoute(const UserWorkoutsManagementRoute());
  }
  
  /// Constrói um card com estatística
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4D4D4D),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Constrói visualização de treinos por tipo
  Widget _buildWorkoutTypeDistribution(BuildContext context, Map<String, dynamic> workoutsByType) {
    // Se não há tipos de treino, mostrar mensagem
    if (workoutsByType.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Vamos criar barras para cada tipo de treino
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                  Text(
            'Tipos de Treino',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontFamily: 'StingerTrial',
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4D4D4D),
            ),
          ),
        const SizedBox(height: 8),
        ...workoutsByType.entries.map((entry) {
          final workoutType = entry.key;
          final count = entry.value is int ? entry.value : 0;
          
          // Limitar tamanho para evitar overflow
          final displayName = workoutType.length > 15 
              ? '${workoutType.substring(0, 12)}...'
              : workoutType;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _calculateProgressValue(count, workoutsByType),
                          backgroundColor: Colors.grey.shade200,
                          color: _getColorForWorkoutType(workoutType),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        count == 1 ? '$count treino' : '$count treinos',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
  
  /// Calcula valor da barra de progresso com base no total
  double _calculateProgressValue(int count, Map<String, dynamic> allTypes) {
    // Encontra o valor máximo entre todos os tipos
    int maxCount = 0;
    for (final value in allTypes.values) {
      final valueAsInt = value is int ? value : 0;
      if (valueAsInt > maxCount) {
        maxCount = valueAsInt;
      }
    }
    
    // Se não há treinos, retorna 0
    if (maxCount == 0) return 0;
    
    // Normaliza o valor entre 0.1 e 1.0
    // Mínimo de 0.1 para que sempre apareça um pouco da barra
    return (count / maxCount).clamp(0.1, 1.0);
  }
  
  /// Retorna uma cor baseada no tipo de treino
  Color _getColorForWorkoutType(String type) {
    // Definir cor baseada no tipo de exercício
    Color exerciseColor;
    IconData exerciseIcon;
    
    final normalizedType = type.toLowerCase();
    if (normalizedType.contains('corrida')) {
      exerciseColor = const Color(0xFF26A69A);
      exerciseIcon = Icons.directions_run;
    } else if (normalizedType.contains('flexibilidade') || normalizedType.contains('alongamento')) {
      exerciseColor = const Color(0xFF45B7D1);
      exerciseIcon = Icons.accessibility_new;
    } else if (normalizedType.contains('força') || normalizedType.contains('musculação')) {
      exerciseColor = const Color(0xFF4ECDC4);
      exerciseIcon = Icons.fitness_center;
    } else if (normalizedType.contains('pilates')) {
      exerciseColor = const Color(0xFFDDA0DD);
      exerciseIcon = Icons.spa;
    } else if (normalizedType.contains('funcional')) {
      exerciseColor = const Color(0xFFFF7043);
      exerciseIcon = Icons.sports_martial_arts;
    } else if (normalizedType.contains('fisioterapia')) {
      exerciseColor = const Color(0xFF78909C);
      exerciseIcon = Icons.healing;
    } else {
      exerciseColor = const Color(0xFF6B73FF);
      exerciseIcon = Icons.sports_gymnastics;
    }
    
    return exerciseColor;
  }
} 