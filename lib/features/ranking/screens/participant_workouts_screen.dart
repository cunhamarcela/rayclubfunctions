import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../data/ranking_service.dart';
import '../data/participant_workout.dart';

@RoutePage()
class ParticipantWorkoutsScreen extends ConsumerStatefulWidget {
  final String participantId;
  final String participantName;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const ParticipantWorkoutsScreen({
    super.key,
    required this.participantId,
    required this.participantName,
    this.dateFrom,
    this.dateTo,
  });

  @override
  ConsumerState<ParticipantWorkoutsScreen> createState() => _ParticipantWorkoutsScreenState();
}

class _ParticipantWorkoutsScreenState extends ConsumerState<ParticipantWorkoutsScreen> {
  final ScrollController _controller = ScrollController();
  final RankingService _service = RankingService();
  
  List<ParticipantWorkout> _workouts = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 100; // Aumentado para mostrar todos os treinos
  
  // Valores reais das estatísticas (não limitados por paginação)
  int? _totalRealMinutes;
  int? _totalRealWorkouts;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200) {
      _loadMoreWorkouts();
    }
  }

  Future<void> _loadWorkouts() async {
    print('DEBUG: _loadWorkouts - participantId: ${widget.participantId}, name: ${widget.participantName}');
    print('DEBUG: Filtros - dateFrom: ${widget.dateFrom}, dateTo: ${widget.dateTo}');
    print('DEBUG: Data atual: ${DateTime.now()}');
    print('DEBUG: Data atual UTC: ${DateTime.now().toUtc()}');
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _currentPage = 0;
      _workouts.clear();
    });

    try {
      // Buscar estatísticas REAIS usando a mesma função do ranking
      print('DEBUG: Buscando estatísticas reais do ranking...');
      final stats = await _service.getParticipantCardioStats(
        participantId: widget.participantId,
        from: widget.dateFrom,
        to: widget.dateTo,
      );
      
      print('DEBUG: Chamando getParticipantCardioWorkouts...');
      final workouts = await _service.getParticipantCardioWorkouts(
        participantId: widget.participantId,
        from: widget.dateFrom,
        to: widget.dateTo,
        limit: null, // SEM LIMITE - carregar TODOS os treinos
        offset: 0,
      );
      
      print('DEBUG: Treinos retornados: ${workouts.length}');
      print('DEBUG: Stats reais - minutos: ${stats['totalMinutes']}, treinos: ${stats['totalWorkouts']}');

      setState(() {
        _workouts = workouts;
        _totalRealMinutes = stats['totalMinutes'];
        _totalRealWorkouts = stats['totalWorkouts'];
        _hasMore = false; // Não há mais paginação - todos os treinos carregados
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Erro ao carregar treinos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreWorkouts() async {
    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final newWorkouts = await _service.getParticipantCardioWorkouts(
        participantId: widget.participantId,
        from: widget.dateFrom,
        to: widget.dateTo,
        limit: _pageSize,
        offset: (_currentPage + 1) * _pageSize,
      );

      setState(() {
        _workouts.addAll(newWorkouts);
        _currentPage++;
        _hasMore = newWorkouts.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshWorkouts() async {
    await _loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.participantName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshWorkouts,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _workouts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.orange),
      );
    }

    if (_hasError && _workouts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Erro ao carregar treinos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Tente novamente mais tarde',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadWorkouts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_workouts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Nenhum treino encontrado',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.participantName} ainda não registrou treinos de cardio no desafio.',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      controller: _controller,
      slivers: [
        // Header com estatísticas
        SliverToBoxAdapter(
          child: _buildStatsCard(),
        ),
        
        // Lista de treinos
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == _workouts.length) {
                  return _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.orange),
                          ),
                        )
                      : const SizedBox.shrink();
                }
                
                final workout = _workouts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _WorkoutCard(workout: workout),
                );
              },
              childCount: _workouts.length + (_hasMore ? 1 : 0),
            ),
          ),
        ),
        
        // Extra space at bottom
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    // CORREÇÃO: Não calcular apenas com treinos carregados (limitados por paginação)
    // Em vez disso, usar os valores totais reais do ranking
    final totalMinutes = _totalRealMinutes ?? _workouts.fold<int>(0, (sum, workout) => sum + workout.durationMinutes);
    final totalWorkouts = _totalRealWorkouts ?? _workouts.length;
    final averageMinutes = totalWorkouts > 0 ? (totalMinutes / totalWorkouts).round() : 0;

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: AppColors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Estatísticas de Cardio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Total de Minutos',
                  value: totalMinutes.toString(),
                  icon: Icons.timer,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Treinos',
                  value: totalWorkouts.toString(),
                  icon: Icons.fitness_center,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Média/Treino',
                  value: '${averageMinutes}min',
                  icon: Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.orange,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final ParticipantWorkout workout;

  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: AppColors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.workoutName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workout.formattedDate,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    workout.durationFormatted,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.orange,
                    ),
                  ),
                ),
              ],
            ),
            if (workout.notes != null && workout.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.notes,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        workout.notes!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (workout.imageUrls != null && workout.imageUrls!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: workout.imageUrls!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(right: index < workout.imageUrls!.length - 1 ? 8 : 0),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(workout.imageUrls![index]),
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
    );
  }
}
