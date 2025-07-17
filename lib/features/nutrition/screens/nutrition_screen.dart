// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../shared/bottom_navigation_bar.dart';
import '../providers/recipe_providers.dart';
import '../models/recipe.dart';
import '../../../core/router/app_router.dart';
import '../../subscription/widgets/premium_feature_gate.dart';
import '../widgets/youtube_player_widget.dart';
import 'package:ray_club_app/features/workout/providers/workout_material_providers.dart';
import 'package:ray_club_app/models/material.dart' as app_material;
import 'package:ray_club_app/widgets/pdf_viewer_widget.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_text_styles.dart';
import '../widgets/recipe_filter_widget.dart';
import '../viewmodels/recipe_filter_view_model.dart';

/// Tela de nutrição que exibe receitas, vídeos e materiais
/// Otimizada para evitar overflow e melhorar responsividade
@RoutePage()
class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              leading: SafeArea(
                child: Container(
                  margin: const EdgeInsets.only(left: 16, top: 8),
                  child: Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.textDark,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                'Nutrição',
                style: AppTextStyles.title.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.background,
              surfaceTintColor: AppColors.background,
              pinned: false,
              floating: true,
              snap: true,
              elevation: 0,
              expandedHeight: 80.0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0), 
                child: const SizedBox.shrink(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
                child: _buildNutritionistPresentation(context),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                _buildTabBar(),
              ),
              pinned: true,
            ),
          ];
        },
        body: _buildTabContent(context, ref),
      ),
      bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: 3),
    );
  }
  
  /// Seção de apresentação da nutricionista otimizada para responsividade
  Widget _buildNutritionistPresentation(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Layout responsivo baseado na largura disponível
          if (constraints.maxWidth < 350) {
            return _buildCompactLayout(context);
          } else {
            return _buildStandardLayout(context);
          }
        },
      ),
    );
  }

  /// Layout compacto para telas pequenas
  Widget _buildCompactLayout(BuildContext context) {
    return Column(
      children: [
        // Foto e informações básicas
        Row(
          children: [
            _buildNutritionistAvatar(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conheça a',
                    style: AppTextStyles.smallText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Bruna Braga',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Nutricionista especialista\nem nutrição esportiva',
                    style: AppTextStyles.smallText.copyWith(
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Botão centralizado
        _buildPresentationButton(),
      ],
    );
  }

  /// Layout padrão para telas maiores
  Widget _buildStandardLayout(BuildContext context) {
    return Row(
      children: [
        // Foto da nutricionista
        _buildNutritionistAvatar(),
        const SizedBox(width: 16),
        
        // Informações da nutricionista
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Conheça a',
                style: AppTextStyles.smallText.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bruna Braga',
                style: AppTextStyles.cardTitle.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Nutricionista especialista\nem nutrição esportiva',
                style: AppTextStyles.smallText.copyWith(
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              _buildPresentationButton(),
            ],
          ),
        ),
        
        // Ícone de play
        const SizedBox(width: 12),
        _buildPlayIcon(),
      ],
    );
  }

  /// Avatar da nutricionista com tratamento de erro
  Widget _buildNutritionistAvatar() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
                     BoxShadow(
             color: Colors.black.withValues(alpha: 0.1),
             blurRadius: 8,
             offset: const Offset(0, 2),
           ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/profiles/bruna_braga.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
                         return Container(
               color: Colors.white.withValues(alpha: 0.2),
               child: Icon(
                 Icons.person,
                 color: Colors.white,
                 size: 32,
               ),
             );
          },
        ),
      ),
    );
  }

  /// Botão de apresentação responsivo
  Widget _buildPresentationButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _openNutritionistPresentation(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 2,
        ),
        icon: const Icon(Icons.play_arrow, size: 18),
        label: Text(
          'Assistir Apresentação',
          style: AppTextStyles.buttonTextSmall.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Ícone de play otimizado
  Widget _buildPlayIcon() {
    return GestureDetector(
      onTap: () => _openNutritionistPresentation(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
                         color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.play_circle_filled,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  void _openNutritionistPresentation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => YouTubePlayerWidget(
          videoId: 'thsBEiNW93M',
          autoPlay: false,
          showControls: true,
        ),
      ),
    );
  }

  /// TabBar otimizada com design system
  TabBar _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTextStyles.tabSelected,
      unselectedLabelStyle: AppTextStyles.tabUnselected,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 3,
        ),
        insets: const EdgeInsets.symmetric(horizontal: 40),
      ),
      indicatorPadding: EdgeInsets.zero,
      tabs: const [
        Tab(text: 'Receitas'),
        Tab(text: 'Vídeos'),
        Tab(text: 'Materiais'),
      ],
    );
  }

  Widget _buildTabContent(BuildContext context, WidgetRef ref) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildRecipesTab(context, ref),
        _buildVideosTab(context, ref),
        _buildMaterialsTab(context, ref),
      ],
    );
  }

  Widget _buildRecipesTab(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(nutritionistRecipesProvider);
    final filteredRecipes = ref.watch(filteredRecipesProvider);
    
    return recipesAsync.when(
      data: (allRecipes) => ProgressGate(
        featureKey: 'nutrition_guide',
        progressTitle: 'Receitas da Bruna Braga ✨',
        progressDescription: 'Evolua no app para desbloquear receitas especiais desenvolvidas por nossa nutricionista especialista.',
        child: Column(
          children: [
            // Widget de filtros compacto
            const CompactFilterDisplay(),
            
            // Lista de receitas filtradas
            Expanded(
              child: _buildRecipeList(
                context, 
                filteredRecipes.where((recipe) => recipe.contentType == RecipeContentType.text).toList()
              ),
            ),
          ],
        ),
      ),
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Carregando receitas da Bruna Braga...',
              style: AppTextStyles.smallText.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      error: (error, _) => _buildErrorState(error, () {
        ref.refresh(nutritionistRecipesProvider);
      }),
    );
  }

  Widget _buildVideosTab(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(nutritionistRecipesProvider);
    
    return recipesAsync.when(
      data: (recipes) => ProgressGate(
        featureKey: 'nutrition_guide',
        progressTitle: 'Vídeos de Nutrição 🎥',
        progressDescription: 'Continue sua jornada para desbloquear vídeos exclusivos sobre nutrição.',
        child: _buildRecipeList(context, recipes.where((recipe) => recipe.contentType == RecipeContentType.video).toList()),
      ),
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Carregando vídeos...',
              style: AppTextStyles.smallText.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      error: (error, _) => _buildErrorState(error, () {
        ref.refresh(nutritionistRecipesProvider);
      }),
    );
  }

  Widget _buildMaterialsTab(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(nutritionMaterialsProvider);

    return materialsAsync.when(
      data: (materials) => materials.isNotEmpty
          ? _buildMaterialsList(context, materials)
          : _buildEmptyMaterialsState(),
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Carregando materiais...',
              style: AppTextStyles.smallText.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      error: (error, _) => _buildErrorState(error, () {
        ref.refresh(nutritionMaterialsProvider);
      }),
    );
  }

  Widget _buildMaterialsList(BuildContext context, List<app_material.Material> materials) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final material = materials[index];
        return _buildMaterialCard(context, material);
      },
    );
  }

  Widget _buildMaterialCard(BuildContext context, app_material.Material material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
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
            Text(
              material.title,
              style: AppTextStyles.cardTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              material.description,
              style: AppTextStyles.cardSubtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Botão de visualizar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openPdfViewer(context, material),
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('Visualizar PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMaterialsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Materiais em breve! ✨',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'PDFs, ebooks e guias nutricionais\nserão disponibilizados aqui.',
              style: AppTextStyles.smallText.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openPdfViewer(BuildContext context, app_material.Material material) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerWidget(
          material: material,
          title: material.title,
        ),
      ),
    );
  }

  Widget _buildRecipeList(BuildContext context, List<Recipe> recipes) {
    if (recipes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Nenhuma receita disponível',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Novas receitas saudáveis\nserão adicionadas em breve!',
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _buildRecipeCard(context, recipe);
      },
    );
  }

  /// Card de receita otimizado para responsividade e tratamento de imagens
  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.router.push(RecipeDetailRoute(recipeId: recipe.id));
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Layout responsivo baseado na largura disponível
              if (constraints.maxWidth < 400) {
                return _buildCompactRecipeCard(recipe);
              } else {
                return _buildStandardRecipeCard(recipe);
              }
            },
          ),
        ),
      ),
    );
  }

  /// Layout compacto do card para telas pequenas
  Widget _buildCompactRecipeCard(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com ícone e título
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecipeIconBadge(recipe),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecipeTitle(recipe),
                    const SizedBox(height: 4),
                    _buildRecipeDescription(recipe),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecipeInfo(recipe),
        ],
      ),
    );
  }

  /// Layout padrão do card para telas maiores  
  Widget _buildStandardRecipeCard(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com ícone e título
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecipeIconBadge(recipe),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecipeTitle(recipe),
                    const SizedBox(height: 4),
                    _buildRecipeDescription(recipe),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecipeInfo(recipe),
        ],
      ),
    );
  }

  /// Determina ícone e cor baseado no tipo de receita
  Map<String, dynamic> _getRecipeIconData(Recipe recipe) {
    final title = recipe.title.toLowerCase();
    
    // Mapeamento de ícones por tipo de receita
    if (title.contains('panqueca') || title.contains('pancake')) {
      return {'icon': Icons.breakfast_dining, 'color': AppColors.pastelYellow, 'bgColor': AppColors.pastelYellow.withValues(alpha: 0.15)};
    } else if (title.contains('omelete') || title.contains('ovo')) {
      return {'icon': Icons.egg, 'color': AppColors.pastelYellow, 'bgColor': AppColors.pastelYellow.withValues(alpha: 0.15)};
    } else if (title.contains('pão') || title.contains('toast') || title.contains('torrada')) {
      return {'icon': Icons.bakery_dining, 'color': AppColors.orange, 'bgColor': AppColors.primaryLight};
    } else if (title.contains('cacau') || title.contains('chocolate') || title.contains('bolo')) {
      return {'icon': Icons.cake, 'color': AppColors.orange, 'bgColor': AppColors.primaryLight};
    } else if (title.contains('atum') || title.contains('peixe') || title.contains('salmão')) {
      return {'icon': Icons.set_meal, 'color': AppColors.purple, 'bgColor': AppColors.purple.withValues(alpha: 0.15)};
    } else if (title.contains('patê') || title.contains('pasta')) {
      return {'icon': Icons.lunch_dining, 'color': AppColors.softPink, 'bgColor': AppColors.softPink.withValues(alpha: 0.15)};
    } else if (title.contains('salada') || title.contains('verde')) {
      return {'icon': Icons.eco, 'color': AppColors.purple, 'bgColor': AppColors.purple.withValues(alpha: 0.15)};
    } else if (title.contains('smoothie') || title.contains('suco') || title.contains('vitamina')) {
      return {'icon': Icons.local_drink, 'color': AppColors.purple, 'bgColor': AppColors.purple.withValues(alpha: 0.15)};
    } else if (title.contains('fruta') || title.contains('banana') || title.contains('maçã')) {
      return {'icon': Icons.local_dining, 'color': AppColors.pastelYellow, 'bgColor': AppColors.pastelYellow.withValues(alpha: 0.15)};
    } else {
      return {'icon': Icons.restaurant_menu, 'color': AppColors.primary, 'bgColor': AppColors.primaryLight};
    }
  }

  /// Badge com ícone pequeno e discreto da receita
  Widget _buildRecipeIconBadge(Recipe recipe) {
    final iconData = _getRecipeIconData(recipe);
    
    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconData['bgColor'] as Color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (iconData['color'] as Color).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            iconData['icon'] as IconData,
            size: 24,
            color: iconData['color'] as Color,
          ),
        ),
        
        // Indicador de vídeo pequeno
        if (recipe.contentType == RecipeContentType.video)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
      ],
    );
  }

  /// Título da receita com destaque
  Widget _buildRecipeTitle(Recipe recipe) {
    return Text(
      recipe.title,
      style: AppTextStyles.cardTitle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Descrição da receita
  Widget _buildRecipeDescription(Recipe recipe) {
    return Text(
      recipe.description,
      style: AppTextStyles.cardSubtitle.copyWith(
        fontSize: 14,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Informações da receita (tempo e dificuldade)
  Widget _buildRecipeInfo(Recipe recipe) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '${recipe.preparationTimeMinutes}min',
          style: AppTextStyles.chipText.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.restaurant_menu,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            recipe.difficulty,
            style: AppTextStyles.chipText.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
                             decoration: BoxDecoration(
                 color: AppColors.error.withValues(alpha: 0.1),
                 shape: BoxShape.circle,
               ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ops, algo não saiu como esperado 😔',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Vamos tentar de novo?',
              style: AppTextStyles.smallText.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
} 

/// Delegate para o SliverPersistentHeader otimizado
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: overlapsContent ? [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
} 
