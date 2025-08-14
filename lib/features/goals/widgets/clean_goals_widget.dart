import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/auth_provider.dart';

/// Widget limpo e simples para metas - usando apenas Supabase direto
class CleanGoalsWidget extends ConsumerStatefulWidget {
  const CleanGoalsWidget({super.key});

  @override
  ConsumerState<CleanGoalsWidget> createState() => _CleanGoalsWidgetState();
}

class _CleanGoalsWidgetState extends ConsumerState<CleanGoalsWidget> {
  List<Map<String, dynamic>>? _goals;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        setState(() {
          _error = 'Usuário não logado';
          _isLoading = false;
        });
        return;
      }

      final goals = await _fetchGoalsDirectly(userId);
      setState(() {
        _goals = goals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard();
    }
    
    if (_error != null) {
      return _buildErrorCard(_error!);
    }
    
    final goals = _goals ?? [];
    
    if (goals.isEmpty) {
      return _buildEmptyCard(context);
    }
    
    return _buildGoalsCard(context, goals);
  }

  /// Busca metas diretamente do Supabase sem camadas intermediárias
  Future<List<Map<String, dynamic>>> _fetchGoalsDirectly(String userId) async {
    try {
      debugPrint('🎯 [CleanWidget] Buscando metas para: $userId');
      
      final supabase = Supabase.instance.client;
      
      // Usar a função SQL que sabemos que funciona
      final response = await supabase.rpc('get_user_category_goals', params: {
        'p_user_id': userId,
      });
      
      debugPrint('🎯 [CleanWidget] Resposta: $response');
      debugPrint('🎯 [CleanWidget] Tipo: ${response.runtimeType}');
      
      if (response is List) {
        debugPrint('🎯 [CleanWidget] ${response.length} metas encontradas');
        return List<Map<String, dynamic>>.from(response);
      }
      
      return [];
    } catch (e) {
      debugPrint('❌ [CleanWidget] Erro: $e');
      rethrow;
    }
  }

  Widget _buildGoalsCard(BuildContext context, List<Map<String, dynamic>> goals) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.flag, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Metas da Semana',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showCreateGoalDialog(context),
                child: const Text('+ Criar'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Lista de metas
          ...goals.map((goal) => _buildGoalItem(context, goal)).toList(),
        ],
      ),
    );
  }

  Widget _buildGoalItem(BuildContext context, Map<String, dynamic> goal) {
    final category = goal['category']?.toString() ?? 'Categoria';
    final currentMinutes = goal['current_minutes'] ?? 0;
    final goalMinutes = goal['goal_minutes'] ?? 1;
    final percentage = goal['percentage_completed']?.toDouble() ?? 0.0;
    final completed = goal['completed'] == true;
    final goalId = goal['id']?.toString() ?? '';
    
    return GestureDetector(
      onTap: () => _showGoalDetailsModal(context, goal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: completed ? Colors.green : Colors.grey[300]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    category.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: completed ? Colors.green[700] : Colors.black87,
                    ),
                  ),
                ),
                Text(
                  '$currentMinutes/$goalMinutes min',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.grey[500],
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                completed ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${percentage.toInt()}% concluído • Toque para editar',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando metas...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error, color: Colors.red[700], size: 32),
          const SizedBox(height: 8),
          Text(
            'Erro ao carregar metas',
            style: TextStyle(
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: TextStyle(color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.flag_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Nenhuma meta para esta semana',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie sua primeira meta!',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showCreateGoalDialog(context),
            child: const Text('Criar Meta'),
          ),
        ],
      ),
    );
  }

  void _showCreateGoalDialog(BuildContext context) {
    debugPrint('🎯 [CleanWidget] Abrindo modal de criação de meta');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCreateGoalModal(context),
    );
  }

  Widget _buildCreateGoalModal(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Criar Nova Meta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Escolha uma categoria:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Categorias disponíveis
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                      children: [
                        _buildCategoryButton(context, 'Cardio', Icons.favorite, Colors.red),
                        _buildCategoryButton(context, 'Musculação', Icons.fitness_center, Colors.blue),
                        _buildCategoryButton(context, 'Funcional', Icons.sports_gymnastics, Colors.orange),
                        _buildCategoryButton(context, 'Yoga', Icons.self_improvement, Colors.purple),
                        _buildCategoryButton(context, 'Pilates', Icons.accessibility_new, Colors.green),
                        _buildCategoryButton(context, 'HIIT', Icons.flash_on, Colors.amber),
                        _buildCategoryButton(context, 'Corrida', Icons.directions_run, Colors.teal),
                        _buildCategoryButton(context, 'Natação', Icons.pool, Colors.cyan),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Meta personalizada
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showCustomGoalModal(context),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Meta Personalizada'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[700],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, String category, IconData icon, Color color) {
    return ElevatedButton(
      onPressed: () => _showGoalConfigModal(context, category),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createGoalForCategory(BuildContext context, String category) async {
    try {
      debugPrint('🎯 [CleanWidget] Criando meta para categoria: $category');
      
      Navigator.pop(context); // Fechar modal
      
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId == null) {
        throw Exception('Usuário não logado');
      }
      
      // Criar meta usando a função SQL que funciona
      await supabase.rpc('set_category_goal', params: {
        'p_user_id': userId,
        'p_category': category.toLowerCase(),
        'p_goal_minutes': 90, // Meta padrão de 90 minutos
      });
      
      Navigator.pop(context); // Fechar loading
      
      // Mostrar sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meta de $category criada com sucesso! 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Recarregar lista de metas
      await _loadGoals();
      
    } catch (e) {
      Navigator.pop(context); // Fechar loading se houver erro
      
      debugPrint('❌ [CleanWidget] Erro ao criar meta: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar meta: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showGoalDetailsModal(BuildContext context, Map<String, dynamic> goal) {
    final category = goal['category']?.toString() ?? 'Categoria';
    final currentMinutes = goal['current_minutes'] ?? 0;
    final goalMinutes = goal['goal_minutes'] ?? 1;
    final completed = goal['completed'] == true;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGoalDetailsModal(context, goal),
    );
  }

  Widget _buildGoalDetailsModal(BuildContext context, Map<String, dynamic> goal) {
    final category = goal['category']?.toString() ?? 'Categoria';
    final currentMinutes = goal['current_minutes'] ?? 0;
    final goalMinutes = goal['goal_minutes'] ?? 1;
    final completed = goal['completed'] == true;
    final TextEditingController minutesController = TextEditingController();
    
    return Container(
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
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Meta de ${category.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Botão Editar
                IconButton(
                  onPressed: () => _showEditGoalModal(context, goal),
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Editar meta',
                ),
                // Botão Excluir
                IconButton(
                  onPressed: () => _showDeleteConfirmation(context, goal),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Excluir meta',
                ),
                // Botão Fechar
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Progress info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progresso atual:',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '$currentMinutes/$goalMinutes min',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (currentMinutes / goalMinutes).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completed ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Add minutes section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adicionar minutos:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Quick add buttons
                Row(
                  children: [
                    _buildQuickAddButton(context, goal, 15),
                    const SizedBox(width: 8),
                    _buildQuickAddButton(context, goal, 30),
                    const SizedBox(width: 8),
                    _buildQuickAddButton(context, goal, 45),
                    const SizedBox(width: 8),
                    _buildQuickAddButton(context, goal, 60),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Custom input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minutesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Minutos customizados',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixText: 'min',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        final minutes = int.tryParse(minutesController.text);
                        if (minutes != null && minutes > 0) {
                          _addMinutesToGoal(context, goal, minutes);
                        }
                      },
                      child: const Text('Adicionar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(BuildContext context, Map<String, dynamic> goal, int minutes) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _addMinutesToGoal(context, goal, minutes),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.withOpacity(0.1),
          foregroundColor: Colors.orange,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text('+${minutes}min'),
      ),
    );
  }

  Future<void> _addMinutesToGoal(BuildContext context, Map<String, dynamic> goal, int minutesToAdd) async {
    try {
      debugPrint('🎯 [CleanWidget] Adicionando $minutesToAdd minutos à meta ${goal['category']}');
      
      Navigator.pop(context); // Fechar modal
      
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId == null) {
        throw Exception('Usuário não logado');
      }
      
      // Atualizar diretamente na tabela
      final currentMinutes = goal['current_minutes'] ?? 0;
      final newMinutes = currentMinutes + minutesToAdd;
      
      await supabase
          .from('workout_category_goals')
          .update({
            'current_minutes': newMinutes,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goal['id']);
      
      Navigator.pop(context); // Fechar loading
      
      // Mostrar sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$minutesToAdd minutos adicionados! 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Recarregar lista de metas
      await _loadGoals();
      
    } catch (e) {
      Navigator.pop(context); // Fechar loading se houver erro
      
      debugPrint('❌ [CleanWidget] Erro ao adicionar minutos: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar minutos: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showGoalConfigModal(BuildContext context, String category) {
    Navigator.pop(context); // Fechar modal anterior
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGoalConfigModal(context, category),
    );
  }

  Widget _buildGoalConfigModal(BuildContext context, String category) {
    final TextEditingController quantityController = TextEditingController(text: '90');
    String selectedType = 'minutos'; // 'minutos' ou 'dias'
    
    return StatefulBuilder(
      builder: (context, setState) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
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
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Meta de $category',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo de meta:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Tipo de meta
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Minutos'),
                            value: 'minutos',
                            groupValue: selectedType,
                            onChanged: (value) {
                              setState(() {
                                selectedType = value!;
                                quantityController.text = '90';
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Dias'),
                            value: 'dias',
                            groupValue: selectedType,
                            onChanged: (value) {
                              setState(() {
                                selectedType = value!;
                                quantityController.text = '5'; // 5 dias = 150 min
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Quantidade
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: selectedType == 'minutos' ? 'Minutos por semana' : 'Dias por semana',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixText: selectedType,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Botão criar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final quantity = int.tryParse(quantityController.text);
                          if (quantity != null && quantity > 0) {
                            _createGoalWithConfig(context, category, quantity, selectedType);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Criar Meta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomGoalModal(BuildContext context) {
    Navigator.pop(context); // Fechar modal anterior
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCustomGoalModal(context),
    );
  }

  Widget _buildCustomGoalModal(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController(text: '90');
    String selectedType = 'minutos';
    
    return StatefulBuilder(
      builder: (context, setState) => Container(
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
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'Meta Personalizada',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome da meta
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome da meta',
                        hintText: 'Ex: Alongamento, Meditação...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    const Text(
                      'Tipo de meta:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Tipo de meta
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Minutos'),
                            value: 'minutos',
                            groupValue: selectedType,
                            onChanged: (value) {
                              setState(() {
                                selectedType = value!;
                                quantityController.text = '90';
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Dias'),
                            value: 'dias',
                            groupValue: selectedType,
                            onChanged: (value) {
                              setState(() {
                                selectedType = value!;
                                quantityController.text = '5'; // 5 dias = 150 min
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Quantidade
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: selectedType == 'minutos' ? 'Minutos por semana' : 'Dias por semana',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixText: selectedType,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Botão criar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final quantity = int.tryParse(quantityController.text);
                          if (name.isNotEmpty && quantity != null && quantity > 0) {
                            _createGoalWithConfig(context, name.toLowerCase(), quantity, selectedType);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Criar Meta Personalizada',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createGoalWithConfig(BuildContext context, String category, int quantity, String type) async {
    try {
      debugPrint('🎯 [CleanWidget] Criando meta: $category - $quantity $type');
      
      Navigator.pop(context); // Fechar modal
      
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId == null) {
        throw Exception('Usuário não logado');
      }
      
      // Criar meta usando a nova função que suporta dias e minutos
      await supabase.rpc('set_category_goal', params: {
        'p_user_id': userId,
        'p_category': category,
        'p_goal_value': quantity,
        'p_goal_type': type,
      });
      
      Navigator.pop(context); // Fechar loading
      
      // Mostrar sucesso
      final successMessage = 'Meta de $category criada: $quantity $type! 🎉';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Recarregar lista de metas
      await _loadGoals();
      
    } catch (e) {
      Navigator.pop(context); // Fechar loading se houver erro
      
      debugPrint('❌ [CleanWidget] Erro ao criar meta: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar meta: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showEditGoalModal(BuildContext context, Map<String, dynamic> goal) {
    Navigator.pop(context); // Fechar modal anterior
    
    final TextEditingController quantityController = TextEditingController();
    final category = goal['category']?.toString() ?? '';
    final currentGoalMinutes = goal['goal_minutes'] ?? 90;
    
    // Determinar se é meta de dias ou minutos baseado no valor atual
    String selectedType = 'minutes';
    int displayValue = currentGoalMinutes;
    
    // Se for múltiplo de 30 e maior que 30, provavelmente é meta de dias
    if (currentGoalMinutes >= 30 && currentGoalMinutes % 30 == 0) {
      selectedType = 'dias';
      displayValue = currentGoalMinutes ~/ 30;
    }
    
    quantityController.text = displayValue.toString();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar Meta de ${category.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Tipo de meta
              const Text('Tipo de meta:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Minutos'),
                      value: 'minutes',
                      groupValue: selectedType,
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                          if (selectedType == 'minutes') {
                            quantityController.text = '90';
                          } else {
                            quantityController.text = '5';
                          }
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Dias'),
                      value: 'dias',
                      groupValue: selectedType,
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                          if (selectedType == 'minutes') {
                            quantityController.text = '90';
                          } else {
                            quantityController.text = '5';
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Quantidade
              Text('Quantidade (${selectedType}):', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: selectedType == 'dias' ? '5' : '90',
                  suffixText: selectedType == 'dias' ? 'dias' : 'min',
                ),
              ),
              
              const Spacer(),
              
              // Botões
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateGoal(context, goal, int.parse(quantityController.text), selectedType),
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateGoal(BuildContext context, Map<String, dynamic> goal, int quantity, String type) async {
    try {
      Navigator.pop(context); // Fechar modal
      
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      final goalId = goal['id'];
      
      if (userId == null) {
        throw Exception('Usuário não logado');
      }
      
      // Converter dias para minutos se necessário (compatibilidade com backend atual)
      int goalMinutes;
      if (type == 'dias') {
        goalMinutes = quantity * 30; // 30 min por dia
      } else {
        goalMinutes = quantity;
      }
      
      // Atualizar meta diretamente na tabela
      await supabase
          .from('workout_category_goals')
          .update({
            'goal_minutes': goalMinutes,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId);
      
      Navigator.pop(context); // Fechar loading
      
      // Recarregar lista de metas
      await _loadGoals();
      
      // Mostrar sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meta atualizada: $quantity $type! 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
    } catch (e) {
      Navigator.pop(context); // Fechar loading se houver erro
      
      debugPrint('❌ [CleanWidget] Erro ao atualizar meta: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar meta: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> goal) {
    final category = goal['category']?.toString() ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Meta'),
        content: Text('Tem certeza que deseja excluir a meta de ${category.toUpperCase()}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _deleteGoal(context, goal),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGoal(BuildContext context, Map<String, dynamic> goal) async {
    try {
      Navigator.pop(context); // Fechar dialog de confirmação
      Navigator.pop(context); // Fechar modal de detalhes
      
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      final supabase = Supabase.instance.client;
      final goalId = goal['id'];
      final category = goal['category']?.toString() ?? '';
      
      // Excluir meta da tabela
      await supabase
          .from('workout_category_goals')
          .delete()
          .eq('id', goalId);
      
      Navigator.pop(context); // Fechar loading
      
      // Recarregar lista de metas
      await _loadGoals();
      
      // Mostrar sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meta de ${category.toUpperCase()} excluída! 🗑️'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
    } catch (e) {
      Navigator.pop(context); // Fechar loading se houver erro
      
      debugPrint('❌ [CleanWidget] Erro ao excluir meta: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir meta: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
