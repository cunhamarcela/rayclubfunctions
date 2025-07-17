// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/components/app_error_widget.dart';
import 'package:ray_club_app/core/components/app_loading.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_typography.dart';
import 'package:ray_club_app/features/workout/models/workout_model.dart';
import 'package:ray_club_app/features/workout/screens/workout_detail_screen.dart';
import 'package:ray_club_app/features/workout/viewmodels/states/workout_state.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_view_model.dart';
import 'package:ray_club_app/features/workout/widgets/workout_card.dart';
import 'package:ray_club_app/shared/bottom_navigation_bar.dart';

@RoutePage()
class WorkoutListScreen extends ConsumerWidget {
  const WorkoutListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(workoutViewModelProvider);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Treinos', style: AppTypography.headingMedium),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Navegar para o histórico/calendário de treinos
              context.router.pushNamed('/workout-history');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(workoutViewModelProvider.notifier).loadWorkouts();
            },
          ),
        ],
      ),
      body: _buildBody(context, workoutState, ref),
      bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/workout/new');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WorkoutState state, WidgetRef ref) {
    return state.maybeWhen(
      initial: () => const AppLoading(),
      loading: () => const AppLoading(),
      error: (message) => AppErrorWidget(
        message: message,
        onRetry: () => ref.read(workoutViewModelProvider.notifier).loadWorkouts(),
      ),
      orElse: () => _buildContent(context, state, ref),
    );
  }

  Widget _buildContent(BuildContext context, WorkoutState state, WidgetRef ref) {
    final workouts = state.currentWorkouts;
    
    if (workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fitness_center,
              size: 64,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum treino encontrado',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.white),
            ),
          ],
        ),
      );
    }

    // Lista simples de treinos sem filtros - organizados por data no repositório
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final workout = workouts[index];
          return WorkoutCard(
            workout: workout,
            onTap: () => _navigateToDetail(context, workout, ref),
          );
        },
      ),
    );
  }

  void _navigateToDetail(
    BuildContext context,
    Workout workout,
    WidgetRef ref,
  ) {
    ref.read(workoutViewModelProvider.notifier).selectWorkout(workout);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutDetailScreen(workoutId: workout.id),
      ),
    );
  }
} 
