// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_fitness_view_model.dart';
import 'package:ray_club_app/features/dashboard/widgets/fitness_calendar_widget.dart';
import 'package:ray_club_app/features/dashboard/widgets/progress_cards_widget.dart';
import 'package:ray_club_app/features/dashboard/widgets/enhanced_dashboard_widget.dart';
import 'package:ray_club_app/features/dashboard/widgets/period_fitness_selector_widget.dart';
import 'package:ray_club_app/core/widgets/app_bar_widget.dart';
import 'package:ray_club_app/shared/bottom_navigation_bar.dart';
import 'package:ray_club_app/features/goals/viewmodels/weekly_goal_expanded_view_model.dart';
import 'package:ray_club_app/features/goals/viewmodels/personalized_goal_viewmodel.dart';
import 'package:ray_club_app/features/dashboard/widgets/goals_section_enhanced.dart';
import 'package:ray_club_app/features/subscription/widgets/premium_feature_gate.dart';
import 'package:ray_club_app/features/dashboard/widgets/cardio_challenge_progress_widget.dart';

/// Tela principal do dashboard fitness com calendário e estatísticas
@RoutePage()
class FitnessDashboardScreen extends ConsumerStatefulWidget {
  const FitnessDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FitnessDashboardScreen> createState() => _FitnessDashboardScreenState();
}

class _FitnessDashboardScreenState extends ConsumerState<FitnessDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializa os dados quando a tela é carregada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardFitnessViewModelProvider.notifier).loadDashboardData();
      // Inicializa também o sistema de metas semanais (antigo)
      ref.read(weeklyGoalExpandedViewModelProvider.notifier).loadCurrentGoal();
      // Inicializa o sistema NOVO de metas personalizáveis
      ref.read(personalizedGoalViewModelProvider.notifier).loadActiveGoal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProgressGate(
      featureKey: 'advanced_tracking',
      progressTitle: 'Dashboard Fitness Avançado',
      progressDescription: 'Continue evoluindo para acessar o dashboard fitness completo com calendário de treinos, metas personalizadas e estatísticas avançadas.',
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F1E7), // Fundo bege claro
        appBar: const AppBarWidget(
          title: 'Dashboard Fitness',
          showBackButton: true,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await ref.read(dashboardFitnessViewModelProvider.notifier).refreshData();
            // Também atualiza as metas semanais (antigo)
            await ref.read(weeklyGoalExpandedViewModelProvider.notifier).refresh();
            // Atualiza o sistema NOVO de metas personalizáveis
            await ref.read(personalizedGoalViewModelProvider.notifier).refresh();
          },
          color: const Color(0xFFF38C38),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    
                    // 🆕 Widget de filtros de período
                    const PeriodFitnessSelectorWidget(),
                    
                    const SizedBox(height: 16),
                    
                    // 🏃‍♂️ Progresso do Desafio de Cardio
                    const CardioChallengeProgressWidget(),
                    
                    const SizedBox(height: 16),
                    
                    // Conteúdo principal
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. Resumo do mês
                          Consumer(
                            builder: (context, ref, child) {
                              final dashboardState = ref.watch(dashboardFitnessViewModelProvider);
                              return dashboardState.when(
                                data: (data) => ProgressCardsWidget.buildMonthSummary(data),
                                loading: () => const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFF38638),
                                    ),
                                  ),
                                ),
                                error: (error, _) => Container(
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline, color: Colors.red.shade600),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Erro ao carregar dados do período',
                                          style: TextStyle(
                                            color: Colors.red.shade600,
                                            fontFamily: 'Century',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // 2. Resumo da semana
                          Consumer(
                            builder: (context, ref, child) {
                              final dashboardState = ref.watch(dashboardFitnessViewModelProvider);
                              return dashboardState.when(
                                data: (data) => ProgressCardsWidget.buildWeekSummary(data),
                                loading: () => const SizedBox.shrink(),
                                error: (error, _) => const SizedBox.shrink(),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // 3. Evolução semanal
                          EnhancedDashboardWidget.buildWeeklyEvolution(context, ref),
                          
                          const SizedBox(height: 20),
                          
                          // 5. Metas da semana (SISTEMA NOVO) 
                          const GoalsSectionEnhanced(),
                          
                          const SizedBox(height: 20),
                          
                          // 6. Calendário fitness
                          const FitnessCalendarWidget(),
                          
                          // Espaço extra no final
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: 4),
      ),
    );
  }
} 