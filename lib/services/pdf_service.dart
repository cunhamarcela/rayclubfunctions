import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ray_club_app/core/providers/providers.dart';
import 'package:ray_club_app/models/material.dart';

final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService(
    supabase: ref.watch(supabaseClientProvider),
  );
});

/// Serviço unificado para gerenciar PDFs no Supabase
class PdfService {
  final SupabaseClient _supabase;

  PdfService({required SupabaseClient supabase}) : _supabase = supabase;

  /// Gera URL assinada para visualização segura do PDF
  Future<String> generateSignedUrl(String filePath, {int expiresInSeconds = 60}) async {
    try {
      final response = await _supabase.storage
          .from('materials')
          .createSignedUrl(filePath, expiresInSeconds);

      return response;
    } catch (e) {
      debugPrint('Erro ao gerar URL assinada: $e');
      throw Exception('Erro ao acessar o material: $e');
    }
  }

  /// Cria URL do Google Docs Viewer para renderização segura
  String createViewerUrl(String signedUrl) {
    return 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(signedUrl)}';
  }

  /// Busca materiais por contexto (workout, nutrition, general)
  Future<List<Material>> getMaterialsByContext(MaterialContext context) async {
    try {
      final response = await _supabase
          .from('materials')
          .select()
          .eq('material_context', context.name)
          .order('order_index', ascending: true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Material.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar materiais: $e');
      throw Exception('Erro ao carregar materiais: $e');
    }
  }

  /// Busca PDFs específicos de um vídeo de treino
  Future<List<Material>> getMaterialsByWorkoutVideo(String workoutVideoId) async {
    try {
      final response = await _supabase
          .from('materials')
          .select()
          .eq('workout_video_id', workoutVideoId)
          .order('order_index', ascending: true);

      return (response as List)
          .map((json) => Material.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar materiais do treino: $e');
      return []; // Retorna lista vazia se não houver PDFs
    }
  }

  /// Busca material por ID
  Future<Material?> getMaterialById(String id) async {
    try {
      final response = await _supabase
          .from('materials')
          .select()
          .eq('id', id)
          .single();

      return Material.fromJson(response);
    } catch (e) {
      debugPrint('Erro ao buscar material: $e');
      return null;
    }
  }
} 