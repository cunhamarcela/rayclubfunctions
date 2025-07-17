import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/providers/providers.dart';
import 'package:ray_club_app/features/workout/models/workout_video_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final workoutVideosRepositoryProvider = Provider<WorkoutVideosRepository>((ref) {
  return WorkoutVideosRepository(
    supabase: ref.watch(supabaseClientProvider),
    dio: ref.watch(dioProvider),
  );
});

class WorkoutVideosRepository {
  final SupabaseClient _supabase;

  WorkoutVideosRepository({
    required SupabaseClient supabase,
    required Dio dio,
  })  : _supabase = supabase;

  /// Busca vídeos por categoria ordenados por ordem de inserção
  /// TODOS os usuários veem TODOS os vídeos
  Future<List<WorkoutVideo>> getVideosByCategory(String category) async {
    try {
      final response = await _supabase
          .from('workout_videos')
          .select()
          .eq('category', category)
          .order('order_index', ascending: true)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => WorkoutVideo.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar vídeos da categoria $category: $e');
    }
  }

  /// Busca vídeos populares ordenados por ordem de inserção
  Future<List<WorkoutVideo>> getPopularVideos({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('workout_videos')
          .select()
          .eq('is_popular', true)
          .limit(limit)
          .order('order_index', ascending: true)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => WorkoutVideo.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar vídeos populares: $e');
    }
  }

  /// Busca vídeos recomendados ordenados por ordem de inserção
  Future<List<WorkoutVideo>> getRecommendedVideos({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('workout_videos')
          .select()
          .eq('is_recommended', true)
          .limit(limit)
          .order('order_index', ascending: true)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => WorkoutVideo.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar vídeos recomendados: $e');
    }
  }

  /// Busca vídeos novos ordenados por ordem de inserção
  Future<List<WorkoutVideo>> getNewVideos({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('workout_videos')
          .select()
          .eq('is_new', true)
          .limit(limit)
          .order('order_index', ascending: true)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => WorkoutVideo.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar vídeos novos: $e');
    }
  }

  /// Busca todos os vídeos ordenados por ordem de inserção
  Future<List<WorkoutVideo>> getAllVideos() async {
    try {
      final response = await _supabase
          .from('workout_videos')
          .select()
          .order('order_index', ascending: true)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => WorkoutVideo.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar todos os vídeos: $e');
    }
  }

  /// Busca vídeos com filtros ordenados por ordem de inserção
  Future<List<WorkoutVideo>> searchVideos({
    String? query,
    String? category,
    String? difficulty,
    String? instructor,
    int? maxDuration,
  }) async {
    try {
      var queryBuilder = _supabase.from('workout_videos').select();

      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.or('title.ilike.%$query%,description.ilike.%$query%');
      }

      if (category != null) {
        queryBuilder = queryBuilder.eq('category', category);
      }

      if (difficulty != null) {
        queryBuilder = queryBuilder.eq('difficulty', difficulty);
      }

      if (instructor != null) {
        queryBuilder = queryBuilder.eq('instructor_name', instructor);
      }

      if (maxDuration != null) {
        queryBuilder = queryBuilder.lte('duration_minutes', maxDuration);
      }

      final response = await queryBuilder
          .order('order_index', ascending: true)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => WorkoutVideo.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar vídeos: $e');
    }
  }

  /// NOVA: Verifica se usuário pode acessar o link de um vídeo específico
  Future<bool> canUserAccessVideoLink(String videoId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase.rpc('can_user_access_video_link', 
        params: {
          'p_user_id': userId,
          'p_video_id': videoId,
        });

      return response as bool;
    } catch (e) {
      debugPrint('Erro ao verificar acesso ao vídeo: $e');
      return false;
    }
  }

  /// NOVA: Obtém nível do usuário atual
  Future<String> getCurrentUserLevel() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      print('🔍 [getCurrentUserLevel] User ID atual: $userId');
      
      if (userId == null) {
        print('❌ [getCurrentUserLevel] Usuário não autenticado');
        return 'basic';
      }

      print('🔍 [getCurrentUserLevel] Chamando RPC get_user_level...');
      final response = await _supabase.rpc('get_user_level', 
        params: {
          'p_user_id': userId,
        });

      final level = response as String? ?? 'basic';
      print('✅ [getCurrentUserLevel] RPC retornou: "$level" para user $userId');
      
      return level;
    } catch (e) {
      print('❌ [getCurrentUserLevel] Erro ao obter nível do usuário: $e');
      return 'basic';
    }
  }

  /// Registra visualização de vídeo
  Future<void> recordVideoView(String videoId, String userId) async {
    try {
      await _supabase.from('workout_video_views').insert({
        'video_id': videoId,
        'user_id': userId,
        'viewed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Ignora erro se já foi visualizado
      debugPrint('Erro ao registrar visualização: $e');
    }
  }
} 