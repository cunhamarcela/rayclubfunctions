import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔄 Analisando receitas da Bruna Braga...');
  
  // Ler o arquivo MD
  final file = File('../lib/features/nutrition/screens/Receitas Escritas - Bruna Braga Nutrição.md');
  final content = await file.readAsString();
  
  // Extrair receitas
  final recipes = parseRecipes(content);
  
  print('📊 Total de receitas encontradas: ${recipes.length}');
  
  // Analisar filtros únicos
  final filters = extractUniqueFilters(recipes);
  print('🏷️ Filtros únicos encontrados:');
  filters.forEach((category, options) {
    print('  $category: ${options.join(", ")}');
  });
  
  // Gerar JSON das receitas
  final recipesJson = recipes.map((recipe) => recipe.toJson()).toList();
  
  // Salvar em arquivo para análise
  final outputFile = File('bruna_recipes_parsed.json');
  await outputFile.writeAsString(jsonEncode(recipesJson));
  
  print('✅ Receitas salvas em: ${outputFile.path}');
  
  // Gerar SQL de inserção
  generateInsertSQL(recipes);
}

List<BrunaRecipe> parseRecipes(String content) {
  final recipes = <BrunaRecipe>[];
  
  // Split por delimitador de receitas
  final sections = content.split('________________');
  
  for (final section in sections) {
    final lines = section.trim().split('\n');
    if (lines.length < 5) continue;
    
    BrunaRecipe? recipe;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.startsWith('Título da Receita:')) {
        recipe = BrunaRecipe(
          title: line.substring('Título da Receita:'.length).trim(),
        );
      } else if (line.startsWith('Filtros:') && recipe != null) {
        final filtersText = line.substring('Filtros:'.length).trim();
        recipe.filters = filtersText.split(' / ').map((e) => e.trim()).toList();
      } else if (line.startsWith('Tempo de preparo:') && recipe != null) {
        final timeText = line.substring('Tempo de preparo:'.length).trim();
        recipe.preparationTime = timeText;
      } else if (line.startsWith('Valor calórico estimado:') && recipe != null) {
        final caloriesText = line.substring('Valor calórico estimado:'.length).trim();
        recipe.calories = caloriesText;
      } else if (line.startsWith('Porção rende para:') && recipe != null) {
        final servingsText = line.substring('Porção rende para:'.length).trim();
        recipe.servings = servingsText;
      } else if (line == 'Ingredientes:' && recipe != null) {
        // Capturar ingredientes
        i++; // próxima linha
        final ingredients = <String>[];
        while (i < lines.length && lines[i].trim().startsWith('*')) {
          ingredients.add(lines[i].trim().substring(1).trim());
          i++;
        }
        recipe.ingredients = ingredients;
        i--; // voltar uma linha
      } else if (line == 'Modo de preparo:' && recipe != null) {
        // Capturar modo de preparo
        i++; // próxima linha
        final instructions = <String>[];
        while (i < lines.length && lines[i].trim().startsWith('*')) {
          instructions.add(lines[i].trim().substring(1).trim());
          i++;
        }
        recipe.instructions = instructions;
        i--; // voltar uma linha
      }
    }
    
    if (recipe != null && recipe.title.isNotEmpty) {
      recipes.add(recipe);
    }
  }
  
  return recipes;
}

Map<String, Set<String>> extractUniqueFilters(List<BrunaRecipe> recipes) {
  final filterCategories = <String, Set<String>>{
    'Objetivo': <String>{},
    'Paladar': <String>{},
    'Refeição': <String>{},
    'Timing': <String>{},
    'Macronutrientes': <String>{},
    'Outros': <String>{},
  };
  
  for (final recipe in recipes) {
    for (final filter in recipe.filters) {
      // Categorizar filtros baseado no documento
      if (['Emagrecimento', 'Hipertrofia'].contains(filter)) {
        filterCategories['Objetivo']!.add(filter);
      } else if (['Doce', 'Salgado', 'Paladar Infantil'].contains(filter)) {
        filterCategories['Paladar']!.add(filter);
      } else if (['Café da Manhã', 'Almoço', 'Lanche da Tarde', 'Jantar', 'Lanche', 'Sobremesa', 'Café da manhã'].contains(filter)) {
        filterCategories['Refeição']!.add(filter);
      } else if (['Pré Treino', 'Pós Treino', 'Pós-treino'].contains(filter)) {
        filterCategories['Timing']!.add(filter);
      } else if (['Carboidratos', 'Proteínas', 'Gorduras', 'Proteína'].contains(filter)) {
        filterCategories['Macronutrientes']!.add(filter);
      } else {
        filterCategories['Outros']!.add(filter);
      }
    }
  }
  
  return filterCategories.map((key, value) => MapEntry(key, value));
}

