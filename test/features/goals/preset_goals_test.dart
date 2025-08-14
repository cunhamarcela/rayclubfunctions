import 'package:flutter_test/flutter_test.dart';
import 'package:ray_club_app/features/goals/models/preset_category_goals.dart';

void main() {
  group('PresetCategoryGoal Tests', () {
    test('deve ter todas as categorias definidas', () {
      final presets = PresetCategoryGoal.allPresets;
      
      expect(presets.length, greaterThanOrEqualTo(11));
      
      // Verificar se categorias essenciais estão presentes
      final categories = presets.map((p) => p.category).toList();
      expect(categories, contains('cardio'));
      expect(categories, contains('musculacao'));
      expect(categories, contains('funcional'));
      expect(categories, contains('yoga'));
      expect(categories, contains('pilates'));
      expect(categories, contains('hiit'));
      expect(categories, contains('alongamento'));
      expect(categories, contains('danca'));
      expect(categories, contains('corrida'));
      expect(categories, contains('caminhada'));
    });

    test('deve formatar minutos corretamente', () {
      final preset = PresetCategoryGoal.allPresets.first;
      
      expect(preset.formatMinutes(30), equals('30min'));
      expect(preset.formatMinutes(60), equals('1h'));
      expect(preset.formatMinutes(90), equals('1h 30min'));
      expect(preset.formatMinutes(120), equals('2h'));
    });

    test('deve calcular dias a partir de minutos', () {
      final preset = PresetCategoryGoal.allPresets.first;
      
      expect(preset.calculateDaysFromMinutes(90, avgSessionMinutes: 30), equals(3));
      expect(preset.calculateDaysFromMinutes(120, avgSessionMinutes: 40), equals(3));
      expect(preset.calculateDaysFromMinutes(150, avgSessionMinutes: 50), equals(3));
    });

    test('deve encontrar preset por categoria', () {
      final cardioPreset = PresetCategoryGoal.getByCategory('cardio');
      expect(cardioPreset, isNotNull);
      expect(cardioPreset!.category, equals('cardio'));
      expect(cardioPreset.displayName, equals('Cardio'));
      expect(cardioPreset.emoji, equals('❤️'));

      final musculacaoPreset = PresetCategoryGoal.getByCategory('musculacao');
      expect(musculacaoPreset, isNotNull);
      expect(musculacaoPreset!.category, equals('musculacao'));
      expect(musculacaoPreset.displayName, equals('Musculação'));
      expect(musculacaoPreset.emoji, equals('💪'));
    });

    test('deve retornar null para categoria inexistente', () {
      final inexistente = PresetCategoryGoal.getByCategory('categoria_inexistente');
      expect(inexistente, isNull);
    });

    test('deve ter valores padrão razoáveis', () {
      for (final preset in PresetCategoryGoal.allPresets) {
        // Valores padrão entre 30 min e 4 horas
        expect(preset.defaultMinutes, greaterThanOrEqualTo(30));
        expect(preset.defaultMinutes, lessThanOrEqualTo(240));
        
        // Deve ter pelo menos 3 sugestões de minutos
        expect(preset.suggestedMinutes.length, greaterThanOrEqualTo(3));
        
        // Deve ter pelo menos 2 sugestões de dias
        expect(preset.suggestedDays.length, greaterThanOrEqualTo(2));
        
        // Sugestões de dias devem ser entre 1 e 7
        for (final day in preset.suggestedDays) {
          expect(day, greaterThanOrEqualTo(1));
          expect(day, lessThanOrEqualTo(7));
        }
      }
    });

    test('deve ter textos motivacionais únicos', () {
      final motivationalTexts = PresetCategoryGoal.allPresets
          .map((p) => p.motivationalText)
          .toSet();
      
      // A maioria deve ter textos únicos (permitir algumas repetições)
      expect(motivationalTexts.length, greaterThanOrEqualTo(8));
    });

    test('deve ter cores diferentes para categorias principais', () {
      final colors = PresetCategoryGoal.allPresets
          .take(5) // Primeiras 5 categorias
          .map((p) => p.color)
          .toSet();
      
      expect(colors.length, greaterThanOrEqualTo(4)); // Pelo menos 4 cores diferentes
    });
  });

  group('GoalUnit Tests', () {
    test('deve ter unidades corretas', () {
      expect(GoalUnit.minutes.value, equals('minutes'));
      expect(GoalUnit.minutes.label, equals('Minutos'));
      expect(GoalUnit.minutes.shortLabel, equals('min'));

      expect(GoalUnit.days.value, equals('days'));
      expect(GoalUnit.days.label, equals('Dias'));
      expect(GoalUnit.days.shortLabel, equals('dias'));
    });
  });
} 