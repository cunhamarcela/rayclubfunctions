// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/core/providers/providers.dart';
import 'package:ray_club_app/features/auth/models/auth_state.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/nutrition/models/meal.dart';
import 'package:ray_club_app/features/nutrition/repositories/meal_repository_interface.dart';

part 'meal_view_model.freezed.dart';

/// Provider for MealViewModel
final mealViewModelProvider = StateNotifierProvider<MealViewModel, MealState>((ref) {
  final repository = ref.watch(mealRepositoryProvider);
  final authState = ref.watch(authViewModelProvider);
  
  return MealViewModel(repository, authState);
});

/// State for the MealViewModel
@freezed
class MealState with _$MealState {
  const factory MealState({
    @Default([]) List<Meal> meals,
    @Default(false) bool isLoading,
    String? error,
    @Default(false) bool isMealAdded,
    @Default(false) bool isMealUpdated,
    @Default(false) bool isMealDeleted,
  }) = _MealState;
}

/// ViewModel for managing meal data
class MealViewModel extends StateNotifier<MealState> {
  final MealRepositoryInterface _repository;
  final AuthState _authState;
  
  MealViewModel(this._repository, this._authState) : super(const MealState()) {
    initState();
  }
  
  /// Método que pode ser sobrescrito para testes
  void initState() {
    // Load meals initially if user is authenticated
    _authState.maybeWhen(
      authenticated: (user) => loadMeals(),
      orElse: () => null,
    );
  }
  
  /// Load all meals for the current user
  Future<void> loadMeals({DateTime? startDate, DateTime? endDate}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final userId = _getUserId();
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not authenticated',
        );
        return;
      }
      
      final meals = await _repository.getMeals(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      
      state = state.copyWith(
        meals: meals,
        isLoading: false,
        isMealAdded: false,
        isMealUpdated: false,
        isMealDeleted: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Add a new meal
  Future<void> addMeal(Meal meal) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final userId = _getUserId();
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not authenticated',
        );
        return;
      }
      
      final addedMeal = await _repository.addMeal(meal, userId);
      
      state = state.copyWith(
        meals: [addedMeal, ...state.meals],
        isLoading: false,
        isMealAdded: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Update an existing meal
  Future<void> updateMeal(Meal meal) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final updatedMeal = await _repository.updateMeal(meal);
      
      state = state.copyWith(
        meals: state.meals.map((m) => m.id == meal.id ? updatedMeal : m).toList(),
        isLoading: false,
        isMealUpdated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Delete a meal
  Future<void> deleteMeal(String mealId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _repository.deleteMeal(mealId);
      
      state = state.copyWith(
        meals: state.meals.where((meal) => meal.id != mealId).toList(),
        isLoading: false,
        isMealDeleted: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Get current user ID
  String? _getUserId() {
    return _authState.maybeWhen(
      authenticated: (user) => user.id,
      orElse: () => null,
    );
  }
  
  /// Calculate total calories from all meals
  int calculateTotalCalories() {
    return state.meals.fold<int>(0, (sum, meal) => sum + meal.calories);
  }
  
  /// Calculate total proteins from all meals
  double calculateTotalProteins() {
    return state.meals.fold<double>(0, (sum, meal) => sum + meal.proteins);
  }
  
  /// Calculate total carbs from all meals
  double calculateTotalCarbs() {
    return state.meals.fold<double>(0, (sum, meal) => sum + meal.carbs);
  }
  
  /// Calculate total fats from all meals
  double calculateTotalFats() {
    return state.meals.fold<double>(0, (sum, meal) => sum + meal.fats);
  }
  
  /// Calculate the percentage distribution of macronutrients
  Map<String, double> calculateMacroDistribution() {
    final totalProteins = calculateTotalProteins();
    final totalCarbs = calculateTotalCarbs();
    final totalFats = calculateTotalFats();
    
    final totalGrams = totalProteins + totalCarbs + totalFats;
    
    if (totalGrams == 0) {
      return {
        'protein': 0,
        'carbs': 0,
        'fats': 0,
      };
    }
    
    return {
      'protein': (totalProteins / totalGrams) * 100,
      'carbs': (totalCarbs / totalGrams) * 100,
      'fats': (totalFats / totalGrams) * 100,
    };
  }
  
  /// Get weekly nutrition statistics
  Future<List<Map<String, dynamic>>> getWeeklyStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final weekStats = <Map<String, dynamic>>[];
    
    // Calculate days between start and end date
    final days = endDate.difference(startDate).inDays + 1;
    final limit = days > 7 ? 7 : days; // Maximum of 7 days
    
    for (var i = 0; i < limit; i++) {
      final currentDate = startDate.add(Duration(days: i));
      final endOfDay = DateTime(
        currentDate.year, 
        currentDate.month, 
        currentDate.day, 
        23, 59, 59
      );
      
      // Load meals for this specific day
      await loadMeals(startDate: currentDate, endDate: endOfDay);
      
      weekStats.add({
        'date': currentDate,
        'calories': calculateTotalCalories(),
        'proteins': calculateTotalProteins(),
        'carbs': calculateTotalCarbs(),
        'fats': calculateTotalFats(),
      });
    }
    
    return weekStats;
  }
} 
