import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../models/workout_record_with_user.dart';
import '../repositories/challenge_repository.dart';
import '../providers/challenge_providers.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../features/workout/widgets/workout_edit_modal.dart';
import '../../../features/workout/models/workout_record.dart';
import '../../../core/router/app_router.dart';
import '../../../features/home/widgets/register_exercise_sheet.dart';

/// A screen that displays all workouts for a specific user in a challenge
@RoutePage()
class UserChallengeWorkoutsScreen extends ConsumerStatefulWidget {
  final String challengeId;
  final String userId;
  final String userName;

  const UserChallengeWorkoutsScreen({
    @PathParam('challengeId') required this.challengeId,
    @QueryParam('userId') this.userId = '',
    @QueryParam('userName') this.userName = 'Usuário',
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<UserChallengeWorkoutsScreen> createState() => _UserChallengeWorkoutsScreenState();
}

class _UserChallengeWorkoutsScreenState extends ConsumerState<UserChallengeWorkoutsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<WorkoutRecordWithUser> _workouts = [];
  
  @override
  void initState() {
    super.initState();
    
    // Verificar se o userId é válido
    if (widget.userId.isEmpty) {
      debugPrint('❌ ERRO: userId vazio, não é possível carregar treinos específicos de usuário');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Não foi possível identificar o usuário selecionado.';
      });
    } else {
      _loadUserWorkouts();
    }
  }
  
  Future<void> _loadUserWorkouts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Adicionar logs de depuração
      debugPrint('🔍 UserChallengeWorkoutsScreen - Carregando treinos para:');
      debugPrint('🔍 challengeId: ${widget.challengeId}');
      debugPrint('🔍 userId: ${widget.userId}');
      debugPrint('🔍 userName: ${widget.userName}');
      
      // Get repository from provider
      final repository = ref.read(challengeRepositoryProvider);
      
      // Usar o método específico para buscar treinos de um usuário
      final workouts = await repository.getUserChallengeWorkoutRecords(
        widget.challengeId,
        widget.userId,
        limit: 100,
        useCache: false,  // Desabilitar cache para garantir dados atualizados
      );
      
      debugPrint('🔍 Treinos encontrados para este usuário: ${workouts.length}');
      
      if (workouts.isNotEmpty) {
        debugPrint('🔍 Primeiro treino: ${workouts.first.workoutName} (${workouts.first.id})');
        debugPrint('🔍 Data do primeiro treino: ${workouts.first.date}');
      }
      
      // Sort by date (newest first)
      workouts.sort((a, b) => b.date.compareTo(a.date));
      
      debugPrint('🔍 Antes do setState - _workouts.length: ${_workouts.length}');
      debugPrint('🔍 Antes do setState - workouts.length: ${workouts.length}');
      
      setState(() {
        _workouts = workouts;
        _isLoading = false;
        debugPrint('🔍 Dentro do setState - _workouts.length: ${_workouts.length}');
      });
      
      debugPrint('🔍 Após o setState - _workouts.length: ${_workouts.length}');
    } catch (e) {
      debugPrint('❌ Erro ao carregar treinos: $e');
      setState(() {
        _errorMessage = 'Erro ao carregar treinos: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.read(currentUserProvider)?.id;
    final isCurrentUser = currentUserId != null && currentUserId == widget.userId;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Treinos de ${widget.userName}',
          style: const TextStyle(
            fontFamily: 'StingerTrial',
            fontWeight: FontWeight.w200,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: _buildContent(),
      // Mostrar FAB apenas se o usuário visualizando é o próprio dono dos treinos
      floatingActionButton: isCurrentUser 
        ? FloatingActionButton.extended(
            onPressed: _showAddWorkoutModal,
            backgroundColor: AppColors.orange,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text(
              'Adicionar Treino',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
              ),
            ),
          )
        : null,
    );
  }
  
  Widget _buildContent() {
    debugPrint('🔍 _buildContent chamado - _isLoading: $_isLoading, _errorMessage: $_errorMessage, _workouts.length: ${_workouts.length}');
    
    if (_isLoading) {
      debugPrint('🔍 Mostrando loading indicator');
      return const Center(child: LoadingIndicator());
    }
    
    if (_errorMessage != null) {
      debugPrint('🔍 Mostrando erro: $_errorMessage');
      return EmptyState(
        message: _errorMessage!,
        icon: Icons.error_outline,
        actionLabel: 'Tentar novamente',
        onAction: _loadUserWorkouts,
      );
    }
    
    if (_workouts.isEmpty) {
      debugPrint('🔍 Lista de treinos vazia - mostrando empty state');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center_outlined,
                size: 72,
                color: AppColors.lightGray,
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.userName} ainda não registrou treinos neste desafio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Os treinos aparecerão aqui quando o usuário registrar atividades neste desafio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar para o ranking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Build list of workouts
    debugPrint('🔍 Construindo lista de treinos com ${_workouts.length} itens');
    return RefreshIndicator(
      onRefresh: _loadUserWorkouts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _workouts.length,
        itemBuilder: (context, index) {
          debugPrint('🔍 itemBuilder chamado para index $index');
          final workout = _workouts[index];
          debugPrint('🔍 Construindo card para treino: ${workout.workoutName}');
          return _buildWorkoutCard(workout);
        },
      ),
    );
  }
  
  Widget _buildWorkoutCard(WorkoutRecordWithUser workout) {
    debugPrint('🔍 _buildWorkoutCard chamado para treino: ${workout.workoutName} (ID: ${workout.id})');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currentUserId = ref.read(currentUserProvider)?.id;
    final isCurrentUserWorkout = currentUserId != null && currentUserId == workout.userId;
    
    return InkWell(
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF4D4D4D),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    // Mostrar botão de edição apenas para treinos do usuário atual
                    if (isCurrentUserWorkout)
                      IconButton(
                        onPressed: () => _showEditDeleteModal(workout),
                        icon: Icon(
                          Icons.edit,
                          color: AppColors.purple,
                          size: 20,
                        ),
                        tooltip: 'Editar ou excluir treino',
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
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
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFFCDA8F0),
                        ),
                      ),
                    ),
                  ],
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
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF386380),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today, size: 16, color: AppColors.darkGray),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(workout.date),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF386380),
                  ),
                ),
              ],
            ),
            if (workout.notes != null && workout.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                workout.notes!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
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
  
  /// Exibe o modal para editar ou excluir o treino
  void _showEditDeleteModal(WorkoutRecordWithUser workout) {
    // Converter o WorkoutRecordWithUser para WorkoutRecord para ser aceito pelo modal
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
    
    showWorkoutEditModal(
      context: context,
      workoutRecord: workoutRecord,
      onUpdateSuccess: () {
        // Recarregar a lista de treinos ao atualizar
        _loadUserWorkouts();
      },
      onDeleteSuccess: () {
        // Recarregar a lista de treinos ao excluir
        _loadUserWorkouts();
      },
      challengeId: widget.challengeId,
    );
  }
  
  /// Exibe o modal para adicionar um novo treino
  void _showAddWorkoutModal() {
    showRegisterExerciseSheet(
      context,
      challengeId: widget.challengeId,
    );
    // Recarregar a lista após o modal fechar (o RegisterExerciseSheet já faz o refresh automático)
    Future.delayed(const Duration(milliseconds: 500), () {
      _loadUserWorkouts();
    });
  }
} 