// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/providers/service_providers.dart';
import 'package:ray_club_app/features/nutrition/repositories/meal_repository_interface.dart';
import 'package:ray_club_app/features/nutrition/repositories/supabase_meal_repository.dart';

/// Provider para o repositório de refeições
final mealRepositoryProvider = Provider<MealRepository>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final supabase = Supabase.instance.client;
  
  return SupabaseMealRepository(
    supabaseClient: supabase,
    storageService: storageService,
  );
}); 
