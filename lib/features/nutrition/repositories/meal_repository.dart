// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart' as app_errors;
import 'package:ray_club_app/features/nutrition/models/meal.dart';
import 'package:ray_club_app/features/nutrition/repositories/meal_repository_interface.dart';

/// Provider for MealRepository
final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepository(Supabase.instance.client);
});

/// Repository for managing meal data
class MealRepository implements MealRepositoryInterface {
  final SupabaseClient _client;
  
  MealRepository(this._client);
  
  /// Fetch all meals for a user
  @override
  Future<List<Meal>> getMeals({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client
          .from('meals')
          .select()
          .eq('user_id', userId)
          .order('date_time', ascending: false);
      
      // Primeiro fazemos o select, depois aplicamos os filtros
      final response = await query;
      
      // Filtramos no Dart se as datas foram fornecidas
      var filteredData = response;
      
      if (startDate != null) {
        filteredData = filteredData.where(
          (data) => DateTime.parse(data['date_time']).isAfter(startDate) ||
                    DateTime.parse(data['date_time']).isAtSameMomentAs(startDate)
        ).toList();
      }
      
      if (endDate != null) {
        filteredData = filteredData.where(
          (data) => DateTime.parse(data['date_time']).isBefore(endDate) ||
                    DateTime.parse(data['date_time']).isAtSameMomentAs(endDate)
        ).toList();
      }
      
      return filteredData.map((data) => Meal.fromJson(data)).toList();
    } catch (e, stackTrace) {
      throw app_errors.StorageException(
        message: 'Failed to fetch meals',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Add a new meal
  @override
  Future<Meal> addMeal(Meal meal, String userId) async {
    try {
      final mealJson = meal.toJson();
      mealJson['user_id'] = userId;
      
      final response = await _client
          .from('meals')
          .insert(mealJson)
          .select()
          .single();
      
      return Meal.fromJson(response);
    } catch (e, stackTrace) {
      throw app_errors.StorageException(
        message: 'Failed to add meal',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Update an existing meal
  @override
  Future<Meal> updateMeal(Meal meal) async {
    try {
      final response = await _client
          .from('meals')
          .update(meal.toJson())
          .eq('id', meal.id)
          .select()
          .single();
      
      return Meal.fromJson(response);
    } catch (e, stackTrace) {
      throw app_errors.StorageException(
        message: 'Failed to update meal',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Delete a meal
  @override
  Future<void> deleteMeal(String mealId) async {
    try {
      await _client
          .from('meals')
          .delete()
          .eq('id', mealId);
    } catch (e, stackTrace) {
      throw app_errors.StorageException(
        message: 'Failed to delete meal',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
} 
