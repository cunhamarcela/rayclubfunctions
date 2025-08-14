/// Mapeamento entre modalidades de exercício (registro) e categorias de metas
/// 
/// **Data:** 2025-01-21 às 15:20
/// **Objetivo:** Conectar automaticamente exercícios registrados às metas correspondentes
/// **Referência:** Sistema de metas automático Ray Club

class WorkoutCategoryMapping {
  /// Mapa que conecta modalidades de exercício (tela de registro) 
  /// com categorias de metas (dashboard fitness)
  static const Map<String, String> exerciseToGoalCategory = {
    // Modalidades de Exercício → Categorias de Metas
    
    // 🏃‍♀️ Atividades Cardiovasculares
    'Corrida': 'corrida',
    'Caminhada': 'caminhada', 
    'Ciclismo': 'ciclismo',
    'Cardio': 'cardio',
    'HIIT': 'hiit',
    'Dança': 'danca',
    
    // 🧘‍♀️ Atividades de Flexibilidade/Bem-estar
    'Yoga': 'yoga',
    'Pilates': 'pilates',
    'Alongamento': 'alongamento',
    
    // 💪 Atividades de Força
    'Musculação': 'musculacao',
    'Funcional': 'funcional',
    'CrossFit': 'crossfit',
    
    // 🏊‍♀️ Outras atividades
    'Natação': 'natacao',
    'Luta': 'luta',
    'Fisioterapia': 'fisioterapia',
    
    // ⚡ Genéricos (fallback)
    'Treino': 'geral',
    'Exercício': 'geral',
    'Outro': 'geral',
  };

  /// Categorias válidas para metas (baseado na tela de criação de metas)
  static const List<String> validGoalCategories = [
    'corrida',
    'caminhada', 
    'yoga',
    'funcional',
    'musculacao',
    'natacao',
    'ciclismo',
    'crossfit',
    'pilates',
    'alongamento',
    'cardio',
    'hiit',
    'danca',
    'luta',
    'fisioterapia',
    'geral',
  ];

  /// Converte uma modalidade de exercício para categoria de meta
  /// 
  /// **Exemplo:**
  /// ```dart
  /// getGoalCategory('Corrida') // retorna 'corrida'
  /// getGoalCategory('Treino Funcional') // retorna 'funcional' 
  /// getGoalCategory('Modalidade Inexistente') // retorna 'geral'
  /// ```
  static String getGoalCategory(String exerciseType) {
    if (exerciseType.isEmpty) return 'geral';
    
    // Primeiro, tentar match exato
    final exactMatch = exerciseToGoalCategory[exerciseType];
    if (exactMatch != null) return exactMatch;
    
    // Se não encontrar, tentar match parcial (case insensitive)
    final lowerExerciseType = exerciseType.toLowerCase();
    
    for (final entry in exerciseToGoalCategory.entries) {
      if (lowerExerciseType.contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(lowerExerciseType)) {
        return entry.value;
      }
    }
    
    // Fallback para categoria geral
    return 'geral';
  }

  /// Verifica se uma categoria de meta é válida
  static bool isValidGoalCategory(String category) {
    return validGoalCategories.contains(category.toLowerCase());
  }

  /// Obtém lista de modalidades que mapeiam para uma categoria específica
  static List<String> getExerciseTypesForCategory(String goalCategory) {
    return exerciseToGoalCategory.entries
        .where((entry) => entry.value == goalCategory)
        .map((entry) => entry.key)
        .toList();
  }

  /// Lista todas as modalidades de exercício disponíveis
  static List<String> get allExerciseTypes => exerciseToGoalCategory.keys.toList();
  
  /// Lista todas as categorias de meta disponíveis  
  static List<String> get allGoalCategories => validGoalCategories;
} 