// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/home/models/weekly_highlight.dart';

/// Widget para exibir destaques da semana em formato semelhante a "Rooms"
class WeeklyHighlightsGrid extends StatelessWidget {
  /// Lista de destaques da semana para exibir
  final List<WeeklyHighlight> highlights;
  
  /// Callback quando um destaque é selecionado
  final Function(String id)? onHighlightTap;

  const WeeklyHighlightsGrid({
    Key? key,
    required this.highlights,
    this.onHighlightTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Verificar se temos destaques suficientes
    if (highlights.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Primeira linha: 1 item grande + 1 médio
          Row(
            children: [
              // Item grande (ocupando 2/3 do espaço)
              if (highlights.length > 0)
                Expanded(
                  flex: 2,
                  child: _HighlightCardLarge(
                    highlight: highlights[0],
                    onTap: () => onHighlightTap?.call(highlights[0].id),
                  ),
                ),
              const SizedBox(width: 12),
              // Item médio vertical (ocupando 1/3 do espaço)
              if (highlights.length > 1)
                Expanded(
                  flex: 1,
                  child: _HighlightCardMedium(
                    highlight: highlights[1],
                    onTap: () => onHighlightTap?.call(highlights[1].id),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Segunda linha: 2-3 cards circulares
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: highlights.length > 5 ? 5 : highlights.length - 2,
              itemBuilder: (context, index) {
                // Começamos do índice 2 porque os dois primeiros já foram usados
                final actualIndex = index + 2;
                if (actualIndex < highlights.length) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: 12,
                      left: index == 0 ? 0 : 0,
                    ),
                    child: _HighlightCardCircular(
                      highlight: highlights[actualIndex],
                      onTap: () => onHighlightTap?.call(highlights[actualIndex].id),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Card grande para um destaque da semana
class _HighlightCardLarge extends StatelessWidget {
  final WeeklyHighlight highlight;
  final VoidCallback onTap;

  const _HighlightCardLarge({
    Key? key,
    required this.highlight,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        image: highlight.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(highlight.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(16),
            child: Text(
              highlight.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Card médio para um destaque da semana
class _HighlightCardMedium extends StatelessWidget {
  final WeeklyHighlight highlight;
  final VoidCallback onTap;

  const _HighlightCardMedium({
    Key? key,
    required this.highlight,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        image: highlight.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(highlight.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(16),
            child: Text(
              highlight.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Card circular para um destaque da semana
class _HighlightCardCircular extends StatelessWidget {
  final WeeklyHighlight highlight;
  final VoidCallback onTap;

  const _HighlightCardCircular({
    Key? key,
    required this.highlight,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
              image: highlight.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(highlight.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: highlight.imageUrl == null
                ? Center(
                    child: Icon(
                      highlight.icon,
                      color: highlight.color,
                      size: 40,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          highlight.title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
} 