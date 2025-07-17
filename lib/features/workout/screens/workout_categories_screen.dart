// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/core/theme/app_theme.dart';
import 'package:ray_club_app/features/workout/models/workout_model.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/providers/workout_providers.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_view_model.dart';
import 'package:ray_club_app/shared/bottom_navigation_bar.dart';
import 'package:ray_club_app/features/workout/models/workout_category.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_categories_view_model.dart';

@RoutePage()
class WorkoutCategoriesScreen extends ConsumerWidget {
  const WorkoutCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(workoutCategoriesViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: 1),
      body: _buildBody(context, categoriesState, ref),
    );
  }

  Widget _buildBody(BuildContext context, WorkoutCategoriesState state, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state.errorMessage != null) {
      return Center(child: Text('Erro: ${state.errorMessage}'));
    }
    
    return _buildCategoriesContent(context, state.categories, ref);
  }

  Widget _buildCategoriesContent(BuildContext context, List<WorkoutCategory> categories, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        
        // Treino em destaque - sempre visível
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverToBoxAdapter(
            child: _buildFeaturedWorkout(context),
          ),
        ),
        
        // Todas as categorias - sem separação
        _buildAllCategoriesSection(context, categories, ref),
        
        // Espaço final
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Treinos',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
            fontFamily: 'Century',
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF8F9FA),
                Color(0xFFE9ECEF),
              ],
            ),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF333333)),
    );
  }

  Widget _buildFeaturedWorkout(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B73FF),
            Color(0xFF9B59B6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to featured workout
            context.router.push(const WorkoutListRoute());
          },
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(height: 8),
                Text(
                  'Treino do Dia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Exercícios especialmente selecionados para você hoje',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói a seção com todas as categorias
  /// 
  /// **Layout Atualizado:** Agora utiliza um grid 3x3 com formato circular
  /// para as categorias, seguindo o design de referência fornecido
  Widget _buildAllCategoriesSection(BuildContext context, List<WorkoutCategory> categories, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.fitness_center, size: 20, color: Color(0xFF6B73FF)),
                SizedBox(width: 8),
                Text(
                  'Categorias de Treino',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
                childAspectRatio: 0.85,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(context, category);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói o card de categoria com design circular
  /// 
  /// **Design Atualizado:** Cards agora são circulares com ícones centralizados,
  /// seguindo o padrão visual da imagem de referência fornecida
  Widget _buildCategoryCard(BuildContext context, WorkoutCategory category) {
    return Column(
      children: [
        // Container circular com a logo/ícone
        GestureDetector(
          onTap: () {
            // Navigate to category videos
            context.router.push(WorkoutVideosRoute(
              categoryId: category.id,
              categoryName: category.name,
            ));
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: _buildCategoryIcon(category.name),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Nome da categoria
        Text(
          category.name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _getCategoryVideosLabel(String categoryName) {
    // Para categorias de parceiros, mostrar "vídeos" ao invés de "exercícios"
    switch (categoryName.toLowerCase()) {
      case 'musculação':
      case 'bodybuilding':
      case 'pilates':
      case 'funcional':
      case 'functional':
      case 'corrida':
      case 'running':
      case 'fisioterapia':
      case 'physiotherapy':
        return 'vídeos';
      default:
        return 'exercícios';
    }
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'força':
      case 'strength':
        return const Color(0xFF4ECDC4);
      case 'flexibilidade':
      case 'flexibility':
        return const Color(0xFF45B7D1);
      case 'pilates':
        return const Color(0xFFDDA0DD);
      case 'musculação':
      case 'bodybuilding':
        return const Color(0xFF5C6BC0);
      case 'funcional':
      case 'functional':
        return const Color(0xFFFF7043);
      case 'corrida':
      case 'running':
        return const Color(0xFF26A69A);
      case 'fisioterapia':
      case 'physiotherapy':
        return const Color(0xFF78909C);
      case 'alongamento':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF6B73FF);
    }
  }

  /// Constrói o ícone da categoria, usando logos específicas para algumas categorias
  Widget _buildCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'pilates':
        return Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFDDA0DD),
          ),
          child: const Icon(
            Icons.spa,
            color: Colors.white,
            size: 28,
          ),
        );
      case 'funcional':
      case 'functional':
        return Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFF7043),
          ),
          child: const Icon(
            Icons.sports_martial_arts,
            color: Colors.white,
            size: 28,
          ),
        );
      case 'corrida':
      case 'running':
        return Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF26A69A),
          ),
          child: const Icon(
            Icons.directions_run_outlined,
            color: Colors.white,
            size: 28,
          ),
        );
      default:
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getCategoryColor(categoryName),
          ),
          child: Icon(
            _getCategoryIcon(categoryName),
            color: Colors.white,
            size: 28,
          ),
        );
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'força':
      case 'strength':
        return Icons.fitness_center;
      case 'flexibilidade':
      case 'flexibility':
        return Icons.accessibility_new;
      case 'pilates':
        return Icons.spa;
      case 'musculação':
      case 'bodybuilding':
        return Icons.sports_gymnastics;
      case 'funcional':
      case 'functional':
        return Icons.sports_martial_arts;
      case 'corrida':
      case 'running':
        return Icons.directions_run_outlined;
      case 'fisioterapia':
      case 'physiotherapy':
        return Icons.healing;
      case 'alongamento':
        return Icons.self_improvement;
      default:
        return Icons.sports_gymnastics;
    }
  }
} 