// Flutter imports:
import 'package:flutter/material.dart';
import 'dart:ui';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/home/models/weekly_highlight.dart';

/// Widget para exibir destaques da semana em formato de galeria
class WeeklyGalleryGrid extends StatelessWidget {
  /// Lista de destaques da semana para exibir
  final List<WeeklyHighlight> highlights;
  
  /// Callback quando um destaque é selecionado
  final Function(String id)? onHighlightTap;

  const WeeklyGalleryGrid({
    Key? key,
    required this.highlights,
    this.onHighlightTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          
          // Dimensões e posicionamentos EXATAMENTE como na referência
          // Primeiro card (grande oval esquerda)
          final card1Width = maxWidth * 0.42;
          final card1Height = maxWidth * 0.55;
          
          // Segundo card (círculo direita superior)
          final card2Diameter = maxWidth * 0.28;
          
          // Terceiro card (oval direita meio)
          final card3Width = maxWidth * 0.38;
          final card3Height = maxWidth * 0.38;
          
          // Quarto card (círculo esquerda meio)
          final card4Diameter = maxWidth * 0.28;
          
          // Quinto card (círculo esquerda inferior)
          final card5Diameter = maxWidth * 0.28;
          
          // Sexto card (círculo direita inferior)
          final card6Diameter = maxWidth * 0.28;
          
          // Espaçamentos exatos baseados na referência
          final verticalSpacing = maxWidth * 0.03; // Espaço vertical entre cards
          
          // Altura total do container baseada nos cards da referência
          final totalHeight = card1Height + card5Diameter + verticalSpacing * 2;
          
          // Garantir que temos pelo menos 6 itens (ou repetir para preencher)
          final displayHighlights = _ensureEnoughItems(highlights, 6);

          return Container(
            height: totalHeight,
            width: maxWidth,
            child: Stack(
              children: [
                // 1. Card oval grande (esquerda superior)
                Positioned(
                  left: 0,
                  top: 0,
                  child: _OvalHighlightCard(
                    highlight: displayHighlights[0],
                    onTap: () => onHighlightTap?.call(displayHighlights[0].id),
                    width: card1Width,
                    height: card1Height,
                  ),
                ),
                
                // 2. Card circular (direita superior)
                Positioned(
                  right: 0,
                  top: 0,
                  child: _CircleHighlightCard(
                    highlight: displayHighlights[1],
                    onTap: () => onHighlightTap?.call(displayHighlights[1].id),
                    size: card2Diameter,
                  ),
                ),
                
                // 3. Card oval (direita meio) - EXATAMENTE como na referência
                Positioned(
                  right: 0,
                  top: card2Diameter + verticalSpacing,
                  child: _OvalHighlightCard(
                    highlight: displayHighlights[2],
                    onTap: () => onHighlightTap?.call(displayHighlights[2].id),
                    width: card3Width,
                    height: card3Height,
                    isCircular: true, // Esta oval é quase circular na referência
                  ),
                ),
                
                // 4. Card circular (esquerda meio)
                Positioned(
                  left: 0,
                  top: card1Height + verticalSpacing,
                  child: _CircleHighlightCard(
                    highlight: displayHighlights[3],
                    onTap: () => onHighlightTap?.call(displayHighlights[3].id),
                    size: card4Diameter,
                  ),
                ),
                
                // 5. Card circular (esquerda inferior)
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: _CircleHighlightCard(
                    highlight: displayHighlights[4],
                    onTap: () => onHighlightTap?.call(displayHighlights[4].id),
                    size: card5Diameter,
                  ),
                ),
                
                // 6. Card circular (direita inferior)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _CircleHighlightCard(
                    highlight: displayHighlights[5],
                    onTap: () => onHighlightTap?.call(displayHighlights[5].id),
                    size: card6Diameter,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // Garantir que temos itens suficientes, repetindo se necessário
  List<WeeklyHighlight> _ensureEnoughItems(List<WeeklyHighlight> items, int count) {
    if (items.isEmpty) {
      return [];
    }
    
    if (items.length >= count) {
      return items.take(count).toList();
    }
    
    final result = List<WeeklyHighlight>.from(items);
    while (result.length < count) {
      result.add(items[result.length % items.length]);
    }
    
    return result;
  }
}

/// Card circular para destaques
class _CircleHighlightCard extends StatelessWidget {
  final WeeklyHighlight highlight;
  final VoidCallback onTap;
  final double size;

  const _CircleHighlightCard({
    Key? key,
    required this.highlight,
    required this.onTap,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Selecionar imagem baseada no conteúdo
    String imageAsset = _getContentMatchedImage(highlight);
    
    // Obter texto descritivo
    final texto = highlight.tagline ?? highlight.title;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagem de fundo
              _buildBackgroundImage(imageAsset),
              
              // Barra preta com texto na parte inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.7),
                  child: Text(
                    texto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card oval para destaques
class _OvalHighlightCard extends StatelessWidget {
  final WeeklyHighlight highlight;
  final VoidCallback onTap;
  final double width;
  final double height;
  final bool isCircular;

  const _OvalHighlightCard({
    Key? key,
    required this.highlight,
    required this.onTap,
    required this.width,
    required this.height,
    this.isCircular = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Selecionar imagem baseada no conteúdo
    String imageAsset = _getContentMatchedImage(highlight);
    
    // Obter texto descritivo
    final texto = highlight.tagline ?? highlight.title;

    // O raio do borderRadius baseado se é mais circular ou mais oval
    final radius = isCircular ? height / 2 : height / 2.5;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagem de fundo
              _buildBackgroundImage(imageAsset),
              
              // Barra preta com texto na parte inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.7),
                  child: Text(
                    texto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Utilitários compartilhados
Widget _buildBackgroundImage(String imageAsset) {
  return Stack(
    fit: StackFit.expand,
    children: [
      // Imagem original
      imageAsset.startsWith('http')
          ? Image.network(
              imageAsset, 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('❌ Erro ao carregar imagem: $imageAsset');
                return Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey.shade400,
                    size: 40,
                  ),
                );
              },
            )
          : Image.asset(imageAsset, fit: BoxFit.cover),
      
      // Efeito de blur muito suave (quase imperceptível como na referência)
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
        child: Container(
          color: Colors.black.withOpacity(0.03),
        ),
      ),
    ],
  );
}

/// Método para obter imagem de acordo com o conteúdo
String _getContentMatchedImage(WeeklyHighlight highlight) {
  // Se a imagem já estiver definida no modelo, use-a diretamente
  if (highlight.artImage != null) {
    return highlight.artImage!;
  }
  
  // Mapear ID para o tipo de conteúdo e selecionar a imagem correspondente
  final id = highlight.id.toLowerCase();
  
  if (id.contains('yoga') || id.contains('relax')) {
    // Imagem para Yoga e relaxamento
    return 'assets/images/art_yoga.jpg';
  } else if (id.contains('hiit') || id.contains('cardio') || id.contains('workout')) {
    // Imagem para HIIT, treinos intensos e cardio
    return 'assets/images/art_hiit.jpg';
  } else if (id.contains('travel') || id.contains('viagem')) {
    // Imagem para treinos de viagem
    return 'assets/images/art_travel.jpg';
  } else if (id.contains('recipe') || id.contains('receita') || id.contains('nutri')) {
    // Imagem para receitas e nutrição
    return 'assets/images/art_recipe.jpg';
  } else if (id.contains('office') || id.contains('trabalho') || id.contains('alongamento')) {
    // Imagem para alongamentos no trabalho
    return 'assets/images/art_office.jpg';
  } else if (id.contains('body') || id.contains('equipment') || id.contains('sem')) {
    // Imagem para treinos sem equipamentos
    return 'assets/images/art_bodyweight.jpg';
  }
  
  // Caso não encontre correspondência por ID, verifique pelo título ou descrição
  final titleLower = highlight.title.toLowerCase();
  final descLower = highlight.description.toLowerCase();
  
  if (titleLower.contains('yoga') || descLower.contains('yoga') || 
      titleLower.contains('relax') || descLower.contains('relax')) {
    return 'assets/images/art_yoga.jpg';
  } else if (titleLower.contains('hiit') || descLower.contains('hiit') ||
            titleLower.contains('intens') || descLower.contains('intens')) {
    return 'assets/images/art_hiit.jpg';
  } else if (titleLower.contains('viagem') || descLower.contains('viagem') ||
            titleLower.contains('travel') || descLower.contains('travel')) {
    return 'assets/images/art_travel.jpg';
  } else if (titleLower.contains('receit') || descLower.contains('receit') ||
            titleLower.contains('aliment') || descLower.contains('aliment')) {
    return 'assets/images/art_recipe.jpg';
  } else if (titleLower.contains('trabalho') || descLower.contains('trabalho') ||
            titleLower.contains('office') || descLower.contains('office') ||
            titleLower.contains('along') || descLower.contains('along')) {
    return 'assets/images/art_office.jpg';
  }
  
  // Se ainda não encontrou, selecione um fallback baseado no hash do ID
  final List<String> artImages = [
    'assets/images/art_travel.jpg',
    'assets/images/art_hiit.jpg',
    'assets/images/art_recipe.jpg',
    'assets/images/art_yoga.jpg',
    'assets/images/art_office.jpg',
    'assets/images/art_bodyweight.jpg',
  ];

  final index = highlight.id.hashCode % artImages.length;
  return artImages[index.abs()];
} 