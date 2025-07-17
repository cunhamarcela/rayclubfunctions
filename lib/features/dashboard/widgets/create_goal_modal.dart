// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/models/dashboard_data_enhanced.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_enhanced_view_model.dart';

/// Modal para criar ou editar uma meta
class CreateGoalModal extends ConsumerStatefulWidget {
  final GoalData? existingGoal;
  
  const CreateGoalModal({
    Key? key,
    this.existingGoal,
  }) : super(key: key);
  
  static Future<void> show(BuildContext context, {GoalData? existingGoal}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateGoalModal(existingGoal: existingGoal),
    );
  }
  
  @override
  ConsumerState<CreateGoalModal> createState() => _CreateGoalModalState();
}

class _CreateGoalModalState extends ConsumerState<CreateGoalModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _targetValueController;
  late TextEditingController _currentValueController;
  late TextEditingController _unitController;
  
  // Sugestões pré-definidas de metas
  final List<Map<String, dynamic>> _goalSuggestions = [
    {
      'title': 'Treinos semanais',
      'unit': 'treinos',
      'targetValue': 3,
      'icon': Icons.fitness_center,
      'color': const Color(0xFF6B7FD7),
    },
    {
      'title': 'Horas de sono',
      'unit': 'horas',
      'targetValue': 8,
      'icon': Icons.bedtime,
      'color': const Color(0xFF9B59B6),
    },
    {
      'title': 'Passos diários',
      'unit': 'passos',
      'targetValue': 10000,
      'icon': Icons.directions_walk,
      'color': const Color(0xFF3498DB),
    },
    {
      'title': 'Consumo de proteína',
      'unit': 'gramas',
      'targetValue': 120,
      'icon': Icons.egg,
      'color': const Color(0xFFE74C3C),
    },
    {
      'title': 'Minutos de meditação',
      'unit': 'minutos',
      'targetValue': 15,
      'icon': Icons.self_improvement,
      'color': const Color(0xFF27AE60),
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingGoal?.title ?? '');
    _targetValueController = TextEditingController(
      text: widget.existingGoal?.targetValue.toStringAsFixed(0) ?? '',
    );
    _currentValueController = TextEditingController(
      text: widget.existingGoal?.currentValue.toStringAsFixed(0) ?? '0',
    );
    _unitController = TextEditingController(text: widget.existingGoal?.unit ?? '');
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _targetValueController.dispose();
    _currentValueController.dispose();
    _unitController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                  widget.existingGoal != null ? 'Editar Meta' : 'Nova Meta',
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
          
          // Conteúdo
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sugestões de metas
                  if (widget.existingGoal == null) ...[
                    Text(
                      'Sugestões de Metas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _goalSuggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _goalSuggestions[index];
                          return GestureDetector(
                            onTap: () {
                              _titleController.text = suggestion['title'];
                              _unitController.text = suggestion['unit'];
                              _targetValueController.text = 
                                  suggestion['targetValue'].toString();
                              setState(() {});
                            },
                            child: Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (suggestion['color'] as Color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: (suggestion['color'] as Color).withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    suggestion['icon'] as IconData,
                                    color: suggestion['color'] as Color,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    suggestion['title'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: suggestion['color'] as Color,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // Formulário
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título da meta
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Título da Meta',
                            hintText: 'Ex: Treinos semanais',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.flag),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira um título';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Valor alvo e unidade
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _targetValueController,
                                decoration: InputDecoration(
                                  labelText: 'Meta',
                                  hintText: 'Ex: 3',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.flag_outlined),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Insira um valor';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Valor inválido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _unitController,
                                decoration: InputDecoration(
                                  labelText: 'Unidade',
                                  hintText: 'Ex: treinos',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Obrigatório';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Valor atual (opcional)
                        TextFormField(
                          controller: _currentValueController,
                          decoration: InputDecoration(
                            labelText: 'Progresso Atual (opcional)',
                            hintText: 'Ex: 1',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.trending_up),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Visualização prévia
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Visualização',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.flag,
                                    color: Color(0xFF6B7FD7),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _titleController.text.isEmpty 
                                          ? 'Título da meta' 
                                          : _titleController.text,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_currentValueController.text.isEmpty ? '0' : _currentValueController.text} de ${_targetValueController.text.isEmpty ? '?' : _targetValueController.text} ${_unitController.text}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Botões de ação
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B7FD7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.existingGoal != null ? 'Salvar' : 'Criar Meta',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      // Criar ou atualizar meta
      final newGoal = GoalData(
        id: widget.existingGoal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        currentValue: double.tryParse(_currentValueController.text) ?? 0,
        targetValue: double.parse(_targetValueController.text),
        unit: _unitController.text,
        isCompleted: false,
        createdAt: widget.existingGoal?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // TODO: Chamar método do ViewModel para salvar
      // ref.read(dashboardEnhancedViewModelProvider.notifier).createGoal(newGoal);
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingGoal != null 
                ? 'Meta atualizada com sucesso!' 
                : 'Meta criada com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
} 