// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekly_highlight.freezed.dart';
part 'weekly_highlight.g.dart';

/// Classe para converter Color para/de JSON
class ColorConverter implements JsonConverter<Color, String> {
  const ColorConverter();

  @override
  Color fromJson(String json) {
    return Color(int.parse(json, radix: 16));
  }

  @override
  String toJson(Color color) {
    return color.value.toRadixString(16);
  }
}

/// Classe para converter IconData para/de JSON
class IconDataConverter implements JsonConverter<IconData, String> {
  const IconDataConverter();

  @override
  IconData fromJson(String json) {
    // Converte o código codePoint em hexadecimal para um IconData
    return IconData(
      int.parse(json, radix: 16),
      fontFamily: 'MaterialIcons',
    );
  }

  @override
  String toJson(IconData iconData) {
    // Converte o codePoint para uma string hexadecimal
    return iconData.codePoint.toRadixString(16);
  }
}

/// Modelo para um destaque da semana
@freezed
class WeeklyHighlight with _$WeeklyHighlight {
  const factory WeeklyHighlight({
    required String id,
    required String title,
    required String description,
    @IconDataConverter() required IconData icon,
    @ColorConverter() required Color color,
    String? subtitle,
    String? imageUrl,
    String? artImage,
    double? price,
    String? tagline,
    String? actionRoute,
    @Default(false) bool isFeatured,
    DateTime? startDate,
    DateTime? endDate,
  }) = _WeeklyHighlight;

  factory WeeklyHighlight.fromJson(Map<String, dynamic> json) => 
      _$WeeklyHighlightFromJson(json);
}

/// Dados mockados para teste
List<WeeklyHighlight> getMockWeeklyHighlights() {
  return [
    WeeklyHighlight(
      id: 'travel_workout',
      title: 'Treino para Viagem',
      description: 'Exercícios que você pode fazer em qualquer lugar durante suas viagens',
      subtitle: 'Para fazer em qualquer lugar',
      icon: Icons.airplanemode_active,
      color: Colors.blue,
      actionRoute: '/workouts/travel',
      isFeatured: true,
      artImage: 'assets/images/art_travel.jpg',
      price: 2.45,
      tagline: 'Treinos para fazer viajando',
    ),
    WeeklyHighlight(
      id: 'quick_hiit',
      title: 'HIIT de 10 Minutos',
      description: 'Queime calorias com esse treino intenso de apenas 10 minutos',
      subtitle: 'Treino rápido e intenso',
      icon: Icons.timer,
      color: Colors.red,
      actionRoute: '/workouts/quick-hiit',
      isFeatured: true,
      artImage: 'assets/images/art_hiit.jpg',
      price: 1.87,
      tagline: 'HIIT de 10 minutos',
    ),
    WeeklyHighlight(
      id: 'pre_workout_recipe',
      title: 'Receita Pré-Treino',
      description: 'Receita de pré-treino com apenas 2 ingredientes para maximizar energia',
      subtitle: 'Apenas 2 ingredientes',
      icon: Icons.blender,
      color: Colors.green,
      actionRoute: '/nutrition/pre-workout',
      isFeatured: true,
      artImage: 'assets/images/art_recipe.jpg',
      price: 3.15,
      tagline: 'Receita com 2 ingredientes',
    ),
    WeeklyHighlight(
      id: 'relaxing_yoga',
      title: 'Yoga para Relaxar',
      description: 'Sequência de yoga para relaxamento após um dia estressante',
      subtitle: 'Alivie a tensão em 15 min',
      icon: Icons.self_improvement,
      color: Colors.purple,
      actionRoute: '/workouts/relaxing-yoga',
      isFeatured: true,
      artImage: 'assets/images/art_yoga.jpg',
      price: 2.78,
      tagline: 'Yoga pra relaxar',
    ),
    WeeklyHighlight(
      id: 'office_stretching',
      title: 'Alongamento no Escritório',
      description: 'Exercícios de alongamento para fazer durante o trabalho',
      subtitle: 'Para fazer no trabalho',
      icon: Icons.chair,
      color: Colors.brown,
      actionRoute: '/workouts/office-stretch',
      isFeatured: true,
      artImage: 'assets/images/art_office.jpg',
      price: 1.55,
      tagline: 'Alongamento no trabalho',
    ),
    WeeklyHighlight(
      id: 'no_equipment_workout',
      title: 'Treino Sem Equipamentos',
      description: 'Treino completo de força usando apenas o peso do corpo',
      subtitle: 'Apenas peso corporal',
      icon: Icons.fitness_center,
      color: Colors.orange,
      actionRoute: '/workouts/no-equipment',
      isFeatured: true,
      artImage: 'assets/images/art_bodyweight.jpg',
      price: 3.42,
      tagline: 'Treino sem equipamentos',
    ),
  ];
} 