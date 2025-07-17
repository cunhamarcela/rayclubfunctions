// Project imports:
import 'package:flutter/material.dart';
import 'package:ray_club_app/features/home/models/weekly_highlight.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Interface do repositório para os destaques da semana
abstract class WeeklyHighlightsRepository {
  /// Obtém os destaques da semana ativos
  Future<List<WeeklyHighlight>> getWeeklyHighlights();
  
  /// Obtém um destaque específico por ID
  Future<WeeklyHighlight?> getHighlightById(String id);
  
  /// Marca um destaque como visualizado pelo usuário
  Future<void> markHighlightAsViewed(String id);
}

/// Implementação mock do repositório para desenvolvimento
class MockWeeklyHighlightsRepository implements WeeklyHighlightsRepository {
  @override
  Future<List<WeeklyHighlight>> getWeeklyHighlights() async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Retorna dados mockados
    return getMockWeeklyHighlights();
  }
  
  @override
  Future<WeeklyHighlight?> getHighlightById(String id) async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Busca nos dados mockados
    final highlights = getMockWeeklyHighlights();
    return highlights.where((h) => h.id == id).firstOrNull;
  }
  
  @override
  Future<void> markHighlightAsViewed(String id) async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Em uma implementação real, salvaria no Supabase
    debugPrint('Highlight $id marcado como visualizado');
  }
}

/// Implementação do repositório usando Supabase
class SupabaseWeeklyHighlightsRepository implements WeeklyHighlightsRepository {
  final SupabaseClient _supabaseClient;
  
  SupabaseWeeklyHighlightsRepository(this._supabaseClient);
  
  @override
  Future<List<WeeklyHighlight>> getWeeklyHighlights() async {
    try {
      final response = await _supabaseClient
          .from('weekly_highlights')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(10);
      
      return (response as List<dynamic>)
          .map((data) => WeeklyHighlight.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Log do erro
      print('Erro ao buscar destaques semanais: $e');
      // Retorna os dados mockados como fallback durante desenvolvimento
      return getMockWeeklyHighlights();
    }
  }
  
  @override
  Future<WeeklyHighlight?> getHighlightById(String id) async {
    try {
      final response = await _supabaseClient
          .from('weekly_highlights')
          .select()
          .eq('id', id)
          .single();
      
      return WeeklyHighlight.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      // Log do erro
      print('Erro ao buscar destaque por ID: $e');
      // Busca nos dados mockados como fallback
      final highlights = getMockWeeklyHighlights();
      return highlights.where((h) => h.id == id).firstOrNull;
    }
  }
  
  @override
  Future<void> markHighlightAsViewed(String id) async {
    try {
      // Obtém o ID do usuário atual
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        print('Usuário não autenticado');
        return;
      }
      
      // Verificar se o registro já existe
      final existing = await _supabaseClient
          .from('highlight_views')
          .select()
          .eq('highlight_id', id)
          .eq('user_id', userId);
      
      if ((existing as List).isEmpty) {
        // Insere novo registro de visualização
        await _supabaseClient.from('highlight_views').insert({
          'highlight_id': id,
          'user_id': userId,
          'viewed_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Erro ao marcar destaque como visualizado: $e');
    }
  }
} 