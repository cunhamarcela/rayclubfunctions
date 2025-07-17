// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/components/app_error_widget.dart';
import 'package:ray_club_app/core/components/app_loading.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_typography.dart';
import 'package:ray_club_app/features/workout/models/workout_model.dart';
import 'package:ray_club_app/features/workout/models/workout_section_model.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_view_model.dart';

class WorkoutFormScreen extends ConsumerStatefulWidget {
  final String? workoutId;

  const WorkoutFormScreen({
    Key? key,
    this.workoutId,
  }) : super(key: key);

  @override
  ConsumerState<WorkoutFormScreen> createState() => _WorkoutFormScreenState();
}

class _WorkoutFormScreenState extends ConsumerState<WorkoutFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _typeController;
  late TextEditingController _durationController;
  String _difficulty = '';
  final List<String> _equipment = [];
  final List<WorkoutSection> _sections = [];
  bool _isLoading = false;
  
  final List<String> _difficultyOptions = [];
  
  final List<String> _availableEquipment = [
    'Sem equipamento',
    'Halteres',
    'Barra',
    'Kettlebell',
    'Corda',
    'Elástico',
    'Step',
    'Bola',
    'TRX',
    'Banco',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _typeController = TextEditingController();
    _durationController = TextEditingController(text: '30');
    
    if (widget.workoutId != null) {
      _loadWorkout();
    }
  }
  
  Future<void> _loadWorkout() async {
    if (widget.workoutId == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Carregar dados do treino existente
      final viewModel = ref.read(workoutViewModelProvider.notifier);
      await viewModel.selectWorkout(widget.workoutId!);
      
      final workout = ref.read(workoutViewModelProvider).selectedWorkout;
      
      if (workout != null) {
        _titleController.text = workout.title;
        _descriptionController.text = workout.description;
        _typeController.text = workout.type;
        _durationController.text = workout.durationMinutes.toString();
        _difficulty = workout.difficulty;
        
        setState(() {
          _equipment.clear();
          _equipment.addAll(workout.equipment);
          
          _sections.clear();
          _sections.addAll(workout.sections);
          
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar treino: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final viewModel = ref.read(workoutViewModelProvider.notifier);
      
      final workout = Workout(
        id: widget.workoutId ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        type: _typeController.text,
        durationMinutes: int.tryParse(_durationController.text) ?? 30,
        difficulty: _difficulty,
        equipment: _equipment,
        sections: _sections,
        creatorId: '', // Será preenchido pelo repository
        createdAt: DateTime.now(),
      );
      
      if (widget.workoutId == null) {
        await viewModel.createWorkout(workout);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treino criado com sucesso!')),
        );
      } else {
        await viewModel.updateWorkout(workout);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treino atualizado com sucesso!')),
        );
      }
      
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar treino: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          widget.workoutId == null ? 'Novo Treino' : 'Editar Treino',
          style: AppTypography.headingMedium,
        ),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
      ),
      body: _isLoading ? const AppLoading() : _buildForm(),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _saveWorkout,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Título
          _buildTextField(
            controller: _titleController,
            label: 'Título',
            hint: 'Ex: Treino HIIT Full Body',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira um título';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Tipo
          _buildTextField(
            controller: _typeController,
            label: 'Categoria',
            hint: 'Ex: HIIT, Yoga, Musculação',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira uma categoria';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Descrição
          _buildTextField(
            controller: _descriptionController,
            label: 'Descrição',
            hint: 'Descreva o treino brevemente',
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira uma descrição';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Duração
          _buildTextField(
            controller: _durationController,
            label: 'Duração (minutos)',
            hint: 'Ex: 30',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira a duração';
              }
              final duration = int.tryParse(value);
              if (duration == null || duration <= 0) {
                return 'A duração deve ser um número positivo';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Equipamentos
          _buildEquipmentSelector(),
          const SizedBox(height: 16),
          
          // Seções de exercícios
          _buildSectionsHeader(),
          
          // Lista de seções
          _sections.isEmpty
              ? _buildEmptySections()
              : _buildSectionsList(),
          
          const SizedBox(height: 100), // Espaço para o FAB
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            fillColor: AppColors.backgroundLight,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              dropdownColor: AppColors.backgroundLight,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Equipamentos Necessários',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableEquipment.map((equipment) {
            final isSelected = _equipment.contains(equipment);
            
            return FilterChip(
              label: Text(equipment),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _equipment.add(equipment);
                  } else {
                    _equipment.remove(equipment);
                  }
                });
              },
              backgroundColor: AppColors.backgroundLight,
              selectedColor: AppColors.primary,
              checkmarkColor: AppColors.white,
              labelStyle: AppTypography.bodySmall.copyWith(
                color: isSelected ? AppColors.white : AppColors.textLight,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Seções do Treino',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          icon: const Icon(Icons.add, color: AppColors.primary),
          label: Text(
            'Adicionar Seção',
            style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
          ),
          onPressed: () {
            // Implementar adição de seção (em um app real isso abriria um modal)
            setState(() {
              _sections.add(
                const WorkoutSection(
                  name: 'Nova Seção',
                  exercises: [],
                ),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildEmptySections() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.backgroundMedium),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.playlist_add,
              color: AppColors.textLight,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione seções ao seu treino',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _sections.length,
      itemBuilder: (context, index) {
        final section = _sections[index];
        
        return Card(
          color: AppColors.backgroundLight,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      section.name,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.primary),
                          onPressed: () {
                            // Implementar edição de seção
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _sections.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (section.exercises.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Sem exercícios. Toque em editar para adicionar.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: section.exercises.length,
                    itemBuilder: (context, exerciseIndex) {
                      final exercise = section.exercises[exerciseIndex];
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text('${exerciseIndex + 1}'),
                        ),
                        title: Text(
                          exercise.name,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                        ),
                        subtitle: Text(
                          exercise.sets > 0
                              ? '${exercise.sets} séries x ${exercise.repetitions} repetições'
                              : '${exercise.duration} segundos',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
} 
