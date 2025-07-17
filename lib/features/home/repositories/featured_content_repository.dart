// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/home/models/featured_content.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';

/// Interface para o repositório de conteúdos em destaque
abstract class FeaturedContentRepository {
  /// Recupera a lista de conteúdos em destaque
  Future<List<FeaturedContent>> getFeaturedContents();
  
  /// Recupera um conteúdo específico pelo ID
  Future<FeaturedContent?> getFeaturedContentById(String id);
}

/// Implementação mock do repositório para desenvolvimento
class MockFeaturedContentRepository implements FeaturedContentRepository {
  @override
  Future<List<FeaturedContent>> getFeaturedContents() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    return [
      FeaturedContent(
        id: '1',
        title: 'Dicas de Nutrição',
        description: 'Como montar um prato ideal após o treino',
        category: ContentCategory(
          id: 'cat1',
          name: 'Nutrição',
          color: Colors.green,
          colorHex: '#4CAF50',
        ),
        icon: Icons.restaurant,
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        isFeatured: true,
      ),
      FeaturedContent(
        id: '2',
        title: 'Treino HIIT de 20 minutos',
        description: 'Queime calorias em casa sem equipamentos',
        category: ContentCategory(
          id: 'cat2',
          name: 'Treinos',
          color: Colors.orange,
          colorHex: '#FF9800',
        ),
        icon: Icons.fitness_center,
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        isFeatured: true,
      ),
      FeaturedContent(
        id: '3',
        title: 'Alongamento pós-treino',
        description: 'Técnicas para recuperação muscular eficiente',
        category: ContentCategory(
          id: 'cat3',
          name: 'Recuperação',
          color: Colors.blue,
          colorHex: '#2196F3',
        ),
        icon: Icons.self_improvement,
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      FeaturedContent(
        id: '4',
        title: 'Meditações guiadas',
        description: 'Reduza o estresse e melhore seu sono',
        category: ContentCategory(
          id: 'cat4',
          name: 'Bem-estar',
          color: Colors.purple,
          colorHex: '#9C27B0',
        ),
        icon: Icons.spa,
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  @override
  Future<FeaturedContent?> getFeaturedContentById(String id) async {
    final list = await getFeaturedContents();
    return list.where((content) => content.id == id).firstOrNull;
  }
}

/// Implementação real do repositório usando Supabase (para ser implementado futuramente)
class SupabaseFeaturedContentRepository implements FeaturedContentRepository {
  final SupabaseClient _supabaseClient;
  
  SupabaseFeaturedContentRepository(this._supabaseClient);
  
  @override
  Future<List<FeaturedContent>> getFeaturedContents() async {
    try {
      final response = await _supabaseClient
          .from('featured_contents')
          .select('*, category:categories(id, name, color)')
          .order('published_at', ascending: false);
      
      return (response as List<dynamic>)
          .map((data) => _mapToFeaturedContent(data))
          .toList();
    } catch (e) {
      // Em caso de erro durante o desenvolvimento, retornar dados mock como fallback
      print('Erro ao buscar conteúdos destacados: $e');
      return MockFeaturedContentRepository().getFeaturedContents();
    }
  }

  @override
  Future<FeaturedContent?> getFeaturedContentById(String id) async {
    try {
      final response = await _supabaseClient
          .from('featured_contents')
          .select('*, category:categories(id, name, color)')
          .eq('id', id)
          .single();
      
      return _mapToFeaturedContent(response);
    } catch (e) {
      // Em caso de erro durante o desenvolvimento, retornar dados mock como fallback
      print('Erro ao buscar conteúdo destacado por ID: $e');
      return MockFeaturedContentRepository().getFeaturedContentById(id);
    }
  }
  
  // Helper para converter dados do Supabase para o modelo FeaturedContent
  FeaturedContent _mapToFeaturedContent(Map<String, dynamic> data) {
    // Processa a categoria
    final categoryData = data['category'] as Map<String, dynamic>?;
    final category = categoryData != null
        ? ContentCategory(
            id: categoryData['id'] as String,
            name: categoryData['name'] as String,
            color: _hexToColor(categoryData['color'] as String? ?? '#6E44FF'),
            colorHex: categoryData['color'] as String? ?? '#6E44FF',
          )
        : ContentCategory(
            id: 'default',
            name: 'Geral',
            color: const Color(0xFF6E44FF),
            colorHex: '#6E44FF',
          );
    
    // Determinar o ícone com base no tipo
    IconData icon = Icons.star;
    final type = data['type'] as String? ?? 'article';
    switch (type.toLowerCase()) {
      case 'workout':
        icon = Icons.fitness_center;
        break;
      case 'nutrition':
        icon = Icons.restaurant;
        break;
      case 'wellness':
        icon = Icons.spa;
        break;
      case 'challenge':
        icon = Icons.emoji_events;
        break;
      default:
        icon = Icons.article;
    }
    
    return FeaturedContent(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      category: category,
      icon: icon,
      imageUrl: data['image_url'] as String?,
      actionUrl: data['content_url'] as String?,
      publishedAt: data['published_at'] != null ? DateTime.parse(data['published_at'] as String) : null,
      isFeatured: data['is_featured'] as bool? ?? false,
    );
  }
  
  // Helper para converter hex para Color
  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
} 
