// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/nutrition/providers/recipe_providers.dart';
import 'package:ray_club_app/features/nutrition/models/recipe.dart';
import 'package:ray_club_app/features/home/widgets/youtube_player_widget.dart';

/// Widget para exibir a seção "Receitas Favoritas da Ray" na home
/// Layout 2x2 com cards quadrados e bordas arredondadas
/// ✨ Sempre mostra 4 cards atrativos com bom fallback
class RayFavoriteRecipesSection extends ConsumerWidget {
  const RayFavoriteRecipesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteRecipesAsync = ref.watch(rayFavoriteRecipeVideosProvider);

    return favoriteRecipesAsync.when(
      data: (recipes) => _buildSection(context, recipes),
      loading: () => _buildLoadingSection(),
      error: (error, _) => _buildFallbackSection(context),
    );
  }

  Widget _buildSection(BuildContext context, List<Recipe> recipes) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 12), // Reduzir margens
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção com melhor design
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Título principal
                const Expanded(
                  child: Text(
                    'Receitas Favoritas da Ray ✨',
                    style: TextStyle(
                      fontSize: 18, // Reduzir um pouco
                      fontWeight: FontWeight.w500, // Remover negrito: w700 → w500
                      color: Color(0xFF333333),
                      fontFamily: 'CenturyGothic',
                    ),
                  ),
                ),
                // Decoração com gradiente
                Container(
                  padding: const EdgeInsets.all(8), // Reduzir padding
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE78639), Color(0xFFFEDC94)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14), // Menor
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE78639).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 18, // Menor
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12), // Reduzir espaçamento
          
          // Grid 2x2 de receitas - sempre 4 cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Primeira linha - Cards 1 e 2
                Row(
                  children: [
                    Expanded(child: _buildRecipeCards(context, recipes)[0]),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRecipeCards(context, recipes)[1]),
                  ],
                ),
                const SizedBox(height: 12),
                // Segunda linha - Cards 3 e 4
                Row(
                  children: [
                    Expanded(child: _buildRecipeCards(context, recipes)[2]),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRecipeCards(context, recipes)[3]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói os 4 cards de receitas com fallback inteligente
  List<Widget> _buildRecipeCards(BuildContext context, List<Recipe> recipes) {
    print('🎯 [Widget] Construindo cards para ${recipes.length} receitas');
    
    // Debug: verificar URLs dos vídeos
    for (int i = 0; i < recipes.length; i++) {
      print('🎯 [Widget] Receita ${i+1}: "${recipes[i].title}" - videoUrl: ${recipes[i].videoUrl}');
    }
    
    // Dados de fallback quando não há receitas suficientes
    final fallbackRecipes = [
      {
        'title': 'Gororoba de Banana',
        'time': '15 min',
        'icon': Icons.blender,
        'color': const Color(0xFF4CAF50),
        'description': 'Deliciosa mistura proteica',
      },
      {
        'title': 'Bolo Alagado',
        'time': '45 min',
        'icon': Icons.cake,
        'color': const Color(0xFFFF9800),
        'description': 'Sobremesa especial',
      },
      {
        'title': 'Banana Toast',
        'time': '10 min',
        'icon': Icons.breakfast_dining,
        'color': const Color(0xFF2196F3),
        'description': 'Café da manhã nutritivo',
      },
      {
        'title': 'Pão de Queijo Fit',
        'time': '25 min',
        'icon': Icons.bakery_dining,
        'color': const Color(0xFF9C27B0),
        'description': 'Lanche proteico',
      },
    ];

    final List<Widget> cards = [];
    
    // SEMPRE criar exatamente 4 cards - REMOVENDO CONDIÇÃO DE VIDEO URL
    for (int i = 0; i < 4; i++) {
      if (i < recipes.length) {
        // Card com receita real (independente se tem vídeo ou não)
        print('🎯 [Widget] Card ${i+1}: Receita real "${recipes[i].title}"');
        cards.add(_buildRealRecipeCard(context, recipes[i]));
      } else {
        // Card de fallback
        print('🎯 [Widget] Card ${i+1}: Fallback "${fallbackRecipes[i]['title']}"');
        cards.add(_buildFallbackCard(context, fallbackRecipes[i]));
      }
    }

    print('🎯 [Widget] Total de cards criados: ${cards.length}');
    return cards;
  }

  /// Card de receita real do banco de dados
  Widget _buildRealRecipeCard(BuildContext context, Recipe recipe) {
    return GestureDetector(
      onTap: () => _openRecipeVideoPlayer(context, recipe),
      child: Container(
        height: 85, // Aumentar de 75 para 85 para resolver overflow
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10), // Reduzir de 12 para 10
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Importante para evitar overflow
          children: [
            // Ícone menor
            Container(
              width: 24, // Reduzir de 28
              height: 24, // Reduzir de 28
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 16, // Reduzir de 18
              ),
            ),
            const SizedBox(height: 6), // Reduzir de 8
            // Título da receita
            Flexible(
              child: Text(
                recipe.title,
                style: const TextStyle(
                  fontSize: 11, // Reduzir de 12
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                  fontFamily: 'CenturyGothic',
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2, // Garantir máximo 2 linhas
              ),
            ),
            const SizedBox(height: 4), // Reduzir de 6
            // Tempo de preparo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 10, // Reduzir de 12
                  color: Color(0xFF666666),
                ),
                const SizedBox(width: 3), // Reduzir de 4
                Flexible(
                  child: Text(
                    '${recipe.preparationTimeMinutes} min',
                    style: const TextStyle(
                      fontSize: 9, // Reduzir de 10
                      color: Color(0xFF666666),
                      fontFamily: 'CenturyGothic',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Card de fallback para receitas em desenvolvimento
  Widget _buildFallbackCard(BuildContext context, Map<String, dynamic> fallbackData) {
    return Container(
      height: 85, // Mesma altura dos cards reais
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(10), // Mesmo padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: fallbackData['color'] as Color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              fallbackData['icon'] as IconData,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(height: 6),
          // Título
          Flexible(
            child: Text(
              fallbackData['title'] as String,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
                fontFamily: 'CenturyGothic',
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 4),
          // Status "Em breve"
          Flexible(
            child: Text(
              'Em breve ✨',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade500,
                fontFamily: 'CenturyGothic',
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Seção de loading melhorada
  Widget _buildLoadingSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 12), // Mesmas margens
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Receitas Favoritas da Ray ✨',
              style: TextStyle(
                fontSize: 18, // Mesmo tamanho
                fontWeight: FontWeight.w500, // Consistente: w700 → w500
                color: Color(0xFF333333),
                fontFamily: 'CenturyGothic',
              ),
            ),
          ),
          const SizedBox(height: 12), // Mesmo espaçamento
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Primeira linha - Cards 1 e 2
                Row(
                  children: [
                    Expanded(child: _buildLoadingCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildLoadingCard()),
                  ],
                ),
                const SizedBox(height: 12),
                // Segunda linha - Cards 3 e 4
                Row(
                  children: [
                    Expanded(child: _buildLoadingCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildLoadingCard()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card de loading com shimmer effect
  Widget _buildLoadingCard() {
    return Container(
      height: 75, // Mesma altura
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12), // Mesmo tamanho
      ),
      padding: const EdgeInsets.all(12), // Mesmo padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28, // Mesmo tamanho
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8), // Mesmo raio
            ),
          ),
          const SizedBox(height: 6), // Mesmo espaçamento
          Container(
            width: 50, // Menor para caber melhor
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 30, // Menor
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  /// Seção de fallback quando há erro
  Widget _buildFallbackSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 12), // Mesmas margens
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Receitas Favoritas da Ray ✨',
              style: TextStyle(
                fontSize: 18, // Mesmo tamanho
                fontWeight: FontWeight.w500, // Consistente: w700 → w500
                color: Color(0xFF333333),
                fontFamily: 'CenturyGothic',
              ),
            ),
          ),
          const SizedBox(height: 12), // Mesmo espaçamento
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Primeira linha - Cards 1 e 2
                Row(
                  children: [
                    Expanded(child: _buildRecipeCards(context, [])[0]),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRecipeCards(context, [])[1]),
                  ],
                ),
                const SizedBox(height: 12),
                // Segunda linha - Cards 3 e 4
                Row(
                  children: [
                    Expanded(child: _buildRecipeCards(context, [])[2]),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRecipeCards(context, [])[3]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mostra diálogo "Em breve" para cards de fallback
  void _showComingSoonDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nova receita em breve! ✨'),
        backgroundColor: Color(0xFFE78639),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Abre o player de vídeo interno
  Future<void> _openRecipeVideoPlayer(BuildContext context, Recipe recipe) async {
    if (recipe.videoUrl == null) {
      // Mostrar mensagem de que o vídeo não está disponível
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vídeo em breve! 🎥'),
          backgroundColor: Color(0xFFE78639),
        ),
      );
      return;
    }

    try {
      // Abrir player interno com modal
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
            videoUrl: recipe.videoUrl!,
            title: recipe.title,
            description: recipe.description,
            onClose: () => Navigator.pop(context),
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao abrir o vídeo ❌'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Obtém cor específica para cada receita
  Color _getRecipeColor(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('gororoba') || titleLower.contains('banana')) {
      return const Color(0xFF4CAF50); // Verde para banana
    } else if (titleLower.contains('bolo') || titleLower.contains('alagado')) {
      return const Color(0xFFFF9800); // Laranja para bolo
    } else if (titleLower.contains('toast') || titleLower.contains('saudável')) {
      return const Color(0xFF2196F3); // Azul para toast
    } else if (titleLower.contains('pão') || titleLower.contains('queijo')) {
      return const Color(0xFF9C27B0); // Roxo para pão de queijo
    }
    return const Color(0xFFE78639); // Cor padrão laranja
  }

  /// Obtém ícone específico para cada receita
  IconData _getRecipeIcon(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('gororoba') || titleLower.contains('banana')) {
      return Icons.blender; // Liquidificador para gororoba
    } else if (titleLower.contains('bolo') || titleLower.contains('alagado')) {
      return Icons.cake; // Bolo
    } else if (titleLower.contains('toast') || titleLower.contains('saudável')) {
      return Icons.breakfast_dining; // Café da manhã
    } else if (titleLower.contains('pão') || titleLower.contains('queijo')) {
      return Icons.bakery_dining; // Padaria
    }
    return Icons.restaurant_menu; // Ícone padrão
  }

  /// Obtém título curto para o layout compacto
  String _getShortTitle(String title) {
    if (title.toLowerCase().contains('gororoba')) {
      return 'Gororoba';
    } else if (title.toLowerCase().contains('bolo')) {
      return 'Bolo Alagado';
    } else if (title.toLowerCase().contains('toast')) {
      return 'Banana Toast';
    } else if (title.toLowerCase().contains('pão')) {
      return 'Pão de Queijo';
    }
    
    // Fallback: pegar as primeiras palavras
    final words = title.split(' ');
    if (words.length <= 2) return title;
    return '${words[0]} ${words[1]}';
  }
} 