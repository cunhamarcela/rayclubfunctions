// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/theme/app_theme.dart';
import '../viewmodels/meal_view_model.dart';

@RoutePage()
class MealDetailScreen extends ConsumerWidget {
  final String mealId;

  const MealDetailScreen({
    super.key,
    @PathParam('id') required this.mealId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtém o ViewModel para todas as refeições
    final mealViewModel = ref.watch(mealViewModelProvider);
    
    // Verifica se o estado está carregando
    if (mealViewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Verifica se há erro
    if (mealViewModel.error != null) {
      return Scaffold(
        body: Center(child: Text('Erro: ${mealViewModel.error}')),
      );
    }
    
    // Encontra a refeição específica pelo ID
    final meal = mealViewModel.meals.firstWhere(
      (meal) => meal.id == mealId,
      orElse: () => throw Exception('Refeição não encontrada'),
    );
    
    // Renderiza os detalhes da refeição
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: _buildMealDetail(context, meal.toJson()),
    );
  }

  Widget _buildMealDetail(BuildContext context, Map<String, dynamic> meal) {
    return CustomScrollView(
      slivers: [
        // Imagem de fundo expandida com header
        _buildSliverAppBar(context, meal),
        
        // Conteúdo
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -30),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumo da refeição
                    _buildMealSummary(context, meal),
                    
                    const SizedBox(height: 24),
                    
                    // Macronutrientes
                    _buildMacronutrients(context, meal),
                    
                    const SizedBox(height: 24),
                    
                    // Seção de ingredientes
                    const Text(
                      'Ingredientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildIngredientsList(context, meal),
                    
                    const SizedBox(height: 24),
                    
                    // Preparação (ou receita)
                    if (meal['preparation'] != null) ...[
                      const Text(
                        'Preparação',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPreparationSteps(context, meal),
                      
                      const SizedBox(height: 24),
                    ],
                    
                    // Botões de ação
                    _buildActionButtons(context),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, Map<String, dynamic> meal) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Imagem de fundo
            Image.network(
              meal['imageUrl'] ?? 'https://images.unsplash.com/photo-1547592180-85f173990554?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppTheme.primaryColor.withOpacity(0.2),
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                  size: 60,
                ),
              ),
            ),
            
            // Gradiente escuro para melhorar legibilidade
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag/Badge da refeição
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      meal['category'] ?? 'Refeição',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Título
                  Text(
                    meal['title'] ?? 'Detalhes da Refeição',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Tags secundárias
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        meal['time'] ?? 'Café da Manhã',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${meal['calories'] ?? 0} cal',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          color: Colors.white,
          onPressed: () => context.router.maybePop(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.bookmark_border, size: 20),
            color: Colors.white,
            onPressed: () {},
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share, size: 20),
            color: Colors.white,
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildMealSummary(BuildContext context, Map<String, dynamic> meal) {
    return Row(
      children: [
        // Calorias
        Expanded(
          child: _buildSummaryItem(
            label: 'Calorias',
            value: '${meal['calories'] ?? 0}',
            unit: 'kcal',
            icon: Icons.local_fire_department,
            color: const Color(0xFFE53935),
          ),
        ),
        
        // Proteínas
        Expanded(
          child: _buildSummaryItem(
            label: 'Proteínas',
            value: '${meal['protein'] ?? 0}',
            unit: 'g',
            icon: Icons.fitness_center,
            color: const Color(0xFF4CAF50),
          ),
        ),
        
        // Carboidratos
        Expanded(
          child: _buildSummaryItem(
            label: 'Carboidratos',
            value: '${meal['carbs'] ?? 0}',
            unit: 'g',
            icon: Icons.grain,
            color: const Color(0xFFFF9800),
          ),
        ),
        
        // Gorduras
        Expanded(
          child: _buildSummaryItem(
            label: 'Gorduras',
            value: '${meal['fat'] ?? 0}',
            unit: 'g',
            icon: Icons.opacity,
            color: const Color(0xFF2196F3),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            children: [
              TextSpan(text: value),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF777777),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF777777),
          ),
        ),
      ],
    );
  }

  Widget _buildMacronutrients(BuildContext context, Map<String, dynamic> meal) {
    // Valores de exemplo
    final protein = (meal['protein'] ?? 30).toDouble();
    final carbs = (meal['carbs'] ?? 45).toDouble();
    final fat = (meal['fat'] ?? 25).toDouble();
    final total = protein + carbs + fat;
    
    final proteinPercent = (protein / total * 100).round();
    final carbsPercent = (carbs / total * 100).round();
    final fatPercent = (fat / total * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribuição de Macronutrientes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          
          // Barra de progresso
          Container(
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                // Proteína
                Container(
                  width: MediaQuery.of(context).size.width * 0.7 * protein / total,
                  color: const Color(0xFF4CAF50),
                ),
                
                // Carboidratos
                Container(
                  width: MediaQuery.of(context).size.width * 0.7 * carbs / total,
                  color: const Color(0xFFFF9800),
                ),
                
                // Gorduras
                Container(
                  width: MediaQuery.of(context).size.width * 0.7 * fat / total,
                  color: const Color(0xFF2196F3),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Legenda
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroLegendItem(
                color: const Color(0xFF4CAF50),
                name: 'Proteínas',
                percent: '$proteinPercent%',
              ),
              _buildMacroLegendItem(
                color: const Color(0xFFFF9800),
                name: 'Carboidratos',
                percent: '$carbsPercent%',
              ),
              _buildMacroLegendItem(
                color: const Color(0xFF2196F3),
                name: 'Gorduras',
                percent: '$fatPercent%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroLegendItem({
    required Color color,
    required String name,
    required String percent,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF777777),
              ),
            ),
            Text(
              percent,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIngredientsList(BuildContext context, Map<String, dynamic> meal) {
    final ingredients = meal['ingredients'] as List<dynamic>? ?? [
      {'name': 'Ovos', 'amount': '2 unidades'},
      {'name': 'Pão integral', 'amount': '2 fatias'},
      {'name': 'Abacate', 'amount': '1/2 unidade'},
      {'name': 'Sal e pimenta', 'amount': 'a gosto'},
    ];

    return Column(
      children: ingredients.map<Widget>((ingredient) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingredient['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    if (ingredient['amount'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        ingredient['amount'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreparationSteps(BuildContext context, Map<String, dynamic> meal) {
    final steps = meal['preparation'] as List<dynamic>? ?? [
      'Pré-aqueça uma frigideira antiaderente em fogo médio.',
      'Quebre os ovos em uma tigela e bata levemente com um garfo.',
      'Tempere com sal e pimenta a gosto.',
      'Despeje na frigideira e mexa gentilmente até que estejam ao ponto desejado.',
      'Sirva com o pão integral e fatias de abacate.',
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  steps[index],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Botão editar
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: BorderSide(color: AppTheme.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Editar Refeição'),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Botão excluir
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Icon(Icons.delete_outline, size: 20),
        ),
        
        const SizedBox(width: 16),
        
        // Botão adicionar ao diário
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Adicionar ao Diário'),
          ),
        ),
      ],
    );
  }
} 