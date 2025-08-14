import 'package:flutter/material.dart';

/// Modelo para metas pré-estabelecidas por categoria de exercício
class PresetCategoryGoal {
  final String category;
  final String displayName;
  final String description;
  final String emoji;
  final Color color;
  final int defaultMinutes;
  final List<int> suggestedMinutes;
  final List<int> suggestedDays;
  final String unit; // 'minutes' ou 'days'

  const PresetCategoryGoal({
    required this.category,
    required this.displayName,
    required this.description,
    required this.emoji,
    required this.color,
    required this.defaultMinutes,
    required this.suggestedMinutes,
    required this.suggestedDays,
    this.unit = 'minutes',
  });

  /// Lista de todas as metas pré-estabelecidas disponíveis
  static List<PresetCategoryGoal> get allPresets => [
    // Cardio
    const PresetCategoryGoal(
      category: 'cardio',
      displayName: 'Cardio',
      description: 'Exercícios cardiovasculares para melhorar resistência',
      emoji: '❤️',
      color: Color(0xFFE74C3C),
      defaultMinutes: 150,
      suggestedMinutes: [90, 120, 150, 180, 210],
      suggestedDays: [2, 3, 4, 5],
    ),

    // Musculação
    const PresetCategoryGoal(
      category: 'musculacao',
      displayName: 'Musculação',
      description: 'Treinos de força para desenvolvimento muscular',
      emoji: '💪',
      color: Color(0xFF2E8B57),
      defaultMinutes: 180,
      suggestedMinutes: [120, 150, 180, 210, 240],
      suggestedDays: [2, 3, 4, 5],
    ),

    // Funcional
    const PresetCategoryGoal(
      category: 'funcional',
      displayName: 'Funcional',
      description: 'Movimentos funcionais para o dia a dia',
      emoji: '🏃‍♀️',
      color: Color(0xFFE74C3C),
      defaultMinutes: 120,
      suggestedMinutes: [60, 90, 120, 150, 180],
      suggestedDays: [2, 3, 4, 5],
    ),

    // Yoga
    const PresetCategoryGoal(
      category: 'yoga',
      displayName: 'Yoga',
      description: 'Práticas de yoga para flexibilidade e bem-estar',
      emoji: '🧘‍♀️',
      color: Color(0xFF9B59B6),
      defaultMinutes: 90,
      suggestedMinutes: [60, 75, 90, 120, 150],
      suggestedDays: [2, 3, 4, 5, 6, 7],
    ),

    // Pilates
    const PresetCategoryGoal(
      category: 'pilates',
      displayName: 'Pilates',
      description: 'Fortalecimento do core e postura',
      emoji: '🤸‍♀️',
      color: Color(0xFF009688),
      defaultMinutes: 120,
      suggestedMinutes: [60, 90, 120, 150, 180],
      suggestedDays: [2, 3, 4, 5],
    ),

    // HIIT
    const PresetCategoryGoal(
      category: 'hiit',
      displayName: 'HIIT',
      description: 'Treinos intervalados de alta intensidade',
      emoji: '🔥',
      color: Color(0xFFFF6B35),
      defaultMinutes: 60,
      suggestedMinutes: [30, 45, 60, 75, 90],
      suggestedDays: [2, 3, 4],
    ),

    // Alongamento
    const PresetCategoryGoal(
      category: 'alongamento',
      displayName: 'Alongamento',
      description: 'Exercícios para flexibilidade e recuperação',
      emoji: '🌿',
      color: Color(0xFF4CAF50),
      defaultMinutes: 60,
      suggestedMinutes: [30, 45, 60, 90, 120],
      suggestedDays: [3, 4, 5, 6, 7],
    ),

    // Dança
    const PresetCategoryGoal(
      category: 'danca',
      displayName: 'Dança',
      description: 'Atividades de dança para diversão e exercício',
      emoji: '💃',
      color: Color(0xFFE91E63),
      defaultMinutes: 90,
      suggestedMinutes: [60, 75, 90, 120, 150],
      suggestedDays: [2, 3, 4, 5],
    ),

    // Corrida
    const PresetCategoryGoal(
      category: 'corrida',
      displayName: 'Corrida',
      description: 'Exercícios de corrida para resistência cardiovascular',
      emoji: '🏃‍♂️',
      color: Color(0xFF3498DB),
      defaultMinutes: 120,
      suggestedMinutes: [60, 90, 120, 150, 180],
      suggestedDays: [2, 3, 4, 5],
    ),

    // Caminhada
    const PresetCategoryGoal(
      category: 'caminhada',
      displayName: 'Caminhada',
      description: 'Caminhadas para atividade física regular',
      emoji: '🚶‍♀️',
      color: Color(0xFF27AE60),
      defaultMinutes: 150,
      suggestedMinutes: [90, 120, 150, 180, 210],
      suggestedDays: [3, 4, 5, 6, 7],
    ),

    // Força (treinos específicos de força)
    const PresetCategoryGoal(
      category: 'forca',
      displayName: 'Força',
      description: 'Treinos específicos de força e potência',
      emoji: '🏋️‍♀️',
      color: Color(0xFF8E44AD),
      defaultMinutes: 90,
      suggestedMinutes: [60, 75, 90, 120, 150],
      suggestedDays: [2, 3, 4],
    ),

    // Fisioterapia
    const PresetCategoryGoal(
      category: 'fisioterapia',
      displayName: 'Fisioterapia',
      description: 'Exercícios terapêuticos e reabilitação',
      emoji: '🩺',
      color: Color(0xFF16A085),
      defaultMinutes: 60,
      suggestedMinutes: [30, 45, 60, 75, 90],
      suggestedDays: [3, 4, 5, 6, 7],
    ),

    // Flexibilidade
    const PresetCategoryGoal(
      category: 'flexibilidade',
      displayName: 'Flexibilidade',
      description: 'Exercícios para melhorar amplitude de movimento',
      emoji: '🤸‍♂️',
      color: Color(0xFF1ABC9C),
      defaultMinutes: 45,
      suggestedMinutes: [30, 45, 60, 75, 90],
      suggestedDays: [4, 5, 6, 7],
    ),

    // Outro (personalizado)
    const PresetCategoryGoal(
      category: 'outro',
      displayName: 'Outro',
      description: 'Atividades personalizadas',
      emoji: '⭐',
      color: Color(0xFF95A5A6),
      defaultMinutes: 90,
      suggestedMinutes: [60, 90, 120, 150, 180],
      suggestedDays: [2, 3, 4, 5],
    ),
  ];

