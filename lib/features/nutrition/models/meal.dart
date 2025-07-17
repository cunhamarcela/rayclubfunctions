// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal.freezed.dart';
part 'meal.g.dart';

/// Representa uma refeição de usuário com informações nutricionais.
/// Este modelo é usado para armazenar e gerenciar dados de alimentação
/// como calorias, macronutrientes e metadados relacionados.
@freezed
class Meal with _$Meal {
  const factory Meal({
    /// Identificador único da refeição
    required String id,
    
    /// Nome da refeição (ex: "Café da manhã", "Almoço")
    required String name,
    
    /// Data e hora em que a refeição foi consumida
    required DateTime dateTime,
    
    /// Quantidade total de calorias (kcal)
    required int calories,
    
    /// Quantidade de proteínas em gramas
    required double proteins,
    
    /// Quantidade de carboidratos em gramas
    required double carbs,
    
    /// Quantidade de gorduras em gramas
    required double fats,
    
    /// Observações adicionais sobre a refeição
    String? notes,
    
    /// URL da imagem da refeição, quando disponível
    String? imageUrl,
    
    /// Indica se a refeição foi marcada como favorita
    @Default(false) bool isFavorite,
    
    /// Lista de tags para categorização (ex: "lowcarb", "vegetariano")
    @Default([]) List<String> tags,
  }) = _Meal;

  /// Cria uma instância de Meal a partir de um mapa JSON
  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);

  /// Cria uma refeição vazia com valores padrão
  /// Útil para inicializar formulários de criação de refeição
  factory Meal.empty() => Meal(
        id: '',
        name: '',
        dateTime: DateTime.now(),
        calories: 0,
        proteins: 0,
        carbs: 0,
        fats: 0,
      );
} 
