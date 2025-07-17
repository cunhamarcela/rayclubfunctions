// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:ray_club_app/core/widgets/app_bar_widget.dart';
import 'package:ray_club_app/features/goals/viewmodels/goals_view_model.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data_enhanced.dart';

/// Tela de formulário para criar ou editar metas
@RoutePage()
class GoalFormScreen extends ConsumerStatefulWidget {
  final GoalData? existingGoal;
  
  const GoalFormScreen({
    Key? key,
    this.existingGoal,
  }) : super(key: key);

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _unitController = TextEditingController();
  
  String _selectedCategory = 'fitness';
  DateTime? _selectedDeadline;
  bool _isLoading = false;
  
  final List<Map<String, dynamic>> _categories = [
    {'value': 'fitness', 'label': 'Fitness', 'icon': Icons.fitness_center},
    {'value': 'nutrition', 'label': 'Nutrição', 'icon': Icons.restaurant},
    {'value': 'wellness', 'label': 'Bem-estar', 'icon': Icons.spa},
    {'value': 'personal', 'label': 'Pessoal', 'icon': Icons.person},
  ];
  
  @override
  void initState() {
    super.initState();
    if (widget.existingGoal != null) {
      _loadGoalData();
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    _unitController.dispose();
    super.dispose();
  }
  
  Future<void> _loadGoalData() async {
    try {
      setState(() => _isLoading = true);
      
      final goal = widget.existingGoal;
      
      if (goal != null) {
        _titleController.text = goal.title;
        _descriptionController.text = goal.description ?? '';
        _targetValueController.text = goal.targetValue.toStringAsFixed(0);
        _unitController.text = goal.unit;
        _selectedCategory = goal.category;
        _selectedDeadline = goal.deadline;
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar meta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingGoal != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      appBar: AppBarWidget(
        title: isEditing ? 'Editar Meta' : 'Nova Meta',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Categoria
                    Text(
                      'Categoria',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCategorySelector(),
                    
                    const SizedBox(height: 24),
                    
                    // Título
                    _buildTextField(
                      controller: _titleController,
                      label: 'Título da Meta',
                      hint: 'Ex: Perder 5kg',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira um título';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Descrição
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Descrição (opcional)',
                      hint: 'Descreva sua meta...',
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Valor e Unidade
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _targetValueController,
                            label: 'Valor da Meta',
                            hint: 'Ex: 5',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Insira um valor';
                              }
                              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                return 'Valor inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _unitController,
                            label: 'Unidade',
                            hint: 'Ex: kg',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Unidade';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Prazo
                    _buildDeadlineSelector(),
                    
                    const SizedBox(height: 32),
                    
                    // Botões
                    Row(
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveGoal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF38638),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(isEditing ? 'Salvar' : 'Criar Meta'),
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
  
  Widget _buildCategorySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = category['value']),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? _getCategoryColor(category['value']).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      category['icon'],
                      color: isSelected 
                          ? _getCategoryColor(category['value'])
                          : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category['label'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                            ? _getCategoryColor(category['value'])
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFF38638),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDeadlineSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prazo (opcional)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDeadline,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFFF38638),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDeadline != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedDeadline!)
                        : 'Selecionar prazo',
                    style: TextStyle(
                      color: _selectedDeadline != null 
                          ? const Color(0xFF2D2D2D)
                          : Colors.grey,
                    ),
                  ),
                ),
                if (_selectedDeadline != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () => setState(() => _selectedDeadline = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione o prazo da meta',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      fieldHintText: 'dd/mm/aaaa',
      fieldLabelText: 'Prazo da meta',
      errorFormatText: 'Digite uma data válida no formato dd/mm/aaaa',
      errorInvalidText: 'Digite uma data válida',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF38638),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2D2D2D),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }
  
  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final viewModel = ref.read(goalsViewModelProvider.notifier);
      
      if (widget.existingGoal != null) {
        // Editar meta existente
        await viewModel.updateGoal(
          goalId: widget.existingGoal!.id,
          title: _titleController.text.trim(),
          category: _selectedCategory,
          targetValue: double.parse(_targetValueController.text),
          unit: _unitController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          deadline: _selectedDeadline,
        );
      } else {
        // Criar nova meta
        await viewModel.createGoal(
          title: _titleController.text.trim(),
          category: _selectedCategory,
          targetValue: double.parse(_targetValueController.text),
          unit: _unitController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          deadline: _selectedDeadline,
        );
      }
      
      if (mounted) {
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
        Navigator.pop(context);
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar meta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fitness':
        return const Color(0xFF6B7FD7);
      case 'nutrition':
        return Colors.green;
      case 'wellness':
        return const Color(0xFF4FC3F7);
      case 'personal':
        return const Color(0xFFF38638);
      default:
        return Colors.grey;
    }
  }
} 