  /// Obter preset por categoria
  static PresetCategoryGoal? getByCategory(String category) {
    try {
      return allPresets.firstWhere(
        (preset) => preset.category.toLowerCase() == category.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Formatar minutos para exibição amigável
  String formatMinutes(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    } else if (minutes % 60 == 0) {
      return '${minutes ~/ 60}h';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}min';
    }
  }

  /// Calcular meta em dias baseada em duração média por sessão
  int calculateDaysFromMinutes(int totalMinutes, {int avgSessionMinutes = 30}) {
    return (totalMinutes / avgSessionMinutes).ceil();
  }

  /// Obter cor mais clara para background
  Color get lightColor => color.withOpacity(0.1);

  /// Obter texto motivacional baseado na categoria
  String get motivationalText {
    switch (category) {
      case 'cardio':
        return 'Seu coração vai agradecer! 💓';
      case 'musculacao':
        return 'Construindo força e confiança! 💪';
      case 'funcional':
        return 'Movimentos para a vida real! 🌟';
      case 'yoga':
        return 'Equilibrio de corpo e mente! 🧘‍♀️';
      case 'pilates':
        return 'Core forte, postura perfeita! ✨';
      case 'hiit':
        return 'Máximo resultado em pouco tempo! 🔥';
      case 'alongamento':
        return 'Flexibilidade e bem-estar! 🌿';
      case 'danca':
        return 'Diversão em movimento! 💃';
      case 'corrida':
        return 'Um passo de cada vez! 🏃‍♂️';
      case 'caminhada':
        return 'Movimento suave e constante! 🚶‍♀️';
      default:
        return 'Vamos nessa! ⭐';
    }
  }
}

/// Opções de unidade de medição para metas
enum GoalUnit {
  minutes('minutes', 'Minutos', 'min'),
  days('days', 'Dias', 'dias');

  const GoalUnit(this.value, this.label, this.shortLabel);
  
  final String value;
  final String label;
  final String shortLabel;
} 