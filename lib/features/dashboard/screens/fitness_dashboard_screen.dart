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
import 'package:ray_club_app/core/widgets/app_bar_widget.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E7), // Fundo bege claro
      appBar: const AppBarWidget(
        title: 'Dashboard Fitness',
        showBackButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(dashboardFitnessViewModelProvider.notifier).refreshData();
        },
        color: const Color(0xFFF38C38),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Calendário fitness
              const FitnessCalendarWidget(),
              
              // Cards de progresso
              const ProgressCardsWidget(),
              
              // Metas por categoria de treino
              const EnhancedDashboardWidget(),
              
              // Espaço extra no final
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      // Botão flutuante para adicionar treino
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddWorkout(context),
        backgroundColor: const Color(0xFFF38C38),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Novo Treino',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  /// Navega para a tela de adicionar treino
  void _navigateToAddWorkout(BuildContext context) {
    // TODO: Implementar navegação para tela de adicionar treino
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de adicionar treino em desenvolvimento'),
        backgroundColor: Color(0xFFF38C38),
      ),
    );
  }
} 