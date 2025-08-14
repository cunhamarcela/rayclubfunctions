// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:ray_club_app/features/dashboard/widgets/challenge_progress_widget.dart';
import 'package:ray_club_app/features/dashboard/widgets/period_selector_widget.dart';
import 'package:ray_club_app/features/dashboard/widgets/progress_dashboard_widget.dart';
import 'package:ray_club_app/features/dashboard/widgets/workout_calendar_widget.dart';
import 'package:ray_club_app/features/dashboard/widgets/workout_duration_widget.dart';

import 'package:ray_club_app/features/settings/screens/settings_screen.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_view_model.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_history_view_model.dart';
import 'package:ray_club_app/features/workout/providers/workout_providers.dart';
import 'package:ray_club_app/features/subscription/widgets/premium_feature_gate.dart';

/// Tela que exibe o dashboard completo do usuário
@RoutePage()
class DashboardScreen extends ConsumerStatefulWidget {
  /// Construtor
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    
    // Inicializa os dados quando a tela é carregada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }
  
  /// Inicializa todos os dados necessários para o dashboard
  Future<void> _initializeData() async {
    // Carrega os dados do dashboard
    ref.read(dashboardViewModelProvider.notifier).loadDashboardData();
    
    // Importante: Carrega o histórico de treinos para o calendário
    ref.read(workoutHistoryViewModelProvider.notifier).loadWorkoutHistory();
    
    debugPrint('✅ Dashboard: Dados inicializados');
  }

  @override
  Widget build(BuildContext context) {
    return ProgressGate(
      featureKey: 'enhanced_dashboard',
      progressTitle: 'Dashboard de Progresso',
      progressDescription: 'Continue evoluindo para acessar estatísticas detalhadas e acompanhar seu progresso completo.',
      child: Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      // Removendo a AppBar e integrando o título no body
      body: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: Opacity(
              opacity: 0.2, // Aumentada a opacidade para melhor visibilidade
              child: Image.asset(
                'assets/images/logos/app/gradientes_7.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Conteúdo principal com RefreshIndicator
          Column(
            children: [
              // Título "Dashboard" no topo, no lugar da AppBar
              Padding(
                padding: const EdgeInsets.only(top: 48.0, left: 16.0, right: 16.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ CORREÇÃO: Botão de voltar funcional
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4D4D4D)),
                      onPressed: () {
                        try {
                          // Método 1: Usar auto_route (preferido)
                          debugPrint('🔄 Dashboard: Tentando voltar para home via auto_route');
                          context.router.navigateNamed('/');
                        } catch (e) {
                          try {
                            // Método 2: Fallback com Navigator padrão
                            debugPrint('🔄 Dashboard: Fallback - tentando Navigator.pop()');
                            Navigator.of(context).pop();
                          } catch (e2) {
                            try {
                              // Método 3: Último recurso - navegação manual para home
                              debugPrint('🔄 Dashboard: Último recurso - navegação manual para home');
                              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                            } catch (e3) {
                              debugPrint('❌ Dashboard: Erro ao navegar de volta: $e3');
                            }
                          }
                        }
                      },
                    ),
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontFamily: 'Century',
                        fontSize: 22,
                        color: Color(0xFF4D4D4D),
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFFF38638)),
                      onPressed: () {
                        ref.refresh(dashboardViewModelProvider);
                        ref.read(workoutHistoryViewModelProvider.notifier).loadWorkoutHistory();
                      },
                    ),
                  ],
                ),
              ),
              // Conteúdo com scroll
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(dashboardViewModelProvider.notifier).refreshData();
                    await ref.read(workoutHistoryViewModelProvider.notifier).loadWorkoutHistory();
                  },
                  color: const Color(0xFFF38638),
                  backgroundColor: Colors.white,
                  child: _buildDashboard(context, ref),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
  
  /// Constrói o dashboard completo
  Widget _buildDashboard(BuildContext context, WidgetRef ref) {
    // Estado global do dashboard
    final dashboardState = ref.watch(dashboardDataProvider);
    
    return dashboardState.when(
      data: (_) => _buildDashboardContent(context),
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF38638),
        )
      ),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFF38638)),
              const SizedBox(height: 16),
              Text(
                'Falha ao carregar o dashboard',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF4D4D4D),
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF4D4D4D)
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Recarrega o dashboard e o histórico de treinos
                  ref.refresh(dashboardViewModelProvider);
                  ref.read(workoutHistoryViewModelProvider.notifier).loadWorkoutHistory();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF38638),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Constrói o conteúdo do dashboard quando os dados estão disponíveis
  Widget _buildDashboardContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seletor de período
          const PeriodSelectorWidget(),
          
          const SizedBox(height: 16),
          
          // Dashboard de progresso
          const ProgressDashboardWidget(),
          
          const SizedBox(height: 16),
          
          // Desafio atual
          const ChallengeProgressWidget(),
          
          const SizedBox(height: 16),
          
          // Progresso de tempo de treino
          const WorkoutDurationWidget(),
          
          const SizedBox(height: 16),
          
          // Calendário de treinos
          const WorkoutCalendarWidget(),
          
          // Espaço extra no final para evitar que o último item fique sob a barra de navegação
          const SizedBox(height: 80),
        ],
      ),
    );
  }
} 