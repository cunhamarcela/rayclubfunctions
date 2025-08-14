// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Added for kDebugMode

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/goals/viewmodels/weekly_goal_view_model.dart';
import 'package:ray_club_app/features/goals/repositories/weekly_goal_repository.dart'; // Added for weeklyGoalRepositoryProvider

/// ✅ WIDGET NOVO: Progresso de Tempo - Meta Semanal com dados reais
/// Conectado ao sistema weekly_goals com reset automático
class WorkoutDurationWidgetNew extends ConsumerStatefulWidget {
  const WorkoutDurationWidgetNew({Key? key}) : super(key: key);

  @override
  ConsumerState<WorkoutDurationWidgetNew> createState() => _WorkoutDurationWidgetNewState();
}

class _WorkoutDurationWidgetNewState extends ConsumerState<WorkoutDurationWidgetNew> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // ✅ SINCRONIZAÇÃO INICIAL: Garantir que dados existentes sejam sincronizados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWeeklyGoal();
    });
  }

  /// Inicializa e sincroniza weekly goal
  Future<void> _initializeWeeklyGoal() async {
    if (_isInitialized) return;
    
    try {
      debugPrint('🔄 WorkoutDurationWidgetNew: Inicializando weekly goal...');
      
      // Carregar meta atual
      await ref.read(weeklyGoalViewModelProvider.notifier).loadCurrentGoal();
      
      // ✅ SINCRONIZAÇÃO AUTOMÁTICA: Sincronizar treinos existentes da semana
      final repository = ref.read(weeklyGoalRepositoryProvider);
      final syncResult = await repository.syncExistingWorkouts();
      
      debugPrint('✅ Sincronização concluída: ${syncResult['message']}');
      debugPrint('📊 Treinos encontrados: ${syncResult['workouts_found']}');
      debugPrint('⏱️ Total minutos: ${syncResult['total_minutes']}');
      
      // Recarregar após sincronização
      await ref.read(weeklyGoalViewModelProvider.notifier).loadCurrentGoal();
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ Erro na inicialização: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final weeklyGoalState = ref.watch(weeklyGoalViewModelProvider);
    
    // ✅ TRATAMENTO DE ESTADOS
    if (weeklyGoalState.isLoading) {
      return _buildLoadingWidget();
    }
    
    if (weeklyGoalState.error != null) {
      return _buildErrorWidget(weeklyGoalState.error!);
    }
    
    final goal = weeklyGoalState.currentGoal;
    
    // Fallback para dados padrão se não conseguir carregar
    final goalMinutes = goal?.goalMinutes ?? 180;
    final currentMinutes = goal?.currentMinutes ?? 0;
    final progressPercentage = goal?.percentageCompleted ?? 0.0;
    final isCompleted = goal?.completed ?? false;
    
    // ✅ INDICADOR DE RESET SEMANAL
    final now = DateTime.now();
    final isMonday = now.weekday == 1;
    final isMorning = now.hour < 12;
    final showResetIndicator = isMonday && isMorning;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ CABEÇALHO COM INDICADOR DE RESET
          Row(
            children: [
              const Icon(
                Icons.timer,
                color: Color(0xFFF38638),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Progresso de Tempo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4D4D4D),
                ),
              ),
              if (showResetIndicator) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '🔄 Reset hoje!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // ✅ PROGRESSO CIRCULAR COM DADOS REAIS
          Row(
            children: [
              // Círculo de progresso
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Fundo do progresso
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey[200]!,
                      ),
                    ),
                    // Progresso real
                    CircularProgressIndicator(
                      value: (progressPercentage / 100).clamp(0.0, 1.0),
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? Colors.green : const Color(0xFFF38638),
                      ),
                    ),
                    // Texto central
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$currentMinutes',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF38638),
                          ),
                        ),
                        const Text(
                          'min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4D4D4D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // ✅ INFORMAÇÕES DETALHADAS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meta Semanal',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentMinutes/$goalMinutes min',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4D4D4D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Barra de progresso
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (progressPercentage / 100).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCompleted ? Colors.green : const Color(0xFFF38638),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${progressPercentage.toStringAsFixed(1)}% concluído',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // ✅ MENSAGEM MOTIVACIONAL
          Text(
            _getMotivationalMessage(currentMinutes, goalMinutes, isCompleted),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          
          // ✅ DEBUG INFO (apenas em debug mode)
          if (kDebugMode && goal != null) ...[
            const SizedBox(height: 8),
            Text(
              'Debug: Semana ${goal.weekStartDate.day}/${goal.weekStartDate.month} - ${goal.weekEndDate.day}/${goal.weekEndDate.month}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Widget de loading
  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF38638)),
          ),
          SizedBox(height: 16),
          Text(
            'Carregando meta semanal...',
            style: TextStyle(
              color: Color(0xFF4D4D4D),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget de erro
  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            'Erro ao carregar meta semanal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _initializeWeeklyGoal(),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  /// Gera mensagem motivacional baseada no progresso
  String _getMotivationalMessage(int current, int goal, bool isCompleted) {
    if (isCompleted) {
      return "🎉 Parabéns! Meta semanal concluída! Continue assim!";
    }
    
    final remaining = goal - current;
    final percentage = (current / goal * 100);
    
    if (percentage >= 80) {
      return "🔥 Quase lá! Faltam apenas $remaining minutos!";
    } else if (percentage >= 50) {
      return "💪 Você está no meio do caminho! Continue assim!";
    } else if (percentage >= 25) {
      return "⭐ Bom progresso! Mantenha o ritmo!";
    } else if (current > 0) {
      return "🌱 Ótimo começo! Cada minuto conta!";
    } else {
      return "🚀 Tempo total de treino nesta semana. Continue assim!";
    }
  }
} 