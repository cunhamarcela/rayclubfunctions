// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/workout_model.dart';
import '../viewmodels/workout_view_model.dart';
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/viewmodels/states/workout_state.dart';

@RoutePage()
class WorkoutDetailScreen extends ConsumerWidget {
  final String workoutId;

  const WorkoutDetailScreen({
    super.key,
    @PathParam('id') required this.workoutId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(workoutViewModelProvider);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: workoutState.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (workouts, filteredWorkouts, categories, filter) {
          // Usa os treinos filtrados se existirem, senão usa todos os treinos
          final workoutList = filteredWorkouts.isNotEmpty ? filteredWorkouts : workouts;
          
          // Find the specific workout by ID
          final workout = workoutList.firstWhere(
            (w) => w.id == workoutId,
            orElse: () => throw Exception('Workout not found: $workoutId'),
          );
          return _buildWorkoutDetail(context, workout);
        },
        selectedWorkout: (workout, workouts, filteredWorkouts, categories, filter) {
          // Se o treino selecionado é o que queremos, usa ele diretamente
          if (workout.id == workoutId) {
            return _buildWorkoutDetail(context, workout);
          }
          
          // Senão, procura na lista
          final workoutList = filteredWorkouts.isNotEmpty ? filteredWorkouts : workouts;
          final foundWorkout = workoutList.firstWhere(
            (w) => w.id == workoutId,
            orElse: () => throw Exception('Workout not found: $workoutId'),
          );
          return _buildWorkoutDetail(context, foundWorkout);
        },
        error: (message) => Center(child: Text('Erro: $message')),
      ),
    );
  }

  Widget _buildWorkoutDetail(BuildContext context, Workout workout) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, workout),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWorkoutInfo(context, workout),
                const SizedBox(height: 32),
                _buildWorkoutDescription(context, workout),
                const SizedBox(height: 32),
                _buildActionButtons(context, workout),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Workout workout) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Imagem de fundo
            workout.imageUrl != null
                ? Image.network(
                    workout.imageUrl!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
            
            // Gradiente para melhorar legibilidade
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            // Informações no AppBar
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoria
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      workout.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Título
                  Text(
                    workout.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Informações básicas
                  Row(
                    children: [
                      const Icon(
                        Icons.timer,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.durationMinutes} min',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Treino',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.only(left: 16, top: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            // Adicionar aos favoritos
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16, top: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.favorite_border,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutInfo(BuildContext context, Workout workout) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildInfoItem(
            icon: Icons.timer,
            label: 'Duração',
            value: '${workout.durationMinutes} min',
            color: Colors.blue,
          ),
          _buildInfoDivider(),
          _buildInfoItem(
            icon: Icons.fitness_center,
            label: 'Tipo',
            value: workout.type,
            color: Colors.green,
          ),
          _buildInfoDivider(),
          _buildInfoItem(
            icon: Icons.trending_up,
            label: 'Dificuldade',
            value: workout.difficulty,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildWorkoutDescription(BuildContext context, Workout workout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalhes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            workout.description,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Workout workout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Navegar para a tela de edição
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Excluir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Mostrar confirmação antes de excluir
                  _showDeleteConfirmationDialog(context, workout);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Workout workout) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Excluir Treino'),
          content: Text('Tem certeza que deseja excluir o treino "${workout.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fechar o diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Fechar o diálogo
                Navigator.of(dialogContext).pop();
                
                // Excluir o treino e navegar de volta
                // ref.read(workoutViewModelProvider.notifier).deleteWorkout(workout.id);
                Navigator.of(context).pop();
              },
              child: const Text('Excluir'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
} 
