// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
import 'package:ray_club_app/core/services/expert_video_guard.dart';
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

  /// ✨ URLs de fallback estáveis e testadas para diferentes tipos de receitas
  static const Map<String, List<String>> RECIPE_FALLBACK_URLS = {
    'sufle': [
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop&q=80',
      'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=300&fit=crop&q=80',
    ],
    'waffle': [
      'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop&q=80',
      'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&h=300&fit=crop&q=80',
    ],
    'torta': [
      'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&h=300&fit=crop&q=80',
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=300&fit=crop&q=80',
    ],
    'bolo': [
      'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&h=300&fit=crop&q=80',
      'https://images.unsplash.com/photo-1464349095431-e9a21285b5f3?w=400&h=300&fit=crop&q=80',
    ],
    'salada': [
      'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=300&fit=crop&q=80',
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop&q=80',
    ],
    'smoothie': [
      'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=400&h=300&fit=crop&q=80',
      'https://images.unsplash.com/photo-1570197788417-0e82375c9371?w=400&h=300&fit=crop&q=80',
    ],
    'pao': [
      'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=300&fit=crop&q=80',
      'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop&q=80',
    ],
    'geral': [
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=300&fit=crop&q=80',
      'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=300&fit=crop&q=80',
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop&q=80',
    ],
  };

  /// ✨ Cache manager customizado para imagens de receitas
  static final CacheManager _recipeImageCacheManager = CacheManager(
    Config(
      'recipe_images',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: 'recipe_images'),
      fileService: HttpFileService(),
    ),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // ✨ Limpar cache de imagens se necessário (apenas em debug)
    _clearImageCacheIfNeeded();
  }

  /// ✨ NOVO: Método para limpar cache de imagens em situações específicas
  Future<void> _clearImageCacheIfNeeded() async {
    try {
      // Só limpa o cache em modo debug para não afetar performance em produção
      assert(() {
        print('🧹 [Cache] Limpando cache de imagens em modo debug...');
        _recipeImageCacheManager.emptyCache();
        return true;
      }());
    } catch (e) {
      print('⚠️ [Cache] Erro ao limpar cache: $e');
    }
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
    final recipesAsync = ref.watch(nutritionistRecipesWithFavoritesProvider);
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
    final recipesAsync = ref.watch(nutritionistRecipesWithFavoritesProvider);
    
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
    final isVideo = material.materialType == app_material.MaterialType.video;
    
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
            // Header com ícone do tipo de material
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isVideo ? Colors.red.withValues(alpha: 0.1) : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isVideo ? Icons.play_arrow : Icons.picture_as_pdf,
                    color: isVideo ? Colors.red : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    material.title,
                    style: AppTextStyles.cardTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Text(
              material.description,
              style: AppTextStyles.cardSubtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Mostrar duração do vídeo se disponível
            if (isVideo && material.videoDuration != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${material.videoDuration! ~/ 60}:${(material.videoDuration! % 60).toString().padLeft(2, '0')} min',
                    style: AppTextStyles.chipText.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 16),

            // Botão de visualizar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => isVideo 
                    ? _openVideoPlayer(context, material)
                    : _openPdfViewer(context, material),
                icon: Icon(
                  isVideo ? Icons.play_arrow : Icons.visibility, 
                  size: 18
                ),
                label: Text(isVideo ? 'Assistir Vídeo' : 'Visualizar PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isVideo ? Colors.red : AppColors.primary,
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
              'PDFs, vídeos educativos e guias nutricionais\nserão disponibilizados aqui.',
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
    // ✅ PROTEÇÃO EXPERT: Usar ExpertVideoGuard para PDFs
    ExpertVideoGuard.openProtectedPdf(context, ref, material);
  }

  void _openVideoPlayer(BuildContext context, app_material.Material material) {
    if (material.videoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ ID do vídeo não disponível'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header do modal
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        material.title,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Player do YouTube
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: YouTubePlayerWidget(
                    videoId: material.videoId!,
                    autoPlay: false,
                    showControls: true,
                  ),
                ),
              ),
            ],
          ),
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
    return Row(
      children: [
        // ✨ NOVA: Imagem da receita à esquerda
        _buildRecipeImage(recipe, width: 80, height: 80),
        
        // Conteúdo à direita
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com título e badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(width: 8),
                    _buildContentTypeBadge(recipe),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRecipeInfo(recipe),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Layout padrão do card para telas maiores  
  Widget _buildStandardRecipeCard(Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✨ NOVA: Imagem no topo
        _buildRecipeImage(recipe, height: 180),
        
        // Conteúdo abaixo da imagem
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com título e badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(width: 8),
                  _buildContentTypeBadge(recipe),
                ],
              ),
              const SizedBox(height: 16),
              _buildRecipeInfo(recipe),
            ],
          ),
        ),
      ],
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

  /// ✨ MELHORADO: Widget de imagem da receita com sistema robusto de fallbacks
  Widget _buildRecipeImage(Recipe recipe, {double? width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          width != null ? 12 : 0, // Bordas arredondadas apenas para thumbnails laterais
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ✨ Sistema robusto de carregamento com múltiplos fallbacks
          _buildImageWithFallbacks(recipe, width),
          
          // Badge de rating no canto superior direito (apenas para imagens grandes)
          if (width == null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      recipe.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ✨ NOVO: Sistema de carregamento com múltiplos fallbacks automáticos
  Widget _buildImageWithFallbacks(Recipe recipe, double? width) {
    final primaryUrl = recipe.imageUrl;
    final fallbackUrls = _getFallbackUrls(recipe);
    
    print('🖼️ [Imagem] Carregando imagem para "${recipe.title}"');
    print('🔗 [Imagem] URL principal: $primaryUrl');
    print('🔄 [Imagem] ${fallbackUrls.length} URLs de fallback disponíveis');
    
    return _tryLoadImage(
      urls: [primaryUrl, ...fallbackUrls],
      currentIndex: 0,
      recipe: recipe,
      width: width,
    );
  }

  /// ✨ NOVO: Tentativa de carregamento com fallbacks automáticos
  Widget _tryLoadImage({
    required List<String> urls,
    required int currentIndex,
    required Recipe recipe,
    required double? width,
  }) {
    if (currentIndex >= urls.length) {
      print('❌ [Imagem] Todas as URLs falharam para "${recipe.title}", usando fallback visual');
      return _buildImageFallback(recipe, width);
    }
    
    final currentUrl = urls[currentIndex];
    print('🔄 [Imagem] Tentativa ${currentIndex + 1}/${urls.length}: $currentUrl');
    
    return CachedNetworkImage(
      imageUrl: currentUrl,
      fit: BoxFit.cover,
      // ✨ Cache manager customizado
      cacheManager: _recipeImageCacheManager,
      placeholder: (context, url) => Container(
        color: AppColors.primaryLight,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        print('❌ [Imagem] Erro na tentativa ${currentIndex + 1}: $error');
        
        // Tentar próxima URL automaticamente
        return _tryLoadImage(
          urls: urls,
          currentIndex: currentIndex + 1,
          recipe: recipe,
          width: width,
        );
      },
    );
  }

  /// ✨ NOVO: Obter URLs de fallback baseadas no tipo de receita
  List<String> _getFallbackUrls(Recipe recipe) {
    final title = recipe.title.toLowerCase();
    
    if (title.contains('suflê') || title.contains('sufle')) {
      return RECIPE_FALLBACK_URLS['sufle']!;
    } else if (title.contains('waffle')) {
      return RECIPE_FALLBACK_URLS['waffle']!;
    } else if (title.contains('torta')) {
      return RECIPE_FALLBACK_URLS['torta']!;
    } else if (title.contains('bolo') || title.contains('cake')) {
      return RECIPE_FALLBACK_URLS['bolo']!;
    } else if (title.contains('salada') || title.contains('verde')) {
      return RECIPE_FALLBACK_URLS['salada']!;
    } else if (title.contains('smoothie') || title.contains('suco') || title.contains('vitamina')) {
      return RECIPE_FALLBACK_URLS['smoothie']!;
    } else if (title.contains('pão') || title.contains('toast') || title.contains('torrada')) {
      return RECIPE_FALLBACK_URLS['pao']!;
    } else {
      return RECIPE_FALLBACK_URLS['geral']!;
    }
  }

  /// ✨ NOVA: Fallback quando a imagem não carrega
  Widget _buildImageFallback(Recipe recipe, double? width) {
    final iconData = _getRecipeIconData(recipe);
    
    return Container(
      color: iconData['bgColor'] as Color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData['icon'] as IconData,
            size: width != null ? 32 : 48,
            color: iconData['color'] as Color,
          ),
          if (width == null) ...[
            const SizedBox(height: 8),
            Text(
              'Imagem não disponível',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// ✨ NOVA: Badge do tipo de conteúdo (vídeo/receita)
  Widget _buildContentTypeBadge(Recipe recipe) {
    final isVideo = recipe.contentType == RecipeContentType.video;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isVideo 
            ? Colors.red.withOpacity(0.1)
            : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVideo 
              ? Colors.red.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVideo ? Icons.play_circle_filled : Icons.description,
            color: isVideo ? Colors.red : AppColors.primary,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            isVideo ? 'Vídeo' : 'Receita',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isVideo ? Colors.red : AppColors.primary,
            ),
          ),
        ],
      ),
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

  /// ✨ MODIFICADO: Informações da receita mais completas
  Widget _buildRecipeInfo(Recipe recipe) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildCompactInfo(Icons.access_time, '${recipe.preparationTimeMinutes}min'),
        _buildCompactInfo(Icons.local_fire_department, '${recipe.calories}kcal'),
        _buildCompactInfo(Icons.people, '${recipe.servings}p'),
        _buildDifficultyChip(recipe.difficulty),
      ],
    );
  }

  /// ✨ NOVA: Item de informação compacto
  Widget _buildCompactInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// ✨ NOVA: Badge de dificuldade com cores
  Widget _buildDifficultyChip(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'fácil':
        color = Colors.green;
        break;
      case 'médio':
        color = Colors.orange;
        break;
      case 'difícil':
        color = Colors.red;
        break;
      default:
        color = AppColors.primary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
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
