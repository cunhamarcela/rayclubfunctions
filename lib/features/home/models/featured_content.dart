// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'featured_content.freezed.dart';
part 'featured_content.g.dart';

/// Conversor personalizado para IconData
class IconDataConverter implements JsonConverter<IconData, String> {
  const IconDataConverter();

  @override
  IconData fromJson(String json) {
    // Converte o código codePoint em hexadecimal para um IconData
    return IconData(
      int.parse(json, radix: 16),
      fontFamily: 'MaterialIcons',
    );
  }

  @override
  String toJson(IconData iconData) {
    // Converte o codePoint para uma string hexadecimal
    return iconData.codePoint.toRadixString(16);
  }
}

/// Modelo que representa conteúdos em destaque na tela inicial
@freezed
class FeaturedContent with _$FeaturedContent {
  const factory FeaturedContent({
    required String id,
    required String title,
    required String description,
    required ContentCategory category,
    @IconDataConverter() required IconData icon,
    String? imageUrl,
    String? actionUrl,
    DateTime? publishedAt,
    @Default(false) bool isFeatured,
  }) = _FeaturedContent;

  factory FeaturedContent.fromJson(Map<String, dynamic> json) => _$FeaturedContentFromJson(json);
}

/// Categoria de conteúdo com nome e cor
@freezed
class ContentCategory with _$ContentCategory {
  const factory ContentCategory({
    @Default('') String id,
    required String name,
    @JsonKey(ignore: true) Color? color,
    String? colorHex,
  }) = _ContentCategory;
  
  factory ContentCategory.fromJson(Map<String, dynamic> json) => _$ContentCategoryFromJson(json);
}

/// Dados mockados para a exibição dos conteúdos em destaque
final List<FeaturedContent> featuredContents = [
  FeaturedContent(
    id: '1',
    title: 'Treinos para fazer viajando',
    description: 'Exercícios simples que cabem na sua mala e no seu tempo',
    category: ContentCategory(
      id: 'travel',
      name: 'Viagem',
      color: Colors.blue,
      colorHex: '#2196F3',
    ),
    icon: Icons.flight,
  ),
  FeaturedContent(
    id: '2',
    title: 'HIIT de 7 minutos',
    description: 'Treino rápido e intenso para dias corridos',
    category: ContentCategory(
      id: 'training',
      name: 'Treinos',
      color: Colors.orange,
      colorHex: '#FF9800',
    ),
    icon: Icons.timer,
  ),
  FeaturedContent(
    id: '3',
    title: 'Receita pré-treino com 2 ingredientes',
    description: 'Shake energético simples e rápido de preparar',
    category: ContentCategory(
      id: 'nutrition',
      name: 'Nutrição',
      color: Colors.green,
      colorHex: '#4CAF50',
    ),
    icon: Icons.blender,
  ),
  FeaturedContent(
    id: '4',
    title: 'Yoga para relaxar em 15 minutos',
    description: 'Sequência para fazer antes de dormir e melhorar seu sono',
    category: ContentCategory(
      id: 'wellness',
      name: 'Bem-estar',
      color: Colors.purple,
      colorHex: '#9C27B0',
    ),
    icon: Icons.self_improvement,
  ),
  FeaturedContent(
    id: '5',
    title: 'Exercícios para fazer no escritório',
    description: 'Alivie a tensão sem sair da sua mesa',
    category: ContentCategory(
      id: 'office',
      name: 'Trabalho',
      color: Colors.brown,
      colorHex: '#795548',
    ),
    icon: Icons.chair,
  ),
  FeaturedContent(
    id: '6',
    title: 'Treino completo sem equipamentos',
    description: 'Trabalhe todos os grupos musculares apenas com seu peso corporal',
    category: ContentCategory(
      id: 'bodyweight',
      name: 'Sem Equip.',
      color: Colors.red,
      colorHex: '#F44336',
    ),
    icon: Icons.fitness_center,
  ),
]; 
