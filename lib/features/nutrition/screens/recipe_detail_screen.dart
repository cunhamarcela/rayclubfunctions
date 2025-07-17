// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/providers/auth_provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_providers.dart';
import '../providers/recipe_favorites_providers.dart';
import '../widgets/youtube_player_widget.dart';

/// Tela de detalhes da receita que suporta conteúdo de texto e vídeo
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          _buildFavoriteButton(context, ref, recipe),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da receita
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
    );
  }

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
        
        // Informações principais da receita
        Row(
          children: [
            // Rating
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
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
            
            // Tipo de conteúdo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFCDA8F0).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    recipe.contentType == RecipeContentType.video 
                        ? Icons.play_circle_filled 
                        : Icons.description,
                    color: const Color(0xFFCDA8F0),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    recipe.contentType == RecipeContentType.video ? 'Vídeo' : 'Receita',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7B5CA0),
                    ),
                  ),
                ],
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recipe.tags.map((tag) => Chip(
              label: Text(tag),
              backgroundColor: const Color(0xFFCDA8F0).withOpacity(0.2),
              labelStyle: const TextStyle(
                color: Color(0xFF7B5CA0),
                fontSize: 14,
              ),
            )).toList(),
          ),
        ],
        
        // ✅ Informações nutricionais fictícias removidas
        // Apenas valor calórico real da Bruna Braga é mostrado no header
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
          ...recipe.instructions!.asMap().entries.map((entry) => Padding(
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
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
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
          const SizedBox(height: 24),
        ],
        
        // Dica da Nutricionista
        if (recipe.nutritionistTip != null) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFCDA8F0).withOpacity(0.1),
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
                  children: const [
                    Icon(Icons.lightbulb_outline, color: Color(0xFFCDA8F0)),
                    SizedBox(width: 8),
                    Text(
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recipe.tags.map((tag) => Chip(
              label: Text(tag),
              backgroundColor: const Color(0xFFCDA8F0).withOpacity(0.2),
              labelStyle: const TextStyle(
                color: Color(0xFF7B5CA0),
                fontSize: 14,
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
        ],
        
        // ✅ Informações nutricionais fictícias removidas
        // Receitas da Bruna Braga contêm apenas calorias totais reais
      ],
    );
  }

  Widget _buildNutritionalInfo(Map<String, dynamic> nutritionalInfo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações Nutricionais',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3,
            children: nutritionalInfo.entries.map((entry) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  Text(
                    '${entry.value}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  /// Constrói o botão de favorito que muda baseado no estado
  Widget _buildFavoriteButton(BuildContext context, WidgetRef ref, Recipe recipe) {
    final currentUser = ref.watch(currentUserProvider);
    final isFavorite = ref.watch(isRecipeFavoriteProvider(recipe.id));
    
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.bookmark : Icons.bookmark_border,
        color: isFavorite ? Colors.amber : const Color(0xFF333333),
      ),
      onPressed: currentUser != null 
          ? () => _toggleFavorite(context, ref, currentUser.id, recipe)
          : null,
    );
  }

  /// Alterna o status de favorito da receita
  Future<void> _toggleFavorite(
    BuildContext context, 
    WidgetRef ref, 
    String userId, 
    Recipe recipe
  ) async {
    try {
      final favoritesNotifier = ref.read(recipeFavoritesProvider.notifier);
      await favoritesNotifier.toggleFavorite(userId, recipe.id);
      
      final isFavorite = ref.read(isRecipeFavoriteProvider(recipe.id));
      
      // Feedback visual para o usuário
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite 
                ? '✨ Receita adicionada aos favoritos!' 
                : '💔 Receita removida dos favoritos',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: isFavorite ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ops! Algo deu errado. Vamos tentar de novo? 🤗'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}