void generateInsertSQL(List<BrunaRecipe> recipes) {
  print('\n🔨 Gerando SQL de inserção...');
  
  final sqlFile = File('insert_bruna_recipes.sql');
  final buffer = StringBuffer();
  
  buffer.writeln('-- Receitas reais da Bruna Braga extraídas do documento oficial');
  buffer.writeln('-- Gerado automaticamente em ${DateTime.now()}');
  buffer.writeln();
  buffer.writeln('-- Limpar receitas mockadas existentes');
  buffer.writeln("DELETE FROM recipes WHERE author_name = 'Bruna Braga' OR author_name = 'Dra. Maria Silva';");
  buffer.writeln();
  
  for (int i = 0; i < recipes.length; i++) {
    final recipe = recipes[i];
    buffer.writeln('-- Receita ${i + 1}: ${recipe.title}');
    buffer.writeln('INSERT INTO recipes (');
    buffer.writeln('    title,');
    buffer.writeln('    description,');
    buffer.writeln('    category,');
    buffer.writeln('    preparation_time_minutes,');
    buffer.writeln('    calories,');
    buffer.writeln('    servings,');
    buffer.writeln('    difficulty,');
    buffer.writeln('    rating,');
    buffer.writeln('    content_type,');
    buffer.writeln('    author_name,');
    buffer.writeln('    author_type,');
    buffer.writeln('    is_featured,');
    buffer.writeln('    ingredients,');
    buffer.writeln('    instructions,');
    buffer.writeln('    tags,');
    buffer.writeln('    created_at,');
    buffer.writeln('    updated_at');
    buffer.writeln(') VALUES (');
    buffer.writeln("    '${recipe.title.replaceAll("'", "''")}',");
    buffer.writeln("    '${recipe.generateDescription().replaceAll("'", "''")}',");
    buffer.writeln("    '${recipe.getMainCategory()}',");
    buffer.writeln("    ${recipe.getPreparationMinutes()},");
    buffer.writeln("    ${recipe.getCaloriesNumber()},");
    buffer.writeln("    ${recipe.getServingsNumber()},");
    buffer.writeln("    'Fácil',");
    buffer.writeln("    4.5,");
    buffer.writeln("    'text',");
    buffer.writeln("    'Bruna Braga',");
    buffer.writeln("    'nutritionist',");
    buffer.writeln("    ${i < 5 ? 'true' : 'false'},");
    buffer.writeln("    ARRAY[${recipe.ingredients.map((ing) => "'${ing.replaceAll("'", "''")}'").join(', ')}],");
    buffer.writeln("    ARRAY[${recipe.instructions.map((inst) => "'${inst.replaceAll("'", "''")}'").join(', ')}],");
    buffer.writeln("    ARRAY[${recipe.filters.map((filter) => "'${filter.replaceAll("'", "''")}'").join(', ')}],");
    buffer.writeln("    NOW(),");
    buffer.writeln("    NOW()");
    buffer.writeln(');');
    buffer.writeln();
  }
  
  sqlFile.writeAsStringSync(buffer.toString());
  print('📄 SQL gerado em: ${sqlFile.path}');
}

class BrunaRecipe {
  String title = '';
  List<String> filters = [];
  String preparationTime = '';
  String calories = '';
  String servings = '';
  List<String> ingredients = [];
  List<String> instructions = [];
  
  BrunaRecipe({required this.title});
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'filters': filters,
      'preparationTime': preparationTime,
      'calories': calories,
      'servings': servings,
      'ingredients': ingredients,
      'instructions': instructions,
    };
  }
  
  String generateDescription() {
    // Gerar descrição baseada nos filtros
    final descriptions = <String>[];
    
    if (filters.contains('Emagrecimento')) descriptions.add('Ideal para emagrecimento');
    if (filters.contains('Hipertrofia')) descriptions.add('Rico em proteínas');
    if (filters.contains('Low Carb')) descriptions.add('Baixo em carboidratos');
    if (filters.contains('Detox')) descriptions.add('Propriedades detox');
    if (filters.contains('Vegano')) descriptions.add('100% vegano');
    
    if (descriptions.isEmpty) {
      descriptions.add('Receita saudável e nutritiva');
    }
    
    return descriptions.join(', ') + '.';
  }
  
  String getMainCategory() {
    // Determinar categoria principal baseada nos filtros
    if (filters.any((f) => ['Café da Manhã', 'Café da manhã'].contains(f))) return 'Café da Manhã';
    if (filters.contains('Almoço')) return 'Almoço';
    if (filters.contains('Jantar')) return 'Jantar';
    if (filters.any((f) => ['Lanche', 'Lanche da Tarde'].contains(f))) return 'Lanches';
    if (filters.contains('Sobremesa')) return 'Sobremesas';
    if (filters.contains('Sopa')) return 'Sopas';
    
    return 'Receitas Gerais';
  }
  
  int getPreparationMinutes() {
    // Extrair minutos do texto
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(preparationTime);
    return match != null ? int.parse(match.group(1)!) : 30;
  }
  
  int getCaloriesNumber() {
    // Extrair número de calorias
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(calories);
    return match != null ? int.parse(match.group(1)!) : 200;
  }
  
  int getServingsNumber() {
    // Extrair número de porções
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(servings);
    return match != null ? int.parse(match.group(1)!) : 1;
  }
} 