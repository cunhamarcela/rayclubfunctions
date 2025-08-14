// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_enhanced_view_model.dart';
import 'package:ray_club_app/features/dashboard/widgets/redeemed_benefits_widget.dart';
import 'package:ray_club_app/features/dashboard/widgets/nutrition_tracking_widget.dart';
import 'package:ray_club_app/features/subscription/widgets/premium_feature_gate.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/challenge_progress_widget.dart';
import '../widgets/goals_section_enhanced.dart';

/// Dashboard aprimorado com recursos adicionais
/// Este dashboard usa a função get_dashboard_data e é separado do dashboard core
@RoutePage()
class DashboardEnhancedScreen extends ConsumerStatefulWidget {
  const DashboardEnhancedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardEnhancedScreen> createState() => _DashboardEnhancedScreenState();
}

class _DashboardEnhancedScreenState extends ConsumerState<DashboardEnhancedScreen> {
  @override
  void initState() {
    super.initState();
    // Força recarregamento ao entrar na tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardEnhancedViewModelProvider.notifier).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardEnhancedViewModelProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      body: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/logos/app/gradientes_7.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Conteúdo principal
          Column(
            children: [
              // Header customizado
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BackButton(color: Color(0xFF4D4D4D)),
                    Text(
                      'Wellness Dashboard',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'StingerTrial',
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4D4D4D),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFFF38638)),
                      onPressed: () {
                        ref.read(dashboardEnhancedViewModelProvider.notifier).refreshData();
                      },
                    ),
                  ],
                ),
              ),
              // Conteúdo com scroll
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(dashboardEnhancedViewModelProvider.notifier).refreshData();
                  },
                  color: const Color(0xFFF38638),
                  child: dashboardState.when(
                    data: (data) => _buildContent(context, data),
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF38638),
                      ),
                    ),
                    error: (error, _) => _buildErrorState(context, error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent(BuildContext context, dynamic data) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Quick Stats Grid - Sempre visível
        _buildQuickStats(context, data),
        
        const SizedBox(height: 20),
        
        // Água - Widget compacto - Sempre visível
        GestureDetector(
          onTap: () => context.router.push(const WaterIntakeRoute()),
          child: const SizedBox.shrink(), // Placeholder
        ),
        
        const SizedBox(height: 16),
        
        // Nutrição - Protegida por gate
        ProgressGate(
          featureKey: 'nutrition_guide',
          progressTitle: 'Tracking de Nutrição',
          progressDescription: 'Alcance o próximo nível para acessar o monitoramento completo de calorias e macronutrientes.',
          child: NutritionTrackingWidget(
            caloriesConsumed: data.nutritionData?.caloriesConsumed ?? 0,
            caloriesGoal: data.nutritionData?.caloriesGoal ?? 2000,
            macros: {
              'proteins': data.nutritionData?.proteins ?? 0.0,
              'carbs': data.nutritionData?.carbs ?? 0.0,
              'fats': data.nutritionData?.fats ?? 0.0,
            },
            onAddMeal: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade de nutrição em desenvolvimento'),
                  backgroundColor: Color(0xFFF38638),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Metas Pré-Estabelecidas - Nova seção integrada
        const GoalsSectionEnhanced(),
        
        const SizedBox(height: 16),

        // Metas antigas - Protegidas por gate inline
        if (data.goals.isNotEmpty) ...[
          QuietProgressGate(
            featureKey: 'advanced_tracking',
            placeholder: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: const Color(0xFFF38638),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Continue sua jornada para desbloquear metas personalizadas',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            child: SizedBox.shrink(), // Placeholder after removing GoalsWidget
          ),
          const SizedBox(height: 16),
        ],
        
        // Desafio atual - Sempre visível
        if (data.currentChallenge != null) ...[
          _buildCurrentChallenge(context, data.currentChallenge, data.challengeProgress),
          const SizedBox(height: 16),
        ],
        
        // Benefícios resgatados - Protegidos por gate
        if (data.redeemedBenefits.isNotEmpty) ...[
          ProgressGate(
            featureKey: 'detailed_reports',
            progressTitle: 'Histórico de Benefícios',
            progressDescription: 'Evolua mais para acessar o histórico completo de benefícios e recompensas.',
            child: const RedeemedBenefitsWidget(),
          ),
          const SizedBox(height: 16),
        ],
        
        // Treinos recentes - Protegidos por gate
        if (data.recentWorkouts.isNotEmpty) ...[
          ProgressGate(
            featureKey: 'workout_library',
            progressTitle: 'Análise de Treinos',
            progressDescription: 'Mantenha sua consistência para desbloquear análises detalhadas dos seus treinos.',
            child: _buildRecentWorkouts(context, data.recentWorkouts),
          ),
          const SizedBox(height: 16),
        ],
        
        // Espaço extra no final
        const SizedBox(height: 80),
      ],
    );
  }
  
  Widget _buildQuickStats(BuildContext context, dynamic data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF38638).withValues(alpha: 0.1),
            const Color(0xFFFFE0B2).withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do Dia',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'StingerTrial',
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4D4D4D),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Treinos',
                  '${data.stats?.workoutCount ?? 0}',
                  Icons.fitness_center,
                  const Color(0xFFF38638),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Check-ins',
                  '${data.stats?.checkinCount ?? 0}',
                  Icons.check_circle,
                  const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pontos',
                  '${data.stats?.totalPoints ?? 0}',
                  Icons.star,
                  const Color(0xFFFFB74D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Sequência',
                  '${data.stats?.currentStreak ?? 0}',
                  Icons.local_fire_department,
                  const Color(0xFFFF7043),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4D4D4D),
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCurrentChallenge(BuildContext context, challenge, progress) {
    return Container(
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
            children: [
              if (challenge.imageUrl != null && challenge.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    challenge.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback quando a imagem falha ao carregar (404, etc.)
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF38638).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Color(0xFFF38638),
                          size: 32,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFF38638),
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF38638).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Color(0xFFF38638),
                    size: 32,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${challenge.daysRemaining} dias restantes',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildChallengeMetric(
                  context,
                  label: 'Check-ins',
                  value: '${progress.totalCheckIns}',
                  icon: Icons.check_circle_outline,
                ),
                _buildChallengeMetric(
                  context,
                  label: 'Posição',
                  value: '${progress.position}º',
                  icon: Icons.leaderboard,
                ),
                _buildChallengeMetric(
                  context,
                  label: 'Progresso',
                  value: '${progress.completionPercentage.toInt()}%',
                  icon: Icons.trending_up,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildChallengeMetric(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFF38638), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecentWorkouts(BuildContext context, List<dynamic> workouts) {
    return Container(
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
                'Treinos Recentes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navegar para histórico completo
                },
                child: const Text('Ver todos'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...workouts.take(3).map((workout) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B7FD7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Color(0xFF6B7FD7),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.workoutName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${workout.durationMinutes} min • ${_formatDate(workout.date)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (workout.isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context, dynamic error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar dashboard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(dashboardEnhancedViewModelProvider.notifier).refreshData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF38638),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else {
      return '${difference.inDays} dias atrás';
    }
  }
} 