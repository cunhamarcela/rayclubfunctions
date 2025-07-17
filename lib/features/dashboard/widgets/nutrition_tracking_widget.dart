// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

/// Widget para tracking de nutrição e calorias
class NutritionTrackingWidget extends ConsumerWidget {
  final int caloriesConsumed;
  final int caloriesGoal;
  final Map<String, double> macros; // proteínas, carboidratos, gorduras
  final VoidCallback? onAddMeal;
  
  const NutritionTrackingWidget({
    Key? key,
    required this.caloriesConsumed,
    required this.caloriesGoal,
    required this.macros,
    this.onAddMeal,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percentage = caloriesGoal > 0 
        ? (caloriesConsumed / caloriesGoal).clamp(0.0, 1.0)
        : 0.0;
    final caloriesRemaining = (caloriesGoal - caloriesConsumed).clamp(0, caloriesGoal);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Color(0xFF27AE60),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Nutrição',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                ],
              ),
              if (onAddMeal != null)
                IconButton(
                  onPressed: onAddMeal,
                  icon: const Icon(Icons.add_circle),
                  color: const Color(0xFF27AE60),
                  tooltip: 'Adicionar refeição',
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Visualização principal de calorias
          Row(
            children: [
              // Gráfico circular
              CircularPercentIndicator(
                radius: 60,
                lineWidth: 10,
                percent: percentage,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      caloriesConsumed.toString(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                    Text(
                      'kcal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                progressColor: _getProgressColor(percentage),
                backgroundColor: Colors.grey.shade200,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              
              const SizedBox(width: 24),
              
              // Informações detalhadas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalorieInfo(
                      context,
                      label: 'Meta',
                      value: caloriesGoal,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 8),
                    _buildCalorieInfo(
                      context,
                      label: 'Consumidas',
                      value: caloriesConsumed,
                      color: _getProgressColor(percentage),
                    ),
                    const SizedBox(height: 8),
                    _buildCalorieInfo(
                      context,
                      label: 'Restantes',
                      value: caloriesRemaining,
                      color: const Color(0xFF3498DB),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Macros
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Macronutrientes',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMacroItem(
                      context,
                      label: 'Proteínas',
                      value: macros['proteins'] ?? 0,
                      unit: 'g',
                      color: const Color(0xFFE74C3C),
                      icon: Icons.egg,
                    ),
                    _buildMacroItem(
                      context,
                      label: 'Carboidratos',
                      value: macros['carbs'] ?? 0,
                      unit: 'g',
                      color: const Color(0xFF3498DB),
                      icon: Icons.bakery_dining,
                    ),
                    _buildMacroItem(
                      context,
                      label: 'Gorduras',
                      value: macros['fats'] ?? 0,
                      unit: 'g',
                      color: const Color(0xFFF39C12),
                      icon: Icons.water_drop,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Botão de ação rápida
          if (onAddMeal != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // Abrir modal de registro rápido de alimento
                _showQuickAddModal(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Registro Rápido'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF27AE60),
                side: const BorderSide(color: Color(0xFF27AE60)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildCalorieInfo(
    BuildContext context, {
    required String label,
    required int value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          '$value kcal',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMacroItem(
    BuildContext context, {
    required String label,
    required double value,
    required String unit,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${value.toStringAsFixed(0)}$unit',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
  
  Color _getProgressColor(double percentage) {
    if (percentage < 0.5) {
      return const Color(0xFF27AE60); // Verde
    } else if (percentage < 0.8) {
      return const Color(0xFF3498DB); // Azul
    } else if (percentage < 1.0) {
      return const Color(0xFFF39C12); // Laranja
    } else {
      return const Color(0xFFE74C3C); // Vermelho (excedeu)
    }
  }
  
  void _showQuickAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Registro Rápido',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Opções rápidas
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildQuickAddOption(
                    context,
                    icon: Icons.free_breakfast,
                    title: 'Café da Manhã',
                    subtitle: '~300-400 kcal',
                    color: const Color(0xFFF39C12),
                  ),
                  _buildQuickAddOption(
                    context,
                    icon: Icons.lunch_dining,
                    title: 'Almoço',
                    subtitle: '~500-700 kcal',
                    color: const Color(0xFF3498DB),
                  ),
                  _buildQuickAddOption(
                    context,
                    icon: Icons.dinner_dining,
                    title: 'Jantar',
                    subtitle: '~400-600 kcal',
                    color: const Color(0xFF9B59B6),
                  ),
                  _buildQuickAddOption(
                    context,
                    icon: Icons.cookie,
                    title: 'Lanche',
                    subtitle: '~100-200 kcal',
                    color: const Color(0xFF27AE60),
                  ),
                  _buildQuickAddOption(
                    context,
                    icon: Icons.local_drink,
                    title: 'Bebida',
                    subtitle: '~0-200 kcal',
                    color: const Color(0xFFE74C3C),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickAddOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            // TODO: Abrir tela específica para adicionar o tipo de refeição
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 