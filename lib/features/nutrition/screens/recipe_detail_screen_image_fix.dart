// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import '../../../core/providers/auth_provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_providers.dart';
import '../providers/recipe_favorites_providers.dart';
import '../widgets/youtube_player_widget.dart';

/// Tela de detalhes da receita que suporta conteúdo de texto e vídeo
/// VERSÃO CORRIGIDA: Inclui exibição da imagem da receita
@RoutePage()
class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;
  
  const RecipeDetailScreen({
    super.key,
    @PathParam('id') required this.recipeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeByIdProvider(recipeId));
    final currentUser = ref.watch(currentUserProvider);
    
    // Carregar favoritos do usuário quando a tela é inicializada
    ref.listen(currentUserProvider, (previous, next) {
      if (next != null) {
        ref.read(recipeFavoritesProvider.notifier).loadFavorites(next.id);
      }
    });
    
    return recipeAsync.when(
      data: (recipe) => _buildContent(context, ref, recipe),
      loading: () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar receita: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(recipeByIdProvider(recipeId)),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Recipe recipe) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ✨ NOVO: SliverAppBar com imagem da receita
          _buildImageHeader(context, recipe),
          
          // Conteúdo principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho da receita (sem imagem, pois está no header)
                  _buildRecipeHeader(recipe),
                  const SizedBox(height: 24),
                  
                  // Informações da receita
                  _buildRecipeInfo(recipe),
                  const SizedBox(height: 24),
                  
                  // Exibe conteúdo baseado no tipo
                  if (recipe.contentType == RecipeContentType.video && recipe.videoId != null)
                    _buildVideoContent(recipe)
                  else
                    _buildTextContent(recipe),
                ],
              ),
            ),
          ),
        ],
      ),
      // ✨ NOVO: Botão de favorito flutuante
      floatingActionButton: _buildFloatingFavoriteButton(context, ref, recipe),
    );
  }

  /// ✨ NOVO: Header com imagem da receita usando SliverAppBar
  Widget _buildImageHeader(BuildContext context, Recipe recipe) {
    return SliverAppBar(
      expandedHeight: 280.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Imagem da receita
            CachedNetworkImage(
              imageUrl: recipe.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: const Color(0xFFF5F5F5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCDA8F0)),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFFF5F5F5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 64,
                      color: const Color(0xFFCDA8F0).withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Imagem não\ndisponível',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF666666).withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
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
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            
            // Badge de conteúdo (vídeo/texto) no canto superior direito
            Positioned(
              top: 60,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: recipe.contentType == RecipeContentType.video 
                      ? Colors.red.withOpacity(0.9)
                      : const Color(0xFFCDA8F0).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      recipe.contentType == RecipeContentType.video 
                          ? Icons.play_circle_filled 
                          : Icons.description,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recipe.contentType == RecipeContentType.video ? 'Vídeo' : 'Receita',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✨ MODIFICADO: Header da receita sem imagem (já está no SliverAppBar)
  Widget _buildRecipeHeader(Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da receita
        Text(
          recipe.title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        
        // Rating
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    recipe.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Categoria
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFCDA8F0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                recipe.category,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7B5CA0),
                ),
              ),
            ),
          ],
        ),
        
        // Descrição da receita
        if (recipe.description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            recipe.description,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  /// ✨ NOVO: Botão de favorito flutuante
  Widget _buildFloatingFavoriteButton(BuildContext context, WidgetRef ref, Recipe recipe) {
    final favoritesAsync = ref.watch(recipeFavoritesProvider);
    
    return favoritesAsync.when(
      data: (favorites) {
        final isFavorite = favorites.any((fav) => fav.recipeId == recipe.id);
        
        return FloatingActionButton(
          onPressed: () async {
            final user = ref.read(currentUserProvider);
            if (user == null) return;
            
            if (isFavorite) {
              await ref.read(recipeFavoritesProvider.notifier).removeFavorite(recipe.id);
            } else {
              await ref.read(recipeFavoritesProvider.notifier).addFavorite(recipe.id);
            }
          },
          backgroundColor: isFavorite ? Colors.red : Colors.white,
          foregroundColor: isFavorite ? Colors.white : Colors.red,
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
          ),
        );
      },
      loading: () => FloatingActionButton(
        onPressed: null,
        backgroundColor: Colors.grey,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildRecipeInfo(Recipe recipe) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.access_time, '${recipe.preparationTimeMinutes} min'),
          _buildInfoItem(Icons.people, '${recipe.servings} porções'),
          _buildInfoItem(Icons.local_fire_department, '${recipe.calories} kcal'),
          _buildInfoItem(Icons.signal_cellular_alt, recipe.difficulty),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: const Color(0xFFCDA8F0)),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoContent(Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vídeo da Receita',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        
        // Player do YouTube
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: YouTubePlayerWidget(
            videoId: recipe.videoId!,
            autoPlay: false,
            showControls: true,
          ),
        ),
        
        // Tags
        if (recipe.tags.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildTags(recipe.tags),
        ],
      ],
    );
  }

  Widget _buildTextContent(Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ingredientes
        if (recipe.ingredients != null && recipe.ingredients!.isNotEmpty) ...[
          const Text(
            'Ingredientes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          ...recipe.ingredients!.map((ingredient) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCDA8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: Text(
                    ingredient,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
          const SizedBox(height: 32),
        ],
        
        // Modo de Preparo
        if (recipe.instructions != null && recipe.instructions!.isNotEmpty) ...[
          const Text(
            'Modo de Preparo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          ...recipe.instructions!.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDA8F0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      instruction,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 32),
        ],
        
        // Dica da Nutricionista
        if (recipe.nutritionistTip != null && recipe.nutritionistTip!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFCDA8F0).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCDA8F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lightbulb,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Dica da Nutricionista',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B5CA0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  recipe.nutritionistTip!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        
        // Tags
        if (recipe.tags.isNotEmpty) ...[
          _buildTags(recipe.tags),
        ],
      ],
    );
  }

  Widget _buildTags(List<String> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFCDA8F0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFCDA8F0).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7B5CA0),
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
} 