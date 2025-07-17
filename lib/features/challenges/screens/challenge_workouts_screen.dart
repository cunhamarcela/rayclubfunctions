import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/router/app_router.dart';
import '../../../features/workout/models/workout_record.dart';
import '../models/workout_record_with_user.dart';
import '../viewmodels/challenge_workouts_view_model.dart';

@RoutePage()
class ChallengeWorkoutsScreen extends ConsumerStatefulWidget {
  final String challengeId;

  const ChallengeWorkoutsScreen({
    @PathParam('challengeId') required this.challengeId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ChallengeWorkoutsScreen> createState() => _ChallengeWorkoutsScreenState();
}

class _ChallengeWorkoutsScreenState extends ConsumerState<ChallengeWorkoutsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Load workout records when the screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(challengeWorkoutsViewModelProvider.notifier)
        .loadChallengeWorkouts(widget.challengeId);
    });
    
    // Add scroll listener for infinite pagination
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  // Handle scroll events for pagination
  void _onScroll() {
    if (_isBottomOfList) {
      _loadMoreData();
    }
  }
  
  // Check if we've scrolled to the bottom of the list
  bool get _isBottomOfList {
    if (!_scrollController.hasClients) return false;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    const loadMoreThreshold = 200.0; // Start loading more when within 200px of bottom
    
    return currentScroll >= (maxScroll - loadMoreThreshold);
  }
  
  // Load more data when reaching the bottom
  void _loadMoreData() {
    final state = ref.read(challengeWorkoutsViewModelProvider);
    
    if (!state.isLoading && !state.isLoadingMore && state.hasMoreRecords) {
      ref.read(challengeWorkoutsViewModelProvider.notifier)
        .loadMoreWorkouts(widget.challengeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeWorkoutsViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Treinos do Desafio',
          style: TextStyle(
            fontFamily: 'Century Gothic',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: _buildContent(state),
    );
  }
  
  Widget _buildContent(ChallengeWorkoutsState state) {
    if (state.isLoading && state.workoutRecords.isEmpty) {
      return const Center(child: LoadingIndicator());
    }
    
    if (state.errorMessage != null && state.workoutRecords.isEmpty) {
      return EmptyState(
        message: state.errorMessage!,
        icon: Icons.error_outline,
        actionLabel: 'Tentar novamente',
        onAction: () => ref.read(challengeWorkoutsViewModelProvider.notifier)
          .refreshWorkouts(widget.challengeId),
      );
    }
    
    if (state.workoutRecords.isEmpty) {
      return const EmptyState(
        message: 'Nenhum treino registrado neste desafio ainda',
        icon: Icons.fitness_center,
      );
    }
    
    // Build a list of workouts grouped by user with pull-to-refresh
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(challengeWorkoutsViewModelProvider.notifier)
          .refreshWorkouts(widget.challengeId);
      },
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.workoutsByUser.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom when loading more items
              if (index == state.workoutsByUser.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              // Get the user ID and workout list for this index
              final userId = state.workoutsByUser.keys.elementAt(index);
              final userWorkouts = state.workoutsByUser[userId] ?? [];
              
              // Skip if user has no workouts
              if (userWorkouts.isEmpty) {
                return const SizedBox.shrink();
              }
              
              // Get the user's name and photo from the first workout
              final user = userWorkouts.first;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserHeader(user, workoutsCount: userWorkouts.length),
                  const SizedBox(height: 8),
                  ...userWorkouts.map((workout) => _buildWorkoutCard(workout)).toList(),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
          // Show cached data indicator if needed
          if (state.isCached && !state.isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: AppColors.pastelYellow,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: const Center(
                  child: Text(
                    'Mostrando dados em cache. Puxe para atualizar.',
                    style: TextStyle(
                      fontFamily: 'Century Gothic',
                      fontSize: 12,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildUserHeader(WorkoutRecordWithUser user, {required int workoutsCount}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFFE6E6E6),
          backgroundImage: user.userPhotoUrl != null 
              ? NetworkImage(user.userPhotoUrl!) 
              : null,
          child: user.userPhotoUrl == null 
              ? const Icon(Icons.person, color: Color(0xFF4D4D4D)) 
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.userName,
                style: const TextStyle(
                  fontFamily: 'Century Gothic',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:  Color(0xFF4D4D4D),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$workoutsCount ${workoutsCount == 1 ? 'treino' : 'treinos'} registrados',
                style: const TextStyle(
                  fontFamily: 'Century Gothic',
                  fontSize: 12,
                  color:  Color(0xFF4D4D4D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildWorkoutCard(WorkoutRecordWithUser workout) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Converter WorkoutRecordWithUser para WorkoutRecord
          final workoutRecord = WorkoutRecord(
            id: workout.id,
            userId: workout.userId,
            workoutId: null,
            workoutName: workout.workoutName,
            workoutType: workout.workoutType,
            date: workout.date,
            durationMinutes: workout.durationMinutes,
            isCompleted: true,
            notes: workout.notes,
            challengeId: widget.challengeId,
            imageUrls: workout.imageUrls ?? [],
          );
          
          // Navegar para tela de detalhes
          context.pushRoute(WorkoutRecordDetailRoute(
            recordId: workout.id,
            workoutRecord: workoutRecord,
          ));
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    workout.workoutName,
                    style: const TextStyle(
                      fontFamily: 'Century Gothic',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:  Color(0xFF4D4D4D),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCDA8F0).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    workout.workoutType,
                    style: const TextStyle(
                      fontFamily: 'Century Gothic',
                      fontSize: 12,
                      color: Color(0xFFCDA8F0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: AppColors.darkGray),
                const SizedBox(width: 4),
                Text(
                  '${workout.durationMinutes} minutos',
                  style: const TextStyle(
                    fontFamily: 'Century Gothic',
                    fontSize: 14,
                    color: Color(0xFF38638),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today, size: 16, color: AppColors.darkGray),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(workout.date),
                  style: const TextStyle(
                    fontFamily: 'Century Gothic',
                    fontSize: 14,
                    color: Color(0xFF38638),
                  ),
                ),
              ],
            ),
            if (workout.notes != null && workout.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                workout.notes!,
                style: const TextStyle(
                  fontFamily: 'Century Gothic',
                  fontSize: 14,
                  color: Color(0xFFEE583F),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (workout.imageUrls != null && workout.imageUrls!.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: workout.imageUrls!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _showImageFullscreen(context, workout.imageUrls![index]),
                      child: Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(workout.imageUrls![index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Show image in full screen
  void _showImageFullscreen(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / 
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
} 