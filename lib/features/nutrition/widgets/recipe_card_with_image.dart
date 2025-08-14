// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/recipe.dart';

/// ✨ WIDGET CORRIGIDO: Card de receita com imagem
/// Substitui o card original que não exibia imagens
class RecipeCardWithImage extends StatelessWidget {
  final Recipe recipe;
  final bool isCompact;

  const RecipeCardWithImage({
    super.key,
    required this.recipe,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
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
          child: isCompact 
              ? _buildCompactLayout()
              : _buildStandardLayout(),
        ),
      ),
    );
  }

  /// Layout compacto para telas pequenas (horizontal)
  Widget _buildCompactLayout() {
    return Row(
      children: [
        // Thumbnail da imagem à esquerda
        _buildRecipeImage(width: 100, height: 100),
        
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
                          _buildRecipeTitle(),
                          const SizedBox(height: 4),
                          _buildRecipeDescription(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildContentTypeBadge(),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRecipeInfo(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Layout padrão para telas maiores (vertical)
  Widget _buildStandardLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagem no topo
        _buildRecipeImage(height: 200),
        
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
                        _buildRecipeTitle(),
                        const SizedBox(height: 4),
                        _buildRecipeDescription(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildContentTypeBadge(),
                ],
              ),
              const SizedBox(height: 16),
              _buildRecipeInfo(),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget de imagem da receita com fallback elegante
  Widget _buildRecipeImage({double? width, required double height}) {
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
          // Imagem da receita com cache
          CachedNetworkImage(
            imageUrl: recipe.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.primaryLight,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 2,
                ),
              ),
            ),
            errorWidget: (context, url, error) => _buildImageFallback(width),
          ),
          
          // Gradiente sutil para melhorar legibilidade (apenas para imagens grandes)
          if (width == null)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          
          // Badge de rating no canto superior direito (apenas para layout padrão)
          if (width == null)
            Positioned(
              top: 12,
              right: 12,
              child: _buildRatingBadge(),
            ),
        ],
      ),
    );
  }

  /// Fallback quando a imagem não carrega
  Widget _buildImageFallback(double? width) {
    final iconData = _getRecipeIconData();
    
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

  /// Badge de rating para imagens grandes
  Widget _buildRatingBadge() {
    return Container(
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
    );
  }

  /// Badge do tipo de conteúdo (vídeo/receita)
  Widget _buildContentTypeBadge() {
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

  /// Título da receita
  Widget _buildRecipeTitle() {
    return Text(
      recipe.title,
      style: AppTextStyles.cardTitle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Descrição da receita
  Widget _buildRecipeDescription() {
    return Text(
      recipe.description,
      style: AppTextStyles.smallText.copyWith(
        color: AppColors.textSecondary,
        fontSize: 12,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Informações da receita (tempo, calorias, porções, dificuldade)
  Widget _buildRecipeInfo() {
    return Row(
      children: [
        _buildCompactInfo(Icons.access_time, '${recipe.preparationTimeMinutes}min'),
        const SizedBox(width: 12),
        _buildCompactInfo(Icons.local_fire_department, '${recipe.calories}kcal'),
        const SizedBox(width: 12),
        _buildCompactInfo(Icons.people, '${recipe.servings}p'),
        const Spacer(),
        _buildDifficultyBadge(),
      ],
    );
  }

  /// Item de informação compacto
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

  /// Badge de dificuldade com cores apropriadas
  Widget _buildDifficultyBadge() {
    Color color;
    switch (recipe.difficulty.toLowerCase()) {
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
        recipe.difficulty,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Determina ícone e cor baseado no tipo de receita (para fallback)
  Map<String, dynamic> _getRecipeIconData() {
    final title = recipe.title.toLowerCase();
    
    // Mapeamento de ícones por tipo de receita
    if (title.contains('panqueca') || title.contains('pancake')) {
      return {'icon': Icons.breakfast_dining, 'color': AppColors.pastelYellow, 'bgColor': AppColors.pastelYellow.withOpacity(0.15)};
    } else if (title.contains('omelete') || title.contains('ovo')) {
      return {'icon': Icons.egg, 'color': AppColors.pastelYellow, 'bgColor': AppColors.pastelYellow.withOpacity(0.15)};
    } else if (title.contains('pão') || title.contains('toast') || title.contains('torrada')) {
      return {'icon': Icons.bakery_dining, 'color': AppColors.orange, 'bgColor': AppColors.primaryLight};
    } else if (title.contains('cacau') || title.contains('chocolate') || title.contains('bolo')) {
      return {'icon': Icons.cake, 'color': AppColors.orange, 'bgColor': AppColors.primaryLight};
    } else if (title.contains('atum') || title.contains('peixe') || title.contains('salmão')) {
      return {'icon': Icons.set_meal, 'color': AppColors.purple, 'bgColor': AppColors.purple.withOpacity(0.15)};
    } else if (title.contains('patê') || title.contains('pasta')) {
      return {'icon': Icons.lunch_dining, 'color': AppColors.softPink, 'bgColor': AppColors.softPink.withOpacity(0.15)};
    } else if (title.contains('salada') || title.contains('verde')) {
      return {'icon': Icons.eco, 'color': AppColors.purple, 'bgColor': AppColors.purple.withOpacity(0.15)};
    } else if (title.contains('smoothie') || title.contains('suco') || title.contains('vitamina')) {
      return {'icon': Icons.local_drink, 'color': AppColors.purple, 'bgColor': AppColors.purple.withOpacity(0.15)};
    } else if (title.contains('fruta') || title.contains('banana') || title.contains('maçã')) {
      return {'icon': Icons.local_dining, 'color': AppColors.pastelYellow, 'bgColor': AppColors.pastelYellow.withOpacity(0.15)};
    } else {
      return {'icon': Icons.restaurant_menu, 'color': AppColors.primary, 'bgColor': AppColors.primaryLight};
    }
  }
} 