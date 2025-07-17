// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/goals/models/workout_category_goal.dart';
import 'package:ray_club_app/features/goals/repositories/workout_category_goals_repository.dart';

/// Modal para definir meta de minutos por categoria de treino
class SetCategoryGoalModal extends ConsumerStatefulWidget {
  /// Categoria para a qual definir a meta
  final String? initialCategory;
  
  /// Meta inicial (para edição)
  final WorkoutCategoryGoal? existingGoal;

  const SetCategoryGoalModal({
    super.key,
    this.initialCategory,
    this.existingGoal,
  });

  /// Mostra o modal
  static Future<bool?> show(
    BuildContext context, {
    String? category,
    WorkoutCategoryGoal? existingGoal,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SetCategoryGoalModal(
        initialCategory: category,
        existingGoal: existingGoal,
      ),
    );
  }

  @override
  ConsumerState<SetCategoryGoalModal> createState() => _SetCategoryGoalModalState();
}

class _SetCategoryGoalModalState extends ConsumerState<SetCategoryGoalModal> {
  final _minutesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedCategory;
  bool _isLoading = false;
  
  final List<String> _popularCategories = [
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
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.existingGoal != null) {
      _selectedCategory = widget.existingGoal!.category;
      _minutesController.text = widget.existingGoal!.goalMinutes.toString();
    } else if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
      _minutesController.text = _getDefaultGoalForCategory(widget.initialCategory!).toString();
    }
  }

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildCategorySelection(),
                const SizedBox(height: 24),
                _buildGoalInput(),
                const SizedBox(height: 24),
                _buildPresetButtons(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              Icons.flag,
              color: const Color(0xFF4D4D4D),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.existingGoal != null ? 'Editar Meta' : 'Definir Meta Semanal',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4D4D4D),
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Defina quantos minutos quer treinar por semana em uma categoria específica 💪',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Escolha a categoria',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4D4D4D),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularCategories.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                  if (_minutesController.text.isEmpty) {
                    _minutesController.text = _getDefaultGoalForCategory(category).toString();
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getCategoryEmoji(category),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getCategoryDisplayName(category),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF4D4D4D),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGoalInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meta em minutos por semana',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4D4D4D),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE9ECEF)),
          ),
          child: TextFormField(
            controller: _minutesController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4D4D4D),
            ),
            decoration: const InputDecoration(
              hintText: '90',
              hintStyle: TextStyle(
                color: Color(0xFFADB5BD),
                fontWeight: FontWeight.normal,
              ),
              suffixText: 'min',
              suffixStyle: TextStyle(
                fontSize: 16,
                color: Color(0xFF6C757D),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Digite a meta em minutos';
              }
              
              final minutes = int.tryParse(value);
              if (minutes == null || minutes < 15) {
                return 'Mínimo de 15 minutos';
              }
              
              if (minutes > 1440) {
                return 'Máximo de 1440 minutos (24h)';
              }
              
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 8),
        if (_minutesController.text.isNotEmpty)
          Text(
            _formatMinutesToReadable(_minutesController.text),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Widget _buildPresetButtons() {
    final presets = [30, 60, 90, 120, 180, 300]; // minutos
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metas populares',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6C757D),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((minutes) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _minutesController.text = minutes.toString();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _minutesController.text == minutes.toString() 
                      ? const Color(0xFF2196F3).withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _minutesController.text == minutes.toString()
                        ? const Color(0xFF2196F3)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  _formatMinutes(minutes),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _minutesController.text == minutes.toString()
                        ? const Color(0xFF2196F3)
                        : const Color(0xFF6C757D),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6C757D),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _canSaveGoal() ? _saveGoal : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.existingGoal != null ? 'Atualizar Meta' : 'Definir Meta',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  bool _canSaveGoal() {
    return _selectedCategory != null && 
           _minutesController.text.isNotEmpty && 
           !_isLoading &&
           _formKey.currentState?.validate() == true;
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(workoutCategoryGoalsRepositoryProvider);
      final minutes = int.parse(_minutesController.text);
      
      await repository.setCategoryGoal(_selectedCategory!, minutes);
      
      if (mounted) {
        Navigator.of(context).pop(true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingGoal != null 
                  ? 'Meta atualizada com sucesso! 🎯'
                  : 'Meta definida com sucesso! 🎯',
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao definir meta: ${e.toString()}'),
            backgroundColor: const Color(0xFFE53E3E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int _getDefaultGoalForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'corrida':
      case 'caminhada':
        return 120; // 2 horas
      case 'yoga':
      case 'alongamento':
        return 90; // 1.5 horas
      case 'funcional':
      case 'crossfit':
        return 60; // 1 hora
      case 'natacao':
      case 'ciclismo':
        return 100; // 1h40
      default:
        return 90; // Padrão: 1.5 horas
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'corrida': return '🏃‍♀️';
      case 'caminhada': return '🚶‍♀️';
      case 'yoga': return '🧘‍♀️';
      case 'alongamento': return '🤸‍♀️';
      case 'funcional': return '💪';
      case 'crossfit': return '🏋️‍♀️';
      case 'natacao': return '🏊‍♀️';
      case 'ciclismo': return '🚴‍♀️';
      case 'musculacao': return '🏋️‍♂️';
      case 'pilates': return '🤸‍♀️';
      default: return '🏃‍♀️';
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'corrida': return 'Corrida';
      case 'caminhada': return 'Caminhada';
      case 'yoga': return 'Yoga';
      case 'alongamento': return 'Alongamento';
      case 'funcional': return 'Funcional';
      case 'crossfit': return 'CrossFit';
      case 'natacao': return 'Natação';
      case 'ciclismo': return 'Ciclismo';
      case 'musculacao': return 'Musculação';
      case 'pilates': return 'Pilates';
      default: return category.substring(0, 1).toUpperCase() + 
                    category.substring(1).toLowerCase();
    }
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${mins}min';
      }
    }
  }

  String _formatMinutesToReadable(String minutesText) {
    final minutes = int.tryParse(minutesText);
    if (minutes == null) return '';
    
    final formatted = _formatMinutes(minutes);
    final daysPerWeek = (minutes / 30).round(); // ~30min por sessão
    
    return '$formatted • ~$daysPerWeek treinos de 30min por semana';
  }
} 