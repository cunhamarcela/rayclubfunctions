// Project imports:
import 'package:ray_club_app/features/nutrition/models/meal.dart';

/// Interface para operações relacionadas a refeições
abstract class MealRepositoryInterface {
  /// Busca refeições do usuário com filtros opcionais de data
  Future<List<Meal>> getMeals({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Adiciona uma nova refeição
  Future<Meal> addMeal(Meal meal, String userId);
  
  /// Atualiza uma refeição existente
  Future<Meal> updateMeal(Meal meal);
  
  /// Exclui uma refeição pelo ID
  Future<void> deleteMeal(String mealId);
} 
