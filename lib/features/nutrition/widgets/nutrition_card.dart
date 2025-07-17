// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/features/nutrition/models/nutrition_item.dart';

/// Card para exibir um item de nutrição
class NutritionCard extends StatelessWidget {
  final NutritionItem item;
  final VoidCallback? onTap;
  final bool isCompact;

  const NutritionCard({
    Key? key,
    required this.item,
    this.onTap,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: isCompact ? _buildCompactLayout() : _buildFullLayout(),
      ),
    );
  }

  Widget _buildFullLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagem
        _buildImageSection(),
        
        // Conteúdo
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tags
              if (item.tags.isNotEmpty) _buildTags(),
              
              const SizedBox(height: 8),
              
              // Título
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Descrição
              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Tempo de preparo
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.preparationTimeMinutes} min',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Row(
      children: [
        // Imagem lateral
        SizedBox(
          width: 120,
          height: 120,
          child: _buildImage(),
        ),
        
        // Conteúdo
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tags
                if (item.tags.isNotEmpty) _buildTags(),
                
                const SizedBox(height: 8),
                
                // Título
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Tempo de preparo
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.primaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.preparationTimeMinutes} min',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _buildImage(),
        ),
        
        // Badge para dica nutricional 
        if (item.nutritionistTip != null)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.info,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.health_and_safety,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Dica da Nutri',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Badge para indicar o autor da receita (Nutri ou Ray)
        if (item.category.toLowerCase() == 'recipe')
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: item.nutritionistTip != null 
                    ? AppColors.info 
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.nutritionistTip != null 
                        ? Icons.health_and_safety 
                        : Icons.fitness_center,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.nutritionistTip != null 
                        ? 'Nutri' 
                        : 'Ray',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage() {
    return CachedNetworkImage(
      imageUrl: item.imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.primaryLight.withOpacity(0.1),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.primaryLight.withOpacity(0.1),
        child: const Icon(
          Icons.restaurant,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: item.tags.take(2).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
} 
