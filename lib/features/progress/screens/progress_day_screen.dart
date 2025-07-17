// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:ray_club_app/core/constants/app_padding.dart';
import 'package:ray_club_app/core/constants/app_strings.dart';
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/core/router/route_validation.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/utils/formatters.dart';
import 'package:ray_club_app/core/widgets/app_bar_leading.dart';
import 'package:ray_club_app/core/widgets/app_loader.dart';
import 'package:ray_club_app/core/widgets/empty_state.dart';
import 'package:ray_club_app/core/widgets/error_state.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/challenges/providers/challenge_providers.dart';
import 'package:ray_club_app/features/progress/widgets/date_selector.dart';
import 'package:ray_club_app/features/workouts/models/workout.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/providers/workout_providers.dart';
import 'package:ray_club_app/features/workout/screens/workout_detail_screen.dart';
import 'package:ray_club_app/features/progress/widgets/workout_item.dart';
import 'package:ray_club_app/features/progress/view_models/progress_view_model.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';

@RoutePage()
class ProgressDayScreen extends HookConsumerWidget {
  final int day;
  
  const ProgressDayScreen({
    @PathParam('day') required this.day,
    Key? key,
  }) : super(key: key);

  /// Construtor alternativo que valida e converte o parâmetro de string para int
  /// Usado pelo auto_route quando o parâmetro vem da URL como string
  static ProgressDayScreen fromPathParams(Map<String, String> params) {
    try {
      final dayParam = params['day'] ?? '1';
      debugPrint('ProgressDayScreen.fromPathParams: recebido day=$dayParam');
      
      // Validar e converter o parâmetro day
      int validatedDay;
      try {
        validatedDay = int.parse(dayParam);
        
        // Garantir que o valor está dentro do intervalo esperado (1-14)
        if (validatedDay < 1 || validatedDay > 14) {
          debugPrint('ProgressDayScreen.fromPathParams: day fora do intervalo válido: $validatedDay. Usando 1.');
          validatedDay = 1; // Valor padrão se for inválido
        }
      } catch (e) {
        // Se não for possível converter para int, usar valor padrão
        debugPrint('ProgressDayScreen.fromPathParams: erro ao converter day: $e. Usando 1.');
        validatedDay = 1;
      }
      
      return ProgressDayScreen(day: validatedDay);
    } catch (e, stack) {
      // Capturar qualquer erro no construtor e logging
      debugPrint('ProgressDayScreen.fromPathParams: ERRO GRAVE: $e');
      debugPrint('Stack: ${stack.toString().substring(0, 300)}...');
      
      // Retornar uma versão segura
      return const ProgressDayScreen(day: 1);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize EffectCallback:
    useEffect(() {
      debugPrint('ProgressDayScreen: Inicializando com day=$day');
      
      // Sincronizar dados do usuário ao carregar a tela
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncUserProgressData(ref);
      });
      
      final timer = Future.delayed(const Duration(seconds: 3), () {
        // Verificar se a tela ainda está montada
        if (context.mounted) {
          debugPrint('ProgressDayScreen: Dashboard carregado com sucesso');
        }
      });
      return null;
    }, const []);  // Empty dependency array - run only once
    
    // Calcular a data real baseada no dia passado
    final today = DateTime.now();
    final selectedDate = useState(
      DateTime(today.year, today.month, today.day - (14 - day))
    );
    
    // Observar o estado do ProgressViewModel
    final progressState = ref.watch(progressViewModelProvider);
    
    // Carregar os treinos para o dia selecionado quando a data mudar
    useEffect(() {
      ref.read(progressViewModelProvider.notifier).loadWorkoutsForDate(selectedDate.value);
      return null;
    }, [selectedDate.value]);
    
    // Tratar erros de providers com fallback
    final userChallenges = ref.watch(userActiveChallengesProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: const AppBarLeading(),
        title: Text(
          formatDate(selectedDate.value),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Botão para sincronizar progresso do usuário
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar dados',
            onPressed: () {
              ref.read(progressViewModelProvider.notifier).syncProgressFromWorkouts();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(context, selectedDate, ref),
          Expanded(
            child: progressState.isLoadingWorkouts
                ? const Center(child: CircularProgressIndicator())
                : progressState.error != null
                    ? ErrorState(
                        message: 'Erro ao carregar treinos: ${progressState.error?.message}',
                        onRetry: () => ref.read(progressViewModelProvider.notifier)
                            .loadWorkoutsForDate(selectedDate.value),
                      )
                    : _buildWorkoutsList(context, progressState.workouts),
          ),
          _buildChallengeProgress(userChallenges),
          _buildProgressStats(context, ref),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    ValueNotifier<DateTime> selectedDate,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.p16),
      child: DateSelector(
        selectedDate: selectedDate.value,
        daysToShow: 14,
        onDateSelected: (date) {
          selectedDate.value = date;
          ref.read(progressViewModelProvider.notifier).loadWorkoutsForDate(date);
        },
      ),
    );
  }

