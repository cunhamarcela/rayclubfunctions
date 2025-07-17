// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:ray_club_app/core/constants/app_colors.dart';
import 'package:ray_club_app/features/nutrition/models/meal.dart';

/// Bottom sheet para adicionar ou editar uma refeição
class AddMealSheet extends StatefulWidget {
  final Meal? meal;
  final Function(Meal) onSave;

  const AddMealSheet({
    super.key,
    this.meal,
    required this.onSave,
  });

  @override
  State<AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<AddMealSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinsController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatsController;
  late final TextEditingController _notesController;
  late DateTime _selectedDateTime;
  final List<String> _tags = [];

  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.meal != null;
    
    // Inicializar valores
    _nameController = TextEditingController(text: widget.meal?.name ?? '');
    _caloriesController = TextEditingController(
      text: widget.meal?.calories.toString() ?? '',
    );
    _proteinsController = TextEditingController(
      text: widget.meal?.proteins.toString() ?? '',
    );
    _carbsController = TextEditingController(
      text: widget.meal?.carbs.toString() ?? '',
    );
    _fatsController = TextEditingController(
      text: widget.meal?.fats.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.meal?.notes ?? '');
    _selectedDateTime = widget.meal?.dateTime ?? DateTime.now();
    
    if (widget.meal != null) {
      _tags.addAll(widget.meal!.tags);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título do formulário
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Editar Refeição' : 'Nova Refeição',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: Colors.grey,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Nome da refeição
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da refeição',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe o nome da refeição';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Data e hora
              InkWell(
                onTap: _showDateTimePicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          DateFormat('dd/MM/yyyy - HH:mm').format(_selectedDateTime),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Informações nutricionais
              const Text(
                'Informações Nutricionais',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Grid de campos nutricionais
              Row(
                children: [
                  // Calorias
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _caloriesController,
                      decoration: const InputDecoration(
                        labelText: 'Calorias (kcal)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Obrigatório';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Proteínas
                  Expanded(
                    child: TextFormField(
                      controller: _proteinsController,
                      decoration: const InputDecoration(
                        labelText: 'Proteínas (g)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Obrigatório';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  // Carboidratos
                  Expanded(
                    child: TextFormField(
                      controller: _carbsController,
                      decoration: const InputDecoration(
                        labelText: 'Carboidratos (g)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Obrigatório';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Gorduras
                  Expanded(
                    child: TextFormField(
                      controller: _fatsController,
                      decoration: const InputDecoration(
                        labelText: 'Gorduras (g)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Obrigatório';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Notas
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  border: OutlineInputBorder(),
                  hintText: 'Adicione informações adicionais sobre a refeição',
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              // Tags
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._tags.map((tag) => _buildTagChip(tag)).toList(),
                      ActionChip(
                        label: const Text('Adicionar'),
                        avatar: const Icon(Icons.add, size: 16),
                        onPressed: _showAddTagDialog,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Botão de salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Atualizar' : 'Salvar',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Exibir seletor de data e hora
  void _showDateTimePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione a data da refeição',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      fieldHintText: 'dd/mm/aaaa',
      fieldLabelText: 'Data da refeição',
      errorFormatText: 'Digite uma data válida no formato dd/mm/aaaa',
      errorInvalidText: 'Digite uma data válida',
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        helpText: 'Selecione a hora da refeição',
        cancelText: 'Cancelar',
        confirmText: 'Confirmar',
        hourLabelText: 'Hora',
        minuteLabelText: 'Minuto',
        errorInvalidText: 'Digite uma hora válida',
      );
      
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  // Exibir diálogo para adicionar tag
  void _showAddTagDialog() {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Tag'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Ex: café da manhã, proteína, jantar',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final tag = textController.text.trim();
              if (tag.isNotEmpty && !_tags.contains(tag)) {
                setState(() {
                  _tags.add(tag);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  // Construir chip para tag
  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag),
      deleteIcon: const Icon(Icons.clear, size: 16),
      onDeleted: () {
        setState(() {
          _tags.remove(tag);
        });
      },
      backgroundColor: AppColors.primaryLight.withOpacity(0.1),
      labelStyle: TextStyle(color: AppColors.primaryLight),
    );
  }

  // Salvar refeição
  void _saveMeal() {
    if (_formKey.currentState?.validate() ?? false) {
      final meal = Meal(
        id: widget.meal?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        dateTime: _selectedDateTime,
        calories: int.parse(_caloriesController.text.trim()),
        proteins: double.parse(_proteinsController.text.trim()),
        carbs: double.parse(_carbsController.text.trim()),
        fats: double.parse(_fatsController.text.trim()),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        tags: _tags,
      );
      
      widget.onSave(meal);
    }
  }
} 
