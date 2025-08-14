import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/router/app_router.dart';
import '../models/workout_record.dart';
import '../viewmodels/workout_history_view_model.dart';
import '../providers/workout_providers.dart';
import '../widgets/workout_edit_modal.dart';
import '../../home/widgets/register_exercise_sheet.dart';
import '../../../core/providers/auth_provider.dart';

/// Tela para gerenciamento completo dos treinos do usuário
@RoutePage()
class UserWorkoutsManagementScreen extends ConsumerStatefulWidget {
  const UserWorkoutsManagementScreen({super.key});

  @override
  ConsumerState<UserWorkoutsManagementScreen> createState() => _UserWorkoutsManagementScreenState();
}

class _UserWorkoutsManagementScreenState extends ConsumerState<UserWorkoutsManagementScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Todos';
  final List<String> _filterOptions = ['Todos', 'Funcional', 'Musculação', 'Cardio', 'Yoga', 'Pilates'];

  @override
  void initState() {
    super.initState();
    // Carregar treinos quando a tela for criada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workoutHistoryViewModelProvider.notifier).loadWorkoutHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutHistoryViewModelProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Meus Treinos',
          style: AppTypography.headingMedium.copyWith(
            fontFamily: 'CenturyGothic',
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(workoutHistoryViewModelProvider.notifier).loadWorkoutHistory();
            },
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa e filtros
          _buildSearchAndFilter(),
          
          // Lista de treinos
          Expanded(
            child: _buildWorkoutsList(workoutState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showRegisterExerciseSheet(context);
        },
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        label: Text(
          'Adicionar Treino',
          style: AppTypography.button.copyWith(
            fontFamily: 'CenturyGothic',
            fontSize: 14,
          ),
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Campo de pesquisa
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Pesquisar treinos...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Filtros por tipo
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(filter),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppColors.purple.withOpacity(0.2),
                    checkmarkColor: AppColors.purple,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.purple : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutsList(WorkoutHistoryState workoutState) {
    return switch (workoutState) {
      WorkoutHistoryLoaded(:final allRecords) => () {
        final filteredRecords = _filterWorkouts(allRecords);
        
        if (filteredRecords.isEmpty) {
          return _buildEmptyState();
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            ref.read(workoutHistoryViewModelProvider.notifier).loadWorkoutHistory();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredRecords.length,
            itemBuilder: (context, index) {
              final workout = filteredRecords[index];
              return _buildWorkoutCard(workout);
            },
          ),
        );
      }(),
      WorkoutHistoryLoading() => const Center(child: LoadingIndicator()),
      WorkoutHistoryError(:final message) => _buildErrorView(message),
      WorkoutHistoryEmpty() => _buildEmptyState(),
    };
  }

  List<WorkoutRecord> _filterWorkouts(List<WorkoutRecord> records) {
    var filtered = records;
    
    // Filtro por tipo
    if (_selectedFilter != 'Todos') {
      filtered = filtered.where((record) => record.workoutType == _selectedFilter).toList();
    }
    
    // Filtro por pesquisa
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((record) {
        return record.workoutName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               record.workoutType.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // Ordenar por data (mais recente primeiro)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    
    return filtered;
  }

  Widget _buildWorkoutCard(WorkoutRecord workout) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currentUserId = ref.read(currentUserProvider)?.id;
    final isCurrentUserWorkout = currentUserId != null && currentUserId == workout.userId;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navegar para detalhes do treino
          context.pushRoute(WorkoutRecordDetailRoute(
            recordId: workout.id,
            workoutRecord: workout,
          ));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      workout.workoutName,
                      style: AppTypography.titleMedium.copyWith(
                        fontFamily: 'CenturyGothic',
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      // Botão de edição (apenas para treinos do próprio usuário)
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
                      // Chip do tipo de treino
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          workout.workoutType,
                          style: TextStyle(
                            fontFamily: 'CenturyGothic',
                            fontSize: 12,
                            color: AppColors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Informações do treino
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    '${workout.durationMinutes} min',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textLight,
                      fontFamily: 'CenturyGothic',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.calendar_today, size: 16, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(workout.date),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textLight,
                      fontFamily: 'CenturyGothic',
                    ),
                  ),
                ],
              ),
              
              // Notas (se houver)
              if (workout.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  workout.notes ?? '',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textDark,
                    fontFamily: 'CenturyGothic',
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Imagens (se houver)
              if (workout.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: workout.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(workout.imageUrls[index]),
                            fit: BoxFit.cover,
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
      ),
    );
  }

  void _showEditDeleteModal(WorkoutRecord workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkoutEditModal(
        workoutRecord: workout,
        onUpdateSuccess: () {
          // Invalidar providers para forçar atualização do calendário
          ref.invalidate(userWorkoutsProvider);
          // Recarregar a lista após edição
          ref.read(workoutHistoryViewModelProvider.notifier).loadWorkoutHistory();
        },
        onDeleteSuccess: () {
          // Invalidar providers para forçar atualização do calendário
          ref.invalidate(userWorkoutsProvider);
          // Recarregar a lista após exclusão
          ref.read(workoutHistoryViewModelProvider.notifier).loadWorkoutHistory();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty || _selectedFilter != 'Todos'
                  ? 'Nenhum treino encontrado'
                  : 'Nenhum treino registrado',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textDark,
                fontFamily: 'CenturyGothic',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedFilter != 'Todos'
                  ? 'Tente ajustar os filtros de pesquisa'
                  : 'Comece adicionando seu primeiro treino',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textLight,
                fontFamily: 'CenturyGothic',
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isEmpty && _selectedFilter == 'Todos') ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  showRegisterExerciseSheet(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Primeiro Treino'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Erro ao carregar treinos',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textDark,
                fontFamily: 'CenturyGothic',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textLight,
                fontFamily: 'CenturyGothic',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(workoutHistoryViewModelProvider.notifier).loadWorkoutHistory();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 