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
      backgroundColor: const Color(0xFFF8F1E7), // Fundo bege claro
      bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: 1),
      body: _buildBody(context, categoriesState, ref),
    );
  }

  Widget _buildBody(BuildContext context, WorkoutCategoriesState state, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF38638)), // Laranja
        ),
      );
    }
    
    if (state.errorMessage != null) {
      return Center(
        child: Text(
          'Erro: ${state.errorMessage}',
          style: const TextStyle(
            color: Color(0xFF4D4D4D), // Cinza escuro para contraste
            fontSize: 16,
          ),
        ),
      );
    }
    
    return _buildCategoriesContent(context, state.categories, ref);
  }

  Widget _buildCategoriesContent(BuildContext context, List<WorkoutCategory> categories, WidgetRef ref) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          
          // Seção de boas-vindas com visual melhorado
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            sliver: SliverToBoxAdapter(
              child: _buildWelcomeSection(),
            ),
          ),
          
          // Todas as categorias - com visual melhorado
          _buildAllCategoriesSection(context, categories, ref),
          
          // Espaço final para evitar overflow com bottom navigation
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFF8F1E7),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Treinos',
          style: TextStyle(
            color: Color(0xFF4D4D4D), // Cinza escuro para contraste
            fontWeight: FontWeight.w500, // Removido mais negrito
            fontFamily: 'Century',
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F1E7), // Apenas cor sólida bege, sem gradiente amarelo
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF4D4D4D)),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFCDA8F0), // Roxo claro
            Color(0xFFEFB9B7), // Rosa claro
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4D4D4D).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Color(0xFF4D4D4D),
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Vamos treinar juntos! ✨',
            style: TextStyle(
              color: Color(0xFF4D4D4D), // Cinza escuro para contraste
              fontSize: 20,
              fontWeight: FontWeight.w500, // Reduzido mais ainda
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Escolha sua categoria favorita e comece agora mesmo',
            style: TextStyle(
              color: Color(0xFF4D4D4D), // Cinza escuro para contraste
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a seção com todas as categorias
  /// 
  /// **Layout Atualizado:** Agora utiliza um grid 3x3 com formato circular
  /// para as categorias, seguindo o design de referência fornecido
  Widget _buildAllCategoriesSection(BuildContext context, List<WorkoutCategory> categories, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4D4D4D).withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF38638).withOpacity(0.1), // Laranja claro
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.apps,
                      size: 18,
                      color: Color(0xFFF38638), // Laranja
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Categorias de Treino',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500, // Removido negrito
                      color: Color(0xFF4D4D4D), // Cinza escuro
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 18,
                childAspectRatio: 1.0,
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
      mainAxisAlignment: MainAxisAlignment.center,
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
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4D4D4D).withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 6,
                  offset: const Offset(0, -1),
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
            fontWeight: FontWeight.w400, // Peso normal
            color: Color(0xFF4D4D4D), // Cinza escuro
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
        return const Color(0xFFF38638); // Laranja
      case 'flexibilidade':
      case 'flexibility':
        return const Color(0xFFCDA8F0); // Roxo claro
      case 'pilates':
        return const Color(0xFFEFB9B7); // Rosa claro
      case 'musculação':
      case 'bodybuilding':
        return const Color(0xFFEE583F); // Vermelho
      case 'funcional':
      case 'functional':
        return const Color(0xFFF38638); // Laranja
      case 'corrida':
      case 'running':
        return const Color(0xFFFEDC94); // Amarelo claro
      case 'fisioterapia':
      case 'physiotherapy':
        return const Color(0xFFCDA8F0); // Roxo claro
      case 'alongamento':
        return const Color(0xFFEFB9B7); // Rosa claro
      default:
        return const Color(0xFFF38638); // Laranja
    }
  }

  /// Constrói o ícone da categoria, usando logos específicas para algumas categorias
  Widget _buildCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'pilates':
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEFB9B7), // Rosa claro
                Color(0xFFCDA8F0), // Roxo claro
              ],
            ),
          ),
          child: const Icon(
            Icons.spa,
            color: Colors.white,
            size: 26,
          ),
        );
      case 'funcional':
      case 'functional':
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF38638), // Laranja
                Color(0xFFEE583F), // Vermelho
              ],
            ),
          ),
          child: const Icon(
            Icons.sports_martial_arts,
            color: Colors.white,
            size: 26,
          ),
        );
      case 'corrida':
      case 'running':
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFEDC94), // Amarelo claro
                Color(0xFFF38638), // Laranja
              ],
            ),
          ),
          child: const Icon(
            Icons.directions_run_outlined,
            color: Colors.white,
            size: 26,
          ),
        );
      default:
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getCategoryColor(categoryName),
                _getCategoryColor(categoryName).withOpacity(0.8),
              ],
            ),
          ),
          child: Icon(
            _getCategoryIcon(categoryName),
            color: Colors.white,
            size: 26,
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