  Widget _buildWorkoutsList(BuildContext context, List<Workout> workouts) {
    debugPrint('ProgressDayScreen: Construindo lista de treinos com ${workouts.length} itens');
    if (workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum treino neste dia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente selecionar outro dia ou registrar um treino',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    
    final dateFormat = DateFormat.yMMMMd();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppPadding.p16),
            child: Text(
              'Treinos realizados (${workouts.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return WorkoutItem(
                  workout: workout,
                  onTap: () {
                    final id = workout.id;
                    if (id != null && id.isNotEmpty) {
                      context.router.push(WorkoutDetailRoute(workoutId: id));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget para exibir estatísticas de progresso
  Widget _buildProgressStats(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(progressViewModelProvider);
    final userProgress = progressState.userProgress;
    
    // Se não tiver dados de progresso, não mostrar o widget
    if (userProgress == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppPadding.p16,
        horizontal: AppPadding.p16,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seu progresso',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                'Total de treinos',
                '${userProgress.totalWorkouts}',
                Icons.fitness_center,
                Colors.blue.shade700,
              ),
              _buildStatCard(
                'Dias treinados',
                '${userProgress.daysTrainedThisMonth}',
                Icons.calendar_today,
                Colors.green.shade700,
              ),
              _buildStatCard(
                'Sequência',
                '${userProgress.currentStreak}',
                Icons.local_fire_department,
                Colors.orange.shade700,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildChallengeProgress(AsyncValue<List<ChallengeProgress>> challengesAsync) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Desafios em andamento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: challengesAsync.when(
              data: (challenges) {
                try {
                  debugPrint('ProgressDayScreen: Carregando ${challenges.length} desafios');
                  
                  if (challenges.isEmpty) {
                    return const Center(
                      child: Text(
                        'Você não está participando de nenhum desafio',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: challenges.length,
                    itemBuilder: (context, index) {
                      try {
                        final progress = challenges[index];
                        return Container(
                          width: 180,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                progress.challengeId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text('Pontos: ${progress.points}'),
                              Text('Posição: ${progress.position}'),
                              const Spacer(),
                              LinearProgressIndicator(
                                value: progress.completionPercentage / 100,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        debugPrint('Erro ao renderizar desafio: $e');
                        return const SizedBox.shrink();
                      }
                    },
                  );
                } catch (e) {
                  debugPrint('Erro ao processar desafios: $e');
                  return const Center(
                    child: Text(
                      'Erro ao carregar desafios',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) {
                debugPrint('Erro ao carregar desafios: $error');
                return const Center(
                  child: Text(
                    'Não foi possível carregar os desafios',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Método para sincronizar os dados de progresso do usuário
  void _syncUserProgressData(WidgetRef ref) async {
    try {
      // Verificar se o usuário está autenticado
      final authState = ref.read(authViewModelProvider);
      final user = authState.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );
      
      if (user == null) {
        debugPrint('ProgressDayScreen: Usuário não autenticado, sincronização cancelada');
        return;
      }
      
      // Mostrar indicador de sincronização
      ScaffoldMessenger.of(ref.context!).showSnackBar(
        const SnackBar(
          content: Text('Sincronizando dados de progresso...'),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Iniciar sincronização
      await ref.read(progressViewModelProvider.notifier).syncProgressFromWorkouts();
      
      debugPrint('ProgressDayScreen: Dados sincronizados com sucesso');
      
      // Mostrar mensagem de sucesso
      if (ref.context != null && ref.context!.mounted) {
        ScaffoldMessenger.of(ref.context!).showSnackBar(
          const SnackBar(
            content: Text('Dados sincronizados com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('ProgressDayScreen: Erro ao sincronizar dados: $e');
      
      // Mostrar mensagem de erro
      if (ref.context != null && ref.context!.mounted) {
        ScaffoldMessenger.of(ref.context!).showSnackBar(
          SnackBar(
            content: Text('Erro ao sincronizar: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
} 