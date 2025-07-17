import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ray_club_app/features/workout/models/workout_category.dart';

class WorkoutCategoriesRepository {
  final SupabaseClient _supabase;

  WorkoutCategoriesRepository({SupabaseClient? supabase}) 
    : _supabase = supabase ?? Supabase.instance.client;

  // Buscar categoria por nome
  Future<WorkoutCategory?> getCategoryByName(String name) async {
    try {
      final response = await _supabase
          .from('workout_categories')
          .select()
          .ilike('name', name)
          .maybeSingle();

      if (response == null) return null;
      
      return WorkoutCategory.fromJson(response);
    } catch (e) {
      debugPrint('Erro ao buscar categoria por nome: $e');
      return null;
    }
  }
} 